import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reads the per-doctor cloud-sync configuration stored in Supabase Postgres.
///
/// Table: node_app.doctor_config (uid PK = Supabase user UUID)
///
/// Fields written by the Griva admin panel:
///   cloudSyncEnabled  : bool   — whether this doctor has paid for cloud sync
///   role              : String — 'solo' | 'clinic' | 'diagnostic' | 'tele_reporter'
///   creditBalance     : int    — prepaid report credits (diagnostic centers only)
///
/// This replaces the previous Firestore `doctor_config/{uid}` collection.
class CloudConfigService {
  CloudConfigService._();
  static final CloudConfigService instance = CloudConfigService._();

  SupabaseClient get _db => Supabase.instance.client;

  DoctorConfig _cache = const DoctorConfig();
  DoctorConfig get current => _cache;

  RealtimeChannel? _channel;

  /// One-shot fetch. Returns [DoctorConfig] defaults on any error.
  Future<DoctorConfig> fetch(String doctorId) async {
    try {
      final row = await _db
          .from('doctor_config')
          .select()
          .eq('uid', doctorId)
          .maybeSingle();
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

  /// Real-time stream using Supabase Realtime.
  /// The returned cancel function should be called on logout.
  Future<void Function()> listenForChanges(
    String doctorId, {
    required void Function(DoctorConfig) onChanged,
  }) async {
    _channel?.unsubscribe();

    _channel = _db
        .channel('doctor_config:$doctorId')
        .onPostgresChanges(
          event:  PostgresChangeEvent.update,
          schema: 'node_app',
          table:  'doctor_config',
          filter: PostgresChangeFilter(
            type:  PostgresChangeFilterType.eq,
            column: 'uid',
            value: doctorId,
          ),
          callback: (payload) {
            final newRow = payload.newRecord;
            if (newRow.isNotEmpty) {
              _cache = DoctorConfig.fromMap(newRow);
              debugPrint('[CONFIG] Config updated for $doctorId: $_cache');
              onChanged(_cache);
            }
          },
        )
        .subscribe();

    return () async {
      await _channel?.unsubscribe();
      _channel = null;
    };
  }

  void reset() {
    _channel?.unsubscribe();
    _channel = null;
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

  Map<String, dynamic> toMap() => {
    'cloudSyncEnabled': cloudSyncEnabled,
    'role':             role,
    'creditBalance':    creditBalance,
  };

  @override
  String toString() =>
      'DoctorConfig(sync=$cloudSyncEnabled, role=$role, credits=$creditBalance)';
}
