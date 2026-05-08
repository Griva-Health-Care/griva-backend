import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../i_auth_provider.dart';

/// Firebase Auth (email/password) implementation of [IAuthProvider].
///
/// The Firebase ID token is sent as the Bearer token on every backend request.
/// The backend verifies it with firebase-admin and maps the Firebase UID to
/// the User row via the supabaseUid column.
class FirebaseAuthProvider implements IAuthProvider {
  FirebaseAuthProvider();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  // Cached ID token — refreshed on sign-in and by [refreshToken].
  String? _cachedToken;

  /// Call once at app start to restore a persisted Firebase session.
  Future<void> restoreSession() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        _cachedToken = await user.getIdToken();
        debugPrint('[FIREBASE_AUTH] Session restored for ${user.email}');
      } catch (e) {
        debugPrint('[FIREBASE_AUTH] Token refresh on restore failed: $e');
        _cachedToken = null;
      }
    }
  }

  /// Force-refresh the Firebase ID token. Called before every backend request
  /// to avoid the 1-hour expiry window.
  Future<String?> refreshToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      _cachedToken = await user.getIdToken(true);
    } catch (e) {
      debugPrint('[FIREBASE_AUTH] Token refresh failed: $e');
    }
    return _cachedToken;
  }

  @override
  Future<void> signInWithPassword(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email:    email.trim(),
      password: password,
    );
    _cachedToken = await cred.user?.getIdToken();
  }

  @override
  Future<void> signUp(
    String email,
    String password, {
    Map<String, dynamic> metadata = const {},
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email:    email.trim(),
      password: password,
    );
    final fullName = metadata['full_name'] as String?;
    if (fullName != null && fullName.isNotEmpty) {
      await cred.user?.updateDisplayName(fullName);
    }
    _cachedToken = await cred.user?.getIdToken();
  }

  @override
  Future<void> signOut() async {
    _cachedToken = null;
    await _auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  String? get currentUserEmail => _auth.currentUser?.email;

  @override
  Map<String, dynamic> get currentUserMetadata {
    final user = _auth.currentUser;
    if (user == null) return {};
    return {
      if (user.displayName != null) 'full_name': user.displayName,
      if (user.email       != null) 'email':     user.email,
    };
  }

  @override
  String? get accessToken => _cachedToken;

  @override
  bool get isSignedIn => _auth.currentUser != null && _cachedToken != null;
}
