import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/patients.dart';
import '../../services/patient_service.dart' show Patient;

part 'patient_dao.g.dart';

@DriftAccessor(tables: [Patients])
class PatientDao extends DatabaseAccessor<AppDatabase> with _$PatientDaoMixin {
  PatientDao(super.db);

  // ── Queries ───────────────────────────────────────────────────────────────

  /// All non-deleted patients belonging to [doctorId], newest first.
  Future<List<Patient>> getAllPatients(String doctorId) async {
    final rows = await (select(patients)
          ..where((t) => t.doctorId.equals(doctorId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    return rows.map(_rowToPatient).toList();
  }

  Future<Patient?> getPatientByUuid(String uuid) async {
    final row = await (select(patients)
          ..where((t) => t.uuid.equals(uuid) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : _rowToPatient(row);
  }

  Future<Patient?> getPatientById(int id) async {
    final row = await (select(patients)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : _rowToPatient(row);
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  Future<Patient> createPatient(Patient patient) async {
    final now = DateTime.now().toIso8601String();
    final id  = await into(patients).insert(
      _patientToCompanion(patient, createdAt: now, updatedAt: now),
    );
    final created = await getPatientById(id);
    if (created == null) throw StateError('Patient insert succeeded but row $id not found');
    return created;
  }

  Future<Patient> updatePatient(Patient patient) async {
    final now = DateTime.now().toIso8601String();
    await (update(patients)..where((t) => t.uuid.equals(patient.uuid)))
        .write(_patientToCompanion(patient, updatedAt: now));
    final updated = await getPatientByUuid(patient.uuid);
    if (updated == null) throw StateError('Patient update succeeded but uuid ${patient.uuid} not found');
    return updated;
  }

  /// Soft-delete: sets deletedAt so the row is excluded from normal queries
  /// but remains for sync propagation to other devices.
  Future<void> softDeletePatient(String uuid) async {
    final now = DateTime.now().toIso8601String();
    await (update(patients)..where((t) => t.uuid.equals(uuid))).write(
      PatientsCompanion(
        deletedAt:  Value(now),
        syncStatus: const Value('pending_upload'),
        updatedAt:  Value(now),
      ),
    );
  }

  Future<void> updateExaminationImages(
    int id,
    List<String> imagePaths,
    Map<String, dynamic>? metadata,
  ) async {
    final now = DateTime.now().toIso8601String();
    await (update(patients)..where((t) => t.id.equals(id))).write(
      PatientsCompanion(
        examinationImages: Value(jsonEncode(imagePaths)),
        imageMetadata:     Value(metadata != null ? jsonEncode(metadata) : null),
        syncStatus:        const Value('pending_upload'),
        updatedAt:         Value(now),
      ),
    );
  }

  // ── Sync helpers ──────────────────────────────────────────────────────────

  Future<List<Patient>> getPendingUpload(String doctorId) async {
    final rows = await (select(patients)
          ..where((t) =>
              t.doctorId.equals(doctorId) &
              t.syncStatus.equals('pending_upload')))
        .get();
    return rows.map(_rowToPatient).toList();
  }

  Future<void> markSynced(String uuid, String cloudId) async {
    final now = DateTime.now().toIso8601String();
    await (update(patients)..where((t) => t.uuid.equals(uuid))).write(
      PatientsCompanion(
        syncStatus: const Value('synced'),
        cloudId:    Value(cloudId),
        updatedAt:  Value(now),
      ),
    );
  }

  // ── Mapping ───────────────────────────────────────────────────────────────

  Patient _rowToPatient(PatientRow r) {
    DateTime? d(String? v) {
      if (v == null) return null;
      try { return DateTime.parse(v); } catch (_) { return null; }
    }

    Map<String, String>? decodeForensic(String? json) {
      if (json == null) return null;
      try {
        final decoded = jsonDecode(json);
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
      } catch (_) {}
      return null;
    }

    List<String>? decodeImages(String? json) {
      if (json == null) return null;
      try {
        final decoded = jsonDecode(json);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return null;
    }

    Map<String, dynamic>? decodeMeta(String? json) {
      if (json == null) return null;
      try {
        final decoded = jsonDecode(json);
        if (decoded is Map) return decoded.map((k, v) => MapEntry(k.toString(), v));
      } catch (_) {}
      return null;
    }

    return Patient(
      id:           r.id,
      uuid:         r.uuid,
      doctorId:     r.doctorId,
      syncStatus:   r.syncStatus,
      cloudId:      r.cloudId,
      deletedAt:    d(r.deletedAt),
      patientName:  r.patientName,
      patientId:    r.patientId,
      dateOfBirth:  d(r.dateOfBirth),
      dateOfVisit:  d(r.dateOfVisit),
      mobileNo:     r.mobileNo,
      email:        r.email,
      address:      r.address,
      doctorName:   r.doctorName,
      referredBy:   r.referredBy,
      smoking:      r.smoking,
      bloodGroup:   r.bloodGroup,
      medication:   r.medication,
      allergies:    r.allergies,
      menopause:    r.menopause,
      lastMenstrualDate: d(r.lastMenstrualDate),
      sexuallyActive:    r.sexuallyActive,
      contraception:     r.contraception,
      hivStatus:         r.hivStatus,
      pregnant:          r.pregnant,
      liveBirths:   r.liveBirths,
      stillBirths:  r.stillBirths,
      abortions:    r.abortions,
      cesareans:    r.cesareans,
      miscarriages: r.miscarriages,
      hpvVaccination: r.hpvVaccination,
      referralReason: r.referralReason,
      symptoms:       r.symptoms,
      hpvTest:        r.hpvTest,
      hpvResult:      r.hpvResult,
      hpvDate:        d(r.hpvDate),
      hcgTest:        r.hcgTest,
      hcgDate:        d(r.hcgDate),
      hcgLevel:       r.hcgLevel,
      patientSummary:     r.patientSummary,
      chiefComplaint:     r.chiefComplaint,
      cytologyReport:     r.cytologyReport,
      pathologicalReport: r.pathologicalReport,
      colposcopyFindings: r.colposcopyFindings,
      finalImpression:    r.finalImpression,
      remarks:            r.remarks,
      treatmentProvided:  r.treatmentProvided,
      precautions:        r.precautions,
      examiningPhysician: r.examiningPhysician,
      forensicExamination: decodeForensic(r.forensicExamination),
      examinationImages:   decodeImages(r.examinationImages),
      imageMetadata:       decodeMeta(r.imageMetadata),
      createdAt: d(r.createdAt),
      updatedAt: d(r.updatedAt),
    );
  }

  PatientsCompanion _patientToCompanion(
    Patient p, {
    String? createdAt,
    String? updatedAt,
  }) {
    return PatientsCompanion(
      uuid:         Value(p.uuid),
      doctorId:     Value(p.doctorId),
      syncStatus:   Value(p.syncStatus),
      cloudId:      Value(p.cloudId),
      deletedAt:    Value(p.deletedAt?.toIso8601String()),
      patientName:  Value(p.patientName),
      patientId:    Value(p.patientId),
      dateOfBirth:  Value(p.dateOfBirth?.toIso8601String()),
      dateOfVisit:  Value(p.dateOfVisit?.toIso8601String()),
      mobileNo:     Value(p.mobileNo),
      email:        Value(p.email),
      address:      Value(p.address),
      doctorName:   Value(p.doctorName),
      referredBy:   Value(p.referredBy),
      smoking:      Value(p.smoking),
      bloodGroup:   Value(p.bloodGroup),
      medication:   Value(p.medication),
      allergies:    Value(p.allergies),
      menopause:    Value(p.menopause),
      lastMenstrualDate: Value(p.lastMenstrualDate?.toIso8601String()),
      sexuallyActive:    Value(p.sexuallyActive),
      contraception:     Value(p.contraception),
      hivStatus:         Value(p.hivStatus),
      pregnant:          Value(p.pregnant),
      liveBirths:   Value(p.liveBirths),
      stillBirths:  Value(p.stillBirths),
      abortions:    Value(p.abortions),
      cesareans:    Value(p.cesareans),
      miscarriages: Value(p.miscarriages),
      hpvVaccination: Value(p.hpvVaccination),
      referralReason: Value(p.referralReason),
      symptoms:       Value(p.symptoms),
      hpvTest:        Value(p.hpvTest),
      hpvResult:      Value(p.hpvResult),
      hpvDate:        Value(p.hpvDate?.toIso8601String()),
      hcgTest:        Value(p.hcgTest),
      hcgDate:        Value(p.hcgDate?.toIso8601String()),
      hcgLevel:       Value(p.hcgLevel),
      patientSummary:     Value(p.patientSummary),
      chiefComplaint:     Value(p.chiefComplaint),
      cytologyReport:     Value(p.cytologyReport),
      pathologicalReport: Value(p.pathologicalReport),
      colposcopyFindings: Value(p.colposcopyFindings),
      finalImpression:    Value(p.finalImpression),
      remarks:            Value(p.remarks),
      treatmentProvided:  Value(p.treatmentProvided),
      precautions:        Value(p.precautions),
      examiningPhysician: Value(p.examiningPhysician),
      forensicExamination: Value(p.forensicExamination != null
          ? jsonEncode(p.forensicExamination) : null),
      examinationImages: Value(p.examinationImages != null
          ? jsonEncode(p.examinationImages) : null),
      imageMetadata: Value(p.imageMetadata != null
          ? jsonEncode(p.imageMetadata) : null),
      createdAt: Value(createdAt ?? p.createdAt?.toIso8601String()),
      updatedAt: Value(updatedAt ?? p.updatedAt?.toIso8601String()),
    );
  }
}
