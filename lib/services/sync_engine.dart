import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../cloud/cloud_registry.dart';
import '../db/app_database.dart';
import '../db/tables/sync_queue.dart';
import '../services/patient_service.dart' show Patient;
import 'session_service.dart';

/// Processes the local [SyncQueue] table and pushes each entry to the cloud
/// database via [CloudRegistry.instance.database].
///
/// ## Lifecycle
///   - Call [start] once after a successful login when cloud sync is enabled.
///   - Call [stop] on logout or when cloud sync is disabled.
///
/// ## Retry policy
///   - Up to [maxAttempts] retries per entry.
///   - Entries that exceed [maxAttempts] are left in the queue with their
///     last error recorded; they are not retried automatically.
class SyncEngine {
  SyncEngine._();
  static final SyncEngine instance = SyncEngine._();

  static const int      maxAttempts   = 5;
  static const Duration flushInterval = Duration(minutes: 2);

  final AppDatabase _db = AppDatabase.instance;

  Timer? _timer;
  bool   _running  = false;
  bool   _flushing = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void start() {
    if (_running) return;
    _running = true;
    _timer   = Timer.periodic(flushInterval, (_) => flush());
    debugPrint('[SYNC_ENGINE] Started');
    flush();
  }

  void stop() {
    _timer?.cancel();
    _timer   = null;
    _running = false;
    debugPrint('[SYNC_ENGINE] Stopped');
  }

  // ── Queue write ───────────────────────────────────────────────────────────

  Future<void> enqueue({
    required String entityType,
    required String entityUuid,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final now = DateTime.now().toIso8601String();
    await _db.into(_db.syncQueue).insert(
      SyncQueueCompanion.insert(
        entityType: entityType,
        entityUuid: entityUuid,
        operation:  operation,
        payload:    jsonEncode(payload),
        createdAt:  now,
      ),
    );
    debugPrint('[SYNC_ENGINE] Enqueued $operation for $entityType $entityUuid');
  }

  // ── Flush ─────────────────────────────────────────────────────────────────

  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      await _processQueue();
    } finally {
      _flushing = false;
    }
  }

  Future<void> _processQueue() async {
    final rows = await (_db.select(_db.syncQueue)
          ..where((t) => t.attempts.isSmallerThanValue(maxAttempts))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();

    if (rows.isEmpty) return;
    debugPrint('[SYNC_ENGINE] Processing ${rows.length} queued entries');
    for (final row in rows) {
      await _processRow(row);
    }
  }

  Future<void> _processRow(SyncQueueRow row) async {
    final now = DateTime.now().toIso8601String();
    try {
      final payload = jsonDecode(row.payload) as Map<String, dynamic>;
      switch (row.entityType) {
        case 'patient':
          await _syncPatient(row.operation, payload);
        default:
          debugPrint('[SYNC_ENGINE] Unknown entityType: ${row.entityType}');
      }
      await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(row.id))).go();
      debugPrint('[SYNC_ENGINE] ✓ ${row.operation} ${row.entityUuid}');
    } catch (e) {
      await (_db.update(_db.syncQueue)..where((t) => t.id.equals(row.id)))
          .write(SyncQueueCompanion(
        attempts:      Value(row.attempts + 1),
        lastAttemptAt: Value(now),
        lastError:     Value(e.toString()),
      ));
      debugPrint('[SYNC_ENGINE] ✗ ${row.entityUuid} (attempt ${row.attempts + 1}): $e');
    }
  }

  Future<void> _syncPatient(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    final doctorId = SessionService.instance.currentDoctorId;
    final patient  = Patient.fromMap(payload);
    final db       = CloudRegistry.instance.database;

    if (operation == 'delete') {
      await db.update(
        'patients',
        {'deleted_at': DateTime.now().toIso8601String()},
        eq: {'uuid': patient.uuid},
      );
    } else {
      final hasReport = (patient.finalImpression?.isNotEmpty ?? false) ||
          (patient.colposcopyFindings?.isNotEmpty ?? false);
      await db.upsert('patients', {
        'uuid':         patient.uuid,
        'patient_name': patient.patientName,
        'user_id':      doctorId,
        'has_report':   hasReport,
      }, onConflict: 'uuid');
    }

    await (_db.update(_db.patients)..where((t) => t.uuid.equals(patient.uuid)))
        .write(const PatientsCompanion(syncStatus: Value('synced')));
  }
}
