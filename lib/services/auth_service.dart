import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../cloud/cloud_registry.dart';
import '../core/config.dart';
import '../repositories/repository_factory.dart';
import 'cloud_config_service.dart';
import 'profile_service.dart';
import 'session_service.dart';
import 'sync_engine.dart';
import 'user_service.dart' as app_user;

class AuthService {
  final app_user.UserService _userService = app_user.UserService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _sessionEmailKey = 'local_session_email';

  // ================= LOGIN =================
  Future<bool> login(String email, String password) async {
    debugPrint('[AUTH] Login attempt: $email');
    try {
      await CloudRegistry.instance.auth.signInWithPassword(email, password);

      final meta = CloudRegistry.instance.auth.currentUserMetadata;
      await _upsertLocalUser(
        email:    email,
        password: password,
        fullName: meta['full_name'] as String? ?? email.split('@').first,
        role:     'doctor',
        isActive: true,
      );
      await _secureStorage.write(
          key: _sessionEmailKey, value: email.trim().toLowerCase());
      await _postLoginInit();
      debugPrint('[AUTH] Login successful');
      return true;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('connection') ||
          msg.contains('socket')) {
        return await _offlineLogin(email, password);
      }
      debugPrint('[AUTH] Login failed: $e');
      rethrow;
    }
  }

  // Validates credentials against the locally stored bcrypt hash.
  Future<bool> _offlineLogin(String email, String password) async {
    debugPrint('[AUTH] No internet — trying offline login for $email');
    final localUser =
        await _userService.authenticateUser(email.trim().toLowerCase(), password);
    if (localUser == null) {
      throw Exception(
        'No internet connection. Please connect to the internet at least once to activate offline login.',
      );
    }
    await _secureStorage.write(
        key: _sessionEmailKey, value: email.trim().toLowerCase());
    await SessionService.instance.initialize();
    debugPrint('[AUTH] Offline login successful for $email');
    return true;
  }

  // ================= REGISTER =================
  String? _pendingHospital;
  String? _pendingRole;

  Future<bool> register({
    required String email,
    required String name,
    required String password,
    String? hospital,
    String? role,
  }) async {
    try {
      debugPrint('[AUTH] Register: $email');
      _pendingHospital = hospital;
      _pendingRole     = role;

      await CloudRegistry.instance.auth.signUp(
        email,
        password,
        metadata: {'full_name': name},
      );

      await _upsertLocalUser(
        email:    email,
        password: password,
        fullName: name,
        role:     role ?? 'doctor',
        isActive: true,
      );
      debugPrint('[AUTH] Registration successful');
      return true;
    } catch (e) {
      debugPrint('[AUTH] Registration failed: $e');
      _pendingHospital = null;
      _pendingRole     = null;
      rethrow;
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<void> sendPasswordResetEmail(String email) async {
    await CloudRegistry.instance.auth.resetPassword(email);
  }

  // ================= SESSION EMAIL =================
  Future<String?> getSessionEmail() async {
    final cloud = CloudRegistry.instance.auth;
    if (cloud.isSignedIn && (cloud.currentUserEmail?.isNotEmpty ?? false)) {
      return cloud.currentUserEmail;
    }
    return _secureStorage.read(key: _sessionEmailKey);
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await CloudRegistry.instance.auth.signOut();
    await _secureStorage.delete(key: _sessionEmailKey);
    await SessionService.instance.clear();
    SyncEngine.instance.stop();
    CloudConfigService.instance.reset();
    RepositoryFactory.configure(cloudSyncEnabled: false);
    debugPrint('[AUTH] Logged out');
  }

  // ================= AUTO LOGIN =================
  Future<String?> tryAutoLogin() async {
    try {
      final auth = CloudRegistry.instance.auth;
      if (auth.isSignedIn) {
        final email = auth.currentUserEmail ?? '';
        if (email.isNotEmpty) {
          await _secureStorage.write(key: _sessionEmailKey, value: email);
        }
        await _postLoginInit();
        debugPrint('[AUTH] Auto-login: cloud session valid for $email');
        return email.isNotEmpty ? email : null;
      }

      // Fallback: local session marker + local DB user
      final savedEmail = await _secureStorage.read(key: _sessionEmailKey);
      if (savedEmail != null && savedEmail.isNotEmpty) {
        final localUser = await _userService.getUserByEmail(savedEmail);
        if (localUser != null && localUser.isActive) {
          await _postLoginInit();
          debugPrint('[AUTH] Auto-login: local session for $savedEmail');
          return savedEmail;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[AUTH] Auto-login failed: $e');
      return null;
    }
  }

  // ================= POST-LOGIN INIT =================
  Future<void> _postLoginInit() async {
    await SessionService.instance.initialize();
    final doctorId = SessionService.instance.currentDoctorId;

    _registerWithBackend().catchError(
      (e) => debugPrint('[AUTH] Backend sync skipped: $e'),
    );

    final config = await CloudConfigService.instance.fetch(doctorId);
    RepositoryFactory.configure(cloudSyncEnabled: config.cloudSyncEnabled);

    if (config.cloudSyncEnabled) SyncEngine.instance.start();

    debugPrint('[AUTH] Post-login init complete — '
        'doctorId=$doctorId, cloudSync=${config.cloudSyncEnabled}');
  }

  // ================= BACKEND SYNC =================
  Future<void> _registerWithBackend() async {
    final auth = CloudRegistry.instance.auth;
    if (!auth.isSignedIn) return;

    final hospital = _pendingHospital;
    final role     = _pendingRole;
    _pendingHospital = null;
    _pendingRole     = null;

    await Dio().put(
      '${Config.backendUrl}/profile',
      data: {
        'fullName': auth.currentUserMetadata['full_name'],
        'role':     role ?? 'doctor',
        if (hospital != null && hospital.isNotEmpty) 'hospital': hospital,
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${auth.accessToken}'},
      ),
    );
    debugPrint('[AUTH] Backend registration synced for ${auth.currentUserEmail}');
  }

  // ================= LOCAL DB =================
  Future<void> _upsertLocalUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required bool isActive,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final now = DateTime.now();

    final existing = await _userService.getUserByEmail(normalizedEmail);
    if (existing != null) {
      if (existing.id == null) return;
      await _userService.updateUser(
        existing.id!,
        existing.copyWith(
          fullName: fullName,
          email:    normalizedEmail,
          role:     role,
          isActive: isActive,
          updatedAt: now,
        ),
      );
      return;
    }

    await _userService.createUser(
      app_user.User(
        fullName:       fullName,
        email:          normalizedEmail,
        password:       password,
        medicalLicense: 'N/A',
        hospital:       'N/A',
        role:           role,
        isActive:       isActive,
        createdAt:      now,
        updatedAt:      now,
      ),
    );
  }
}

