import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/config.dart';
import 'abdm_auth_service.dart';

/// Authenticated HTTP client for the ABDM backend.
///
/// - Attaches `Authorization: Bearer <ABDM JWT>` on every request
/// - Attaches `X-Tenant-ID` header automatically from stored tenant
/// - Refreshes the token transparently on 401
///
/// Requires the doctor to be connected via [AbdmAuthService] first.
/// Check [AbdmAuthService.isConnected] before calling any method.
class AbdmService {
  static const _accessKey = 'abdm_access_token';
  static const _tenantKey = 'abdm_tenant_id';

  final Dio _dio;
  final FlutterSecureStorage _storage;
  final AbdmAuthService _auth;

  AbdmService({AbdmAuthService? auth})
      : _storage = const FlutterSecureStorage(),
        _auth = auth ?? AbdmAuthService(),
        _dio = Dio(BaseOptions(
          baseUrl: Config.abdmBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _accessKey);
        final tenant = await _storage.read(key: _tenantKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (tenant != null) {
          options.headers['X-Tenant-ID'] = tenant;
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _auth.refreshAccessToken();
          if (refreshed) {
            final token = await _storage.read(key: _accessKey);
            final tenant = await _storage.read(key: _tenantKey);
            final req = error.requestOptions;
            try {
              final retried = await _dio.request(
                req.path,
                data: req.data,
                queryParameters: req.queryParameters,
                options: Options(
                  method: req.method,
                  headers: {
                    ...req.headers,
                    if (token != null) 'Authorization': 'Bearer $token',
                    if (tenant != null) 'X-Tenant-ID': tenant,
                  },
                ),
              );
              return handler.resolve(retried);
            } catch (_) {}
          }
        }
        handler.next(error);
      },
    ));
  }

  // ── Core HTTP ─────────────────────────────────────────────────────────────

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await _dio.get(path, queryParameters: query);
    return res.data;
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    final res = await _dio.post(path, data: data);
    return res.data;
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    final res = await _dio.put(path, data: data);
    return res.data;
  }

  Future<dynamic> delete(String path) async {
    final res = await _dio.delete(path);
    return res.data;
  }

  // ── ABDM API methods — add your endpoints below ───────────────────────────

  /// Fetch the current doctor's ABDM profile.
  Future<Map<String, dynamic>> getProfile() async =>
      Map<String, dynamic>.from(await get('/users/me'));

  /// List all ABDM consents for this tenant.
  Future<List<dynamic>> getConsents() async {
    final res = await get('/api/consents');
    return res as List<dynamic>;
  }

  /// List medical records for a patient.
  Future<List<dynamic>> getPatientRecords(String patientId) async {
    final res = await get('/api/patients/$patientId/records');
    return res as List<dynamic>;
  }

  /// Upload a medical record (colposcopy image/video).
  /// [patientId] — internal patient identifier
  /// [recordType] — e.g. "colposcopy", "imaging"
  /// [uri] — storage URI / file path reference
  Future<Map<String, dynamic>> uploadRecord({
    required String patientId,
    required String recordType,
    required String uri,
  }) async {
    final res = await post('/api/records/upload', data: {
      'patient_id': patientId,
      'record_type': recordType,
      'uri': uri,
    });
    return Map<String, dynamic>.from(res);
  }

  /// Grant internal consent for a patient before accessing records.
  /// [purpose] — e.g. "CARE"
  Future<Map<String, dynamic>> grantConsent({
    required String patientId,
    required String purpose,
  }) async {
    final res = await post('/api/internal-consents/grant', data: {
      'patient_id': patientId,
      'purpose': purpose,
      'scope': {},
      'metadata': {},
    });
    return Map<String, dynamic>.from(res);
  }
}
