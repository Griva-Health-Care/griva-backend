import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../cloud/cloud_registry.dart';
import '../cloud/firebase/firebase_auth_provider.dart';

/// REST client for the Griva Node.js backend (port 5000).
/// Authenticates every request with the Firebase ID token of the
/// currently signed-in user.
class GrivaApiService {
  GrivaApiService._();
  static final GrivaApiService instance = GrivaApiService._();

  static String get _base {
    const env = String.fromEnvironment('BACKEND_URL');
    if (env.isNotEmpty) return env;
    return 'http://3.6.1.238:5000';
  }

  // ── Auth helpers ──────────────────────────────────────────────────────────

  Future<String> _token() async {
    final auth = CloudRegistry.instance.auth;
    // Refresh Firebase ID token before each call to avoid 1-hour expiry
    if (auth is FirebaseAuthProvider) {
      final fresh = await auth.refreshToken();
      if (fresh != null) return fresh;
    }
    final token = auth.accessToken;
    if (token == null) throw Exception('Not signed in');
    return token;
  }

  Future<Map<String, String>> _headers() async => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _token()}',
      };

  // ── Generic request helpers ───────────────────────────────────────────────

  static const _timeout    = Duration(seconds: 30);
  static const _retryDelay = Duration(seconds: 3);

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

  Future<T> _withRetry<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on GrivaApiException {
      rethrow;
    } catch (_) {
      await Future.delayed(_retryDelay);
      return await fn();
    }
  }

  dynamic _parse(http.Response res) {
    dynamic body;
    try {
      body = jsonDecode(res.body);
    } catch (_) {
      throw GrivaApiException(res.statusCode, 'Unexpected server response');
    }
    if (res.statusCode >= 400) {
      final msg = (body is Map ? body['message'] : null) ?? res.reasonPhrase;
      throw GrivaApiException(res.statusCode, msg?.toString() ?? 'Error');
    }
    return body;
  }

  /// Pings /health silently. Never throws.
  Future<void> warmUp() async {
    try {
      await http
          .get(Uri.parse('$_base/health'))
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> authMe() async {
    final data = await _get('/auth/me');
    return data['user'] as Map<String, dynamic>;
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getProfile() async {
    final data = await _get('/profile');
    return data['profile'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> profile) async {
    final data = await _put('/profile', profile);
    return data['profile'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getConfig() async {
    final data = await _get('/profile/config');
    return data['config'] as Map<String, dynamic>;
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
    return GrivaFile.fromJson(body as Map<String, dynamic>);
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
  /// Pass [assignedFirebaseUid] to manually pick a reporter, or omit for auto-assign.
  Future<GrivaCaseResult> submitCase({
    String? assignedFirebaseUid,
    String? notes,
    required List<GrivaFile> files,
  }) async {
    final data = await _post('/cases', {
      if (assignedFirebaseUid != null) 'assignedFirebaseUid': assignedFirebaseUid,
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

  Future<GrivaCase> assignCase(String caseId, String assignedFirebaseUid) async {
    final data = await _put('/cases/$caseId/assign', {'assignedFirebaseUid': assignedFirebaseUid});
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
      : id          = j['id'] as String,
        firebaseUid = j['firebaseUid'] as String,
        fullName    = j['fullName'] as String?,
        email       = j['email'] as String,
        hospital    = j['hospital'] as String?,
        isAvailable = j['isAvailable'] as bool;

  String get displayName => fullName ?? email;
}

class GrivaFile {
  final String  url;   // presigned GET URL (24-hour expiry) — for display only
  final String? key;   // permanent S3 key (e.g. "cases/uuid.jpg") — send back when submitting cases
  final String  name;
  final String  type;
  final int     size;

  const GrivaFile({
    required this.url,
    this.key,
    required this.name,
    required this.type,
    required this.size,
  });

  factory GrivaFile.fromJson(Map<String, dynamic> j) => GrivaFile(
    url:  j['url']  as String,
    key:  j['key']  as String?,
    name: j['name'] as String,
    type: j['type'] as String,
    size: j['size'] as int,
  );

  Map<String, dynamic> toJson() => {
    'url':  url,
    if (key != null) 'key': key,
    'name': name,
    'type': type,
    'size': size,
  };
}

class GrivaCase {
  final String id;
  final String submittedBy;
  final String? assignedFirebaseUid;
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
        assignedFirebaseUid = j['assignedFirebaseUid'] as String?,
        assignedBy = j['assignedBy'] as String?,
        notes = j['notes'] as String?,
        files = ((j['files'] as List?) ?? [])
            .map((f) => GrivaFile.fromJson(f as Map<String, dynamic>))
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
