import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Holds the current authenticated doctor's identity for the lifetime of a
/// session.
///
/// The canonical doctor ID is the Supabase Auth user UUID — a stable,
/// globally unique string that never changes even if the email is updated.
/// When the device is offline the last-known UID is read from secure storage
/// so the same doctor always maps to the same data row — both locally and
/// in the cloud.
///
/// Call [initialize] after a successful login and [clear] on logout.
/// Screens and services read [currentDoctorId]; they never touch Supabase
/// Auth directly.
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  static const _uidKey = 'session_doctor_uid';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String _doctorId = 'local_legacy';

  /// The current doctor's Supabase UUID (or 'local_legacy' for pre-auth rows).
  String get currentDoctorId => _doctorId;

  /// Call once after every successful login (online or offline).
  Future<void> initialize() async {
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    if (supabaseUser != null) {
      _doctorId = supabaseUser.id;
      await _storage.write(key: _uidKey, value: _doctorId);
      debugPrint('[SESSION] Initialized from Supabase UID: $_doctorId');
      return;
    }

    // Offline login path: Supabase session is absent but local bcrypt
    // validation passed. Re-use the last stored UID.
    final stored = await _storage.read(key: _uidKey);
    if (stored != null && stored.isNotEmpty) {
      _doctorId = stored;
      debugPrint('[SESSION] Initialized from stored UID (offline): $_doctorId');
    } else {
      _doctorId = 'local_legacy';
      debugPrint('[SESSION] No UID found — using local_legacy');
    }
  }

  /// Call on logout. In-memory doctorId is reset; the stored key is kept so
  /// the next offline login can still see the same rows.
  Future<void> clear() async {
    _doctorId = 'local_legacy';
    debugPrint('[SESSION] Cleared');
  }
}
