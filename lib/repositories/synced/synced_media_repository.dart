import 'package:flutter/foundation.dart';

import '../cloud/firebase_media_repository.dart';
import '../i_media_repository.dart';
import '../local/local_media_repository.dart';
import '../media_file.dart';

/// Local-first media repository with background cloud upload.
///
/// Binary files are saved to local storage immediately.  A background task
/// then uploads them to Firebase Storage and updates the cloudUrl.
/// When offline uploads are deferred; [SyncEngine] retries them.
class SyncedMediaRepository implements IMediaRepository {
  SyncedMediaRepository({
    LocalMediaRepository?    local,
    FirebaseMediaRepository? cloud,
  })  : _local = local ?? LocalMediaRepository(),
        _cloud = cloud ?? FirebaseMediaRepository();

  final LocalMediaRepository    _local;
  final FirebaseMediaRepository _cloud;

  // ── Queries (always local) ────────────────────────────────────────────────

  @override
  Future<List<MediaFile>> getForPatient(String patientUuid) =>
      _local.getForPatient(patientUuid);

  @override
  Future<MediaFile?> getByUuid(String uuid) => _local.getByUuid(uuid);

  // ── Writes (local-first, upload in background) ────────────────────────────

  @override
  Future<MediaFile> create(MediaFile file) async {
    // Mark as pending so SyncEngine knows to upload it.
    final pending = file.copyWith(syncStatus: 'pending_upload');
    final saved   = await _local.create(pending);
    _uploadInBackground(saved);
    return saved;
  }

  @override
  Future<MediaFile> update(MediaFile file) async {
    final saved = await _local.update(file);
    _uploadInBackground(saved);
    return saved;
  }

  @override
  Future<void> delete(String uuid) async {
    await _local.delete(uuid);
    // Tombstone is propagated by SyncEngine on next flush.
  }

  // ── Sync helpers ──────────────────────────────────────────────────────────

  @override
  Future<List<MediaFile>> getPendingUpload(String doctorId) =>
      _local.getPendingUpload(doctorId);

  @override
  Future<void> markSynced(String uuid, String cloudUrl) =>
      _local.markSynced(uuid, cloudUrl);

  @override
  Future<void> incrementUploadAttempts(String uuid) =>
      _local.incrementUploadAttempts(uuid);

  // ── Internal ──────────────────────────────────────────────────────────────

  void _uploadInBackground(MediaFile file) {
    if (file.localPath == null) return;
    Future(() async {
      try {
        final uploaded = await _cloud.create(file);
        if (uploaded.cloudUrl != null) {
          await _local.markSynced(file.uuid, uploaded.cloudUrl!);
          debugPrint('[SYNC] Uploaded media ${file.uuid} → ${uploaded.cloudUrl}');
        } else {
          await _local.incrementUploadAttempts(file.uuid);
          debugPrint('[SYNC] Upload produced no URL for ${file.uuid} — will retry');
        }
      } catch (e) {
        await _local.incrementUploadAttempts(file.uuid);
        debugPrint('[SYNC] Upload failed for ${file.uuid}: $e — will retry');
      }
    });
  }
}
