import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/media_files.dart';
import '../../repositories/media_file.dart';

part 'media_file_dao.g.dart';

@DriftAccessor(tables: [MediaFiles])
class MediaFileDao extends DatabaseAccessor<AppDatabase>
    with _$MediaFileDaoMixin {
  MediaFileDao(super.db);

  // ── Queries ───────────────────────────────────────────────────────────────

  Future<List<MediaFile>> getForPatient(String patientUuid) async {
    final rows = await (select(mediaFiles)
          ..where((t) =>
              t.patientUuid.equals(patientUuid) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_rowToModel).toList();
  }

  Future<MediaFile?> getByUuid(String uuid) async {
    final row = await (select(mediaFiles)
          ..where((t) => t.uuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : _rowToModel(row);
  }

  Future<MediaFile?> getById(int id) async {
    final row = await (select(mediaFiles)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : _rowToModel(row);
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  Future<MediaFile> createFile(MediaFile file) async {
    final now = DateTime.now().toIso8601String();
    final id  = await into(mediaFiles).insert(
      _modelToCompanion(file, createdAt: now, updatedAt: now),
    );
    return (await getById(id))!;
  }

  Future<MediaFile> updateFile(MediaFile file) async {
    final now = DateTime.now().toIso8601String();
    await (update(mediaFiles)..where((t) => t.uuid.equals(file.uuid)))
        .write(_modelToCompanion(file, updatedAt: now));
    return (await getByUuid(file.uuid))!;
  }

  Future<void> softDelete(String uuid) async {
    final now = DateTime.now().toIso8601String();
    await (update(mediaFiles)..where((t) => t.uuid.equals(uuid))).write(
      MediaFilesCompanion(
        deletedAt:  Value(now),
        syncStatus: const Value('pending_upload'),
        updatedAt:  Value(now),
      ),
    );
  }

  // ── Sync helpers ──────────────────────────────────────────────────────────

  Future<List<MediaFile>> getPendingUpload(String doctorId) async {
    final rows = await (select(mediaFiles)
          ..where((t) =>
              t.doctorId.equals(doctorId) &
              t.syncStatus.equals('pending_upload')))
        .get();
    return rows.map(_rowToModel).toList();
  }

  Future<void> markSynced(String uuid, String cloudUrl) async {
    final now = DateTime.now().toIso8601String();
    await (update(mediaFiles)..where((t) => t.uuid.equals(uuid))).write(
      MediaFilesCompanion(
        syncStatus: const Value('synced'),
        cloudUrl:   Value(cloudUrl),
        updatedAt:  Value(now),
      ),
    );
  }

  Future<void> incrementUploadAttempts(String uuid) async {
    final row = await (select(mediaFiles)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    if (row == null) return;
    final now = DateTime.now().toIso8601String();
    await (update(mediaFiles)..where((t) => t.uuid.equals(uuid))).write(
      MediaFilesCompanion(
        uploadAttempts: Value(row.uploadAttempts + 1),
        updatedAt:      Value(now),
      ),
    );
  }

  // ── Mapping ───────────────────────────────────────────────────────────────

  MediaFile _rowToModel(MediaFileRow r) {
    DateTime? d(String? v) {
      if (v == null) return null;
      try { return DateTime.parse(v); } catch (_) { return null; }
    }

    return MediaFile(
      id:             r.id,
      uuid:           r.uuid,
      patientUuid:    r.patientUuid,
      doctorId:       r.doctorId,
      fileType:       r.fileType,
      localPath:      r.localPath,
      cloudUrl:       r.cloudUrl,
      fileName:       r.fileName,
      mimeType:       r.mimeType,
      fileSize:       r.fileSize,
      checksum:       r.checksum,
      syncStatus:     r.syncStatus,
      uploadAttempts: r.uploadAttempts,
      deletedAt:      d(r.deletedAt),
      capturedAt:     d(r.capturedAt),
      createdAt:      d(r.createdAt),
      updatedAt:      d(r.updatedAt),
    );
  }

  MediaFilesCompanion _modelToCompanion(
    MediaFile f, {
    String? createdAt,
    String? updatedAt,
  }) {
    return MediaFilesCompanion(
      uuid:           Value(f.uuid),
      patientUuid:    Value(f.patientUuid),
      doctorId:       Value(f.doctorId),
      fileType:       Value(f.fileType),
      localPath:      Value(f.localPath),
      cloudUrl:       Value(f.cloudUrl),
      fileName:       Value(f.fileName),
      mimeType:       Value(f.mimeType),
      fileSize:       Value(f.fileSize),
      checksum:       Value(f.checksum),
      syncStatus:     Value(f.syncStatus),
      uploadAttempts: Value(f.uploadAttempts),
      deletedAt:      Value(f.deletedAt?.toIso8601String()),
      capturedAt:     Value(f.capturedAt?.toIso8601String()),
      createdAt:      Value(createdAt ?? f.createdAt?.toIso8601String()),
      updatedAt:      Value(updatedAt ?? f.updatedAt?.toIso8601String()),
    );
  }
}
