import '../../db/app_database.dart';
import '../../db/daos/patient_dao.dart';
import '../../services/patient_service.dart' show Patient;
import '../i_patient_repository.dart';

/// SQLite-backed implementation of [IPatientRepository].
///
/// This is the only implementation used while the doctor has not purchased
/// cloud sync.  When cloud sync is enabled, a [SyncedPatientRepository]
/// (to be built in Phase 5) will wrap this class and push changes upstream.
class LocalPatientRepository implements IPatientRepository {
  LocalPatientRepository() : _dao = PatientDao(AppDatabase.instance);

  final PatientDao _dao;

  @override
  Future<List<Patient>> getAll(String doctorId) =>
      _dao.getAllPatients(doctorId);

  @override
  Future<Patient?> getByUuid(String uuid) =>
      _dao.getPatientByUuid(uuid);

  // Convenience for screens that hold the local SQLite id.
  Future<Patient?> getById(int id) => _dao.getPatientById(id);

  @override
  Future<Patient> create(Patient patient) => _dao.createPatient(patient);

  @override
  Future<Patient> update(Patient patient) => _dao.updatePatient(patient);

  @override
  Future<void> delete(String uuid) => _dao.softDeletePatient(uuid);

  @override
  Future<List<Patient>> getPendingUpload(String doctorId) =>
      _dao.getPendingUpload(doctorId);

  @override
  Future<void> markSynced(String uuid, String cloudId) =>
      _dao.markSynced(uuid, cloudId);

  // ── Legacy image helpers ──────────────────────────────────────────────────
  Future<void> updateExaminationImages(
    int id,
    List<String> imagePaths,
    Map<String, dynamic>? metadata,
  ) => _dao.updateExaminationImages(id, imagePaths, metadata);
}
