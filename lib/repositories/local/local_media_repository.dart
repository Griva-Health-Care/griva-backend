import '../../db/app_database.dart';
import '../../db/daos/media_file_dao.dart';
import '../i_media_repository.dart';
import '../media_file.dart';

/// SQLite-backed implementation of [IMediaRepository].
class LocalMediaRepository implements IMediaRepository {
  LocalMediaRepository() : _dao = MediaFileDao(AppDatabase());

  final MediaFileDao _dao;

  @override
  Future<List<MediaFile>> getForPatient(String patientUuid) =>
      _dao.getForPatient(patientUuid);

  @override
  Future<MediaFile?> getByUuid(String uuid) => _dao.getByUuid(uuid);

  // Convenience for screens that hold the local SQLite id.
  Future<MediaFile?> getById(int id) => _dao.getById(id);

  @override
  Future<MediaFile> create(MediaFile file) => _dao.createFile(file);

  @override
  Future<MediaFile> update(MediaFile file) => _dao.updateFile(file);

  @override
  Future<void> delete(String uuid) => _dao.softDelete(uuid);

  @override
  Future<List<MediaFile>> getPendingUpload(String doctorId) =>
      _dao.getPendingUpload(doctorId);

  @override
  Future<void> markSynced(String uuid, String cloudUrl) =>
      _dao.markSynced(uuid, cloudUrl);

  @override
  Future<void> incrementUploadAttempts(String uuid) =>
      _dao.incrementUploadAttempts(uuid);
}
