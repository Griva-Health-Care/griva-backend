import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Reads the per-doctor cloud-sync configuration stored in Firestore.
///
/// Firestore path: `doctor_config/{doctorId}`
///
/// Fields written by the Griva admin panel:
///   cloudSyncEnabled  : bool   — whether this doctor has paid for cloud sync
///   role              : String — 'solo' | 'clinic' | 'diagnostic' | 'tele_reporter'
///   creditBalance     : int    — prepaid report credits (diagnostic centers only)
///
/// Call [fetch] once after login and cache the result for the session.
/// Call [stream] to listen for real-time admin changes (e.g., when a payment
/// is confirmed and the flag is flipped while the app is open).
class CloudConfigService {
  CloudConfigService._();
  static final CloudConfigService instance = CloudConfigService._();

  static const _collection = 'doctor_config';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // In-memory cache updated by the active stream subscription.
  DoctorConfig _cache = const DoctorConfig();
  DoctorConfig get current => _cache;

  /// One-shot fetch.  Returns [DoctorConfig.defaults] on any error so the app
  /// degrades gracefully when offline.
  Future<DoctorConfig> fetch(String doctorId) async {
    try {
      final doc = await _db.collection(_collection).doc(doctorId).get();
      if (doc.exists && doc.data() != null) {
        _cache = DoctorConfig.fromMap(doc.data()!);
        debugPrint('[CONFIG] Fetched config for $doctorId: $_cache');
        return _cache;
      }
    } catch (e) {
      debugPrint('[CONFIG] Fetch failed (offline?): $e');
    }
    return _cache;
  }

  /// Real-time stream — call [listenForChanges] once after login.
  /// The returned cancel function should be called on logout.
  Future<void Function()> listenForChanges(
    String doctorId, {
    required void Function(DoctorConfig) onChanged,
  }) async {
    final sub = _db
        .collection(_collection)
        .doc(doctorId)
        .snapshots()
        .listen((snap) {
      if (snap.exists && snap.data() != null) {
        _cache = DoctorConfig.fromMap(snap.data()!);
        debugPrint('[CONFIG] Config updated for $doctorId: $_cache');
        onChanged(_cache);
      }
    }, onError: (e) => debugPrint('[CONFIG] Stream error: $e'));
    return sub.cancel;
  }

  void reset() {
    _cache = const DoctorConfig();
  }
}

/// Immutable snapshot of a doctor's cloud configuration.
class DoctorConfig {
  final bool   cloudSyncEnabled;
  final String role;           // 'solo' | 'clinic' | 'diagnostic' | 'tele_reporter'
  final int    creditBalance;  // prepaid report credits (diagnostic centers only)

  const DoctorConfig({
    this.cloudSyncEnabled = false,
    this.role = 'solo',
    this.creditBalance = 0,
  });

  factory DoctorConfig.fromMap(Map<String, dynamic> map) => DoctorConfig(
    cloudSyncEnabled: (map['cloudSyncEnabled'] as bool?) ?? false,
    role:             (map['role']             as String?) ?? 'solo',
    creditBalance:    (map['creditBalance']    as int?)    ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'cloudSyncEnabled': cloudSyncEnabled,
    'role':             role,
    'creditBalance':    creditBalance,
  };

  @override
  String toString() =>
      'DoctorConfig(sync=$cloudSyncEnabled, role=$role, credits=$creditBalance)';
}
