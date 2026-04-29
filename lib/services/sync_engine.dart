import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../db/app_database.dart';
import '../db/tables/sync_queue.dart';
import '../services/patient_service.dart' show Patient;
import 'session_service.dart';

/// Processes the local [SyncQueue] table and pushes each entry to Firestore.
///
/// ## Lifecycle
///   - Call [start] once after a successful login when cloud sync is enabled.
///   - Call [stop] on logout or when cloud sync is disabled.
///
/// ## Retry policy
///   - Up to [maxAttempts] retries per entry.
///   - Entries that exceed [maxAttempts] are left in the queue with their
///     last error recorded for diagnostics; they are not retried automatically.
///
/// ## Connectivity
///   [SyncEngine] does not watch connectivity itself.  Call [flush] whenever
///   you know the device has (re-)gained internet access.  The engine also
///   flushes automatically on a periodic timer while running.
class SyncEngine {
  SyncEngine._();
  static final SyncEngine instance = SyncEngine._();

  static const int    maxAttempts     = 5;
  static const Duration flushInterval = Duration(minutes: 2);

  final AppDatabase       _db  = AppDatabase();
  final FirebaseFirestore _fdb = FirebaseFirestore.instance;

  Timer?  _timer;
  bool    _running  = false;
  bool    _flushing = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void start() {
    if (_running) return;
    _running = true;
    _timer   = Timer.periodic(flushInterval, (_) => flush());
    debugPrint('[SYNC_ENGINE] Started');
    flush(); // immediate first pass
  }

  void stop() {
    _timer?.cancel();
    _timer   = null;
    _running = false;
    debugPrint('[SYNC_ENGINE] Stopped');
  }

  // ── Queue write ───────────────────────────────────────────────────────────

  /// Enqueue a local write for later cloud push.
  /// Called by [SyncedPatientRepository] after every local mutation.
  Future<void> enqueue({
    required String entityType,   // 'patient' | 'media_file'
    required String entityUuid,
    required String operation,    // 'create' | 'update' | 'delete'
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

  /// Push all pending queue entries to Firestore.
  /// Safe to call at any time; re-entrant calls are ignored.
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

      // Success — remove from queue.
      await (_db.delete(_db.syncQueue)
            ..where((t) => t.id.equals(row.id)))
          .go();
      debugPrint('[SYNC_ENGINE] ✓ ${row.operation} ${row.entityUuid}');
    } catch (e) {
      // Failure — increment attempts and record error.
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
    final col      = _fdb
        .collection('doctors')
        .doc(doctorId)
        .collection('patients');

    switch (operation) {
      case 'create':
      case 'update':
        await col.doc(patient.uuid).set(
          payload
            ..['updatedAt'] = FieldValue.serverTimestamp(),
          SetOptions(merge: true),
        );
      case 'delete':
        // Soft-delete: push the tombstone so other devices see deletedAt.
        await col.doc(patient.uuid).set(
          {
            'deletedAt': FieldValue.serverTimestamp(),
            'syncStatus': 'synced',
          },
          SetOptions(merge: true),
        );
    }

    // Mark the local row as synced.
    await (_db.update(_db.patients)
          ..where((t) => t.uuid.equals(patient.uuid)))
        .write(const PatientsCompanion(
      syncStatus: Value('synced'),
    ));
  }
}
