import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../cloud_registry.dart';
import '../i_database_provider.dart';

/// Backend REST implementation of [IDatabaseProvider].
///
/// Routes table-level operations to the self-hosted backend:
///   doctor_profiles  → GET/PUT /profile
///   doctor_config    → GET     /profile/config
///
/// All other tables are not supported by this provider — they are accessed
/// via the local Drift database (offline-first) and synced separately.
class BackendDatabaseProvider implements IDatabaseProvider {
  BackendDatabaseProvider({required String baseUrl}) : _base = baseUrl;

  final String _base;

  String? get _token => CloudRegistry.instance.auth.accessToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Routing ───────────────────────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> select(
    String table, {
    Map<String, dynamic>? eq,
    List<String>? isNull,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    switch (table) {
      case 'doctor_profiles':
        final row = await _getProfile();
        return row != null ? [row] : [];
      case 'doctor_config':
        final row = await _getConfig();
        return row != null ? [row] : [];
      default:
        debugPrint('[BACKEND_DB] select() unsupported table: $table');
        return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> selectSingle(
    String table, {
    required Map<String, dynamic> eq,
  }) async {
    switch (table) {
      case 'doctor_profiles':
        return _getProfile();
      case 'doctor_config':
        return _getConfig();
      default:
        debugPrint('[BACKEND_DB] selectSingle() unsupported table: $table');
        return null;
    }
  }

  @override
  Future<void> upsert(
    String table,
    Map<String, dynamic> data, {
    String? onConflict,
  }) async {
    if (table == 'doctor_profiles') {
      await _putProfile(data);
    } else {
      debugPrint('[BACKEND_DB] upsert() unsupported table: $table');
    }
  }

  @override
  Future<void> update(
    String table,
    Map<String, dynamic> data, {
    required Map<String, dynamic> eq,
  }) async {
    if (table == 'doctor_profiles') {
      await _putProfile(data);
    } else {
      debugPrint('[BACKEND_DB] update() unsupported table: $table');
    }
  }

  @override
  Stream<Map<String, dynamic>> watchRow(
    String table,
    String idColumn,
    String idValue,
  ) {
    // No real-time subscriptions — poll on demand or re-fetch after mutations.
    debugPrint('[BACKEND_DB] watchRow() not supported — returning empty stream');
    return const Stream.empty();
  }

  @override
  Future<void> dispose() async {
    // Nothing to dispose — all requests are stateless HTTP.
  }

  // ── REST helpers ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _getProfile() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/profile'), headers: _headers)
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200) return null;
      return body['profile'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('[BACKEND_DB] _getProfile error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getConfig() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/profile/config'), headers: _headers)
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200) return null;
      return body['config'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('[BACKEND_DB] _getConfig error: $e');
      return null;
    }
  }

  Future<void> _putProfile(Map<String, dynamic> data) async {
    try {
      final res = await http
          .put(
            Uri.parse('$_base/profile'),
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode >= 400) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        throw Exception(body['message'] ?? 'Failed to save profile');
      }
    } catch (e) {
      debugPrint('[BACKEND_DB] _putProfile error: $e');
      rethrow;
    }
  }
}
