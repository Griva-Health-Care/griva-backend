import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/config.dart';

/// A single tenant membership returned by /api/auth/hpr/memberships
class AbdmMembership {
  final String membershipId;
  final String tenantId;
  final String tenantName;
  final String role;
  final String status;

  const AbdmMembership({
    required this.membershipId,
    required this.tenantId,
    required this.tenantName,
    required this.role,
    required this.status,
  });

  factory AbdmMembership.fromJson(Map<String, dynamic> j) => AbdmMembership(
        membershipId: j['membership_id'] as String,
        tenantId: j['tenant_id'] as String,
        tenantName: j['tenant_name'] as String,
        role: j['role'] as String,
        status: j['status'] as String,
      );
}

/// Manages the ABDM backend session independently of Firebase.
///
/// Token storage keys (flutter_secure_storage):
///   abdm_access_token   — short-lived JWT (30 min)
///   abdm_refresh_token  — long-lived JWT (7 days)
///   abdm_tenant_id      — selected tenant UUID
class AbdmAuthService {
  static const _accessKey = 'abdm_access_token';
  static const _refreshKey = 'abdm_refresh_token';
  static const _tenantKey = 'abdm_tenant_id';

  final FlutterSecureStorage _storage;
  final Dio _dio;

  AbdmAuthService()
      : _storage = const FlutterSecureStorage(),
        _dio = Dio(BaseOptions(
          baseUrl: Config.abdmBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ));

  // ── Connection state ──────────────────────────────────────────────────────

  Future<bool> get isConnected async {
    final token = await _storage.read(key: _accessKey);
    return token != null;
  }

  Future<String?> get tenantId => _storage.read(key: _tenantKey);
  Future<String?> get accessToken => _storage.read(key: _accessKey);

  // ── HPR OAuth flow ────────────────────────────────────────────────────────

  /// Step 1: Get the HPR authorization URL to open in WebView.
  Future<String> getHprAuthUrl() async {
    try {
      final res = await _dio.get('/api/auth/hpr/start');
      return res.data['redirect_url'] as String;
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  /// Step 2: After WebView lands on the backend callback, pass the raw JSON
  /// body here. Returns the pre-tenant token (valid 5 min).
  String extractPreTenantToken(Map<String, dynamic> callbackJson) {
    final token = callbackJson['pre_tenant_token'] as String?;
    if (token == null) throw Exception('No pre_tenant_token in callback response');
    return token;
  }

  /// Step 3: Fetch the list of tenants the HPR user belongs to.
  Future<List<AbdmMembership>> getMemberships(String preTenantToken) async {
    try {
      final res = await _dio.get(
        '/api/auth/hpr/memberships',
        options: Options(headers: {'Authorization': 'Bearer $preTenantToken'}),
      );
      final list = res.data['memberships'] as List<dynamic>;
      return list
          .map((m) => AbdmMembership.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  /// Step 4: Select a tenant and persist the session tokens.
  Future<void> selectTenant(String tenantId, String preTenantToken) async {
    try {
      final res = await _dio.post(
        '/api/auth/hpr/select-tenant',
        data: {'tenant_id': tenantId},
        options: Options(headers: {'Authorization': 'Bearer $preTenantToken'}),
      );
      await _saveTokens(
        res.data['access_token'] as String,
        res.data['refresh_token'] as String,
        tenantId,
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  // ── Email / password login (direct ABDM login) ────────────────────────────

  /// Login with ABDM email + password. Requires the tenant ID to be known
  /// (pass via the X-Tenant-ID header per the ABDM backend spec).
  Future<void> loginWithEmail(
    String email,
    String password,
    String tenantId,
  ) async {
    try {
      final res = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
        options: Options(headers: {'X-Tenant-ID': tenantId}),
      );
      await _saveTokens(
        res.data['access_token'] as String,
        res.data['refresh_token'] as String,
        tenantId,
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  // ── Token refresh ─────────────────────────────────────────────────────────

  /// Refresh the access token. Returns true if successful.
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshKey);
      if (refreshToken == null) return false;

      final res = await _dio.post(
        '/api/auth/hpr/refresh',
        data: {'refresh_token': refreshToken},
      );
      final tid = await tenantId;
      await _saveTokens(
        res.data['access_token'] as String,
        res.data['refresh_token'] as String,
        tid ?? '',
      );
      return true;
    } catch (e) {
      debugPrint('[ABDM AUTH] Refresh failed: $e');
      await disconnect();
      return false;
    }
  }

  // ── Disconnect ────────────────────────────────────────────────────────────

  Future<void> disconnect() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _tenantKey);
    debugPrint('[ABDM AUTH] Disconnected');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
    String tid,
  ) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
    await _storage.write(key: _tenantKey, value: tid);
    debugPrint('[ABDM AUTH] Tokens saved for tenant: $tid');
  }

  String _errorMessage(DioException e) {
    final detail = e.response?.data?['detail'] as String?;
    if (detail != null) return detail;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Cannot reach ABDM backend. Check your connection.';
    }
    if (e.response?.statusCode == 401) return 'Invalid ABDM credentials.';
    if (e.response?.statusCode == 403) return 'ABDM account is disabled.';
    return 'ABDM error: ${e.message}';
  }
}
