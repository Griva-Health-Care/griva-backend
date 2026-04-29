import '../services/patient_service.dart' show Patient;

/// Contract that every patient-data back-end must satisfy.
///
/// Screens and services program against this interface.  Swapping from local
/// SQLite to Firestore (or anything else) is a matter of changing which
/// concrete class gets injected — nothing else changes.
abstract interface class IPatientRepository {
  // ── Queries ─────────────────────────────────────────────────────────────────

  /// All non-deleted patients belonging to [doctorId], newest first.
  Future<List<Patient>> getAll(String doctorId);

  /// Look up by the stable cross-device UUID.  Returns null if not found.
  Future<Patient?> getByUuid(String uuid);

  // ── Writes ──────────────────────────────────────────────────────────────────

  /// Persist a new patient and return the saved record (with id / timestamps).
  Future<Patient> create(Patient patient);

  /// Overwrite an existing patient (matched by [Patient.uuid]).
  Future<Patient> update(Patient patient);

  /// Soft-delete: marks [uuid] with a deletedAt timestamp.
  /// The row is retained for sync propagation; normal queries exclude it.
  Future<void> delete(String uuid);

  // ── Sync helpers ─────────────────────────────────────────────────────────────

  /// Patients whose local changes have not yet been pushed to the cloud.
  Future<List<Patient>> getPendingUpload(String doctorId);

  /// Mark a patient as synced and record its cloud-assigned ID.
  Future<void> markSynced(String uuid, String cloudId);
}
