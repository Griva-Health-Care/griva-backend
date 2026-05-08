import '../../services/patient_service.dart' show Patient;
import '../../services/sync_engine.dart';
import '../i_patient_repository.dart';
import '../local/local_patient_repository.dart';

/// Local-first patient repository with background cloud sync.
///
/// Every write goes to SQLite immediately (so the UI never waits for the
/// network).  A [SyncEngine] call is then made in the background to push
/// the change to Firestore.  When offline the local write still succeeds;
/// the pending change is picked up by [SyncEngine] next time connectivity
/// is available.
///
/// Reads always come from the local DB for speed.  The sync engine pulls
/// from Firestore and writes to local when a remote change is detected.
class SyncedPatientRepository implements IPatientRepository {
  SyncedPatientRepository({
    LocalPatientRepository? local,
    void Function(String uuid, String operation, Map<String, dynamic> payload)?
        onQueueWrite,
  })  : _local        = local ?? LocalPatientRepository(),
        _onQueueWrite = onQueueWrite;

  final LocalPatientRepository _local;

  /// Exposed so callers that need direct local-DB access (e.g. image linking)
  /// can reach the underlying SQLite repository regardless of sync mode.
  LocalPatientRepository get local => _local;

  /// Optional callback for tests to intercept queue writes.
  /// In production this is null and [SyncEngine] is used directly.
  final void Function(
    String uuid,
    String operation,
    Map<String, dynamic> payload,
  )? _onQueueWrite;

  // ── Queries (always local) ────────────────────────────────────────────────

  @override
  Future<List<Patient>> getAll(String doctorId) =>
      _local.getAll(doctorId);

  @override
  Future<Patient?> getByUuid(String uuid) => _local.getByUuid(uuid);

  /// SQLite rowid lookup — local only.
  Future<Patient?> getById(int id) => _local.getById(id);

  // ── Writes (local-first, then cloud) ─────────────────────────────────────

  @override
  Future<Patient> create(Patient patient) async {
    final saved = await _local.create(patient);
    _pushOrQueue(saved.uuid, 'create', saved.toMap());
    return saved;
  }

  @override
  Future<Patient> update(Patient patient) async {
    final saved = await _local.update(patient);
    _pushOrQueue(saved.uuid, 'update', saved.toMap());
    return saved;
  }

  @override
  Future<void> delete(String uuid) async {
    await _local.delete(uuid);
    // After soft-delete the row has deletedAt set — re-read it and push the
    // tombstone so the cloud copy is also marked deleted.
    final deleted = await _local.getByUuid(uuid);
    if (deleted != null) _pushOrQueue(uuid, 'delete', deleted.toMap());
  }

  // ── Sync helpers ──────────────────────────────────────────────────────────

  @override
  Future<List<Patient>> getPendingUpload(String doctorId) =>
      _local.getPendingUpload(doctorId);

  @override
  Future<void> markSynced(String uuid, String cloudId) =>
      _local.markSynced(uuid, cloudId);

  // ── Internal ──────────────────────────────────────────────────────────────

  void _pushOrQueue(
    String uuid,
    String operation,
    Map<String, dynamic> payload,
  ) {
    if (_onQueueWrite != null) {
      _onQueueWrite(uuid, operation, payload);
      return;
    }
    // Default: enqueue via SyncEngine (persisted, retried on reconnect).
    SyncEngine.instance.enqueue(
      entityType: 'patient',
      entityUuid: uuid,
      operation:  operation,
      payload:    payload,
    );
  }

}
