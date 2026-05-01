import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// REST client for the Griva Node.js backend (port 5000).
/// Authenticates every request with the Firebase ID token of the
/// currently signed-in user.
class GrivaApiService {
  GrivaApiService._();
  static final GrivaApiService instance = GrivaApiService._();

  static String get _base {
    const env = String.fromEnvironment('GRIVA_NODE_HOST');
    if (env.isNotEmpty) return env; // caller passes full URL incl. scheme
    return 'https://griva-backend.onrender.com';
  }

  // ── Auth helpers ──────────────────────────────────────────────────────────

  Future<String> _token() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not signed in');
    final token = await user.getIdToken(true);
    if (token == null) throw Exception('Failed to get auth token');
    return token;
  }

  Future<Map<String, String>> _headers() async => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _token()}',
      };

  // ── Generic request helpers ───────────────────────────────────────────────

  static const _timeout = Duration(seconds: 65); // covers Render free-tier cold start (~50s)
  static const _retryDelay = Duration(seconds: 4);

  Future<dynamic> _get(String path) => _withRetry(() async {
    final res = await http
        .get(Uri.parse('$_base$path'), headers: await _headers())
        .timeout(_timeout);
    return _parse(res);
  });

  Future<dynamic> _post(String path, Map<String, dynamic> body) => _withRetry(() async {
    final res = await http
        .post(Uri.parse('$_base$path'), headers: await _headers(), body: jsonEncode(body))
        .timeout(_timeout);
    return _parse(res);
  });

  Future<dynamic> _put(String path, Map<String, dynamic> body) => _withRetry(() async {
    final res = await http
        .put(Uri.parse('$_base$path'), headers: await _headers(), body: jsonEncode(body))
        .timeout(_timeout);
    return _parse(res);
  });

  /// Retries once on network/timeout errors. Never retries on 4xx/5xx (those are real errors).
  Future<T> _withRetry<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on GrivaApiException {
      rethrow; // server returned a real error — don't retry
    } catch (_) {
      // Network error or timeout — server may be cold-starting, wait then retry once
      await Future.delayed(_retryDelay);
      return await fn();
    }
  }

  dynamic _parse(http.Response res) {
    dynamic body;
    try {
      body = jsonDecode(res.body);
    } catch (_) {
      // Non-JSON response (e.g. Render gateway page during cold start)
      throw GrivaApiException(res.statusCode, 'Server is starting up, please try again.');
    }
    if (res.statusCode >= 400) {
      final msg = (body is Map ? body['message'] : null) ?? res.reasonPhrase;
      throw GrivaApiException(res.statusCode, msg?.toString() ?? 'Error');
    }
    return body;
  }

  // ── Warm-up (call once at app start to wake Render free-tier server) ────────

  /// Pings /health silently. Never throws — failures are ignored.
  Future<void> warmUp() async {
    try {
      await http
          .get(Uri.parse('$_base/health'))
          .timeout(const Duration(seconds: 70));
    } catch (_) {
      // Intentionally silent — this is a best-effort wake-up call
    }
  }

  // ── User ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMe() async {
    final data = await _get('/users/me');
    return data['user'] as Map<String, dynamic>;
  }

  // ── File upload (replaces Firebase Storage) ──────────────────────────────

  Future<GrivaFile> uploadFile(Uint8List bytes, String filename, String mimeType) async {
    final token = await _token();
    final request = http.MultipartRequest('POST', Uri.parse('$_base/cases/upload'))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(http.MultipartFile.fromBytes('file', bytes,
          filename: filename,
          contentType: MediaType.parse(mimeType)));
    final streamed = await request.send();
    final body = jsonDecode(await streamed.stream.bytesToString());
    if (streamed.statusCode >= 400) {
      throw GrivaApiException(streamed.statusCode,
          (body is Map ? body['message'] : null)?.toString() ?? 'Upload failed');
    }
    return GrivaFile(
      url : body['url']  as String,
      name: body['name'] as String,
      type: body['type'] as String,
      size: body['size'] as int,
    );
  }

  // ── Cases — reporter list ─────────────────────────────────────────────────

  Future<List<GrivaReporter>> listReporters() async {
    final data = await _get('/cases/reporters');
    return (data['reporters'] as List)
        .map((e) => GrivaReporter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Cases — availability ──────────────────────────────────────────────────

  Future<void> setAvailability(bool isAvailable) async {
    await _put('/cases/availability', {'isAvailable': isAvailable});
  }

  // ── Cases — submit ────────────────────────────────────────────────────────

  /// Submit a case with pre-uploaded file metadata.
  /// Pass [assignedUid] to manually pick a reporter, or omit for auto-assign.
  Future<GrivaCaseResult> submitCase({
    String? assignedUid,
    String? notes,
    required List<GrivaFile> files,
  }) async {
    final data = await _post('/cases', {
      if (assignedUid != null) 'assignedUid': assignedUid,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'files': files.map((f) => f.toJson()).toList(),
    });
    return GrivaCaseResult.fromJson(data as Map<String, dynamic>);
  }

  // ── Cases — list ─────────────────────────────────────────────────────────

  Future<List<GrivaCase>> listCases({String? status}) async {
    final qs = status != null ? '?status=$status' : '';
    final data = await _get('/cases$qs');
    return (data['cases'] as List)
        .map((e) => GrivaCase.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<GrivaCase>> listPendingCases() async {
    final data = await _get('/cases/pending');
    return (data['cases'] as List)
        .map((e) => GrivaCase.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Cases — detail ────────────────────────────────────────────────────────

  Future<GrivaCase> getCase(String id) async {
    final data = await _get('/cases/$id');
    return GrivaCase.fromJson(data['teleCase'] as Map<String, dynamic>);
  }

  // ── Cases — assign ────────────────────────────────────────────────────────

  Future<GrivaCase> assignCase(String caseId, String assignedUid) async {
    final data = await _put('/cases/$caseId/assign', {'assignedUid': assignedUid});
    return GrivaCase.fromJson(data['teleCase'] as Map<String, dynamic>);
  }

  // ── Cases — status ────────────────────────────────────────────────────────

  Future<GrivaCase> updateStatus(String caseId, String status) async {
    final data = await _put('/cases/$caseId/status', {'status': status});
    return GrivaCase.fromJson(data['teleCase'] as Map<String, dynamic>);
  }

  // ── Cases — report ────────────────────────────────────────────────────────

  Future<GrivaCase> submitReport(String caseId, String reporterNote) async {
    final data = await _post('/cases/$caseId/report', {'reporterNote': reporterNote});
    return GrivaCase.fromJson(data['teleCase'] as Map<String, dynamic>);
  }

  // ── Cases — PDF URL ───────────────────────────────────────────────────────

  String reportPdfUrl(String caseId) => '$_base/cases/$caseId/report/pdf';

  // ── Patient sync ──────────────────────────────────────────────────────────

  /// Bulk-upsert patients to the backend for admin reporting.
  /// Only sends uuid, name, and hasReport flag — no clinical data.
  Future<void> syncPatientsToBackend(List<Map<String, dynamic>> patients) async {
    await _post('/patients/sync', {'patients': patients});
  }

  // ── FCM token ─────────────────────────────────────────────────────────────

  Future<void> updateFcmToken(String token) async {
    await _put('/users/fcm-token', {'fcmToken': token});
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  Future<List<GrivaNotification>> listNotifications() async {
    final data = await _get('/cases/notifications');
    return (data['notifications'] as List)
        .map((e) => GrivaNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationRead(String id) async {
    await _put('/cases/notifications/$id/read', {});
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

class GrivaApiException implements Exception {
  final int statusCode;
  final String message;
  GrivaApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

class GrivaReporter {
  final String id;
  final String firebaseUid;
  final String? fullName;
  final String email;
  final String? hospital;
  final bool isAvailable;

  GrivaReporter.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        firebaseUid = j['firebaseUid'] as String,
        fullName = j['fullName'] as String?,
        email = j['email'] as String,
        hospital = j['hospital'] as String?,
        isAvailable = j['isAvailable'] as bool;

  String get displayName => fullName ?? email;
}

class GrivaFile {
  final String url;
  final String name;
  final String type;
  final int size;

  const GrivaFile({
    required this.url,
    required this.name,
    required this.type,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'name': name,
        'type': type,
        'size': size,
      };
}

class GrivaCase {
  final String id;
  final String submittedBy;
  final String? assignedUid;
  final String? assignedBy;
  final String? notes;
  final List<GrivaFile> files;
  final String status;
  final String? reporterNote;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  GrivaCase.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        submittedBy = j['submittedBy'] as String,
        assignedUid = j['assignedUid'] as String?,
        assignedBy = j['assignedBy'] as String?,
        notes = j['notes'] as String?,
        files = ((j['files'] as List?) ?? [])
            .map((f) => GrivaFile(
                  url: f['url'] as String,
                  name: f['name'] as String,
                  type: f['type'] as String,
                  size: f['size'] as int,
                ))
            .toList(),
        status = j['status'] as String,
        reporterNote = j['reporterNote'] as String?,
        completedAt = j['completedAt'] != null
            ? DateTime.parse(j['completedAt'] as String)
            : null,
        createdAt = DateTime.parse(j['createdAt'] as String),
        updatedAt = DateTime.parse(j['updatedAt'] as String);

  bool get isImage =>
      files.isNotEmpty && (files.first.type.startsWith('image/'));

  Color get statusColor {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'assigned':
        return const Color(0xFF3B82F6);
      case 'in_review':
        return const Color(0xFF8B5CF6);
      case 'completed':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':   return 'Pending';
      case 'assigned':  return 'Assigned';
      case 'in_review': return 'In Review';
      case 'completed': return 'Completed';
      default:          return status;
    }
  }
}

class GrivaCaseResult {
  final GrivaCase teleCase;
  final bool autoAssigned;
  final bool unassigned;

  GrivaCaseResult.fromJson(Map<String, dynamic> j)
      : teleCase = GrivaCase.fromJson(j['teleCase'] as Map<String, dynamic>),
        autoAssigned = j['autoAssigned'] as bool? ?? false,
        unassigned = j['unassigned'] as bool? ?? false;
}

class GrivaNotification {
  final String id;
  final String title;
  final String body;
  final String? caseId;
  final bool isRead;
  final DateTime createdAt;

  GrivaNotification.fromJson(Map<String, dynamic> j)
      : id        = j['id'] as String,
        title     = j['title'] as String,
        body      = j['body'] as String,
        caseId    = j['caseId'] as String?,
        isRead    = j['isRead'] as bool? ?? false,
        createdAt = DateTime.parse(j['createdAt'] as String);
}
