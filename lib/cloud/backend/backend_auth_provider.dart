import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../i_auth_provider.dart';

/// Backend (EC2 / JWT) implementation of [IAuthProvider].
///
/// Authenticates against the self-hosted Node.js backend.
/// The JWT and user metadata are persisted in secure storage so they
/// survive app restarts without a new network request.
class BackendAuthProvider implements IAuthProvider {
  BackendAuthProvider({required String baseUrl}) : _base = baseUrl;

  final String _base;
  final _storage = const FlutterSecureStorage();

  static const _keyToken    = 'griva_jwt';
  static const _keyId       = 'griva_uid';
  static const _keyEmail    = 'griva_email';
  static const _keyFullName = 'griva_full_name';
  static const _keyRole     = 'griva_role';

  String? _token;
  String? _userId;
  String? _email;
  String? _fullName;
  String? _role;

  /// Must be called once at app start to restore a persisted session.
  Future<void> restoreSession() async {
    _token    = await _storage.read(key: _keyToken);
    _userId   = await _storage.read(key: _keyId);
    _email    = await _storage.read(key: _keyEmail);
    _fullName = await _storage.read(key: _keyFullName);
    _role     = await _storage.read(key: _keyRole);
  }

  Future<void> _persistSession(Map<String, dynamic> user, String token) async {
    _token    = token;
    _userId   = user['id']       as String?;
    _email    = user['email']    as String?;
    _fullName = user['fullName'] as String?;
    _role     = user['role']     as String?;

    await Future.wait([
      _storage.write(key: _keyToken,    value: _token),
      _storage.write(key: _keyId,       value: _userId),
      _storage.write(key: _keyEmail,    value: _email),
      _storage.write(key: _keyFullName, value: _fullName),
      _storage.write(key: _keyRole,     value: _role),
    ]);
  }

  Future<void> _clearSession() async {
    _token = _userId = _email = _fullName = _role = null;
    await _storage.deleteAll();
  }

  @override
  Future<void> signInWithPassword(String email, String password) async {
    final res = await http
        .post(
          Uri.parse('$_base/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email.trim(), 'password': password}),
        )
        .timeout(const Duration(seconds: 30));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['message'] ?? 'Login failed');
    }
    await _persistSession(
      body['user'] as Map<String, dynamic>,
      body['token'] as String,
    );
  }

  @override
  Future<void> signUp(
    String email,
    String password, {
    Map<String, dynamic> metadata = const {},
  }) async {
    final res = await http
        .post(
          Uri.parse('$_base/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email':    email.trim(),
            'password': password,
            if (metadata['full_name'] != null) 'fullName': metadata['full_name'],
            if (metadata['hospital']  != null) 'hospital': metadata['hospital'],
            if (metadata['role']      != null) 'role':     metadata['role'],
          }),
        )
        .timeout(const Duration(seconds: 30));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201) {
      throw Exception(body['message'] ?? 'Registration failed');
    }
    await _persistSession(
      body['user'] as Map<String, dynamic>,
      body['token'] as String,
    );
  }

  @override
  Future<void> signOut() => _clearSession();

  @override
  Future<void> resetPassword(String email) {
    throw UnimplementedError('Password reset via email is not yet supported');
  }

  @override
  String? get currentUserId => _userId;

  @override
  String? get currentUserEmail => _email;

  @override
  Map<String, dynamic> get currentUserMetadata => {
        if (_fullName != null) 'full_name': _fullName,
        if (_role     != null) 'role':      _role,
      };

  @override
  String? get accessToken => _token;

  @override
  bool get isSignedIn => _token != null && _token!.isNotEmpty;
}
