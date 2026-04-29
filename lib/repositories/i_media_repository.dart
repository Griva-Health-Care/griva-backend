import 'media_file.dart';

/// Contract that every media-file back-end must satisfy.
abstract interface class IMediaRepository {
  // ── Queries ─────────────────────────────────────────────────────────────────

  /// All non-deleted files belonging to [patientUuid].
  Future<List<MediaFile>> getForPatient(String patientUuid);

  /// Look up by UUID.  Returns null if not found.
  Future<MediaFile?> getByUuid(String uuid);

  // ── Writes ──────────────────────────────────────────────────────────────────

  /// Persist a new media file record and return the saved row.
  Future<MediaFile> create(MediaFile file);

  /// Update an existing record (matched by [MediaFile.uuid]).
  Future<MediaFile> update(MediaFile file);

  /// Soft-delete a media file record.
  Future<void> delete(String uuid);

  // ── Sync helpers ─────────────────────────────────────────────────────────────

  /// Files not yet uploaded to cloud storage.
  Future<List<MediaFile>> getPendingUpload(String doctorId);

  /// Mark a file as synced and store its cloud download URL.
  Future<void> markSynced(String uuid, String cloudUrl);

  /// Increment the upload attempt counter (used for back-off logic).
  Future<void> incrementUploadAttempts(String uuid);
}
