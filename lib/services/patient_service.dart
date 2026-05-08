import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:uuid/uuid.dart';

import '../repositories/i_patient_repository.dart';
import '../repositories/local/local_patient_repository.dart';
import '../repositories/repository_factory.dart';
import '../repositories/synced/synced_patient_repository.dart';
import 'session_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Domain model
// ─────────────────────────────────────────────────────────────────────────────

class Patient {
  // ── Local & cross-device identity ─────────────────────────────────────────
  final int?    id;       // SQLite rowid — local only
  final String  uuid;     // Stable cross-device identifier (UUIDv4)
  final String  doctorId; // Firebase Auth UID of the owning doctor

  // ── Sync metadata ─────────────────────────────────────────────────────────
  final String  syncStatus; // local_only | pending_upload | synced
  final String? cloudId;    // Firestore document ID once synced
  final DateTime? deletedAt; // soft-delete timestamp

  // ── Patient identity ──────────────────────────────────────────────────────
  final String  patientName;
  final String? patientId;

  // ── Demographics ──────────────────────────────────────────────────────────
  final DateTime? dateOfBirth;
  final DateTime? dateOfVisit;
  final String    mobileNo;
  final String?   email;
  final String?   address;

  // ── Referral ──────────────────────────────────────────────────────────────
  final String? doctorName;
  final String? referredBy;

  // ── Medical history ───────────────────────────────────────────────────────
  final String? smoking;
  final String? bloodGroup;
  final String? medication;
  final String? allergies;
  final String? menopause;
  final DateTime? lastMenstrualDate;
  final String? sexuallyActive;
  final String? contraception;
  final String? hivStatus;
  final String? pregnant;

  // ── Obstetric history ─────────────────────────────────────────────────────
  final int? liveBirths;
  final int? stillBirths;
  final int? abortions;
  final int? cesareans;
  final int? miscarriages;

  // ── Immunisation & testing ────────────────────────────────────────────────
  final String?   hpvVaccination;
  final String?   referralReason;
  final String?   symptoms;
  final String?   hpvTest;
  final String?   hpvResult;
  final DateTime? hpvDate;
  final String?   hcgTest;
  final DateTime? hcgDate;
  final double?   hcgLevel;

  // ── Clinical summary ──────────────────────────────────────────────────────
  final String? patientSummary;
  final String? chiefComplaint;
  final String? cytologyReport;
  final String? pathologicalReport;
  final String? colposcopyFindings;
  final String? finalImpression;
  final String? remarks;
  final String? treatmentProvided;
  final String? precautions;
  final String? examiningPhysician;

  // ── Legacy JSON fields (kept for backward compat) ─────────────────────────
  final Map<String, String>?  forensicExamination;
  final List<String>?         examinationImages;
  final Map<String, dynamic>? imageMetadata;

  // ── Audit timestamps ──────────────────────────────────────────────────────
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Patient({
    this.id,
    required this.uuid,
    required this.doctorId,
    this.syncStatus = 'local_only',
    this.cloudId,
    this.deletedAt,
    required this.patientName,
    this.patientId,
    this.dateOfBirth,
    this.dateOfVisit,
    required this.mobileNo,
    this.email,
    this.address,
    this.doctorName,
    this.referredBy,
    this.smoking,
    this.bloodGroup,
    this.medication,
    this.allergies,
    this.menopause,
    this.lastMenstrualDate,
    this.sexuallyActive,
    this.contraception,
    this.hivStatus,
    this.pregnant,
    this.liveBirths,
    this.stillBirths,
    this.abortions,
    this.cesareans,
    this.miscarriages,
    this.hpvVaccination,
    this.referralReason,
    this.symptoms,
    this.hpvTest,
    this.hpvResult,
    this.hpvDate,
    this.hcgTest,
    this.hcgDate,
    this.hcgLevel,
    this.patientSummary,
    this.chiefComplaint,
    this.cytologyReport,
    this.pathologicalReport,
    this.colposcopyFindings,
    this.finalImpression,
    this.remarks,
    this.treatmentProvided,
    this.precautions,
    this.examiningPhysician,
    this.forensicExamination,
    this.examinationImages,
    this.imageMetadata,
    this.createdAt,
    this.updatedAt,
  });

  Patient copyWith({
    int?    id,
    String? uuid,
    String? doctorId,
    String? syncStatus,
    String? cloudId,
    DateTime? deletedAt,
    String? patientName,
    String? patientId,
    DateTime? dateOfBirth,
    DateTime? dateOfVisit,
    String? mobileNo,
    String? email,
    String? address,
    String? doctorName,
    String? referredBy,
    String? smoking,
    String? bloodGroup,
    String? medication,
    String? allergies,
    String? menopause,
    DateTime? lastMenstrualDate,
    String? sexuallyActive,
    String? contraception,
    String? hivStatus,
    String? pregnant,
    int? liveBirths,
    int? stillBirths,
    int? abortions,
    int? cesareans,
    int? miscarriages,
    String? hpvVaccination,
    String? referralReason,
    String? symptoms,
    String? hpvTest,
    String? hpvResult,
    DateTime? hpvDate,
    String? hcgTest,
    DateTime? hcgDate,
    double? hcgLevel,
    String? patientSummary,
    String? chiefComplaint,
    String? cytologyReport,
    String? pathologicalReport,
    String? colposcopyFindings,
    String? finalImpression,
    String? remarks,
    String? treatmentProvided,
    String? precautions,
    String? examiningPhysician,
    Map<String, String>? forensicExamination,
    List<String>? examinationImages,
    Map<String, dynamic>? imageMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Patient(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    doctorId: doctorId ?? this.doctorId,
    syncStatus: syncStatus ?? this.syncStatus,
    cloudId: cloudId ?? this.cloudId,
    deletedAt: deletedAt ?? this.deletedAt,
    patientName: patientName ?? this.patientName,
    patientId: patientId ?? this.patientId,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    dateOfVisit: dateOfVisit ?? this.dateOfVisit,
    mobileNo: mobileNo ?? this.mobileNo,
    email: email ?? this.email,
    address: address ?? this.address,
    doctorName: doctorName ?? this.doctorName,
    referredBy: referredBy ?? this.referredBy,
    smoking: smoking ?? this.smoking,
    bloodGroup: bloodGroup ?? this.bloodGroup,
    medication: medication ?? this.medication,
    allergies: allergies ?? this.allergies,
    menopause: menopause ?? this.menopause,
    lastMenstrualDate: lastMenstrualDate ?? this.lastMenstrualDate,
    sexuallyActive: sexuallyActive ?? this.sexuallyActive,
    contraception: contraception ?? this.contraception,
    hivStatus: hivStatus ?? this.hivStatus,
    pregnant: pregnant ?? this.pregnant,
    liveBirths: liveBirths ?? this.liveBirths,
    stillBirths: stillBirths ?? this.stillBirths,
    abortions: abortions ?? this.abortions,
    cesareans: cesareans ?? this.cesareans,
    miscarriages: miscarriages ?? this.miscarriages,
    hpvVaccination: hpvVaccination ?? this.hpvVaccination,
    referralReason: referralReason ?? this.referralReason,
    symptoms: symptoms ?? this.symptoms,
    hpvTest: hpvTest ?? this.hpvTest,
    hpvResult: hpvResult ?? this.hpvResult,
    hpvDate: hpvDate ?? this.hpvDate,
    hcgTest: hcgTest ?? this.hcgTest,
    hcgDate: hcgDate ?? this.hcgDate,
    hcgLevel: hcgLevel ?? this.hcgLevel,
    patientSummary: patientSummary ?? this.patientSummary,
    chiefComplaint: chiefComplaint ?? this.chiefComplaint,
    cytologyReport: cytologyReport ?? this.cytologyReport,
    pathologicalReport: pathologicalReport ?? this.pathologicalReport,
    colposcopyFindings: colposcopyFindings ?? this.colposcopyFindings,
    finalImpression: finalImpression ?? this.finalImpression,
    remarks: remarks ?? this.remarks,
    treatmentProvided: treatmentProvided ?? this.treatmentProvided,
    precautions: precautions ?? this.precautions,
    examiningPhysician: examiningPhysician ?? this.examiningPhysician,
    forensicExamination: forensicExamination ?? this.forensicExamination,
    examinationImages: examinationImages ?? this.examinationImages,
    imageMetadata: imageMetadata ?? this.imageMetadata,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'doctor_id': doctorId,
      'sync_status': syncStatus,
      'cloud_id': cloudId,
      'deleted_at': deletedAt?.toIso8601String(),
      'patient_name': patientName,
      'patient_id': patientId,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'date_of_visit': dateOfVisit?.toIso8601String(),
      'mobile_no': mobileNo,
      'email': email,
      'address': address,
      'doctor_name': doctorName,
      'referred_by': referredBy,
      'smoking': smoking,
      'blood_group': bloodGroup,
      'medication': medication,
      'allergies': allergies,
      'menopause': menopause,
      'last_menstrual_date': lastMenstrualDate?.toIso8601String(),
      'sexually_active': sexuallyActive,
      'contraception': contraception,
      'hiv_status': hivStatus,
      'pregnant': pregnant,
      'live_births': liveBirths,
      'still_births': stillBirths,
      'abortions': abortions,
      'cesareans': cesareans,
      'miscarriages': miscarriages,
      'hpv_vaccination': hpvVaccination,
      'referral_reason': referralReason,
      'symptoms': symptoms,
      'hpv_test': hpvTest,
      'hpv_result': hpvResult,
      'hpv_date': hpvDate?.toIso8601String(),
      'hcg_test': hcgTest,
      'hcg_date': hcgDate?.toIso8601String(),
      'hcg_level': hcgLevel,
      'patient_summary': patientSummary,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'chief_complaint': chiefComplaint,
      'cytology_report': cytologyReport,
      'pathological_report': pathologicalReport,
      'colposcopy_findings': colposcopyFindings,
      'final_impression': finalImpression,
      'remarks': remarks,
      'treatment_provided': treatmentProvided,
      'precautions': precautions,
      'examining_physician': examiningPhysician,
      'forensic_examination': forensicExamination != null ? jsonEncode(forensicExamination) : null,
      'examination_images':   examinationImages   != null ? jsonEncode(examinationImages)   : null,
      'image_metadata':       imageMetadata        != null ? jsonEncode(imageMetadata)        : null,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try { return DateTime.parse(v as String); } catch (_) {}
      try { return DateFormat('yyyy-MM-dd').parse(v as String); } catch (_) {}
      return null;
    }

    Map<String, String>? decodeForensic(dynamic v) {
      if (v == null) return null;
      try {
        final d = v is String ? jsonDecode(v) : v;
        if (d is Map) return d.map((k, val) => MapEntry(k.toString(), val.toString()));
      } catch (_) {}
      return null;
    }

    List<String>? decodeImages(dynamic v) {
      if (v == null) return null;
      try {
        final d = v is String ? jsonDecode(v) : v;
        if (d is List) return d.map((e) => e.toString()).toList();
      } catch (_) {}
      return null;
    }

    Map<String, dynamic>? decodeMeta(dynamic v) {
      if (v == null) return null;
      try {
        final d = v is String ? jsonDecode(v) : v;
        if (d is Map) return d.map((k, val) => MapEntry(k.toString(), val));
      } catch (_) {}
      return null;
    }

    return Patient(
      id:           map['id'] as int?,
      uuid:         (map['uuid'] as String?) ?? '',
      doctorId:     (map['doctor_id'] as String?) ?? 'local_legacy',
      syncStatus:   (map['sync_status'] as String?) ?? 'local_only',
      cloudId:      map['cloud_id']  as String?,
      deletedAt:    parseDate(map['deleted_at']),
      patientName:  map['patient_name'] as String,
      patientId:    map['patient_id']   as String?,
      dateOfBirth:  parseDate(map['date_of_birth']),
      dateOfVisit:  parseDate(map['date_of_visit']),
      mobileNo:     map['mobile_no'] as String,
      email:        map['email']     as String?,
      address:      map['address']   as String?,
      doctorName:   map['doctor_name'] as String?,
      referredBy:   map['referred_by'] as String?,
      smoking:      map['smoking']     as String?,
      bloodGroup:   map['blood_group'] as String?,
      medication:   map['medication']  as String?,
      allergies:    map['allergies']   as String?,
      menopause:    map['menopause']   as String?,
      lastMenstrualDate: parseDate(map['last_menstrual_date']),
      sexuallyActive: map['sexually_active'] as String?,
      contraception:  map['contraception']   as String?,
      hivStatus:      map['hiv_status']      as String?,
      pregnant:       map['pregnant']        as String?,
      liveBirths:     map['live_births']  as int?,
      stillBirths:    map['still_births'] as int?,
      abortions:      map['abortions']    as int?,
      cesareans:      map['cesareans']    as int?,
      miscarriages:   map['miscarriages'] as int?,
      hpvVaccination: map['hpv_vaccination'] as String?,
      referralReason: map['referral_reason'] as String?,
      symptoms:       map['symptoms']        as String?,
      hpvTest:        map['hpv_test']        as String?,
      hpvResult:      map['hpv_result']      as String?,
      hpvDate:        parseDate(map['hpv_date']),
      hcgTest:        map['hcg_test']        as String?,
      hcgDate:        parseDate(map['hcg_date']),
      hcgLevel:       (map['hcg_level'] as num?)?.toDouble(),
      patientSummary: map['patient_summary'] as String?,
      createdAt:      parseDate(map['created_at']),
      updatedAt:      parseDate(map['updated_at']),
      chiefComplaint:     map['chief_complaint']     as String?,
      cytologyReport:     map['cytology_report']     as String?,
      pathologicalReport: map['pathological_report'] as String?,
      colposcopyFindings: map['colposcopy_findings'] as String?,
      finalImpression:    map['final_impression']    as String?,
      remarks:            map['remarks']             as String?,
      treatmentProvided:  map['treatment_provided']  as String?,
      precautions:        map['precautions']         as String?,
      examiningPhysician: map['examining_physician'] as String?,
      forensicExamination: decodeForensic(map['forensic_examination']),
      examinationImages:   decodeImages(map['examination_images']),
      imageMetadata:       decodeMeta(map['image_metadata']),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Service  (facade over IPatientRepository — screens never touch the repo directly)
// ─────────────────────────────────────────────────────────────────────────────

class PatientService {
  /// Inject a custom repository in tests or when cloud sync is enabled.
  /// Defaults to [RepositoryFactory.patientRepo()] which returns the
  /// implementation appropriate for the current sync mode.
  PatientService([IPatientRepository? repo])
      : _repo = repo ?? RepositoryFactory.patientRepo();

  final IPatientRepository _repo;

  // A typed reference to the local repo for operations that are always
  // local-only (legacy JSON image arrays, getById by SQLite rowid).
  // Works for both LocalPatientRepository and SyncedPatientRepository.
  LocalPatientRepository get _localRepo {
    if (_repo is LocalPatientRepository) return _repo as LocalPatientRepository;
    if (_repo is SyncedPatientRepository) return (_repo as SyncedPatientRepository).local;
    return LocalPatientRepository();
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  /// Returns all patients for the currently logged-in doctor.
  Future<List<Patient>> getAllPatients() =>
      _repo.getAll(SessionService.instance.currentDoctorId);

  Future<Patient?> getPatientByUuid(String uuid) =>
      _repo.getByUuid(uuid);

  Future<Patient?> getPatientById(int id) =>
      _localRepo.getById(id);

  // ── Writes ────────────────────────────────────────────────────────────────

  /// Creates a patient, automatically injecting uuid and doctorId from the
  /// current session if the caller has not set them.
  Future<Patient> createPatient(Patient patient) {
    final doctorId = SessionService.instance.currentDoctorId;
    final stamped = patient.copyWith(
      uuid:     patient.uuid.isEmpty     ? const Uuid().v4() : patient.uuid,
      doctorId: patient.doctorId.isEmpty ? doctorId          : patient.doctorId,
    );
    return _repo.create(stamped);
  }

  Future<Patient> updatePatient(Patient patient) =>
      _repo.update(patient);

  /// Soft-delete — sets deletedAt timestamp, never removes the row.
  Future<void> deletePatient(String uuid) => _repo.delete(uuid);

  // ── Legacy image helpers (kept for backward compat) ───────────────────────
  // These operate on the JSON arrays embedded in the patient row.
  // New code should use MediaFileService + IMediaRepository instead.

  Future<void> addExaminationImage(
    int patientId,
    String imagePath,
    Map<String, dynamic>? metadata,
  ) async {
    final patient = await getPatientById(patientId);
    if (patient == null) return;
    final images = List<String>.from(patient.examinationImages ?? [])
      ..add(imagePath);
    final meta = Map<String, dynamic>.from(patient.imageMetadata ?? {});
    if (metadata != null) meta[imagePath] = metadata;
    await _localRepo.updateExaminationImages(patientId, images, meta);
  }

  Future<void> removeExaminationImage(int patientId, String imagePath) async {
    final patient = await getPatientById(patientId);
    if (patient == null) return;
    final images = List<String>.from(patient.examinationImages ?? [])
      ..remove(imagePath);
    final meta = Map<String, dynamic>.from(patient.imageMetadata ?? {})
      ..remove(imagePath);
    await _localRepo.updateExaminationImages(patientId, images, meta);
  }

  Future<List<String>> getExaminationImages(int patientId) async {
    final patient = await getPatientById(patientId);
    return patient?.examinationImages ?? [];
  }
}
