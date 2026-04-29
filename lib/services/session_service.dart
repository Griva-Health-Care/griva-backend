import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the current authenticated doctor's identity for the lifetime of a
/// session.
///
/// The canonical doctor ID is the Firebase Auth UID (a stable, globally unique
/// string that never changes even if the doctor's email is updated).
/// When the device is offline the last-known UID is read from secure storage
/// so the same doctor always maps to the same data row — both locally and in
/// the cloud.
///
/// Call [initialize] after a successful login and [clear] on logout.
/// Screens and services read [currentDoctorId]; they never touch Firebase Auth
/// directly.
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  static const _uidKey = 'session_doctor_uid';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String _doctorId = 'local_legacy';

  /// The current doctor's Firebase UID (or 'local_legacy' for pre-auth rows).
  String get currentDoctorId => _doctorId;

  /// Call once after every successful login (online or offline).
  ///
  /// On an online login the Firebase UID is stored to secure storage so it
  /// survives future offline sessions.  On an offline login we fall back to
  /// the previously stored UID.
  Future<void> initialize() async {
    if (Platform.isLinux) {
      // Linux dev environment — no Firebase SDK; use stored UID or fallback.
      final stored = await _storage.read(key: _uidKey);
      _doctorId = (stored != null && stored.isNotEmpty) ? stored : 'local_legacy';
      debugPrint('[SESSION] Linux mode — doctorId: $_doctorId');
      return;
    }

    final firebaseUser = fb.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      _doctorId = firebaseUser.uid;
      await _storage.write(key: _uidKey, value: _doctorId);
      debugPrint('[SESSION] Initialized from Firebase UID: $_doctorId');
      return;
    }

    // Offline login path: Firebase currentUser is null but the user passed
    // local bcrypt validation.  Re-use the last stored UID so their existing
    // local data is still visible.
    final stored = await _storage.read(key: _uidKey);
    if (stored != null && stored.isNotEmpty) {
      _doctorId = stored;
      debugPrint('[SESSION] Initialized from stored UID (offline): $_doctorId');
    } else {
      _doctorId = 'local_legacy';
      debugPrint('[SESSION] No UID found — using local_legacy');
    }
  }

  /// Call on logout.  In-memory doctorId is reset; the stored key is kept so
  /// the next offline login can still see the same rows.
  Future<void> clear() async {
    _doctorId = 'local_legacy';
    debugPrint('[SESSION] Cleared');
  }
}
