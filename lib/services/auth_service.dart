import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';
import '../repositories/repository_factory.dart';
import 'cloud_config_service.dart';
import 'profile_service.dart';
import 'session_service.dart';
import 'sync_engine.dart';
import 'user_service.dart' as app_user;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final app_user.UserService _userService = app_user.UserService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _sessionEmailKey = 'local_session_email';

  // ================= LOGIN =================
  Future<bool> login(String email, String password) async {
    debugPrint('[AUTH] Login attempt: $email');
    try {
      final response = await _supabase.auth.signInWithPassword(
        email:    email.trim(),
        password: password,
      );
      if (response.user == null) throw Exception('Authentication failed');

      await _upsertLocalUser(
        email:    email,
        password: password,
        fullName: response.user!.userMetadata?['full_name'] as String? ??
                  email.split('@').first,
        role:     'doctor',
        isActive: true,
      );
      await _secureStorage.write(
          key: _sessionEmailKey, value: email.trim().toLowerCase());
      await _postLoginInit();
      debugPrint('[AUTH] Login successful');
      return true;
    } on AuthException catch (e) {
      debugPrint('[AUTH] Supabase error: ${e.message}');
      if (e.message.toLowerCase().contains('network') ||
          e.message.toLowerCase().contains('connection')) {
        return await _offlineLogin(email, password);
      }
      throw Exception(_authErrorMessage(e.message));
    } catch (e, st) {
      debugPrint('[AUTH] Login failed: $e\n$st');
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

      final response = await _supabase.auth.signUp(
        email:    email.trim(),
        password: password,
        data:     {'full_name': name},
      );
      if (response.user == null) throw Exception('Registration failed');

      await _upsertLocalUser(
        email:    email,
        password: password,
        fullName: name,
        role:     role ?? 'doctor',
        isActive: true,
      );
      debugPrint('[AUTH] Registration successful');
      return true;
    } on AuthException catch (e) {
      debugPrint('[AUTH] Supabase error: ${e.message}');
      _pendingHospital = null;
      _pendingRole     = null;
      throw Exception(_authErrorMessage(e.message));
    } catch (e) {
      debugPrint('[AUTH] Registration failed: $e');
      _pendingHospital = null;
      _pendingRole     = null;
      rethrow;
    }
  }

  // ================= GOOGLE SIGN-IN =================
  Future<GoogleSignInResult> signInWithGoogle() async {
    if (Platform.isLinux) throw Exception('Google sign-in not supported on Linux');

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return GoogleSignInResult.cancelled();

    final googleAuth = await googleUser.authentication;
    if (googleAuth.idToken == null) throw Exception('Failed to get Google ID token');

    final response = await _supabase.auth.signInWithIdToken(
      provider:    OAuthProvider.google,
      idToken:     googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );

    final user = response.user;
    if (user == null) throw Exception('Google sign-in failed');

    await _upsertLocalUser(
      email:    user.email    ?? '',
      password: user.id,
      fullName: user.userMetadata?['full_name'] as String? ??
                googleUser.displayName ?? '',
      role:     'doctor',
      isActive: true,
    );

    await _secureStorage.write(
      key:   _sessionEmailKey,
      value: (user.email ?? '').trim().toLowerCase(),
    );

    await _postLoginInit();

    final profileComplete =
        await ProfileService.instance.isProfileComplete(user.id);

    return GoogleSignInResult(
      email:        user.email         ?? '',
      displayName:  user.userMetadata?['full_name'] as String? ??
                    googleUser.displayName ?? '',
      needsProfile: !profileComplete,
    );
  }

  // ================= FORGOT PASSWORD =================
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email.trim());
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _supabase.auth.signOut();
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
      final session = _supabase.auth.currentSession;
      if (session != null && !_isTokenExpired(session)) {
        final email = session.user.email ?? '';
        if (email.isNotEmpty) {
          await _secureStorage.write(key: _sessionEmailKey, value: email);
        }
        await _postLoginInit();
        debugPrint('[AUTH] Auto-login: Supabase session valid for $email');
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

  bool _isTokenExpired(Session session) {
    final expiry = session.expiresAt;
    if (expiry == null) return false;
    return DateTime.fromMillisecondsSinceEpoch(expiry * 1000)
        .isBefore(DateTime.now());
  }

  // ================= ERROR MESSAGES =================
  String _authErrorMessage(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login') || m.contains('invalid credentials') ||
        m.contains('wrong password'))      return 'Incorrect email or password.';
    if (m.contains('user not found') ||
        m.contains('no user found'))       return 'No account found with this email.';
    if (m.contains('already registered') ||
        m.contains('already exists'))      return 'This email is already registered. Please sign in instead.';
    if (m.contains('weak password') ||
        m.contains('at least 6'))          return 'Password is too weak. Use at least 8 characters.';
    if (m.contains('invalid email'))       return 'Invalid email address.';
    if (m.contains('too many'))            return 'Too many failed attempts. Please try again later.';
    if (m.contains('disabled'))            return 'This account has been disabled. Contact support.';
    return 'Authentication failed. Please try again.';
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

    if (config.cloudSyncEnabled) {
      SyncEngine.instance.start();
    }

    debugPrint('[AUTH] Post-login init complete — '
        'doctorId=$doctorId, cloudSync=${config.cloudSyncEnabled}');
  }

  // ================= BACKEND SYNC =================
  Future<void> _registerWithBackend() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return;

    final hospital = _pendingHospital;
    final role     = _pendingRole;
    _pendingHospital = null;
    _pendingRole     = null;

    await Dio().post(
      '${Config.piBaseUrl}/users/register',
      data: {
        'fullName': session.user.userMetadata?['full_name'],
        'role':     role ?? 'doctor',
        if (hospital != null && hospital.isNotEmpty) 'hospital': hospital,
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      ),
    );
    debugPrint('[AUTH] Backend registration synced for ${session.user.email}');
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
        fullName:        fullName,
        email:           normalizedEmail,
        password:        password,
        medicalLicense:  'N/A',
        hospital:        'N/A',
        role:            role,
        isActive:        isActive,
        createdAt:       now,
        updatedAt:       now,
      ),
    );
  }
}

class GoogleSignInResult {
  final bool   cancelled;
  final String email;
  final String displayName;
  final bool   needsProfile;

  const GoogleSignInResult({
    this.cancelled    = false,
    this.email        = '',
    this.displayName  = '',
    this.needsProfile = false,
  });

  factory GoogleSignInResult.cancelled() =>
      const GoogleSignInResult(cancelled: true);
}
