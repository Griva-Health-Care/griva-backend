import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/config.dart';
import '../repositories/repository_factory.dart';
import 'cloud_config_service.dart';
import 'session_service.dart';
import 'sync_engine.dart';
import 'user_service.dart' as app_user;

class AuthService {
  final fb.FirebaseAuth? _firebase;
  final app_user.UserService _userService = app_user.UserService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _restBase =
      'https://identitytoolkit.googleapis.com/v1/accounts';
  static const String _sessionEmailKey = 'local_session_email';

  AuthService()
      : _firebase = Platform.isLinux ? null : fb.FirebaseAuth.instance;

  // ================= LOGIN =================
  Future<bool> login(String email, String password) async {
    debugPrint('[AUTH] Login attempt: $email');
    try {
      final user = await _signIn(email, password);
      await _upsertLocalUser(
        email: email,
        password: password,
        fullName: user.displayName ?? email.split('@').first,
        role: 'doctor',
        isActive: true,
      );
      await _secureStorage.write(
          key: _sessionEmailKey, value: email.trim().toLowerCase());
      await _postLoginInit();
      debugPrint('[AUTH] Login successful (online)');
      return true;
    } on fb.FirebaseAuthException catch (e) {
      debugPrint('[AUTH] Firebase error: ${e.code}');
      // Network failure → attempt offline validation against local credentials.
      if (e.code == 'network-request-failed') {
        return await _offlineLogin(email, password);
      }
      throw Exception(_sdkErrorMessage(e.code));
    } catch (e, st) {
      debugPrint('[AUTH] Login failed: $e\n$st');
      rethrow;
    }
  }

  // Validates credentials against the locally stored bcrypt hash.
  // Only reachable when Firebase is unreachable (no internet / on hotspot).
  Future<bool> _offlineLogin(String email, String password) async {
    debugPrint('[AUTH] No internet — trying offline login for $email');
    final localUser =
        await _userService.authenticateUser(email.trim().toLowerCase(), password);
    if (localUser == null) {
      debugPrint('[AUTH] Offline login failed — credentials not recognised');
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
  Future<bool> register({
    required String email,
    required String name,
    required String password,
  }) async {
    fb.User? sdkUser;
    try {
      debugPrint('[AUTH] Register: $email');
      sdkUser = await _createAccount(email, password, name);
      await _upsertLocalUser(
        email: email,
        password: password,
        fullName: name,
        role: 'doctor',
        isActive: true,
      );
      debugPrint('[AUTH] Registration successful');
      return true;
    } on fb.FirebaseAuthException catch (e) {
      debugPrint('[AUTH] Firebase error: ${e.code}');
      await _rollbackFirebaseUser(sdkUser);
      throw Exception(_sdkErrorMessage(e.code));
    } catch (e) {
      debugPrint('[AUTH] Registration failed: $e');
      await _rollbackFirebaseUser(sdkUser);
      rethrow;
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<void> sendPasswordResetEmail(String email) async {
    if (Platform.isLinux) {
      await _restSendPasswordReset(email.trim());
    } else {
      await _firebase!.sendPasswordResetEmail(email: email.trim());
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    if (_firebase != null) await _firebase.signOut();
    await _secureStorage.delete(key: _sessionEmailKey);
    await SessionService.instance.clear();
    SyncEngine.instance.stop();
    CloudConfigService.instance.reset();
    RepositoryFactory.configure(cloudSyncEnabled: false);
    debugPrint('[AUTH] Logged out');
  }

  // ================= AUTO LOGIN =================
  // Returns the user's email if a valid session exists, null otherwise.
  // Never makes a network call — the session is fully offline-capable.
  Future<String?> tryAutoLogin() async {
    try {
      if (Platform.isLinux) return null;

      // 1. Firebase caches the auth state on-device. currentUser is non-null
      //    whenever the user has previously signed in, even with no internet.
      //    We deliberately avoid getIdToken(true) here — that forces a network
      //    round-trip and breaks offline use on the GRIVAVISION hotspot.
      final firebaseUser = _firebase!.currentUser;
      if (firebaseUser != null) {
        final email = firebaseUser.email ?? '';
        if (email.isNotEmpty) {
          await _secureStorage.write(key: _sessionEmailKey, value: email);
        }
        await _postLoginInit();
        debugPrint('[AUTH] Auto-login: Firebase session valid for $email');
        return email.isNotEmpty ? email : null;
      }

      // 2. Fallback: Firebase session was cleared (e.g., app data wiped) but
      //    we still have a local session marker AND a local DB user record.
      //    This keeps the user logged in even when Firebase state is gone.
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

  // ================= FIREBASE — SDK (non-Linux) =================
  Future<fb.User> _signIn(String email, String password) async {
    if (Platform.isLinux) {
      await _restSignIn(email, password);
      throw Exception('Linux login does not return a User object');
    }
    final credential = await _firebase!.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('Firebase user null after sign-in');
    return user;
  }

  Future<fb.User> _createAccount(
      String email, String password, String name) async {
    if (Platform.isLinux) {
      await _restSignUp(email, password);
      throw Exception('Linux registration does not return a User object');
    }
    final credential = await _firebase!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('Firebase user creation failed');
    try {
      await user.updateDisplayName(name);
      await user.sendEmailVerification();
    } catch (_) {}
    return user;
  }

  Future<void> _rollbackFirebaseUser(fb.User? user) async {
    if (user == null) return;
    try {
      await user.delete();
    } catch (_) {}
  }

  // ================= FIREBASE — REST API (Linux) =================
  Future<void> _restSignIn(String email, String password) async {
    try {
      await Dio().post(
        '$_restBase:signInWithPassword?key=${Config.firebaseWebApiKey}',
        data: {'email': email, 'password': password, 'returnSecureToken': true},
      );
    } on DioException catch (e) {
      throw Exception(_restErrorMessage(e));
    }
  }

  Future<void> _restSignUp(String email, String password) async {
    try {
      await Dio().post(
        '$_restBase:signUp?key=${Config.firebaseWebApiKey}',
        data: {'email': email, 'password': password, 'returnSecureToken': true},
      );
    } on DioException catch (e) {
      throw Exception(_restErrorMessage(e));
    }
  }

  Future<void> _restSendPasswordReset(String email) async {
    try {
      await Dio().post(
        '$_restBase:sendOobCode?key=${Config.firebaseWebApiKey}',
        data: {'requestType': 'PASSWORD_RESET', 'email': email},
      );
    } on DioException catch (e) {
      throw Exception(_restErrorMessage(e));
    }
  }

  // ================= ERROR MESSAGES =================
  String _sdkErrorMessage(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  String _restErrorMessage(DioException e) {
    final msg =
        e.response?.data?['error']?['message'] as String? ?? '';
    if (msg.contains('EMAIL_NOT_FOUND') ||
        msg.contains('INVALID_LOGIN_CREDENTIALS')) {
      return 'No account found with this email.';
    }
    if (msg.contains('INVALID_PASSWORD')) {
      return 'Incorrect password. Please try again.';
    }
    if (msg.contains('EMAIL_EXISTS')) {
      return 'This email is already registered. Please sign in instead.';
    }
    if (msg.contains('WEAK_PASSWORD')) {
      return 'Password is too weak. Use at least 8 characters.';
    }
    if (msg.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
      return 'Too many failed attempts. Please try again later.';
    }
    if (msg.contains('USER_DISABLED')) {
      return 'This account has been disabled. Contact support.';
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Network error. Check your connection and try again.';
    }
    return 'Authentication failed. Please try again.';
  }

  // ================= POST-LOGIN INIT =================
  // Called after every successful login (online, offline, and auto-login).
  // Order matters: session first (provides doctorId), then cloud config
  // (uses doctorId to fetch sync flag), then factory (uses sync flag).
  Future<void> _postLoginInit() async {
    await SessionService.instance.initialize();
    final doctorId = SessionService.instance.currentDoctorId;

    // Sync profile to the Node backend (fire-and-forget — must not block login
    // or fail when the device is offline / backend is unreachable).
    _registerWithBackend().catchError(
      (e) => debugPrint('[AUTH] Backend sync skipped: $e'),
    );

    // Fetch cloud config; gracefully no-ops when offline.
    final config = await CloudConfigService.instance.fetch(doctorId);

    // Tell the factory which implementation to use for this session.
    RepositoryFactory.configure(cloudSyncEnabled: config.cloudSyncEnabled);

    // Start the sync engine only when cloud sync is active.
    if (config.cloudSyncEnabled) {
      SyncEngine.instance.start();
    }

    debugPrint('[AUTH] Post-login init complete — '
        'doctorId=$doctorId, cloudSync=${config.cloudSyncEnabled}');
  }

  // ================= BACKEND SYNC =================
  // Registers / syncs the current Firebase user with the Node backend so it
  // appears in PostgreSQL.  Never throws — callers use catchError.
  Future<void> _registerWithBackend() async {
    if (Platform.isLinux) return; // Firebase SDK not available on Linux
    final firebaseUser = _firebase?.currentUser;
    if (firebaseUser == null) return;

    final token = await firebaseUser.getIdToken();
    await Dio().post(
      '${Config.piBaseUrl}/users/register',
      data: {
        'fullName': firebaseUser.displayName,
        'role': 'doctor',
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    debugPrint('[AUTH] Backend registration synced for ${firebaseUser.email}');
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
      // Never overwrite the stored bcrypt hash with a raw password.
      // Profile fields (name, role, active) are kept in sync with Firebase;
      // the password column is left untouched — it was hashed on first create.
      if (existing.id == null) {
        debugPrint('[AUTH] WARNING: existing user has null id — skipping update');
        return;
      }
      await _userService.updateUser(
        existing.id!,
        existing.copyWith(
          fullName: fullName,
          email: normalizedEmail,
          role: role,
          isActive: isActive,
          updatedAt: now,
        ),
      );
      return;
    }

    // First time: createUser hashes the password via PasswordService.
    await _userService.createUser(
      app_user.User(
        fullName: fullName,
        email: normalizedEmail,
        password: password,
        medicalLicense: 'N/A',
        hospital: 'N/A',
        role: role,
        isActive: isActive,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
