import 'i_media_repository.dart';
import 'i_patient_repository.dart';
import 'local/local_media_repository.dart';
import 'local/local_patient_repository.dart';
import 'synced/synced_patient_repository.dart';
import 'synced/synced_media_repository.dart';

/// Returns the correct repository implementation for the current doctor.
///
/// - Cloud sync OFF → pure local (SQLite only, no network calls)
/// - Cloud sync ON  → synced (local-first write, background push to cloud)
///
/// Usage:
///   final patientRepo = RepositoryFactory.patientRepo();
///   final mediaRepo   = RepositoryFactory.mediaRepo();
class RepositoryFactory {
  RepositoryFactory._();

  static bool _cloudSyncEnabled = false;

  /// Called by [AuthService._postLoginInit] after fetching [DoctorConfig].
  static void configure({required bool cloudSyncEnabled}) {
    _cloudSyncEnabled = cloudSyncEnabled;
  }

  /// Returns the active [IPatientRepository].
  static IPatientRepository patientRepo() => _cloudSyncEnabled
      ? SyncedPatientRepository()
      : LocalPatientRepository();

  /// Returns the active [IMediaRepository].
  static IMediaRepository mediaRepo() => _cloudSyncEnabled
      ? SyncedMediaRepository()
      : LocalMediaRepository();
}
