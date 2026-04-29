import 'package:drift/drift.dart';

/// Tracks every local write that has not yet been pushed to Firestore.
///
/// When the device is offline (e.g. on the GRIVAVISION hotspot) all creates,
/// updates, and soft-deletes are recorded here. SyncService processes this
/// queue whenever internet is available and removes entries on success.
@DataClassName('SyncQueueRow')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  // ── What changed ──────────────────────────────────────────────────────────
  // patient | media_file
  TextColumn get entityType => text().named('entity_type')();

  // UUID of the changed entity (Patients.uuid or MediaFiles.uuid).
  TextColumn get entityUuid => text().named('entity_uuid')();

  // create | update | delete
  TextColumn get operation => text()();

  // Full JSON snapshot of the entity at the time of the change.
  // SyncService uses this to push the exact state even if the row is later
  // modified again before sync completes.
  TextColumn get payload => text()();

  // ── Retry tracking ────────────────────────────────────────────────────────
  IntColumn  get attempts       => integer().withDefault(const Constant(0))();
  TextColumn get lastAttemptAt  => text().named('last_attempt_at').nullable()();

  // error | null — last error message for diagnostics.
  TextColumn get lastError => text().named('last_error').nullable()();

  // ── Timestamps ────────────────────────────────────────────────────────────
  TextColumn get createdAt => text().named('created_at')();
}
