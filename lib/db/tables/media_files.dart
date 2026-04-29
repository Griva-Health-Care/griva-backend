import 'package:drift/drift.dart';

/// Stores every media file (image, video, PDF) attached to a patient.
/// Replaces the JSON arrays previously stored directly on the patient row,
/// giving each file its own sync lifecycle and cloud URL.
@DataClassName('MediaFileRow')
class MediaFiles extends Table {
  // ── Local primary key ─────────────────────────────────────────────────────
  IntColumn get id => integer().autoIncrement()();

  // ── Cross-device identity ─────────────────────────────────────────────────
  TextColumn get uuid => text().unique()();

  // ── Ownership ─────────────────────────────────────────────────────────────
  // References Patients.uuid — not a DB-level FK so migrations stay simple,
  // but enforced in the application layer.
  TextColumn get patientUuid => text().named('patient_uuid')();
  TextColumn get doctorId    => text().named('doctor_id')();

  // ── File classification ───────────────────────────────────────────────────
  // image | video | pdf
  TextColumn get fileType => text().named('file_type')();

  // ── Local storage ─────────────────────────────────────────────────────────
  // Absolute path on this device. Null if file was received from cloud and
  // hasn't been downloaded yet.
  TextColumn get localPath => text().named('local_path').nullable()();

  // ── Cloud storage ─────────────────────────────────────────────────────────
  // Firebase Storage download URL. Null until the file has been uploaded.
  TextColumn get cloudUrl => text().named('cloud_url').nullable()();

  // ── File metadata ─────────────────────────────────────────────────────────
  TextColumn get fileName  => text().named('file_name')();
  TextColumn get mimeType  => text().named('mime_type').nullable()();
  IntColumn  get fileSize  => integer().named('file_size').nullable()();

  // MD5/SHA-256 of file bytes — used to skip re-uploading identical files.
  TextColumn get checksum => text().nullable()();

  // ── Sync state ────────────────────────────────────────────────────────────
  // local_only | pending_upload | uploading | synced | error
  TextColumn get syncStatus => text().named('sync_status').withDefault(const Constant('local_only'))();

  // Number of failed upload attempts — used for exponential back-off.
  IntColumn get uploadAttempts => integer().named('upload_attempts').withDefault(const Constant(0))();

  // ── Soft delete ───────────────────────────────────────────────────────────
  TextColumn get deletedAt => text().named('deleted_at').nullable()();

  // ── Timestamps ───────────────────────────────────────────────────────────
  TextColumn get capturedAt => text().named('captured_at').nullable()();
  TextColumn get createdAt  => text().named('created_at').nullable()();
  TextColumn get updatedAt  => text().named('updated_at').nullable()();
}
