import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'connection/connection.dart';
import 'tables/patients.dart';
import 'tables/users.dart';
import 'tables/media_files.dart';
import 'tables/sync_queue.dart';
import 'tables/tele_cases.dart';
import '../services/password_service.dart';
import 'daos/patient_dao.dart';
import 'daos/media_file_dao.dart';
import 'daos/tele_case_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Patients, Users, MediaFiles, SyncQueue, TeleCases],
  daos: [PatientDao, MediaFileDao, TeleCaseDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedAdminUser();
    },
    onUpgrade: (m, from, to) async {
      // ── v1 → v2 ──────────────────────────────────────────────────────
      // Adds cloud-sync columns to the existing patients table and creates
      // the two new tables (media_files, sync_queue).
      // All new columns are nullable so existing rows remain valid.
      if (from < 2) {
        // Check and add columns only if they don't exist
        final uuidExists =
            await customSelect(
              'SELECT COUNT(*) as count FROM pragma_table_info(\'patients\') WHERE name=\'uuid\'',
            ).getSingle();
        if (uuidExists.read<int>('count') == 0) {
          await customStatement(
            'ALTER TABLE "patients" ADD COLUMN "uuid" TEXT',
          );
        }

        final doctorIdExists =
            await customSelect(
              'SELECT COUNT(*) as count FROM pragma_table_info(\'patients\') WHERE name=\'doctor_id\'',
            ).getSingle();
        if (doctorIdExists.read<int>('count') == 0) {
          await customStatement(
            'ALTER TABLE "patients" ADD COLUMN "doctor_id" TEXT',
          );
        }

        final syncStatusExists =
            await customSelect(
              'SELECT COUNT(*) as count FROM pragma_table_info(\'patients\') WHERE name=\'sync_status\'',
            ).getSingle();
        if (syncStatusExists.read<int>('count') == 0) {
          await customStatement(
            'ALTER TABLE "patients" ADD COLUMN "sync_status" TEXT NOT NULL DEFAULT \'local_only\'',
          );
        }

        final cloudIdExists =
            await customSelect(
              'SELECT COUNT(*) as count FROM pragma_table_info(\'patients\') WHERE name=\'cloud_id\'',
            ).getSingle();
        if (cloudIdExists.read<int>('count') == 0) {
          await customStatement(
            'ALTER TABLE "patients" ADD COLUMN "cloud_id" TEXT',
          );
        }

        final deletedAtExists =
            await customSelect(
              'SELECT COUNT(*) as count FROM pragma_table_info(\'patients\') WHERE name=\'deleted_at\'',
            ).getSingle();
        if (deletedAtExists.read<int>('count') == 0) {
          await customStatement(
            'ALTER TABLE "patients" ADD COLUMN "deleted_at" TEXT',
          );
        }

        // Create new tables if they don't exist
        final mediaFilesExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM sqlite_master WHERE type='table' AND name='media_files'",
            ).getSingle();
        if (mediaFilesExists.read<int>('count') == 0) {
          await m.createTable(mediaFiles);
        }

        final syncQueueExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM sqlite_master WHERE type='table' AND name='sync_queue'",
            ).getSingle();
        if (syncQueueExists.read<int>('count') == 0) {
          await m.createTable(syncQueue);
        }

        // Back-fill uuid and doctorId for every pre-existing patient row if not already set
        const uuidGen = Uuid();
        final existingRows = await customSelect(
          'SELECT id FROM patients WHERE uuid IS NULL',
        ).get();
        for (final row in existingRows) {
          final id = row.read<int>('id');
          await customStatement(
            'UPDATE patients SET uuid = ?, doctor_id = ?, sync_status = ? WHERE id = ?',
            [uuidGen.v4(), 'local_legacy', 'local_only', id],
          );
        }

        // Create unique index if it doesn't exist
        final indexExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM sqlite_master WHERE type='index' AND name='idx_patients_uuid'",
            ).getSingle();
        if (indexExists.read<int>('count') == 0) {
          await customStatement(
            'CREATE UNIQUE INDEX idx_patients_uuid ON "patients" ("uuid")',
          );
        }
      }

      // ── v2 → v3 ──────────────────────────────────────────────────────
      // Adds the tele_cases table for the credit-based tele-reporting
      // workflow. Existing data is unaffected.
      if (from < 3) {
        final teleCasesExists =
            await customSelect(
              "SELECT COUNT(*) as count FROM sqlite_master WHERE type='table' AND name='tele_cases'",
            ).getSingle();
        if (teleCasesExists.read<int>('count') == 0) {
          await m.createTable(teleCases);
        }
      }
    },
    beforeOpen: (details) async {
      // Enable WAL mode for better concurrent read performance.
      await customStatement('PRAGMA journal_mode=WAL;');
      // Enforce foreign-key constraints at runtime.
      await customStatement('PRAGMA foreign_keys=ON;');
    },
  );

  Future<void> _seedAdminUser() async {
    final now = DateTime.now().toIso8601String();
    await into(users).insert(
      UsersCompanion.insert(
        fullName: 'System Administrator',
        email: 'admin@griva.com',
        password: PasswordService.hashPassword('admin123'),
        medicalLicense: 'ADMIN001',
        hospital: 'Griva Medical Systems',
        role: const Value('admin'),
        isActive: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}
