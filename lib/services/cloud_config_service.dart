import 'dart:async';

import 'package:flutter/foundation.dart';

import '../cloud/cloud_registry.dart';

/// Reads the per-doctor cloud-sync configuration stored in the cloud database.
///
/// Table: doctor_config (uid PK = auth provider user UUID)
///
/// Fields written by the Griva admin panel:
///   cloudSyncEnabled  : bool   — whether this doctor has paid for cloud sync
///   role              : String — 'solo' | 'clinic' | 'diagnostic' | 'tele_reporter'
///   creditBalance     : int    — prepaid report credits (diagnostic centers only)
class CloudConfigService {
  CloudConfigService._();
  static final CloudConfigService instance = CloudConfigService._();

  DoctorConfig _cache = const DoctorConfig();
  DoctorConfig get current => _cache;

  StreamSubscription<Map<String, dynamic>>? _sub;

  /// One-shot fetch. Returns [DoctorConfig] defaults on any error.
  Future<DoctorConfig> fetch(String doctorId) async {
    try {
      final row = await CloudRegistry.instance.database.selectSingle(
        'doctor_config',
        eq: {'uid': doctorId},
      );
      if (row != null) {
        _cache = DoctorConfig.fromMap(row);
        debugPrint('[CONFIG] Fetched config for $doctorId: $_cache');
        return _cache;
      }
    } catch (e) {
      debugPrint('[CONFIG] Fetch failed (offline?): $e');
    }
    return _cache;
  }

  /// Real-time stream — emits whenever the doctor_config row changes.
  /// Returns a cancel function; call it on logout.
  Future<void Function()> listenForChanges(
    String doctorId, {
    required void Function(DoctorConfig) onChanged,
  }) async {
    await _sub?.cancel();

    _sub = CloudRegistry.instance.database
        .watchRow('doctor_config', 'uid', doctorId)
        .listen((row) {
      _cache = DoctorConfig.fromMap(row);
      debugPrint('[CONFIG] Config updated for $doctorId: $_cache');
      onChanged(_cache);
    });

    return () async {
      await _sub?.cancel();
      _sub = null;
    };
  }

  void reset() {
    _sub?.cancel();
    _sub = null;
    _cache = const DoctorConfig();
  }
}

/// Immutable snapshot of a doctor's cloud configuration.
class DoctorConfig {
  final bool   cloudSyncEnabled;
  final String role;
  final int    creditBalance;

  const DoctorConfig({
    this.cloudSyncEnabled = false,
    this.role             = 'solo',
    this.creditBalance    = 0,
  });

  factory DoctorConfig.fromMap(Map<String, dynamic> map) => DoctorConfig(
    cloudSyncEnabled: (map['cloudSyncEnabled'] as bool?)  ??
                      (map['cloud_sync_enabled'] as bool?) ?? false,
    role:             (map['role']             as String?) ?? 'solo',
    creditBalance:    (map['creditBalance']    as int?)    ??
                      (map['credit_balance']  as int?)    ?? 0,
  );

  @override
  String toString() =>
      'DoctorConfig(sync=$cloudSyncEnabled, role=$role, credits=$creditBalance)';
}
