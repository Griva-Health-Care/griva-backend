// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PatientsTable extends Patients
    with TableInfo<$PatientsTable, PatientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _doctorIdMeta = const VerificationMeta(
    'doctorId',
  );
  @override
  late final GeneratedColumn<String> doctorId = GeneratedColumn<String>(
    'doctor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_only'),
  );
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _patientNameMeta = const VerificationMeta(
    'patientName',
  );
  @override
  late final GeneratedColumn<String> patientName = GeneratedColumn<String>(
    'patient_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<String> dateOfBirth = GeneratedColumn<String>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOfVisitMeta = const VerificationMeta(
    'dateOfVisit',
  );
  @override
  late final GeneratedColumn<String> dateOfVisit = GeneratedColumn<String>(
    'date_of_visit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mobileNoMeta = const VerificationMeta(
    'mobileNo',
  );
  @override
  late final GeneratedColumn<String> mobileNo = GeneratedColumn<String>(
    'mobile_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doctorNameMeta = const VerificationMeta(
    'doctorName',
  );
  @override
  late final GeneratedColumn<String> doctorName = GeneratedColumn<String>(
    'doctor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referredByMeta = const VerificationMeta(
    'referredBy',
  );
  @override
  late final GeneratedColumn<String> referredBy = GeneratedColumn<String>(
    'referred_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _smokingMeta = const VerificationMeta(
    'smoking',
  );
  @override
  late final GeneratedColumn<String> smoking = GeneratedColumn<String>(
    'smoking',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bloodGroupMeta = const VerificationMeta(
    'bloodGroup',
  );
  @override
  late final GeneratedColumn<String> bloodGroup = GeneratedColumn<String>(
    'blood_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medicationMeta = const VerificationMeta(
    'medication',
  );
  @override
  late final GeneratedColumn<String> medication = GeneratedColumn<String>(
    'medication',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allergiesMeta = const VerificationMeta(
    'allergies',
  );
  @override
  late final GeneratedColumn<String> allergies = GeneratedColumn<String>(
    'allergies',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _menopauseMeta = const VerificationMeta(
    'menopause',
  );
  @override
  late final GeneratedColumn<String> menopause = GeneratedColumn<String>(
    'menopause',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMenstrualDateMeta = const VerificationMeta(
    'lastMenstrualDate',
  );
  @override
  late final GeneratedColumn<String> lastMenstrualDate =
      GeneratedColumn<String>(
        'last_menstrual_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sexuallyActiveMeta = const VerificationMeta(
    'sexuallyActive',
  );
  @override
  late final GeneratedColumn<String> sexuallyActive = GeneratedColumn<String>(
    'sexually_active',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contraceptionMeta = const VerificationMeta(
    'contraception',
  );
  @override
  late final GeneratedColumn<String> contraception = GeneratedColumn<String>(
    'contraception',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hivStatusMeta = const VerificationMeta(
    'hivStatus',
  );
  @override
  late final GeneratedColumn<String> hivStatus = GeneratedColumn<String>(
    'hiv_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pregnantMeta = const VerificationMeta(
    'pregnant',
  );
  @override
  late final GeneratedColumn<String> pregnant = GeneratedColumn<String>(
    'pregnant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _liveBirthsMeta = const VerificationMeta(
    'liveBirths',
  );
  @override
  late final GeneratedColumn<int> liveBirths = GeneratedColumn<int>(
    'live_births',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stillBirthsMeta = const VerificationMeta(
    'stillBirths',
  );
  @override
  late final GeneratedColumn<int> stillBirths = GeneratedColumn<int>(
    'still_births',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _abortionsMeta = const VerificationMeta(
    'abortions',
  );
  @override
  late final GeneratedColumn<int> abortions = GeneratedColumn<int>(
    'abortions',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cesareansMeta = const VerificationMeta(
    'cesareans',
  );
  @override
  late final GeneratedColumn<int> cesareans = GeneratedColumn<int>(
    'cesareans',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _miscarriagesMeta = const VerificationMeta(
    'miscarriages',
  );
  @override
  late final GeneratedColumn<int> miscarriages = GeneratedColumn<int>(
    'miscarriages',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hpvVaccinationMeta = const VerificationMeta(
    'hpvVaccination',
  );
  @override
  late final GeneratedColumn<String> hpvVaccination = GeneratedColumn<String>(
    'hpv_vaccination',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referralReasonMeta = const VerificationMeta(
    'referralReason',
  );
  @override
  late final GeneratedColumn<String> referralReason = GeneratedColumn<String>(
    'referral_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _symptomsMeta = const VerificationMeta(
    'symptoms',
  );
  @override
  late final GeneratedColumn<String> symptoms = GeneratedColumn<String>(
    'symptoms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hpvTestMeta = const VerificationMeta(
    'hpvTest',
  );
  @override
  late final GeneratedColumn<String> hpvTest = GeneratedColumn<String>(
    'hpv_test',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hpvResultMeta = const VerificationMeta(
    'hpvResult',
  );
  @override
  late final GeneratedColumn<String> hpvResult = GeneratedColumn<String>(
    'hpv_result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hpvDateMeta = const VerificationMeta(
    'hpvDate',
  );
  @override
  late final GeneratedColumn<String> hpvDate = GeneratedColumn<String>(
    'hpv_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hcgTestMeta = const VerificationMeta(
    'hcgTest',
  );
  @override
  late final GeneratedColumn<String> hcgTest = GeneratedColumn<String>(
    'hcg_test',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hcgDateMeta = const VerificationMeta(
    'hcgDate',
  );
  @override
  late final GeneratedColumn<String> hcgDate = GeneratedColumn<String>(
    'hcg_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hcgLevelMeta = const VerificationMeta(
    'hcgLevel',
  );
  @override
  late final GeneratedColumn<double> hcgLevel = GeneratedColumn<double>(
    'hcg_level',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _patientSummaryMeta = const VerificationMeta(
    'patientSummary',
  );
  @override
  late final GeneratedColumn<String> patientSummary = GeneratedColumn<String>(
    'patient_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chiefComplaintMeta = const VerificationMeta(
    'chiefComplaint',
  );
  @override
  late final GeneratedColumn<String> chiefComplaint = GeneratedColumn<String>(
    'chief_complaint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cytologyReportMeta = const VerificationMeta(
    'cytologyReport',
  );
  @override
  late final GeneratedColumn<String> cytologyReport = GeneratedColumn<String>(
    'cytology_report',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pathologicalReportMeta =
      const VerificationMeta('pathologicalReport');
  @override
  late final GeneratedColumn<String> pathologicalReport =
      GeneratedColumn<String>(
        'pathological_report',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _colposcopyFindingsMeta =
      const VerificationMeta('colposcopyFindings');
  @override
  late final GeneratedColumn<String> colposcopyFindings =
      GeneratedColumn<String>(
        'colposcopy_findings',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _finalImpressionMeta = const VerificationMeta(
    'finalImpression',
  );
  @override
  late final GeneratedColumn<String> finalImpression = GeneratedColumn<String>(
    'final_impression',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _treatmentProvidedMeta = const VerificationMeta(
    'treatmentProvided',
  );
  @override
  late final GeneratedColumn<String> treatmentProvided =
      GeneratedColumn<String>(
        'treatment_provided',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _precautionsMeta = const VerificationMeta(
    'precautions',
  );
  @override
  late final GeneratedColumn<String> precautions = GeneratedColumn<String>(
    'precautions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _examiningPhysicianMeta =
      const VerificationMeta('examiningPhysician');
  @override
  late final GeneratedColumn<String> examiningPhysician =
      GeneratedColumn<String>(
        'examining_physician',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _forensicExaminationMeta =
      const VerificationMeta('forensicExamination');
  @override
  late final GeneratedColumn<String> forensicExamination =
      GeneratedColumn<String>(
        'forensic_examination',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _examinationImagesMeta = const VerificationMeta(
    'examinationImages',
  );
  @override
  late final GeneratedColumn<String> examinationImages =
      GeneratedColumn<String>(
        'examination_images',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _imageMetadataMeta = const VerificationMeta(
    'imageMetadata',
  );
  @override
  late final GeneratedColumn<String> imageMetadata = GeneratedColumn<String>(
    'image_metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    doctorId,
    syncStatus,
    cloudId,
    deletedAt,
    patientName,
    patientId,
    dateOfBirth,
    dateOfVisit,
    mobileNo,
    email,
    address,
    doctorName,
    referredBy,
    smoking,
    bloodGroup,
    medication,
    allergies,
    menopause,
    lastMenstrualDate,
    sexuallyActive,
    contraception,
    hivStatus,
    pregnant,
    liveBirths,
    stillBirths,
    abortions,
    cesareans,
    miscarriages,
    hpvVaccination,
    referralReason,
    symptoms,
    hpvTest,
    hpvResult,
    hpvDate,
    hcgTest,
    hcgDate,
    hcgLevel,
    patientSummary,
    chiefComplaint,
    cytologyReport,
    pathologicalReport,
    colposcopyFindings,
    finalImpression,
    remarks,
    treatmentProvided,
    precautions,
    examiningPhysician,
    forensicExamination,
    examinationImages,
    imageMetadata,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<PatientRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('doctor_id')) {
      context.handle(
        _doctorIdMeta,
        doctorId.isAcceptableOrUnknown(data['doctor_id']!, _doctorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_doctorIdMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('patient_name')) {
      context.handle(
        _patientNameMeta,
        patientName.isAcceptableOrUnknown(
          data['patient_name']!,
          _patientNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientNameMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('date_of_visit')) {
      context.handle(
        _dateOfVisitMeta,
        dateOfVisit.isAcceptableOrUnknown(
          data['date_of_visit']!,
          _dateOfVisitMeta,
        ),
      );
    }
    if (data.containsKey('mobile_no')) {
      context.handle(
        _mobileNoMeta,
        mobileNo.isAcceptableOrUnknown(data['mobile_no']!, _mobileNoMeta),
      );
    } else if (isInserting) {
      context.missing(_mobileNoMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('doctor_name')) {
      context.handle(
        _doctorNameMeta,
        doctorName.isAcceptableOrUnknown(data['doctor_name']!, _doctorNameMeta),
      );
    }
    if (data.containsKey('referred_by')) {
      context.handle(
        _referredByMeta,
        referredBy.isAcceptableOrUnknown(data['referred_by']!, _referredByMeta),
      );
    }
    if (data.containsKey('smoking')) {
      context.handle(
        _smokingMeta,
        smoking.isAcceptableOrUnknown(data['smoking']!, _smokingMeta),
      );
    }
    if (data.containsKey('blood_group')) {
      context.handle(
        _bloodGroupMeta,
        bloodGroup.isAcceptableOrUnknown(data['blood_group']!, _bloodGroupMeta),
      );
    }
    if (data.containsKey('medication')) {
      context.handle(
        _medicationMeta,
        medication.isAcceptableOrUnknown(data['medication']!, _medicationMeta),
      );
    }
    if (data.containsKey('allergies')) {
      context.handle(
        _allergiesMeta,
        allergies.isAcceptableOrUnknown(data['allergies']!, _allergiesMeta),
      );
    }
    if (data.containsKey('menopause')) {
      context.handle(
        _menopauseMeta,
        menopause.isAcceptableOrUnknown(data['menopause']!, _menopauseMeta),
      );
    }
    if (data.containsKey('last_menstrual_date')) {
      context.handle(
        _lastMenstrualDateMeta,
        lastMenstrualDate.isAcceptableOrUnknown(
          data['last_menstrual_date']!,
          _lastMenstrualDateMeta,
        ),
      );
    }
    if (data.containsKey('sexually_active')) {
      context.handle(
        _sexuallyActiveMeta,
        sexuallyActive.isAcceptableOrUnknown(
          data['sexually_active']!,
          _sexuallyActiveMeta,
        ),
      );
    }
    if (data.containsKey('contraception')) {
      context.handle(
        _contraceptionMeta,
        contraception.isAcceptableOrUnknown(
          data['contraception']!,
          _contraceptionMeta,
        ),
      );
    }
    if (data.containsKey('hiv_status')) {
      context.handle(
        _hivStatusMeta,
        hivStatus.isAcceptableOrUnknown(data['hiv_status']!, _hivStatusMeta),
      );
    }
    if (data.containsKey('pregnant')) {
      context.handle(
        _pregnantMeta,
        pregnant.isAcceptableOrUnknown(data['pregnant']!, _pregnantMeta),
      );
    }
    if (data.containsKey('live_births')) {
      context.handle(
        _liveBirthsMeta,
        liveBirths.isAcceptableOrUnknown(data['live_births']!, _liveBirthsMeta),
      );
    }
    if (data.containsKey('still_births')) {
      context.handle(
        _stillBirthsMeta,
        stillBirths.isAcceptableOrUnknown(
          data['still_births']!,
          _stillBirthsMeta,
        ),
      );
    }
    if (data.containsKey('abortions')) {
      context.handle(
        _abortionsMeta,
        abortions.isAcceptableOrUnknown(data['abortions']!, _abortionsMeta),
      );
    }
    if (data.containsKey('cesareans')) {
      context.handle(
        _cesareansMeta,
        cesareans.isAcceptableOrUnknown(data['cesareans']!, _cesareansMeta),
      );
    }
    if (data.containsKey('miscarriages')) {
      context.handle(
        _miscarriagesMeta,
        miscarriages.isAcceptableOrUnknown(
          data['miscarriages']!,
          _miscarriagesMeta,
        ),
      );
    }
    if (data.containsKey('hpv_vaccination')) {
      context.handle(
        _hpvVaccinationMeta,
        hpvVaccination.isAcceptableOrUnknown(
          data['hpv_vaccination']!,
          _hpvVaccinationMeta,
        ),
      );
    }
    if (data.containsKey('referral_reason')) {
      context.handle(
        _referralReasonMeta,
        referralReason.isAcceptableOrUnknown(
          data['referral_reason']!,
          _referralReasonMeta,
        ),
      );
    }
    if (data.containsKey('symptoms')) {
      context.handle(
        _symptomsMeta,
        symptoms.isAcceptableOrUnknown(data['symptoms']!, _symptomsMeta),
      );
    }
    if (data.containsKey('hpv_test')) {
      context.handle(
        _hpvTestMeta,
        hpvTest.isAcceptableOrUnknown(data['hpv_test']!, _hpvTestMeta),
      );
    }
    if (data.containsKey('hpv_result')) {
      context.handle(
        _hpvResultMeta,
        hpvResult.isAcceptableOrUnknown(data['hpv_result']!, _hpvResultMeta),
      );
    }
    if (data.containsKey('hpv_date')) {
      context.handle(
        _hpvDateMeta,
        hpvDate.isAcceptableOrUnknown(data['hpv_date']!, _hpvDateMeta),
      );
    }
    if (data.containsKey('hcg_test')) {
      context.handle(
        _hcgTestMeta,
        hcgTest.isAcceptableOrUnknown(data['hcg_test']!, _hcgTestMeta),
      );
    }
    if (data.containsKey('hcg_date')) {
      context.handle(
        _hcgDateMeta,
        hcgDate.isAcceptableOrUnknown(data['hcg_date']!, _hcgDateMeta),
      );
    }
    if (data.containsKey('hcg_level')) {
      context.handle(
        _hcgLevelMeta,
        hcgLevel.isAcceptableOrUnknown(data['hcg_level']!, _hcgLevelMeta),
      );
    }
    if (data.containsKey('patient_summary')) {
      context.handle(
        _patientSummaryMeta,
        patientSummary.isAcceptableOrUnknown(
          data['patient_summary']!,
          _patientSummaryMeta,
        ),
      );
    }
    if (data.containsKey('chief_complaint')) {
      context.handle(
        _chiefComplaintMeta,
        chiefComplaint.isAcceptableOrUnknown(
          data['chief_complaint']!,
          _chiefComplaintMeta,
        ),
      );
    }
    if (data.containsKey('cytology_report')) {
      context.handle(
        _cytologyReportMeta,
        cytologyReport.isAcceptableOrUnknown(
          data['cytology_report']!,
          _cytologyReportMeta,
        ),
      );
    }
    if (data.containsKey('pathological_report')) {
      context.handle(
        _pathologicalReportMeta,
        pathologicalReport.isAcceptableOrUnknown(
          data['pathological_report']!,
          _pathologicalReportMeta,
        ),
      );
    }
    if (data.containsKey('colposcopy_findings')) {
      context.handle(
        _colposcopyFindingsMeta,
        colposcopyFindings.isAcceptableOrUnknown(
          data['colposcopy_findings']!,
          _colposcopyFindingsMeta,
        ),
      );
    }
    if (data.containsKey('final_impression')) {
      context.handle(
        _finalImpressionMeta,
        finalImpression.isAcceptableOrUnknown(
          data['final_impression']!,
          _finalImpressionMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('treatment_provided')) {
      context.handle(
        _treatmentProvidedMeta,
        treatmentProvided.isAcceptableOrUnknown(
          data['treatment_provided']!,
          _treatmentProvidedMeta,
        ),
      );
    }
    if (data.containsKey('precautions')) {
      context.handle(
        _precautionsMeta,
        precautions.isAcceptableOrUnknown(
          data['precautions']!,
          _precautionsMeta,
        ),
      );
    }
    if (data.containsKey('examining_physician')) {
      context.handle(
        _examiningPhysicianMeta,
        examiningPhysician.isAcceptableOrUnknown(
          data['examining_physician']!,
          _examiningPhysicianMeta,
        ),
      );
    }
    if (data.containsKey('forensic_examination')) {
      context.handle(
        _forensicExaminationMeta,
        forensicExamination.isAcceptableOrUnknown(
          data['forensic_examination']!,
          _forensicExaminationMeta,
        ),
      );
    }
    if (data.containsKey('examination_images')) {
      context.handle(
        _examinationImagesMeta,
        examinationImages.isAcceptableOrUnknown(
          data['examination_images']!,
          _examinationImagesMeta,
        ),
      );
    }
    if (data.containsKey('image_metadata')) {
      context.handle(
        _imageMetadataMeta,
        imageMetadata.isAcceptableOrUnknown(
          data['image_metadata']!,
          _imageMetadataMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PatientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatientRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      uuid:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}uuid'],
          )!,
      doctorId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}doctor_id'],
          )!,
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sync_status'],
          )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      patientName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_name'],
          )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      ),
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_of_birth'],
      ),
      dateOfVisit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_of_visit'],
      ),
      mobileNo:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}mobile_no'],
          )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      doctorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doctor_name'],
      ),
      referredBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referred_by'],
      ),
      smoking: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}smoking'],
      ),
      bloodGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blood_group'],
      ),
      medication: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication'],
      ),
      allergies: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergies'],
      ),
      menopause: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}menopause'],
      ),
      lastMenstrualDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_menstrual_date'],
      ),
      sexuallyActive: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sexually_active'],
      ),
      contraception: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contraception'],
      ),
      hivStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hiv_status'],
      ),
      pregnant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pregnant'],
      ),
      liveBirths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}live_births'],
      ),
      stillBirths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}still_births'],
      ),
      abortions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}abortions'],
      ),
      cesareans: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cesareans'],
      ),
      miscarriages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}miscarriages'],
      ),
      hpvVaccination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hpv_vaccination'],
      ),
      referralReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referral_reason'],
      ),
      symptoms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms'],
      ),
      hpvTest: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hpv_test'],
      ),
      hpvResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hpv_result'],
      ),
      hpvDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hpv_date'],
      ),
      hcgTest: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hcg_test'],
      ),
      hcgDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hcg_date'],
      ),
      hcgLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hcg_level'],
      ),
      patientSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_summary'],
      ),
      chiefComplaint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chief_complaint'],
      ),
      cytologyReport: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cytology_report'],
      ),
      pathologicalReport: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pathological_report'],
      ),
      colposcopyFindings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colposcopy_findings'],
      ),
      finalImpression: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}final_impression'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      treatmentProvided: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treatment_provided'],
      ),
      precautions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}precautions'],
      ),
      examiningPhysician: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}examining_physician'],
      ),
      forensicExamination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}forensic_examination'],
      ),
      examinationImages: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}examination_images'],
      ),
      imageMetadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_metadata'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class PatientRow extends DataClass implements Insertable<PatientRow> {
  final int id;
  final String uuid;
  final String doctorId;
  final String syncStatus;
  final String? cloudId;
  final String? deletedAt;
  final String patientName;
  final String? patientId;
  final String? dateOfBirth;
  final String? dateOfVisit;
  final String mobileNo;
  final String? email;
  final String? address;
  final String? doctorName;
  final String? referredBy;
  final String? smoking;
  final String? bloodGroup;
  final String? medication;
  final String? allergies;
  final String? menopause;
  final String? lastMenstrualDate;
  final String? sexuallyActive;
  final String? contraception;
  final String? hivStatus;
  final String? pregnant;
  final int? liveBirths;
  final int? stillBirths;
  final int? abortions;
  final int? cesareans;
  final int? miscarriages;
  final String? hpvVaccination;
  final String? referralReason;
  final String? symptoms;
  final String? hpvTest;
  final String? hpvResult;
  final String? hpvDate;
  final String? hcgTest;
  final String? hcgDate;
  final double? hcgLevel;
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
  final String? forensicExamination;
  final String? examinationImages;
  final String? imageMetadata;
  final String? createdAt;
  final String? updatedAt;
  const PatientRow({
    required this.id,
    required this.uuid,
    required this.doctorId,
    required this.syncStatus,
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['doctor_id'] = Variable<String>(doctorId);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['patient_name'] = Variable<String>(patientName);
    if (!nullToAbsent || patientId != null) {
      map['patient_id'] = Variable<String>(patientId);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<String>(dateOfBirth);
    }
    if (!nullToAbsent || dateOfVisit != null) {
      map['date_of_visit'] = Variable<String>(dateOfVisit);
    }
    map['mobile_no'] = Variable<String>(mobileNo);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || doctorName != null) {
      map['doctor_name'] = Variable<String>(doctorName);
    }
    if (!nullToAbsent || referredBy != null) {
      map['referred_by'] = Variable<String>(referredBy);
    }
    if (!nullToAbsent || smoking != null) {
      map['smoking'] = Variable<String>(smoking);
    }
    if (!nullToAbsent || bloodGroup != null) {
      map['blood_group'] = Variable<String>(bloodGroup);
    }
    if (!nullToAbsent || medication != null) {
      map['medication'] = Variable<String>(medication);
    }
    if (!nullToAbsent || allergies != null) {
      map['allergies'] = Variable<String>(allergies);
    }
    if (!nullToAbsent || menopause != null) {
      map['menopause'] = Variable<String>(menopause);
    }
    if (!nullToAbsent || lastMenstrualDate != null) {
      map['last_menstrual_date'] = Variable<String>(lastMenstrualDate);
    }
    if (!nullToAbsent || sexuallyActive != null) {
      map['sexually_active'] = Variable<String>(sexuallyActive);
    }
    if (!nullToAbsent || contraception != null) {
      map['contraception'] = Variable<String>(contraception);
    }
    if (!nullToAbsent || hivStatus != null) {
      map['hiv_status'] = Variable<String>(hivStatus);
    }
    if (!nullToAbsent || pregnant != null) {
      map['pregnant'] = Variable<String>(pregnant);
    }
    if (!nullToAbsent || liveBirths != null) {
      map['live_births'] = Variable<int>(liveBirths);
    }
    if (!nullToAbsent || stillBirths != null) {
      map['still_births'] = Variable<int>(stillBirths);
    }
    if (!nullToAbsent || abortions != null) {
      map['abortions'] = Variable<int>(abortions);
    }
    if (!nullToAbsent || cesareans != null) {
      map['cesareans'] = Variable<int>(cesareans);
    }
    if (!nullToAbsent || miscarriages != null) {
      map['miscarriages'] = Variable<int>(miscarriages);
    }
    if (!nullToAbsent || hpvVaccination != null) {
      map['hpv_vaccination'] = Variable<String>(hpvVaccination);
    }
    if (!nullToAbsent || referralReason != null) {
      map['referral_reason'] = Variable<String>(referralReason);
    }
    if (!nullToAbsent || symptoms != null) {
      map['symptoms'] = Variable<String>(symptoms);
    }
    if (!nullToAbsent || hpvTest != null) {
      map['hpv_test'] = Variable<String>(hpvTest);
    }
    if (!nullToAbsent || hpvResult != null) {
      map['hpv_result'] = Variable<String>(hpvResult);
    }
    if (!nullToAbsent || hpvDate != null) {
      map['hpv_date'] = Variable<String>(hpvDate);
    }
    if (!nullToAbsent || hcgTest != null) {
      map['hcg_test'] = Variable<String>(hcgTest);
    }
    if (!nullToAbsent || hcgDate != null) {
      map['hcg_date'] = Variable<String>(hcgDate);
    }
    if (!nullToAbsent || hcgLevel != null) {
      map['hcg_level'] = Variable<double>(hcgLevel);
    }
    if (!nullToAbsent || patientSummary != null) {
      map['patient_summary'] = Variable<String>(patientSummary);
    }
    if (!nullToAbsent || chiefComplaint != null) {
      map['chief_complaint'] = Variable<String>(chiefComplaint);
    }
    if (!nullToAbsent || cytologyReport != null) {
      map['cytology_report'] = Variable<String>(cytologyReport);
    }
    if (!nullToAbsent || pathologicalReport != null) {
      map['pathological_report'] = Variable<String>(pathologicalReport);
    }
    if (!nullToAbsent || colposcopyFindings != null) {
      map['colposcopy_findings'] = Variable<String>(colposcopyFindings);
    }
    if (!nullToAbsent || finalImpression != null) {
      map['final_impression'] = Variable<String>(finalImpression);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || treatmentProvided != null) {
      map['treatment_provided'] = Variable<String>(treatmentProvided);
    }
    if (!nullToAbsent || precautions != null) {
      map['precautions'] = Variable<String>(precautions);
    }
    if (!nullToAbsent || examiningPhysician != null) {
      map['examining_physician'] = Variable<String>(examiningPhysician);
    }
    if (!nullToAbsent || forensicExamination != null) {
      map['forensic_examination'] = Variable<String>(forensicExamination);
    }
    if (!nullToAbsent || examinationImages != null) {
      map['examination_images'] = Variable<String>(examinationImages);
    }
    if (!nullToAbsent || imageMetadata != null) {
      map['image_metadata'] = Variable<String>(imageMetadata);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      doctorId: Value(doctorId),
      syncStatus: Value(syncStatus),
      cloudId:
          cloudId == null && nullToAbsent
              ? const Value.absent()
              : Value(cloudId),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      patientName: Value(patientName),
      patientId:
          patientId == null && nullToAbsent
              ? const Value.absent()
              : Value(patientId),
      dateOfBirth:
          dateOfBirth == null && nullToAbsent
              ? const Value.absent()
              : Value(dateOfBirth),
      dateOfVisit:
          dateOfVisit == null && nullToAbsent
              ? const Value.absent()
              : Value(dateOfVisit),
      mobileNo: Value(mobileNo),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      address:
          address == null && nullToAbsent
              ? const Value.absent()
              : Value(address),
      doctorName:
          doctorName == null && nullToAbsent
              ? const Value.absent()
              : Value(doctorName),
      referredBy:
          referredBy == null && nullToAbsent
              ? const Value.absent()
              : Value(referredBy),
      smoking:
          smoking == null && nullToAbsent
              ? const Value.absent()
              : Value(smoking),
      bloodGroup:
          bloodGroup == null && nullToAbsent
              ? const Value.absent()
              : Value(bloodGroup),
      medication:
          medication == null && nullToAbsent
              ? const Value.absent()
              : Value(medication),
      allergies:
          allergies == null && nullToAbsent
              ? const Value.absent()
              : Value(allergies),
      menopause:
          menopause == null && nullToAbsent
              ? const Value.absent()
              : Value(menopause),
      lastMenstrualDate:
          lastMenstrualDate == null && nullToAbsent
              ? const Value.absent()
              : Value(lastMenstrualDate),
      sexuallyActive:
          sexuallyActive == null && nullToAbsent
              ? const Value.absent()
              : Value(sexuallyActive),
      contraception:
          contraception == null && nullToAbsent
              ? const Value.absent()
              : Value(contraception),
      hivStatus:
          hivStatus == null && nullToAbsent
              ? const Value.absent()
              : Value(hivStatus),
      pregnant:
          pregnant == null && nullToAbsent
              ? const Value.absent()
              : Value(pregnant),
      liveBirths:
          liveBirths == null && nullToAbsent
              ? const Value.absent()
              : Value(liveBirths),
      stillBirths:
          stillBirths == null && nullToAbsent
              ? const Value.absent()
              : Value(stillBirths),
      abortions:
          abortions == null && nullToAbsent
              ? const Value.absent()
              : Value(abortions),
      cesareans:
          cesareans == null && nullToAbsent
              ? const Value.absent()
              : Value(cesareans),
      miscarriages:
          miscarriages == null && nullToAbsent
              ? const Value.absent()
              : Value(miscarriages),
      hpvVaccination:
          hpvVaccination == null && nullToAbsent
              ? const Value.absent()
              : Value(hpvVaccination),
      referralReason:
          referralReason == null && nullToAbsent
              ? const Value.absent()
              : Value(referralReason),
      symptoms:
          symptoms == null && nullToAbsent
              ? const Value.absent()
              : Value(symptoms),
      hpvTest:
          hpvTest == null && nullToAbsent
              ? const Value.absent()
              : Value(hpvTest),
      hpvResult:
          hpvResult == null && nullToAbsent
              ? const Value.absent()
              : Value(hpvResult),
      hpvDate:
          hpvDate == null && nullToAbsent
              ? const Value.absent()
              : Value(hpvDate),
      hcgTest:
          hcgTest == null && nullToAbsent
              ? const Value.absent()
              : Value(hcgTest),
      hcgDate:
          hcgDate == null && nullToAbsent
              ? const Value.absent()
              : Value(hcgDate),
      hcgLevel:
          hcgLevel == null && nullToAbsent
              ? const Value.absent()
              : Value(hcgLevel),
      patientSummary:
          patientSummary == null && nullToAbsent
              ? const Value.absent()
              : Value(patientSummary),
      chiefComplaint:
          chiefComplaint == null && nullToAbsent
              ? const Value.absent()
              : Value(chiefComplaint),
      cytologyReport:
          cytologyReport == null && nullToAbsent
              ? const Value.absent()
              : Value(cytologyReport),
      pathologicalReport:
          pathologicalReport == null && nullToAbsent
              ? const Value.absent()
              : Value(pathologicalReport),
      colposcopyFindings:
          colposcopyFindings == null && nullToAbsent
              ? const Value.absent()
              : Value(colposcopyFindings),
      finalImpression:
          finalImpression == null && nullToAbsent
              ? const Value.absent()
              : Value(finalImpression),
      remarks:
          remarks == null && nullToAbsent
              ? const Value.absent()
              : Value(remarks),
      treatmentProvided:
          treatmentProvided == null && nullToAbsent
              ? const Value.absent()
              : Value(treatmentProvided),
      precautions:
          precautions == null && nullToAbsent
              ? const Value.absent()
              : Value(precautions),
      examiningPhysician:
          examiningPhysician == null && nullToAbsent
              ? const Value.absent()
              : Value(examiningPhysician),
      forensicExamination:
          forensicExamination == null && nullToAbsent
              ? const Value.absent()
              : Value(forensicExamination),
      examinationImages:
          examinationImages == null && nullToAbsent
              ? const Value.absent()
              : Value(examinationImages),
      imageMetadata:
          imageMetadata == null && nullToAbsent
              ? const Value.absent()
              : Value(imageMetadata),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
    );
  }

  factory PatientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatientRow(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      doctorId: serializer.fromJson<String>(json['doctorId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      patientName: serializer.fromJson<String>(json['patientName']),
      patientId: serializer.fromJson<String?>(json['patientId']),
      dateOfBirth: serializer.fromJson<String?>(json['dateOfBirth']),
      dateOfVisit: serializer.fromJson<String?>(json['dateOfVisit']),
      mobileNo: serializer.fromJson<String>(json['mobileNo']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      doctorName: serializer.fromJson<String?>(json['doctorName']),
      referredBy: serializer.fromJson<String?>(json['referredBy']),
      smoking: serializer.fromJson<String?>(json['smoking']),
      bloodGroup: serializer.fromJson<String?>(json['bloodGroup']),
      medication: serializer.fromJson<String?>(json['medication']),
      allergies: serializer.fromJson<String?>(json['allergies']),
      menopause: serializer.fromJson<String?>(json['menopause']),
      lastMenstrualDate: serializer.fromJson<String?>(
        json['lastMenstrualDate'],
      ),
      sexuallyActive: serializer.fromJson<String?>(json['sexuallyActive']),
      contraception: serializer.fromJson<String?>(json['contraception']),
      hivStatus: serializer.fromJson<String?>(json['hivStatus']),
      pregnant: serializer.fromJson<String?>(json['pregnant']),
      liveBirths: serializer.fromJson<int?>(json['liveBirths']),
      stillBirths: serializer.fromJson<int?>(json['stillBirths']),
      abortions: serializer.fromJson<int?>(json['abortions']),
      cesareans: serializer.fromJson<int?>(json['cesareans']),
      miscarriages: serializer.fromJson<int?>(json['miscarriages']),
      hpvVaccination: serializer.fromJson<String?>(json['hpvVaccination']),
      referralReason: serializer.fromJson<String?>(json['referralReason']),
      symptoms: serializer.fromJson<String?>(json['symptoms']),
      hpvTest: serializer.fromJson<String?>(json['hpvTest']),
      hpvResult: serializer.fromJson<String?>(json['hpvResult']),
      hpvDate: serializer.fromJson<String?>(json['hpvDate']),
      hcgTest: serializer.fromJson<String?>(json['hcgTest']),
      hcgDate: serializer.fromJson<String?>(json['hcgDate']),
      hcgLevel: serializer.fromJson<double?>(json['hcgLevel']),
      patientSummary: serializer.fromJson<String?>(json['patientSummary']),
      chiefComplaint: serializer.fromJson<String?>(json['chiefComplaint']),
      cytologyReport: serializer.fromJson<String?>(json['cytologyReport']),
      pathologicalReport: serializer.fromJson<String?>(
        json['pathologicalReport'],
      ),
      colposcopyFindings: serializer.fromJson<String?>(
        json['colposcopyFindings'],
      ),
      finalImpression: serializer.fromJson<String?>(json['finalImpression']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      treatmentProvided: serializer.fromJson<String?>(
        json['treatmentProvided'],
      ),
      precautions: serializer.fromJson<String?>(json['precautions']),
      examiningPhysician: serializer.fromJson<String?>(
        json['examiningPhysician'],
      ),
      forensicExamination: serializer.fromJson<String?>(
        json['forensicExamination'],
      ),
      examinationImages: serializer.fromJson<String?>(
        json['examinationImages'],
      ),
      imageMetadata: serializer.fromJson<String?>(json['imageMetadata']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'doctorId': serializer.toJson<String>(doctorId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'cloudId': serializer.toJson<String?>(cloudId),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'patientName': serializer.toJson<String>(patientName),
      'patientId': serializer.toJson<String?>(patientId),
      'dateOfBirth': serializer.toJson<String?>(dateOfBirth),
      'dateOfVisit': serializer.toJson<String?>(dateOfVisit),
      'mobileNo': serializer.toJson<String>(mobileNo),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'doctorName': serializer.toJson<String?>(doctorName),
      'referredBy': serializer.toJson<String?>(referredBy),
      'smoking': serializer.toJson<String?>(smoking),
      'bloodGroup': serializer.toJson<String?>(bloodGroup),
      'medication': serializer.toJson<String?>(medication),
      'allergies': serializer.toJson<String?>(allergies),
      'menopause': serializer.toJson<String?>(menopause),
      'lastMenstrualDate': serializer.toJson<String?>(lastMenstrualDate),
      'sexuallyActive': serializer.toJson<String?>(sexuallyActive),
      'contraception': serializer.toJson<String?>(contraception),
      'hivStatus': serializer.toJson<String?>(hivStatus),
      'pregnant': serializer.toJson<String?>(pregnant),
      'liveBirths': serializer.toJson<int?>(liveBirths),
      'stillBirths': serializer.toJson<int?>(stillBirths),
      'abortions': serializer.toJson<int?>(abortions),
      'cesareans': serializer.toJson<int?>(cesareans),
      'miscarriages': serializer.toJson<int?>(miscarriages),
      'hpvVaccination': serializer.toJson<String?>(hpvVaccination),
      'referralReason': serializer.toJson<String?>(referralReason),
      'symptoms': serializer.toJson<String?>(symptoms),
      'hpvTest': serializer.toJson<String?>(hpvTest),
      'hpvResult': serializer.toJson<String?>(hpvResult),
      'hpvDate': serializer.toJson<String?>(hpvDate),
      'hcgTest': serializer.toJson<String?>(hcgTest),
      'hcgDate': serializer.toJson<String?>(hcgDate),
      'hcgLevel': serializer.toJson<double?>(hcgLevel),
      'patientSummary': serializer.toJson<String?>(patientSummary),
      'chiefComplaint': serializer.toJson<String?>(chiefComplaint),
      'cytologyReport': serializer.toJson<String?>(cytologyReport),
      'pathologicalReport': serializer.toJson<String?>(pathologicalReport),
      'colposcopyFindings': serializer.toJson<String?>(colposcopyFindings),
      'finalImpression': serializer.toJson<String?>(finalImpression),
      'remarks': serializer.toJson<String?>(remarks),
      'treatmentProvided': serializer.toJson<String?>(treatmentProvided),
      'precautions': serializer.toJson<String?>(precautions),
      'examiningPhysician': serializer.toJson<String?>(examiningPhysician),
      'forensicExamination': serializer.toJson<String?>(forensicExamination),
      'examinationImages': serializer.toJson<String?>(examinationImages),
      'imageMetadata': serializer.toJson<String?>(imageMetadata),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  PatientRow copyWith({
    int? id,
    String? uuid,
    String? doctorId,
    String? syncStatus,
    Value<String?> cloudId = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    String? patientName,
    Value<String?> patientId = const Value.absent(),
    Value<String?> dateOfBirth = const Value.absent(),
    Value<String?> dateOfVisit = const Value.absent(),
    String? mobileNo,
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> doctorName = const Value.absent(),
    Value<String?> referredBy = const Value.absent(),
    Value<String?> smoking = const Value.absent(),
    Value<String?> bloodGroup = const Value.absent(),
    Value<String?> medication = const Value.absent(),
    Value<String?> allergies = const Value.absent(),
    Value<String?> menopause = const Value.absent(),
    Value<String?> lastMenstrualDate = const Value.absent(),
    Value<String?> sexuallyActive = const Value.absent(),
    Value<String?> contraception = const Value.absent(),
    Value<String?> hivStatus = const Value.absent(),
    Value<String?> pregnant = const Value.absent(),
    Value<int?> liveBirths = const Value.absent(),
    Value<int?> stillBirths = const Value.absent(),
    Value<int?> abortions = const Value.absent(),
    Value<int?> cesareans = const Value.absent(),
    Value<int?> miscarriages = const Value.absent(),
    Value<String?> hpvVaccination = const Value.absent(),
    Value<String?> referralReason = const Value.absent(),
    Value<String?> symptoms = const Value.absent(),
    Value<String?> hpvTest = const Value.absent(),
    Value<String?> hpvResult = const Value.absent(),
    Value<String?> hpvDate = const Value.absent(),
    Value<String?> hcgTest = const Value.absent(),
    Value<String?> hcgDate = const Value.absent(),
    Value<double?> hcgLevel = const Value.absent(),
    Value<String?> patientSummary = const Value.absent(),
    Value<String?> chiefComplaint = const Value.absent(),
    Value<String?> cytologyReport = const Value.absent(),
    Value<String?> pathologicalReport = const Value.absent(),
    Value<String?> colposcopyFindings = const Value.absent(),
    Value<String?> finalImpression = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    Value<String?> treatmentProvided = const Value.absent(),
    Value<String?> precautions = const Value.absent(),
    Value<String?> examiningPhysician = const Value.absent(),
    Value<String?> forensicExamination = const Value.absent(),
    Value<String?> examinationImages = const Value.absent(),
    Value<String?> imageMetadata = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => PatientRow(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    doctorId: doctorId ?? this.doctorId,
    syncStatus: syncStatus ?? this.syncStatus,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    patientName: patientName ?? this.patientName,
    patientId: patientId.present ? patientId.value : this.patientId,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    dateOfVisit: dateOfVisit.present ? dateOfVisit.value : this.dateOfVisit,
    mobileNo: mobileNo ?? this.mobileNo,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    doctorName: doctorName.present ? doctorName.value : this.doctorName,
    referredBy: referredBy.present ? referredBy.value : this.referredBy,
    smoking: smoking.present ? smoking.value : this.smoking,
    bloodGroup: bloodGroup.present ? bloodGroup.value : this.bloodGroup,
    medication: medication.present ? medication.value : this.medication,
    allergies: allergies.present ? allergies.value : this.allergies,
    menopause: menopause.present ? menopause.value : this.menopause,
    lastMenstrualDate:
        lastMenstrualDate.present
            ? lastMenstrualDate.value
            : this.lastMenstrualDate,
    sexuallyActive:
        sexuallyActive.present ? sexuallyActive.value : this.sexuallyActive,
    contraception:
        contraception.present ? contraception.value : this.contraception,
    hivStatus: hivStatus.present ? hivStatus.value : this.hivStatus,
    pregnant: pregnant.present ? pregnant.value : this.pregnant,
    liveBirths: liveBirths.present ? liveBirths.value : this.liveBirths,
    stillBirths: stillBirths.present ? stillBirths.value : this.stillBirths,
    abortions: abortions.present ? abortions.value : this.abortions,
    cesareans: cesareans.present ? cesareans.value : this.cesareans,
    miscarriages: miscarriages.present ? miscarriages.value : this.miscarriages,
    hpvVaccination:
        hpvVaccination.present ? hpvVaccination.value : this.hpvVaccination,
    referralReason:
        referralReason.present ? referralReason.value : this.referralReason,
    symptoms: symptoms.present ? symptoms.value : this.symptoms,
    hpvTest: hpvTest.present ? hpvTest.value : this.hpvTest,
    hpvResult: hpvResult.present ? hpvResult.value : this.hpvResult,
    hpvDate: hpvDate.present ? hpvDate.value : this.hpvDate,
    hcgTest: hcgTest.present ? hcgTest.value : this.hcgTest,
    hcgDate: hcgDate.present ? hcgDate.value : this.hcgDate,
    hcgLevel: hcgLevel.present ? hcgLevel.value : this.hcgLevel,
    patientSummary:
        patientSummary.present ? patientSummary.value : this.patientSummary,
    chiefComplaint:
        chiefComplaint.present ? chiefComplaint.value : this.chiefComplaint,
    cytologyReport:
        cytologyReport.present ? cytologyReport.value : this.cytologyReport,
    pathologicalReport:
        pathologicalReport.present
            ? pathologicalReport.value
            : this.pathologicalReport,
    colposcopyFindings:
        colposcopyFindings.present
            ? colposcopyFindings.value
            : this.colposcopyFindings,
    finalImpression:
        finalImpression.present ? finalImpression.value : this.finalImpression,
    remarks: remarks.present ? remarks.value : this.remarks,
    treatmentProvided:
        treatmentProvided.present
            ? treatmentProvided.value
            : this.treatmentProvided,
    precautions: precautions.present ? precautions.value : this.precautions,
    examiningPhysician:
        examiningPhysician.present
            ? examiningPhysician.value
            : this.examiningPhysician,
    forensicExamination:
        forensicExamination.present
            ? forensicExamination.value
            : this.forensicExamination,
    examinationImages:
        examinationImages.present
            ? examinationImages.value
            : this.examinationImages,
    imageMetadata:
        imageMetadata.present ? imageMetadata.value : this.imageMetadata,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  PatientRow copyWithCompanion(PatientsCompanion data) {
    return PatientRow(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      doctorId: data.doctorId.present ? data.doctorId.value : this.doctorId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      patientName:
          data.patientName.present ? data.patientName.value : this.patientName,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      dateOfVisit:
          data.dateOfVisit.present ? data.dateOfVisit.value : this.dateOfVisit,
      mobileNo: data.mobileNo.present ? data.mobileNo.value : this.mobileNo,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      doctorName:
          data.doctorName.present ? data.doctorName.value : this.doctorName,
      referredBy:
          data.referredBy.present ? data.referredBy.value : this.referredBy,
      smoking: data.smoking.present ? data.smoking.value : this.smoking,
      bloodGroup:
          data.bloodGroup.present ? data.bloodGroup.value : this.bloodGroup,
      medication:
          data.medication.present ? data.medication.value : this.medication,
      allergies: data.allergies.present ? data.allergies.value : this.allergies,
      menopause: data.menopause.present ? data.menopause.value : this.menopause,
      lastMenstrualDate:
          data.lastMenstrualDate.present
              ? data.lastMenstrualDate.value
              : this.lastMenstrualDate,
      sexuallyActive:
          data.sexuallyActive.present
              ? data.sexuallyActive.value
              : this.sexuallyActive,
      contraception:
          data.contraception.present
              ? data.contraception.value
              : this.contraception,
      hivStatus: data.hivStatus.present ? data.hivStatus.value : this.hivStatus,
      pregnant: data.pregnant.present ? data.pregnant.value : this.pregnant,
      liveBirths:
          data.liveBirths.present ? data.liveBirths.value : this.liveBirths,
      stillBirths:
          data.stillBirths.present ? data.stillBirths.value : this.stillBirths,
      abortions: data.abortions.present ? data.abortions.value : this.abortions,
      cesareans: data.cesareans.present ? data.cesareans.value : this.cesareans,
      miscarriages:
          data.miscarriages.present
              ? data.miscarriages.value
              : this.miscarriages,
      hpvVaccination:
          data.hpvVaccination.present
              ? data.hpvVaccination.value
              : this.hpvVaccination,
      referralReason:
          data.referralReason.present
              ? data.referralReason.value
              : this.referralReason,
      symptoms: data.symptoms.present ? data.symptoms.value : this.symptoms,
      hpvTest: data.hpvTest.present ? data.hpvTest.value : this.hpvTest,
      hpvResult: data.hpvResult.present ? data.hpvResult.value : this.hpvResult,
      hpvDate: data.hpvDate.present ? data.hpvDate.value : this.hpvDate,
      hcgTest: data.hcgTest.present ? data.hcgTest.value : this.hcgTest,
      hcgDate: data.hcgDate.present ? data.hcgDate.value : this.hcgDate,
      hcgLevel: data.hcgLevel.present ? data.hcgLevel.value : this.hcgLevel,
      patientSummary:
          data.patientSummary.present
              ? data.patientSummary.value
              : this.patientSummary,
      chiefComplaint:
          data.chiefComplaint.present
              ? data.chiefComplaint.value
              : this.chiefComplaint,
      cytologyReport:
          data.cytologyReport.present
              ? data.cytologyReport.value
              : this.cytologyReport,
      pathologicalReport:
          data.pathologicalReport.present
              ? data.pathologicalReport.value
              : this.pathologicalReport,
      colposcopyFindings:
          data.colposcopyFindings.present
              ? data.colposcopyFindings.value
              : this.colposcopyFindings,
      finalImpression:
          data.finalImpression.present
              ? data.finalImpression.value
              : this.finalImpression,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      treatmentProvided:
          data.treatmentProvided.present
              ? data.treatmentProvided.value
              : this.treatmentProvided,
      precautions:
          data.precautions.present ? data.precautions.value : this.precautions,
      examiningPhysician:
          data.examiningPhysician.present
              ? data.examiningPhysician.value
              : this.examiningPhysician,
      forensicExamination:
          data.forensicExamination.present
              ? data.forensicExamination.value
              : this.forensicExamination,
      examinationImages:
          data.examinationImages.present
              ? data.examinationImages.value
              : this.examinationImages,
      imageMetadata:
          data.imageMetadata.present
              ? data.imageMetadata.value
              : this.imageMetadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatientRow(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('doctorId: $doctorId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('patientName: $patientName, ')
          ..write('patientId: $patientId, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('dateOfVisit: $dateOfVisit, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('doctorName: $doctorName, ')
          ..write('referredBy: $referredBy, ')
          ..write('smoking: $smoking, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('medication: $medication, ')
          ..write('allergies: $allergies, ')
          ..write('menopause: $menopause, ')
          ..write('lastMenstrualDate: $lastMenstrualDate, ')
          ..write('sexuallyActive: $sexuallyActive, ')
          ..write('contraception: $contraception, ')
          ..write('hivStatus: $hivStatus, ')
          ..write('pregnant: $pregnant, ')
          ..write('liveBirths: $liveBirths, ')
          ..write('stillBirths: $stillBirths, ')
          ..write('abortions: $abortions, ')
          ..write('cesareans: $cesareans, ')
          ..write('miscarriages: $miscarriages, ')
          ..write('hpvVaccination: $hpvVaccination, ')
          ..write('referralReason: $referralReason, ')
          ..write('symptoms: $symptoms, ')
          ..write('hpvTest: $hpvTest, ')
          ..write('hpvResult: $hpvResult, ')
          ..write('hpvDate: $hpvDate, ')
          ..write('hcgTest: $hcgTest, ')
          ..write('hcgDate: $hcgDate, ')
          ..write('hcgLevel: $hcgLevel, ')
          ..write('patientSummary: $patientSummary, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('cytologyReport: $cytologyReport, ')
          ..write('pathologicalReport: $pathologicalReport, ')
          ..write('colposcopyFindings: $colposcopyFindings, ')
          ..write('finalImpression: $finalImpression, ')
          ..write('remarks: $remarks, ')
          ..write('treatmentProvided: $treatmentProvided, ')
          ..write('precautions: $precautions, ')
          ..write('examiningPhysician: $examiningPhysician, ')
          ..write('forensicExamination: $forensicExamination, ')
          ..write('examinationImages: $examinationImages, ')
          ..write('imageMetadata: $imageMetadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    uuid,
    doctorId,
    syncStatus,
    cloudId,
    deletedAt,
    patientName,
    patientId,
    dateOfBirth,
    dateOfVisit,
    mobileNo,
    email,
    address,
    doctorName,
    referredBy,
    smoking,
    bloodGroup,
    medication,
    allergies,
    menopause,
    lastMenstrualDate,
    sexuallyActive,
    contraception,
    hivStatus,
    pregnant,
    liveBirths,
    stillBirths,
    abortions,
    cesareans,
    miscarriages,
    hpvVaccination,
    referralReason,
    symptoms,
    hpvTest,
    hpvResult,
    hpvDate,
    hcgTest,
    hcgDate,
    hcgLevel,
    patientSummary,
    chiefComplaint,
    cytologyReport,
    pathologicalReport,
    colposcopyFindings,
    finalImpression,
    remarks,
    treatmentProvided,
    precautions,
    examiningPhysician,
    forensicExamination,
    examinationImages,
    imageMetadata,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientRow &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.doctorId == this.doctorId &&
          other.syncStatus == this.syncStatus &&
          other.cloudId == this.cloudId &&
          other.deletedAt == this.deletedAt &&
          other.patientName == this.patientName &&
          other.patientId == this.patientId &&
          other.dateOfBirth == this.dateOfBirth &&
          other.dateOfVisit == this.dateOfVisit &&
          other.mobileNo == this.mobileNo &&
          other.email == this.email &&
          other.address == this.address &&
          other.doctorName == this.doctorName &&
          other.referredBy == this.referredBy &&
          other.smoking == this.smoking &&
          other.bloodGroup == this.bloodGroup &&
          other.medication == this.medication &&
          other.allergies == this.allergies &&
          other.menopause == this.menopause &&
          other.lastMenstrualDate == this.lastMenstrualDate &&
          other.sexuallyActive == this.sexuallyActive &&
          other.contraception == this.contraception &&
          other.hivStatus == this.hivStatus &&
          other.pregnant == this.pregnant &&
          other.liveBirths == this.liveBirths &&
          other.stillBirths == this.stillBirths &&
          other.abortions == this.abortions &&
          other.cesareans == this.cesareans &&
          other.miscarriages == this.miscarriages &&
          other.hpvVaccination == this.hpvVaccination &&
          other.referralReason == this.referralReason &&
          other.symptoms == this.symptoms &&
          other.hpvTest == this.hpvTest &&
          other.hpvResult == this.hpvResult &&
          other.hpvDate == this.hpvDate &&
          other.hcgTest == this.hcgTest &&
          other.hcgDate == this.hcgDate &&
          other.hcgLevel == this.hcgLevel &&
          other.patientSummary == this.patientSummary &&
          other.chiefComplaint == this.chiefComplaint &&
          other.cytologyReport == this.cytologyReport &&
          other.pathologicalReport == this.pathologicalReport &&
          other.colposcopyFindings == this.colposcopyFindings &&
          other.finalImpression == this.finalImpression &&
          other.remarks == this.remarks &&
          other.treatmentProvided == this.treatmentProvided &&
          other.precautions == this.precautions &&
          other.examiningPhysician == this.examiningPhysician &&
          other.forensicExamination == this.forensicExamination &&
          other.examinationImages == this.examinationImages &&
          other.imageMetadata == this.imageMetadata &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PatientsCompanion extends UpdateCompanion<PatientRow> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> doctorId;
  final Value<String> syncStatus;
  final Value<String?> cloudId;
  final Value<String?> deletedAt;
  final Value<String> patientName;
  final Value<String?> patientId;
  final Value<String?> dateOfBirth;
  final Value<String?> dateOfVisit;
  final Value<String> mobileNo;
  final Value<String?> email;
  final Value<String?> address;
  final Value<String?> doctorName;
  final Value<String?> referredBy;
  final Value<String?> smoking;
  final Value<String?> bloodGroup;
  final Value<String?> medication;
  final Value<String?> allergies;
  final Value<String?> menopause;
  final Value<String?> lastMenstrualDate;
  final Value<String?> sexuallyActive;
  final Value<String?> contraception;
  final Value<String?> hivStatus;
  final Value<String?> pregnant;
  final Value<int?> liveBirths;
  final Value<int?> stillBirths;
  final Value<int?> abortions;
  final Value<int?> cesareans;
  final Value<int?> miscarriages;
  final Value<String?> hpvVaccination;
  final Value<String?> referralReason;
  final Value<String?> symptoms;
  final Value<String?> hpvTest;
  final Value<String?> hpvResult;
  final Value<String?> hpvDate;
  final Value<String?> hcgTest;
  final Value<String?> hcgDate;
  final Value<double?> hcgLevel;
  final Value<String?> patientSummary;
  final Value<String?> chiefComplaint;
  final Value<String?> cytologyReport;
  final Value<String?> pathologicalReport;
  final Value<String?> colposcopyFindings;
  final Value<String?> finalImpression;
  final Value<String?> remarks;
  final Value<String?> treatmentProvided;
  final Value<String?> precautions;
  final Value<String?> examiningPhysician;
  final Value<String?> forensicExamination;
  final Value<String?> examinationImages;
  final Value<String?> imageMetadata;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.doctorId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.patientName = const Value.absent(),
    this.patientId = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.dateOfVisit = const Value.absent(),
    this.mobileNo = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.doctorName = const Value.absent(),
    this.referredBy = const Value.absent(),
    this.smoking = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.medication = const Value.absent(),
    this.allergies = const Value.absent(),
    this.menopause = const Value.absent(),
    this.lastMenstrualDate = const Value.absent(),
    this.sexuallyActive = const Value.absent(),
    this.contraception = const Value.absent(),
    this.hivStatus = const Value.absent(),
    this.pregnant = const Value.absent(),
    this.liveBirths = const Value.absent(),
    this.stillBirths = const Value.absent(),
    this.abortions = const Value.absent(),
    this.cesareans = const Value.absent(),
    this.miscarriages = const Value.absent(),
    this.hpvVaccination = const Value.absent(),
    this.referralReason = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.hpvTest = const Value.absent(),
    this.hpvResult = const Value.absent(),
    this.hpvDate = const Value.absent(),
    this.hcgTest = const Value.absent(),
    this.hcgDate = const Value.absent(),
    this.hcgLevel = const Value.absent(),
    this.patientSummary = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.cytologyReport = const Value.absent(),
    this.pathologicalReport = const Value.absent(),
    this.colposcopyFindings = const Value.absent(),
    this.finalImpression = const Value.absent(),
    this.remarks = const Value.absent(),
    this.treatmentProvided = const Value.absent(),
    this.precautions = const Value.absent(),
    this.examiningPhysician = const Value.absent(),
    this.forensicExamination = const Value.absent(),
    this.examinationImages = const Value.absent(),
    this.imageMetadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PatientsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String doctorId,
    this.syncStatus = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String patientName,
    this.patientId = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.dateOfVisit = const Value.absent(),
    required String mobileNo,
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.doctorName = const Value.absent(),
    this.referredBy = const Value.absent(),
    this.smoking = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.medication = const Value.absent(),
    this.allergies = const Value.absent(),
    this.menopause = const Value.absent(),
    this.lastMenstrualDate = const Value.absent(),
    this.sexuallyActive = const Value.absent(),
    this.contraception = const Value.absent(),
    this.hivStatus = const Value.absent(),
    this.pregnant = const Value.absent(),
    this.liveBirths = const Value.absent(),
    this.stillBirths = const Value.absent(),
    this.abortions = const Value.absent(),
    this.cesareans = const Value.absent(),
    this.miscarriages = const Value.absent(),
    this.hpvVaccination = const Value.absent(),
    this.referralReason = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.hpvTest = const Value.absent(),
    this.hpvResult = const Value.absent(),
    this.hpvDate = const Value.absent(),
    this.hcgTest = const Value.absent(),
    this.hcgDate = const Value.absent(),
    this.hcgLevel = const Value.absent(),
    this.patientSummary = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.cytologyReport = const Value.absent(),
    this.pathologicalReport = const Value.absent(),
    this.colposcopyFindings = const Value.absent(),
    this.finalImpression = const Value.absent(),
    this.remarks = const Value.absent(),
    this.treatmentProvided = const Value.absent(),
    this.precautions = const Value.absent(),
    this.examiningPhysician = const Value.absent(),
    this.forensicExamination = const Value.absent(),
    this.examinationImages = const Value.absent(),
    this.imageMetadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : uuid = Value(uuid),
       doctorId = Value(doctorId),
       patientName = Value(patientName),
       mobileNo = Value(mobileNo);
  static Insertable<PatientRow> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? doctorId,
    Expression<String>? syncStatus,
    Expression<String>? cloudId,
    Expression<String>? deletedAt,
    Expression<String>? patientName,
    Expression<String>? patientId,
    Expression<String>? dateOfBirth,
    Expression<String>? dateOfVisit,
    Expression<String>? mobileNo,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? doctorName,
    Expression<String>? referredBy,
    Expression<String>? smoking,
    Expression<String>? bloodGroup,
    Expression<String>? medication,
    Expression<String>? allergies,
    Expression<String>? menopause,
    Expression<String>? lastMenstrualDate,
    Expression<String>? sexuallyActive,
    Expression<String>? contraception,
    Expression<String>? hivStatus,
    Expression<String>? pregnant,
    Expression<int>? liveBirths,
    Expression<int>? stillBirths,
    Expression<int>? abortions,
    Expression<int>? cesareans,
    Expression<int>? miscarriages,
    Expression<String>? hpvVaccination,
    Expression<String>? referralReason,
    Expression<String>? symptoms,
    Expression<String>? hpvTest,
    Expression<String>? hpvResult,
    Expression<String>? hpvDate,
    Expression<String>? hcgTest,
    Expression<String>? hcgDate,
    Expression<double>? hcgLevel,
    Expression<String>? patientSummary,
    Expression<String>? chiefComplaint,
    Expression<String>? cytologyReport,
    Expression<String>? pathologicalReport,
    Expression<String>? colposcopyFindings,
    Expression<String>? finalImpression,
    Expression<String>? remarks,
    Expression<String>? treatmentProvided,
    Expression<String>? precautions,
    Expression<String>? examiningPhysician,
    Expression<String>? forensicExamination,
    Expression<String>? examinationImages,
    Expression<String>? imageMetadata,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (doctorId != null) 'doctor_id': doctorId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (cloudId != null) 'cloud_id': cloudId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (patientName != null) 'patient_name': patientName,
      if (patientId != null) 'patient_id': patientId,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (dateOfVisit != null) 'date_of_visit': dateOfVisit,
      if (mobileNo != null) 'mobile_no': mobileNo,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (doctorName != null) 'doctor_name': doctorName,
      if (referredBy != null) 'referred_by': referredBy,
      if (smoking != null) 'smoking': smoking,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (medication != null) 'medication': medication,
      if (allergies != null) 'allergies': allergies,
      if (menopause != null) 'menopause': menopause,
      if (lastMenstrualDate != null) 'last_menstrual_date': lastMenstrualDate,
      if (sexuallyActive != null) 'sexually_active': sexuallyActive,
      if (contraception != null) 'contraception': contraception,
      if (hivStatus != null) 'hiv_status': hivStatus,
      if (pregnant != null) 'pregnant': pregnant,
      if (liveBirths != null) 'live_births': liveBirths,
      if (stillBirths != null) 'still_births': stillBirths,
      if (abortions != null) 'abortions': abortions,
      if (cesareans != null) 'cesareans': cesareans,
      if (miscarriages != null) 'miscarriages': miscarriages,
      if (hpvVaccination != null) 'hpv_vaccination': hpvVaccination,
      if (referralReason != null) 'referral_reason': referralReason,
      if (symptoms != null) 'symptoms': symptoms,
      if (hpvTest != null) 'hpv_test': hpvTest,
      if (hpvResult != null) 'hpv_result': hpvResult,
      if (hpvDate != null) 'hpv_date': hpvDate,
      if (hcgTest != null) 'hcg_test': hcgTest,
      if (hcgDate != null) 'hcg_date': hcgDate,
      if (hcgLevel != null) 'hcg_level': hcgLevel,
      if (patientSummary != null) 'patient_summary': patientSummary,
      if (chiefComplaint != null) 'chief_complaint': chiefComplaint,
      if (cytologyReport != null) 'cytology_report': cytologyReport,
      if (pathologicalReport != null) 'pathological_report': pathologicalReport,
      if (colposcopyFindings != null) 'colposcopy_findings': colposcopyFindings,
      if (finalImpression != null) 'final_impression': finalImpression,
      if (remarks != null) 'remarks': remarks,
      if (treatmentProvided != null) 'treatment_provided': treatmentProvided,
      if (precautions != null) 'precautions': precautions,
      if (examiningPhysician != null) 'examining_physician': examiningPhysician,
      if (forensicExamination != null)
        'forensic_examination': forensicExamination,
      if (examinationImages != null) 'examination_images': examinationImages,
      if (imageMetadata != null) 'image_metadata': imageMetadata,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PatientsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? doctorId,
    Value<String>? syncStatus,
    Value<String?>? cloudId,
    Value<String?>? deletedAt,
    Value<String>? patientName,
    Value<String?>? patientId,
    Value<String?>? dateOfBirth,
    Value<String?>? dateOfVisit,
    Value<String>? mobileNo,
    Value<String?>? email,
    Value<String?>? address,
    Value<String?>? doctorName,
    Value<String?>? referredBy,
    Value<String?>? smoking,
    Value<String?>? bloodGroup,
    Value<String?>? medication,
    Value<String?>? allergies,
    Value<String?>? menopause,
    Value<String?>? lastMenstrualDate,
    Value<String?>? sexuallyActive,
    Value<String?>? contraception,
    Value<String?>? hivStatus,
    Value<String?>? pregnant,
    Value<int?>? liveBirths,
    Value<int?>? stillBirths,
    Value<int?>? abortions,
    Value<int?>? cesareans,
    Value<int?>? miscarriages,
    Value<String?>? hpvVaccination,
    Value<String?>? referralReason,
    Value<String?>? symptoms,
    Value<String?>? hpvTest,
    Value<String?>? hpvResult,
    Value<String?>? hpvDate,
    Value<String?>? hcgTest,
    Value<String?>? hcgDate,
    Value<double?>? hcgLevel,
    Value<String?>? patientSummary,
    Value<String?>? chiefComplaint,
    Value<String?>? cytologyReport,
    Value<String?>? pathologicalReport,
    Value<String?>? colposcopyFindings,
    Value<String?>? finalImpression,
    Value<String?>? remarks,
    Value<String?>? treatmentProvided,
    Value<String?>? precautions,
    Value<String?>? examiningPhysician,
    Value<String?>? forensicExamination,
    Value<String?>? examinationImages,
    Value<String?>? imageMetadata,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
  }) {
    return PatientsCompanion(
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
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (doctorId.present) {
      map['doctor_id'] = Variable<String>(doctorId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (patientName.present) {
      map['patient_name'] = Variable<String>(patientName.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<String>(dateOfBirth.value);
    }
    if (dateOfVisit.present) {
      map['date_of_visit'] = Variable<String>(dateOfVisit.value);
    }
    if (mobileNo.present) {
      map['mobile_no'] = Variable<String>(mobileNo.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (doctorName.present) {
      map['doctor_name'] = Variable<String>(doctorName.value);
    }
    if (referredBy.present) {
      map['referred_by'] = Variable<String>(referredBy.value);
    }
    if (smoking.present) {
      map['smoking'] = Variable<String>(smoking.value);
    }
    if (bloodGroup.present) {
      map['blood_group'] = Variable<String>(bloodGroup.value);
    }
    if (medication.present) {
      map['medication'] = Variable<String>(medication.value);
    }
    if (allergies.present) {
      map['allergies'] = Variable<String>(allergies.value);
    }
    if (menopause.present) {
      map['menopause'] = Variable<String>(menopause.value);
    }
    if (lastMenstrualDate.present) {
      map['last_menstrual_date'] = Variable<String>(lastMenstrualDate.value);
    }
    if (sexuallyActive.present) {
      map['sexually_active'] = Variable<String>(sexuallyActive.value);
    }
    if (contraception.present) {
      map['contraception'] = Variable<String>(contraception.value);
    }
    if (hivStatus.present) {
      map['hiv_status'] = Variable<String>(hivStatus.value);
    }
    if (pregnant.present) {
      map['pregnant'] = Variable<String>(pregnant.value);
    }
    if (liveBirths.present) {
      map['live_births'] = Variable<int>(liveBirths.value);
    }
    if (stillBirths.present) {
      map['still_births'] = Variable<int>(stillBirths.value);
    }
    if (abortions.present) {
      map['abortions'] = Variable<int>(abortions.value);
    }
    if (cesareans.present) {
      map['cesareans'] = Variable<int>(cesareans.value);
    }
    if (miscarriages.present) {
      map['miscarriages'] = Variable<int>(miscarriages.value);
    }
    if (hpvVaccination.present) {
      map['hpv_vaccination'] = Variable<String>(hpvVaccination.value);
    }
    if (referralReason.present) {
      map['referral_reason'] = Variable<String>(referralReason.value);
    }
    if (symptoms.present) {
      map['symptoms'] = Variable<String>(symptoms.value);
    }
    if (hpvTest.present) {
      map['hpv_test'] = Variable<String>(hpvTest.value);
    }
    if (hpvResult.present) {
      map['hpv_result'] = Variable<String>(hpvResult.value);
    }
    if (hpvDate.present) {
      map['hpv_date'] = Variable<String>(hpvDate.value);
    }
    if (hcgTest.present) {
      map['hcg_test'] = Variable<String>(hcgTest.value);
    }
    if (hcgDate.present) {
      map['hcg_date'] = Variable<String>(hcgDate.value);
    }
    if (hcgLevel.present) {
      map['hcg_level'] = Variable<double>(hcgLevel.value);
    }
    if (patientSummary.present) {
      map['patient_summary'] = Variable<String>(patientSummary.value);
    }
    if (chiefComplaint.present) {
      map['chief_complaint'] = Variable<String>(chiefComplaint.value);
    }
    if (cytologyReport.present) {
      map['cytology_report'] = Variable<String>(cytologyReport.value);
    }
    if (pathologicalReport.present) {
      map['pathological_report'] = Variable<String>(pathologicalReport.value);
    }
    if (colposcopyFindings.present) {
      map['colposcopy_findings'] = Variable<String>(colposcopyFindings.value);
    }
    if (finalImpression.present) {
      map['final_impression'] = Variable<String>(finalImpression.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (treatmentProvided.present) {
      map['treatment_provided'] = Variable<String>(treatmentProvided.value);
    }
    if (precautions.present) {
      map['precautions'] = Variable<String>(precautions.value);
    }
    if (examiningPhysician.present) {
      map['examining_physician'] = Variable<String>(examiningPhysician.value);
    }
    if (forensicExamination.present) {
      map['forensic_examination'] = Variable<String>(forensicExamination.value);
    }
    if (examinationImages.present) {
      map['examination_images'] = Variable<String>(examinationImages.value);
    }
    if (imageMetadata.present) {
      map['image_metadata'] = Variable<String>(imageMetadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('doctorId: $doctorId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('cloudId: $cloudId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('patientName: $patientName, ')
          ..write('patientId: $patientId, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('dateOfVisit: $dateOfVisit, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('doctorName: $doctorName, ')
          ..write('referredBy: $referredBy, ')
          ..write('smoking: $smoking, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('medication: $medication, ')
          ..write('allergies: $allergies, ')
          ..write('menopause: $menopause, ')
          ..write('lastMenstrualDate: $lastMenstrualDate, ')
          ..write('sexuallyActive: $sexuallyActive, ')
          ..write('contraception: $contraception, ')
          ..write('hivStatus: $hivStatus, ')
          ..write('pregnant: $pregnant, ')
          ..write('liveBirths: $liveBirths, ')
          ..write('stillBirths: $stillBirths, ')
          ..write('abortions: $abortions, ')
          ..write('cesareans: $cesareans, ')
          ..write('miscarriages: $miscarriages, ')
          ..write('hpvVaccination: $hpvVaccination, ')
          ..write('referralReason: $referralReason, ')
          ..write('symptoms: $symptoms, ')
          ..write('hpvTest: $hpvTest, ')
          ..write('hpvResult: $hpvResult, ')
          ..write('hpvDate: $hpvDate, ')
          ..write('hcgTest: $hcgTest, ')
          ..write('hcgDate: $hcgDate, ')
          ..write('hcgLevel: $hcgLevel, ')
          ..write('patientSummary: $patientSummary, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('cytologyReport: $cytologyReport, ')
          ..write('pathologicalReport: $pathologicalReport, ')
          ..write('colposcopyFindings: $colposcopyFindings, ')
          ..write('finalImpression: $finalImpression, ')
          ..write('remarks: $remarks, ')
          ..write('treatmentProvided: $treatmentProvided, ')
          ..write('precautions: $precautions, ')
          ..write('examiningPhysician: $examiningPhysician, ')
          ..write('forensicExamination: $forensicExamination, ')
          ..write('examinationImages: $examinationImages, ')
          ..write('imageMetadata: $imageMetadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicalLicenseMeta = const VerificationMeta(
    'medicalLicense',
  );
  @override
  late final GeneratedColumn<String> medicalLicense = GeneratedColumn<String>(
    'medical_license',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hospitalMeta = const VerificationMeta(
    'hospital',
  );
  @override
  late final GeneratedColumn<String> hospital = GeneratedColumn<String>(
    'hospital',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastLoginMeta = const VerificationMeta(
    'lastLogin',
  );
  @override
  late final GeneratedColumn<String> lastLogin = GeneratedColumn<String>(
    'last_login',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileImageMeta = const VerificationMeta(
    'profileImage',
  );
  @override
  late final GeneratedColumn<String> profileImage = GeneratedColumn<String>(
    'profile_image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _specializationMeta = const VerificationMeta(
    'specialization',
  );
  @override
  late final GeneratedColumn<String> specialization = GeneratedColumn<String>(
    'specialization',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _departmentMeta = const VerificationMeta(
    'department',
  );
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
    'department',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reportHeaderImageMeta = const VerificationMeta(
    'reportHeaderImage',
  );
  @override
  late final GeneratedColumn<String> reportHeaderImage =
      GeneratedColumn<String>(
        'report_header_image',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reportFooterImageMeta = const VerificationMeta(
    'reportFooterImage',
  );
  @override
  late final GeneratedColumn<String> reportFooterImage =
      GeneratedColumn<String>(
        'report_footer_image',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _useReportHeaderFooterMeta =
      const VerificationMeta('useReportHeaderFooter');
  @override
  late final GeneratedColumn<bool> useReportHeaderFooter =
      GeneratedColumn<bool>(
        'use_report_header_footer',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("use_report_header_footer" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    email,
    password,
    medicalLicense,
    hospital,
    role,
    isActive,
    lastLogin,
    createdAt,
    updatedAt,
    profileImage,
    phoneNumber,
    specialization,
    department,
    reportHeaderImage,
    reportFooterImage,
    useReportHeaderFooter,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('medical_license')) {
      context.handle(
        _medicalLicenseMeta,
        medicalLicense.isAcceptableOrUnknown(
          data['medical_license']!,
          _medicalLicenseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicalLicenseMeta);
    }
    if (data.containsKey('hospital')) {
      context.handle(
        _hospitalMeta,
        hospital.isAcceptableOrUnknown(data['hospital']!, _hospitalMeta),
      );
    } else if (isInserting) {
      context.missing(_hospitalMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_login')) {
      context.handle(
        _lastLoginMeta,
        lastLogin.isAcceptableOrUnknown(data['last_login']!, _lastLoginMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('profile_image')) {
      context.handle(
        _profileImageMeta,
        profileImage.isAcceptableOrUnknown(
          data['profile_image']!,
          _profileImageMeta,
        ),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('specialization')) {
      context.handle(
        _specializationMeta,
        specialization.isAcceptableOrUnknown(
          data['specialization']!,
          _specializationMeta,
        ),
      );
    }
    if (data.containsKey('department')) {
      context.handle(
        _departmentMeta,
        department.isAcceptableOrUnknown(data['department']!, _departmentMeta),
      );
    }
    if (data.containsKey('report_header_image')) {
      context.handle(
        _reportHeaderImageMeta,
        reportHeaderImage.isAcceptableOrUnknown(
          data['report_header_image']!,
          _reportHeaderImageMeta,
        ),
      );
    }
    if (data.containsKey('report_footer_image')) {
      context.handle(
        _reportFooterImageMeta,
        reportFooterImage.isAcceptableOrUnknown(
          data['report_footer_image']!,
          _reportFooterImageMeta,
        ),
      );
    }
    if (data.containsKey('use_report_header_footer')) {
      context.handle(
        _useReportHeaderFooterMeta,
        useReportHeaderFooter.isAcceptableOrUnknown(
          data['use_report_header_footer']!,
          _useReportHeaderFooterMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      fullName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}full_name'],
          )!,
      email:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}email'],
          )!,
      password:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}password'],
          )!,
      medicalLicense:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}medical_license'],
          )!,
      hospital:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}hospital'],
          )!,
      role:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}role'],
          )!,
      isActive:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_active'],
          )!,
      lastLogin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_login'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      profileImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_image'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      specialization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specialization'],
      ),
      department: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}department'],
      ),
      reportHeaderImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_header_image'],
      ),
      reportFooterImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_footer_image'],
      ),
      useReportHeaderFooter:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}use_report_header_footer'],
          )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final int id;
  final String fullName;
  final String email;
  final String password;
  final String medicalLicense;
  final String hospital;
  final String role;
  final bool isActive;
  final String? lastLogin;
  final String? createdAt;
  final String? updatedAt;
  final String? profileImage;
  final String? phoneNumber;
  final String? specialization;
  final String? department;
  final String? reportHeaderImage;
  final String? reportFooterImage;
  final bool useReportHeaderFooter;
  const UserRow({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.medicalLicense,
    required this.hospital,
    required this.role,
    required this.isActive,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.profileImage,
    this.phoneNumber,
    this.specialization,
    this.department,
    this.reportHeaderImage,
    this.reportFooterImage,
    required this.useReportHeaderFooter,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['full_name'] = Variable<String>(fullName);
    map['email'] = Variable<String>(email);
    map['password'] = Variable<String>(password);
    map['medical_license'] = Variable<String>(medicalLicense);
    map['hospital'] = Variable<String>(hospital);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastLogin != null) {
      map['last_login'] = Variable<String>(lastLogin);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || profileImage != null) {
      map['profile_image'] = Variable<String>(profileImage);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    if (!nullToAbsent || specialization != null) {
      map['specialization'] = Variable<String>(specialization);
    }
    if (!nullToAbsent || department != null) {
      map['department'] = Variable<String>(department);
    }
    if (!nullToAbsent || reportHeaderImage != null) {
      map['report_header_image'] = Variable<String>(reportHeaderImage);
    }
    if (!nullToAbsent || reportFooterImage != null) {
      map['report_footer_image'] = Variable<String>(reportFooterImage);
    }
    map['use_report_header_footer'] = Variable<bool>(useReportHeaderFooter);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      fullName: Value(fullName),
      email: Value(email),
      password: Value(password),
      medicalLicense: Value(medicalLicense),
      hospital: Value(hospital),
      role: Value(role),
      isActive: Value(isActive),
      lastLogin:
          lastLogin == null && nullToAbsent
              ? const Value.absent()
              : Value(lastLogin),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      profileImage:
          profileImage == null && nullToAbsent
              ? const Value.absent()
              : Value(profileImage),
      phoneNumber:
          phoneNumber == null && nullToAbsent
              ? const Value.absent()
              : Value(phoneNumber),
      specialization:
          specialization == null && nullToAbsent
              ? const Value.absent()
              : Value(specialization),
      department:
          department == null && nullToAbsent
              ? const Value.absent()
              : Value(department),
      reportHeaderImage:
          reportHeaderImage == null && nullToAbsent
              ? const Value.absent()
              : Value(reportHeaderImage),
      reportFooterImage:
          reportFooterImage == null && nullToAbsent
              ? const Value.absent()
              : Value(reportFooterImage),
      useReportHeaderFooter: Value(useReportHeaderFooter),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<int>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      email: serializer.fromJson<String>(json['email']),
      password: serializer.fromJson<String>(json['password']),
      medicalLicense: serializer.fromJson<String>(json['medicalLicense']),
      hospital: serializer.fromJson<String>(json['hospital']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastLogin: serializer.fromJson<String?>(json['lastLogin']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      profileImage: serializer.fromJson<String?>(json['profileImage']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      specialization: serializer.fromJson<String?>(json['specialization']),
      department: serializer.fromJson<String?>(json['department']),
      reportHeaderImage: serializer.fromJson<String?>(
        json['reportHeaderImage'],
      ),
      reportFooterImage: serializer.fromJson<String?>(
        json['reportFooterImage'],
      ),
      useReportHeaderFooter: serializer.fromJson<bool>(
        json['useReportHeaderFooter'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fullName': serializer.toJson<String>(fullName),
      'email': serializer.toJson<String>(email),
      'password': serializer.toJson<String>(password),
      'medicalLicense': serializer.toJson<String>(medicalLicense),
      'hospital': serializer.toJson<String>(hospital),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'lastLogin': serializer.toJson<String?>(lastLogin),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'profileImage': serializer.toJson<String?>(profileImage),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'specialization': serializer.toJson<String?>(specialization),
      'department': serializer.toJson<String?>(department),
      'reportHeaderImage': serializer.toJson<String?>(reportHeaderImage),
      'reportFooterImage': serializer.toJson<String?>(reportFooterImage),
      'useReportHeaderFooter': serializer.toJson<bool>(useReportHeaderFooter),
    };
  }

  UserRow copyWith({
    int? id,
    String? fullName,
    String? email,
    String? password,
    String? medicalLicense,
    String? hospital,
    String? role,
    bool? isActive,
    Value<String?> lastLogin = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> profileImage = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
    Value<String?> specialization = const Value.absent(),
    Value<String?> department = const Value.absent(),
    Value<String?> reportHeaderImage = const Value.absent(),
    Value<String?> reportFooterImage = const Value.absent(),
    bool? useReportHeaderFooter,
  }) => UserRow(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    password: password ?? this.password,
    medicalLicense: medicalLicense ?? this.medicalLicense,
    hospital: hospital ?? this.hospital,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    lastLogin: lastLogin.present ? lastLogin.value : this.lastLogin,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    profileImage: profileImage.present ? profileImage.value : this.profileImage,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    specialization:
        specialization.present ? specialization.value : this.specialization,
    department: department.present ? department.value : this.department,
    reportHeaderImage:
        reportHeaderImage.present
            ? reportHeaderImage.value
            : this.reportHeaderImage,
    reportFooterImage:
        reportFooterImage.present
            ? reportFooterImage.value
            : this.reportFooterImage,
    useReportHeaderFooter: useReportHeaderFooter ?? this.useReportHeaderFooter,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      email: data.email.present ? data.email.value : this.email,
      password: data.password.present ? data.password.value : this.password,
      medicalLicense:
          data.medicalLicense.present
              ? data.medicalLicense.value
              : this.medicalLicense,
      hospital: data.hospital.present ? data.hospital.value : this.hospital,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastLogin: data.lastLogin.present ? data.lastLogin.value : this.lastLogin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      profileImage:
          data.profileImage.present
              ? data.profileImage.value
              : this.profileImage,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      specialization:
          data.specialization.present
              ? data.specialization.value
              : this.specialization,
      department:
          data.department.present ? data.department.value : this.department,
      reportHeaderImage:
          data.reportHeaderImage.present
              ? data.reportHeaderImage.value
              : this.reportHeaderImage,
      reportFooterImage:
          data.reportFooterImage.present
              ? data.reportFooterImage.value
              : this.reportFooterImage,
      useReportHeaderFooter:
          data.useReportHeaderFooter.present
              ? data.useReportHeaderFooter.value
              : this.useReportHeaderFooter,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('medicalLicense: $medicalLicense, ')
          ..write('hospital: $hospital, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('lastLogin: $lastLogin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('profileImage: $profileImage, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('specialization: $specialization, ')
          ..write('department: $department, ')
          ..write('reportHeaderImage: $reportHeaderImage, ')
          ..write('reportFooterImage: $reportFooterImage, ')
          ..write('useReportHeaderFooter: $useReportHeaderFooter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fullName,
    email,
    password,
    medicalLicense,
    hospital,
    role,
    isActive,
    lastLogin,
    createdAt,
    updatedAt,
    profileImage,
    phoneNumber,
    specialization,
    department,
    reportHeaderImage,
    reportFooterImage,
    useReportHeaderFooter,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.email == this.email &&
          other.password == this.password &&
          other.medicalLicense == this.medicalLicense &&
          other.hospital == this.hospital &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.lastLogin == this.lastLogin &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.profileImage == this.profileImage &&
          other.phoneNumber == this.phoneNumber &&
          other.specialization == this.specialization &&
          other.department == this.department &&
          other.reportHeaderImage == this.reportHeaderImage &&
          other.reportFooterImage == this.reportFooterImage &&
          other.useReportHeaderFooter == this.useReportHeaderFooter);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<int> id;
  final Value<String> fullName;
  final Value<String> email;
  final Value<String> password;
  final Value<String> medicalLicense;
  final Value<String> hospital;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<String?> lastLogin;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<String?> profileImage;
  final Value<String?> phoneNumber;
  final Value<String?> specialization;
  final Value<String?> department;
  final Value<String?> reportHeaderImage;
  final Value<String?> reportFooterImage;
  final Value<bool> useReportHeaderFooter;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.email = const Value.absent(),
    this.password = const Value.absent(),
    this.medicalLicense = const Value.absent(),
    this.hospital = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastLogin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.profileImage = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.specialization = const Value.absent(),
    this.department = const Value.absent(),
    this.reportHeaderImage = const Value.absent(),
    this.reportFooterImage = const Value.absent(),
    this.useReportHeaderFooter = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String fullName,
    required String email,
    required String password,
    required String medicalLicense,
    required String hospital,
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastLogin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.profileImage = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.specialization = const Value.absent(),
    this.department = const Value.absent(),
    this.reportHeaderImage = const Value.absent(),
    this.reportFooterImage = const Value.absent(),
    this.useReportHeaderFooter = const Value.absent(),
  }) : fullName = Value(fullName),
       email = Value(email),
       password = Value(password),
       medicalLicense = Value(medicalLicense),
       hospital = Value(hospital);
  static Insertable<UserRow> custom({
    Expression<int>? id,
    Expression<String>? fullName,
    Expression<String>? email,
    Expression<String>? password,
    Expression<String>? medicalLicense,
    Expression<String>? hospital,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<String>? lastLogin,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? profileImage,
    Expression<String>? phoneNumber,
    Expression<String>? specialization,
    Expression<String>? department,
    Expression<String>? reportHeaderImage,
    Expression<String>? reportFooterImage,
    Expression<bool>? useReportHeaderFooter,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (medicalLicense != null) 'medical_license': medicalLicense,
      if (hospital != null) 'hospital': hospital,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (lastLogin != null) 'last_login': lastLogin,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (profileImage != null) 'profile_image': profileImage,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (specialization != null) 'specialization': specialization,
      if (department != null) 'department': department,
      if (reportHeaderImage != null) 'report_header_image': reportHeaderImage,
      if (reportFooterImage != null) 'report_footer_image': reportFooterImage,
      if (useReportHeaderFooter != null)
        'use_report_header_footer': useReportHeaderFooter,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? fullName,
    Value<String>? email,
    Value<String>? password,
    Value<String>? medicalLicense,
    Value<String>? hospital,
    Value<String>? role,
    Value<bool>? isActive,
    Value<String?>? lastLogin,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<String?>? profileImage,
    Value<String?>? phoneNumber,
    Value<String?>? specialization,
    Value<String?>? department,
    Value<String?>? reportHeaderImage,
    Value<String?>? reportFooterImage,
    Value<bool>? useReportHeaderFooter,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      medicalLicense: medicalLicense ?? this.medicalLicense,
      hospital: hospital ?? this.hospital,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImage: profileImage ?? this.profileImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      specialization: specialization ?? this.specialization,
      department: department ?? this.department,
      reportHeaderImage: reportHeaderImage ?? this.reportHeaderImage,
      reportFooterImage: reportFooterImage ?? this.reportFooterImage,
      useReportHeaderFooter:
          useReportHeaderFooter ?? this.useReportHeaderFooter,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (medicalLicense.present) {
      map['medical_license'] = Variable<String>(medicalLicense.value);
    }
    if (hospital.present) {
      map['hospital'] = Variable<String>(hospital.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastLogin.present) {
      map['last_login'] = Variable<String>(lastLogin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (profileImage.present) {
      map['profile_image'] = Variable<String>(profileImage.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (specialization.present) {
      map['specialization'] = Variable<String>(specialization.value);
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (reportHeaderImage.present) {
      map['report_header_image'] = Variable<String>(reportHeaderImage.value);
    }
    if (reportFooterImage.present) {
      map['report_footer_image'] = Variable<String>(reportFooterImage.value);
    }
    if (useReportHeaderFooter.present) {
      map['use_report_header_footer'] = Variable<bool>(
        useReportHeaderFooter.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('medicalLicense: $medicalLicense, ')
          ..write('hospital: $hospital, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('lastLogin: $lastLogin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('profileImage: $profileImage, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('specialization: $specialization, ')
          ..write('department: $department, ')
          ..write('reportHeaderImage: $reportHeaderImage, ')
          ..write('reportFooterImage: $reportFooterImage, ')
          ..write('useReportHeaderFooter: $useReportHeaderFooter')
          ..write(')'))
        .toString();
  }
}

class $MediaFilesTable extends MediaFiles
    with TableInfo<$MediaFilesTable, MediaFileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _patientUuidMeta = const VerificationMeta(
    'patientUuid',
  );
  @override
  late final GeneratedColumn<String> patientUuid = GeneratedColumn<String>(
    'patient_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doctorIdMeta = const VerificationMeta(
    'doctorId',
  );
  @override
  late final GeneratedColumn<String> doctorId = GeneratedColumn<String>(
    'doctor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileTypeMeta = const VerificationMeta(
    'fileType',
  );
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
    'file_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cloudUrlMeta = const VerificationMeta(
    'cloudUrl',
  );
  @override
  late final GeneratedColumn<String> cloudUrl = GeneratedColumn<String>(
    'cloud_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_only'),
  );
  static const VerificationMeta _uploadAttemptsMeta = const VerificationMeta(
    'uploadAttempts',
  );
  @override
  late final GeneratedColumn<int> uploadAttempts = GeneratedColumn<int>(
    'upload_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<String> capturedAt = GeneratedColumn<String>(
    'captured_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    patientUuid,
    doctorId,
    fileType,
    localPath,
    cloudUrl,
    fileName,
    mimeType,
    fileSize,
    checksum,
    syncStatus,
    uploadAttempts,
    deletedAt,
    capturedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaFileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('patient_uuid')) {
      context.handle(
        _patientUuidMeta,
        patientUuid.isAcceptableOrUnknown(
          data['patient_uuid']!,
          _patientUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientUuidMeta);
    }
    if (data.containsKey('doctor_id')) {
      context.handle(
        _doctorIdMeta,
        doctorId.isAcceptableOrUnknown(data['doctor_id']!, _doctorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_doctorIdMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(
        _fileTypeMeta,
        fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('cloud_url')) {
      context.handle(
        _cloudUrlMeta,
        cloudUrl.isAcceptableOrUnknown(data['cloud_url']!, _cloudUrlMeta),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('upload_attempts')) {
      context.handle(
        _uploadAttemptsMeta,
        uploadAttempts.isAcceptableOrUnknown(
          data['upload_attempts']!,
          _uploadAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaFileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaFileRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      uuid:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}uuid'],
          )!,
      patientUuid:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_uuid'],
          )!,
      doctorId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}doctor_id'],
          )!,
      fileType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_type'],
          )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      cloudUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_url'],
      ),
      fileName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_name'],
          )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      ),
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sync_status'],
          )!,
      uploadAttempts:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}upload_attempts'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}captured_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $MediaFilesTable createAlias(String alias) {
    return $MediaFilesTable(attachedDatabase, alias);
  }
}

class MediaFileRow extends DataClass implements Insertable<MediaFileRow> {
  final int id;
  final String uuid;
  final String patientUuid;
  final String doctorId;
  final String fileType;
  final String? localPath;
  final String? cloudUrl;
  final String fileName;
  final String? mimeType;
  final int? fileSize;
  final String? checksum;
  final String syncStatus;
  final int uploadAttempts;
  final String? deletedAt;
  final String? capturedAt;
  final String? createdAt;
  final String? updatedAt;
  const MediaFileRow({
    required this.id,
    required this.uuid,
    required this.patientUuid,
    required this.doctorId,
    required this.fileType,
    this.localPath,
    this.cloudUrl,
    required this.fileName,
    this.mimeType,
    this.fileSize,
    this.checksum,
    required this.syncStatus,
    required this.uploadAttempts,
    this.deletedAt,
    this.capturedAt,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['patient_uuid'] = Variable<String>(patientUuid);
    map['doctor_id'] = Variable<String>(doctorId);
    map['file_type'] = Variable<String>(fileType);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || cloudUrl != null) {
      map['cloud_url'] = Variable<String>(cloudUrl);
    }
    map['file_name'] = Variable<String>(fileName);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['upload_attempts'] = Variable<int>(uploadAttempts);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || capturedAt != null) {
      map['captured_at'] = Variable<String>(capturedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  MediaFilesCompanion toCompanion(bool nullToAbsent) {
    return MediaFilesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      patientUuid: Value(patientUuid),
      doctorId: Value(doctorId),
      fileType: Value(fileType),
      localPath:
          localPath == null && nullToAbsent
              ? const Value.absent()
              : Value(localPath),
      cloudUrl:
          cloudUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(cloudUrl),
      fileName: Value(fileName),
      mimeType:
          mimeType == null && nullToAbsent
              ? const Value.absent()
              : Value(mimeType),
      fileSize:
          fileSize == null && nullToAbsent
              ? const Value.absent()
              : Value(fileSize),
      checksum:
          checksum == null && nullToAbsent
              ? const Value.absent()
              : Value(checksum),
      syncStatus: Value(syncStatus),
      uploadAttempts: Value(uploadAttempts),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      capturedAt:
          capturedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(capturedAt),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
    );
  }

  factory MediaFileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaFileRow(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      patientUuid: serializer.fromJson<String>(json['patientUuid']),
      doctorId: serializer.fromJson<String>(json['doctorId']),
      fileType: serializer.fromJson<String>(json['fileType']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      cloudUrl: serializer.fromJson<String?>(json['cloudUrl']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      checksum: serializer.fromJson<String?>(json['checksum']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      uploadAttempts: serializer.fromJson<int>(json['uploadAttempts']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      capturedAt: serializer.fromJson<String?>(json['capturedAt']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'patientUuid': serializer.toJson<String>(patientUuid),
      'doctorId': serializer.toJson<String>(doctorId),
      'fileType': serializer.toJson<String>(fileType),
      'localPath': serializer.toJson<String?>(localPath),
      'cloudUrl': serializer.toJson<String?>(cloudUrl),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String?>(mimeType),
      'fileSize': serializer.toJson<int?>(fileSize),
      'checksum': serializer.toJson<String?>(checksum),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'uploadAttempts': serializer.toJson<int>(uploadAttempts),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'capturedAt': serializer.toJson<String?>(capturedAt),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  MediaFileRow copyWith({
    int? id,
    String? uuid,
    String? patientUuid,
    String? doctorId,
    String? fileType,
    Value<String?> localPath = const Value.absent(),
    Value<String?> cloudUrl = const Value.absent(),
    String? fileName,
    Value<String?> mimeType = const Value.absent(),
    Value<int?> fileSize = const Value.absent(),
    Value<String?> checksum = const Value.absent(),
    String? syncStatus,
    int? uploadAttempts,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> capturedAt = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => MediaFileRow(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    patientUuid: patientUuid ?? this.patientUuid,
    doctorId: doctorId ?? this.doctorId,
    fileType: fileType ?? this.fileType,
    localPath: localPath.present ? localPath.value : this.localPath,
    cloudUrl: cloudUrl.present ? cloudUrl.value : this.cloudUrl,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    checksum: checksum.present ? checksum.value : this.checksum,
    syncStatus: syncStatus ?? this.syncStatus,
    uploadAttempts: uploadAttempts ?? this.uploadAttempts,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    capturedAt: capturedAt.present ? capturedAt.value : this.capturedAt,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  MediaFileRow copyWithCompanion(MediaFilesCompanion data) {
    return MediaFileRow(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      patientUuid:
          data.patientUuid.present ? data.patientUuid.value : this.patientUuid,
      doctorId: data.doctorId.present ? data.doctorId.value : this.doctorId,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      cloudUrl: data.cloudUrl.present ? data.cloudUrl.value : this.cloudUrl,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      uploadAttempts:
          data.uploadAttempts.present
              ? data.uploadAttempts.value
              : this.uploadAttempts,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaFileRow(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('patientUuid: $patientUuid, ')
          ..write('doctorId: $doctorId, ')
          ..write('fileType: $fileType, ')
          ..write('localPath: $localPath, ')
          ..write('cloudUrl: $cloudUrl, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('checksum: $checksum, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('uploadAttempts: $uploadAttempts, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    patientUuid,
    doctorId,
    fileType,
    localPath,
    cloudUrl,
    fileName,
    mimeType,
    fileSize,
    checksum,
    syncStatus,
    uploadAttempts,
    deletedAt,
    capturedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaFileRow &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.patientUuid == this.patientUuid &&
          other.doctorId == this.doctorId &&
          other.fileType == this.fileType &&
          other.localPath == this.localPath &&
          other.cloudUrl == this.cloudUrl &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.fileSize == this.fileSize &&
          other.checksum == this.checksum &&
          other.syncStatus == this.syncStatus &&
          other.uploadAttempts == this.uploadAttempts &&
          other.deletedAt == this.deletedAt &&
          other.capturedAt == this.capturedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MediaFilesCompanion extends UpdateCompanion<MediaFileRow> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> patientUuid;
  final Value<String> doctorId;
  final Value<String> fileType;
  final Value<String?> localPath;
  final Value<String?> cloudUrl;
  final Value<String> fileName;
  final Value<String?> mimeType;
  final Value<int?> fileSize;
  final Value<String?> checksum;
  final Value<String> syncStatus;
  final Value<int> uploadAttempts;
  final Value<String?> deletedAt;
  final Value<String?> capturedAt;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  const MediaFilesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.patientUuid = const Value.absent(),
    this.doctorId = const Value.absent(),
    this.fileType = const Value.absent(),
    this.localPath = const Value.absent(),
    this.cloudUrl = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.checksum = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.uploadAttempts = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MediaFilesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String patientUuid,
    required String doctorId,
    required String fileType,
    this.localPath = const Value.absent(),
    this.cloudUrl = const Value.absent(),
    required String fileName,
    this.mimeType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.checksum = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.uploadAttempts = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : uuid = Value(uuid),
       patientUuid = Value(patientUuid),
       doctorId = Value(doctorId),
       fileType = Value(fileType),
       fileName = Value(fileName);
  static Insertable<MediaFileRow> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? patientUuid,
    Expression<String>? doctorId,
    Expression<String>? fileType,
    Expression<String>? localPath,
    Expression<String>? cloudUrl,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? fileSize,
    Expression<String>? checksum,
    Expression<String>? syncStatus,
    Expression<int>? uploadAttempts,
    Expression<String>? deletedAt,
    Expression<String>? capturedAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (patientUuid != null) 'patient_uuid': patientUuid,
      if (doctorId != null) 'doctor_id': doctorId,
      if (fileType != null) 'file_type': fileType,
      if (localPath != null) 'local_path': localPath,
      if (cloudUrl != null) 'cloud_url': cloudUrl,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileSize != null) 'file_size': fileSize,
      if (checksum != null) 'checksum': checksum,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (uploadAttempts != null) 'upload_attempts': uploadAttempts,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MediaFilesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? patientUuid,
    Value<String>? doctorId,
    Value<String>? fileType,
    Value<String?>? localPath,
    Value<String?>? cloudUrl,
    Value<String>? fileName,
    Value<String?>? mimeType,
    Value<int?>? fileSize,
    Value<String?>? checksum,
    Value<String>? syncStatus,
    Value<int>? uploadAttempts,
    Value<String?>? deletedAt,
    Value<String?>? capturedAt,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
  }) {
    return MediaFilesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      patientUuid: patientUuid ?? this.patientUuid,
      doctorId: doctorId ?? this.doctorId,
      fileType: fileType ?? this.fileType,
      localPath: localPath ?? this.localPath,
      cloudUrl: cloudUrl ?? this.cloudUrl,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      checksum: checksum ?? this.checksum,
      syncStatus: syncStatus ?? this.syncStatus,
      uploadAttempts: uploadAttempts ?? this.uploadAttempts,
      deletedAt: deletedAt ?? this.deletedAt,
      capturedAt: capturedAt ?? this.capturedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (patientUuid.present) {
      map['patient_uuid'] = Variable<String>(patientUuid.value);
    }
    if (doctorId.present) {
      map['doctor_id'] = Variable<String>(doctorId.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (cloudUrl.present) {
      map['cloud_url'] = Variable<String>(cloudUrl.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (uploadAttempts.present) {
      map['upload_attempts'] = Variable<int>(uploadAttempts.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<String>(capturedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaFilesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('patientUuid: $patientUuid, ')
          ..write('doctorId: $doctorId, ')
          ..write('fileType: $fileType, ')
          ..write('localPath: $localPath, ')
          ..write('cloudUrl: $cloudUrl, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('checksum: $checksum, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('uploadAttempts: $uploadAttempts, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityUuidMeta = const VerificationMeta(
    'entityUuid',
  );
  @override
  late final GeneratedColumn<String> entityUuid = GeneratedColumn<String>(
    'entity_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<String> lastAttemptAt = GeneratedColumn<String>(
    'last_attempt_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityUuid,
    operation,
    payload,
    attempts,
    lastAttemptAt,
    lastError,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_uuid')) {
      context.handle(
        _entityUuidMeta,
        entityUuid.isAcceptableOrUnknown(data['entity_uuid']!, _entityUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_entityUuidMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      entityType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_type'],
          )!,
      entityUuid:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_uuid'],
          )!,
      operation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}operation'],
          )!,
      payload:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payload'],
          )!,
      attempts:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}attempts'],
          )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueRow extends DataClass implements Insertable<SyncQueueRow> {
  final int id;
  final String entityType;
  final String entityUuid;
  final String operation;
  final String payload;
  final int attempts;
  final String? lastAttemptAt;
  final String? lastError;
  final String createdAt;
  const SyncQueueRow({
    required this.id,
    required this.entityType,
    required this.entityUuid,
    required this.operation,
    required this.payload,
    required this.attempts,
    this.lastAttemptAt,
    this.lastError,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_uuid'] = Variable<String>(entityUuid);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<String>(lastAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityUuid: Value(entityUuid),
      operation: Value(operation),
      payload: Value(payload),
      attempts: Value(attempts),
      lastAttemptAt:
          lastAttemptAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastAttemptAt),
      lastError:
          lastError == null && nullToAbsent
              ? const Value.absent()
              : Value(lastError),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueRow(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityUuid: serializer.fromJson<String>(json['entityUuid']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastAttemptAt: serializer.fromJson<String?>(json['lastAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityUuid': serializer.toJson<String>(entityUuid),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'attempts': serializer.toJson<int>(attempts),
      'lastAttemptAt': serializer.toJson<String?>(lastAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  SyncQueueRow copyWith({
    int? id,
    String? entityType,
    String? entityUuid,
    String? operation,
    String? payload,
    int? attempts,
    Value<String?> lastAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    String? createdAt,
  }) => SyncQueueRow(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityUuid: entityUuid ?? this.entityUuid,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    attempts: attempts ?? this.attempts,
    lastAttemptAt:
        lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueRow copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueRow(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityUuid:
          data.entityUuid.present ? data.entityUuid.value : this.entityUuid,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastAttemptAt:
          data.lastAttemptAt.present
              ? data.lastAttemptAt.value
              : this.lastAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityUuid: $entityUuid, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityUuid,
    operation,
    payload,
    attempts,
    lastAttemptAt,
    lastError,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityUuid == this.entityUuid &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.attempts == this.attempts &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueRow> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityUuid;
  final Value<String> operation;
  final Value<String> payload;
  final Value<int> attempts;
  final Value<String?> lastAttemptAt;
  final Value<String?> lastError;
  final Value<String> createdAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityUuid = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityUuid,
    required String operation,
    required String payload,
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    required String createdAt,
  }) : entityType = Value(entityType),
       entityUuid = Value(entityUuid),
       operation = Value(operation),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueRow> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityUuid,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<int>? attempts,
    Expression<String>? lastAttemptAt,
    Expression<String>? lastError,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityUuid != null) 'entity_uuid': entityUuid,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (attempts != null) 'attempts': attempts,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entityUuid,
    Value<String>? operation,
    Value<String>? payload,
    Value<int>? attempts,
    Value<String?>? lastAttemptAt,
    Value<String?>? lastError,
    Value<String>? createdAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityUuid: entityUuid ?? this.entityUuid,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      attempts: attempts ?? this.attempts,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityUuid.present) {
      map['entity_uuid'] = Variable<String>(entityUuid.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<String>(lastAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityUuid: $entityUuid, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TeleCasesTable extends TeleCases
    with TableInfo<$TeleCasesTable, TeleCaseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeleCasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _diagnosticDoctorIdMeta =
      const VerificationMeta('diagnosticDoctorId');
  @override
  late final GeneratedColumn<String> diagnosticDoctorId =
      GeneratedColumn<String>(
        'diagnostic_doctor_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _patientUuidMeta = const VerificationMeta(
    'patientUuid',
  );
  @override
  late final GeneratedColumn<String> patientUuid = GeneratedColumn<String>(
    'patient_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reporterDoctorIdMeta = const VerificationMeta(
    'reporterDoctorId',
  );
  @override
  late final GeneratedColumn<String> reporterDoctorId = GeneratedColumn<String>(
    'reporter_doctor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _submissionNotesMeta = const VerificationMeta(
    'submissionNotes',
  );
  @override
  late final GeneratedColumn<String> submissionNotes = GeneratedColumn<String>(
    'submission_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reportFindingsMeta = const VerificationMeta(
    'reportFindings',
  );
  @override
  late final GeneratedColumn<String> reportFindings = GeneratedColumn<String>(
    'report_findings',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reportImpressionMeta = const VerificationMeta(
    'reportImpression',
  );
  @override
  late final GeneratedColumn<String> reportImpression = GeneratedColumn<String>(
    'report_impression',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reportRemarksMeta = const VerificationMeta(
    'reportRemarks',
  );
  @override
  late final GeneratedColumn<String> reportRemarks = GeneratedColumn<String>(
    'report_remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slaDeadlineMeta = const VerificationMeta(
    'slaDeadline',
  );
  @override
  late final GeneratedColumn<String> slaDeadline = GeneratedColumn<String>(
    'sla_deadline',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<String> completedAt = GeneratedColumn<String>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creditsUsedMeta = const VerificationMeta(
    'creditsUsed',
  );
  @override
  late final GeneratedColumn<int> creditsUsed = GeneratedColumn<int>(
    'credits_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_only'),
  );
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<String> submittedAt = GeneratedColumn<String>(
    'submitted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    diagnosticDoctorId,
    patientUuid,
    reporterDoctorId,
    status,
    submissionNotes,
    reportFindings,
    reportImpression,
    reportRemarks,
    slaDeadline,
    completedAt,
    creditsUsed,
    syncStatus,
    cloudId,
    submittedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tele_cases';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeleCaseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('diagnostic_doctor_id')) {
      context.handle(
        _diagnosticDoctorIdMeta,
        diagnosticDoctorId.isAcceptableOrUnknown(
          data['diagnostic_doctor_id']!,
          _diagnosticDoctorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diagnosticDoctorIdMeta);
    }
    if (data.containsKey('patient_uuid')) {
      context.handle(
        _patientUuidMeta,
        patientUuid.isAcceptableOrUnknown(
          data['patient_uuid']!,
          _patientUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientUuidMeta);
    }
    if (data.containsKey('reporter_doctor_id')) {
      context.handle(
        _reporterDoctorIdMeta,
        reporterDoctorId.isAcceptableOrUnknown(
          data['reporter_doctor_id']!,
          _reporterDoctorIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('submission_notes')) {
      context.handle(
        _submissionNotesMeta,
        submissionNotes.isAcceptableOrUnknown(
          data['submission_notes']!,
          _submissionNotesMeta,
        ),
      );
    }
    if (data.containsKey('report_findings')) {
      context.handle(
        _reportFindingsMeta,
        reportFindings.isAcceptableOrUnknown(
          data['report_findings']!,
          _reportFindingsMeta,
        ),
      );
    }
    if (data.containsKey('report_impression')) {
      context.handle(
        _reportImpressionMeta,
        reportImpression.isAcceptableOrUnknown(
          data['report_impression']!,
          _reportImpressionMeta,
        ),
      );
    }
    if (data.containsKey('report_remarks')) {
      context.handle(
        _reportRemarksMeta,
        reportRemarks.isAcceptableOrUnknown(
          data['report_remarks']!,
          _reportRemarksMeta,
        ),
      );
    }
    if (data.containsKey('sla_deadline')) {
      context.handle(
        _slaDeadlineMeta,
        slaDeadline.isAcceptableOrUnknown(
          data['sla_deadline']!,
          _slaDeadlineMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('credits_used')) {
      context.handle(
        _creditsUsedMeta,
        creditsUsed.isAcceptableOrUnknown(
          data['credits_used']!,
          _creditsUsedMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeleCaseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeleCaseRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      uuid:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}uuid'],
          )!,
      diagnosticDoctorId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}diagnostic_doctor_id'],
          )!,
      patientUuid:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_uuid'],
          )!,
      reporterDoctorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reporter_doctor_id'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      submissionNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}submission_notes'],
      ),
      reportFindings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_findings'],
      ),
      reportImpression: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_impression'],
      ),
      reportRemarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_remarks'],
      ),
      slaDeadline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sla_deadline'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_at'],
      ),
      creditsUsed:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}credits_used'],
          )!,
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sync_status'],
          )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}submitted_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TeleCasesTable createAlias(String alias) {
    return $TeleCasesTable(attachedDatabase, alias);
  }
}

class TeleCaseRow extends DataClass implements Insertable<TeleCaseRow> {
  final int id;
  final String uuid;
  final String diagnosticDoctorId;
  final String patientUuid;
  final String? reporterDoctorId;
  final String status;
  final String? submissionNotes;
  final String? reportFindings;
  final String? reportImpression;
  final String? reportRemarks;
  final String? slaDeadline;
  final String? completedAt;
  final int creditsUsed;
  final String syncStatus;
  final String? cloudId;
  final String? submittedAt;
  final String? updatedAt;
  const TeleCaseRow({
    required this.id,
    required this.uuid,
    required this.diagnosticDoctorId,
    required this.patientUuid,
    this.reporterDoctorId,
    required this.status,
    this.submissionNotes,
    this.reportFindings,
    this.reportImpression,
    this.reportRemarks,
    this.slaDeadline,
    this.completedAt,
    required this.creditsUsed,
    required this.syncStatus,
    this.cloudId,
    this.submittedAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['diagnostic_doctor_id'] = Variable<String>(diagnosticDoctorId);
    map['patient_uuid'] = Variable<String>(patientUuid);
    if (!nullToAbsent || reporterDoctorId != null) {
      map['reporter_doctor_id'] = Variable<String>(reporterDoctorId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || submissionNotes != null) {
      map['submission_notes'] = Variable<String>(submissionNotes);
    }
    if (!nullToAbsent || reportFindings != null) {
      map['report_findings'] = Variable<String>(reportFindings);
    }
    if (!nullToAbsent || reportImpression != null) {
      map['report_impression'] = Variable<String>(reportImpression);
    }
    if (!nullToAbsent || reportRemarks != null) {
      map['report_remarks'] = Variable<String>(reportRemarks);
    }
    if (!nullToAbsent || slaDeadline != null) {
      map['sla_deadline'] = Variable<String>(slaDeadline);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<String>(completedAt);
    }
    map['credits_used'] = Variable<int>(creditsUsed);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    if (!nullToAbsent || submittedAt != null) {
      map['submitted_at'] = Variable<String>(submittedAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  TeleCasesCompanion toCompanion(bool nullToAbsent) {
    return TeleCasesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      diagnosticDoctorId: Value(diagnosticDoctorId),
      patientUuid: Value(patientUuid),
      reporterDoctorId:
          reporterDoctorId == null && nullToAbsent
              ? const Value.absent()
              : Value(reporterDoctorId),
      status: Value(status),
      submissionNotes:
          submissionNotes == null && nullToAbsent
              ? const Value.absent()
              : Value(submissionNotes),
      reportFindings:
          reportFindings == null && nullToAbsent
              ? const Value.absent()
              : Value(reportFindings),
      reportImpression:
          reportImpression == null && nullToAbsent
              ? const Value.absent()
              : Value(reportImpression),
      reportRemarks:
          reportRemarks == null && nullToAbsent
              ? const Value.absent()
              : Value(reportRemarks),
      slaDeadline:
          slaDeadline == null && nullToAbsent
              ? const Value.absent()
              : Value(slaDeadline),
      completedAt:
          completedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(completedAt),
      creditsUsed: Value(creditsUsed),
      syncStatus: Value(syncStatus),
      cloudId:
          cloudId == null && nullToAbsent
              ? const Value.absent()
              : Value(cloudId),
      submittedAt:
          submittedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(submittedAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
    );
  }

  factory TeleCaseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeleCaseRow(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      diagnosticDoctorId: serializer.fromJson<String>(
        json['diagnosticDoctorId'],
      ),
      patientUuid: serializer.fromJson<String>(json['patientUuid']),
      reporterDoctorId: serializer.fromJson<String?>(json['reporterDoctorId']),
      status: serializer.fromJson<String>(json['status']),
      submissionNotes: serializer.fromJson<String?>(json['submissionNotes']),
      reportFindings: serializer.fromJson<String?>(json['reportFindings']),
      reportImpression: serializer.fromJson<String?>(json['reportImpression']),
      reportRemarks: serializer.fromJson<String?>(json['reportRemarks']),
      slaDeadline: serializer.fromJson<String?>(json['slaDeadline']),
      completedAt: serializer.fromJson<String?>(json['completedAt']),
      creditsUsed: serializer.fromJson<int>(json['creditsUsed']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      submittedAt: serializer.fromJson<String?>(json['submittedAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'diagnosticDoctorId': serializer.toJson<String>(diagnosticDoctorId),
      'patientUuid': serializer.toJson<String>(patientUuid),
      'reporterDoctorId': serializer.toJson<String?>(reporterDoctorId),
      'status': serializer.toJson<String>(status),
      'submissionNotes': serializer.toJson<String?>(submissionNotes),
      'reportFindings': serializer.toJson<String?>(reportFindings),
      'reportImpression': serializer.toJson<String?>(reportImpression),
      'reportRemarks': serializer.toJson<String?>(reportRemarks),
      'slaDeadline': serializer.toJson<String?>(slaDeadline),
      'completedAt': serializer.toJson<String?>(completedAt),
      'creditsUsed': serializer.toJson<int>(creditsUsed),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'cloudId': serializer.toJson<String?>(cloudId),
      'submittedAt': serializer.toJson<String?>(submittedAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  TeleCaseRow copyWith({
    int? id,
    String? uuid,
    String? diagnosticDoctorId,
    String? patientUuid,
    Value<String?> reporterDoctorId = const Value.absent(),
    String? status,
    Value<String?> submissionNotes = const Value.absent(),
    Value<String?> reportFindings = const Value.absent(),
    Value<String?> reportImpression = const Value.absent(),
    Value<String?> reportRemarks = const Value.absent(),
    Value<String?> slaDeadline = const Value.absent(),
    Value<String?> completedAt = const Value.absent(),
    int? creditsUsed,
    String? syncStatus,
    Value<String?> cloudId = const Value.absent(),
    Value<String?> submittedAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => TeleCaseRow(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    diagnosticDoctorId: diagnosticDoctorId ?? this.diagnosticDoctorId,
    patientUuid: patientUuid ?? this.patientUuid,
    reporterDoctorId:
        reporterDoctorId.present
            ? reporterDoctorId.value
            : this.reporterDoctorId,
    status: status ?? this.status,
    submissionNotes:
        submissionNotes.present ? submissionNotes.value : this.submissionNotes,
    reportFindings:
        reportFindings.present ? reportFindings.value : this.reportFindings,
    reportImpression:
        reportImpression.present
            ? reportImpression.value
            : this.reportImpression,
    reportRemarks:
        reportRemarks.present ? reportRemarks.value : this.reportRemarks,
    slaDeadline: slaDeadline.present ? slaDeadline.value : this.slaDeadline,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    creditsUsed: creditsUsed ?? this.creditsUsed,
    syncStatus: syncStatus ?? this.syncStatus,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    submittedAt: submittedAt.present ? submittedAt.value : this.submittedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  TeleCaseRow copyWithCompanion(TeleCasesCompanion data) {
    return TeleCaseRow(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      diagnosticDoctorId:
          data.diagnosticDoctorId.present
              ? data.diagnosticDoctorId.value
              : this.diagnosticDoctorId,
      patientUuid:
          data.patientUuid.present ? data.patientUuid.value : this.patientUuid,
      reporterDoctorId:
          data.reporterDoctorId.present
              ? data.reporterDoctorId.value
              : this.reporterDoctorId,
      status: data.status.present ? data.status.value : this.status,
      submissionNotes:
          data.submissionNotes.present
              ? data.submissionNotes.value
              : this.submissionNotes,
      reportFindings:
          data.reportFindings.present
              ? data.reportFindings.value
              : this.reportFindings,
      reportImpression:
          data.reportImpression.present
              ? data.reportImpression.value
              : this.reportImpression,
      reportRemarks:
          data.reportRemarks.present
              ? data.reportRemarks.value
              : this.reportRemarks,
      slaDeadline:
          data.slaDeadline.present ? data.slaDeadline.value : this.slaDeadline,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      creditsUsed:
          data.creditsUsed.present ? data.creditsUsed.value : this.creditsUsed,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      submittedAt:
          data.submittedAt.present ? data.submittedAt.value : this.submittedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeleCaseRow(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('diagnosticDoctorId: $diagnosticDoctorId, ')
          ..write('patientUuid: $patientUuid, ')
          ..write('reporterDoctorId: $reporterDoctorId, ')
          ..write('status: $status, ')
          ..write('submissionNotes: $submissionNotes, ')
          ..write('reportFindings: $reportFindings, ')
          ..write('reportImpression: $reportImpression, ')
          ..write('reportRemarks: $reportRemarks, ')
          ..write('slaDeadline: $slaDeadline, ')
          ..write('completedAt: $completedAt, ')
          ..write('creditsUsed: $creditsUsed, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('cloudId: $cloudId, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    diagnosticDoctorId,
    patientUuid,
    reporterDoctorId,
    status,
    submissionNotes,
    reportFindings,
    reportImpression,
    reportRemarks,
    slaDeadline,
    completedAt,
    creditsUsed,
    syncStatus,
    cloudId,
    submittedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeleCaseRow &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.diagnosticDoctorId == this.diagnosticDoctorId &&
          other.patientUuid == this.patientUuid &&
          other.reporterDoctorId == this.reporterDoctorId &&
          other.status == this.status &&
          other.submissionNotes == this.submissionNotes &&
          other.reportFindings == this.reportFindings &&
          other.reportImpression == this.reportImpression &&
          other.reportRemarks == this.reportRemarks &&
          other.slaDeadline == this.slaDeadline &&
          other.completedAt == this.completedAt &&
          other.creditsUsed == this.creditsUsed &&
          other.syncStatus == this.syncStatus &&
          other.cloudId == this.cloudId &&
          other.submittedAt == this.submittedAt &&
          other.updatedAt == this.updatedAt);
}

class TeleCasesCompanion extends UpdateCompanion<TeleCaseRow> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> diagnosticDoctorId;
  final Value<String> patientUuid;
  final Value<String?> reporterDoctorId;
  final Value<String> status;
  final Value<String?> submissionNotes;
  final Value<String?> reportFindings;
  final Value<String?> reportImpression;
  final Value<String?> reportRemarks;
  final Value<String?> slaDeadline;
  final Value<String?> completedAt;
  final Value<int> creditsUsed;
  final Value<String> syncStatus;
  final Value<String?> cloudId;
  final Value<String?> submittedAt;
  final Value<String?> updatedAt;
  const TeleCasesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.diagnosticDoctorId = const Value.absent(),
    this.patientUuid = const Value.absent(),
    this.reporterDoctorId = const Value.absent(),
    this.status = const Value.absent(),
    this.submissionNotes = const Value.absent(),
    this.reportFindings = const Value.absent(),
    this.reportImpression = const Value.absent(),
    this.reportRemarks = const Value.absent(),
    this.slaDeadline = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.creditsUsed = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TeleCasesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String diagnosticDoctorId,
    required String patientUuid,
    this.reporterDoctorId = const Value.absent(),
    this.status = const Value.absent(),
    this.submissionNotes = const Value.absent(),
    this.reportFindings = const Value.absent(),
    this.reportImpression = const Value.absent(),
    this.reportRemarks = const Value.absent(),
    this.slaDeadline = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.creditsUsed = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : uuid = Value(uuid),
       diagnosticDoctorId = Value(diagnosticDoctorId),
       patientUuid = Value(patientUuid);
  static Insertable<TeleCaseRow> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? diagnosticDoctorId,
    Expression<String>? patientUuid,
    Expression<String>? reporterDoctorId,
    Expression<String>? status,
    Expression<String>? submissionNotes,
    Expression<String>? reportFindings,
    Expression<String>? reportImpression,
    Expression<String>? reportRemarks,
    Expression<String>? slaDeadline,
    Expression<String>? completedAt,
    Expression<int>? creditsUsed,
    Expression<String>? syncStatus,
    Expression<String>? cloudId,
    Expression<String>? submittedAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (diagnosticDoctorId != null)
        'diagnostic_doctor_id': diagnosticDoctorId,
      if (patientUuid != null) 'patient_uuid': patientUuid,
      if (reporterDoctorId != null) 'reporter_doctor_id': reporterDoctorId,
      if (status != null) 'status': status,
      if (submissionNotes != null) 'submission_notes': submissionNotes,
      if (reportFindings != null) 'report_findings': reportFindings,
      if (reportImpression != null) 'report_impression': reportImpression,
      if (reportRemarks != null) 'report_remarks': reportRemarks,
      if (slaDeadline != null) 'sla_deadline': slaDeadline,
      if (completedAt != null) 'completed_at': completedAt,
      if (creditsUsed != null) 'credits_used': creditsUsed,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (cloudId != null) 'cloud_id': cloudId,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TeleCasesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? diagnosticDoctorId,
    Value<String>? patientUuid,
    Value<String?>? reporterDoctorId,
    Value<String>? status,
    Value<String?>? submissionNotes,
    Value<String?>? reportFindings,
    Value<String?>? reportImpression,
    Value<String?>? reportRemarks,
    Value<String?>? slaDeadline,
    Value<String?>? completedAt,
    Value<int>? creditsUsed,
    Value<String>? syncStatus,
    Value<String?>? cloudId,
    Value<String?>? submittedAt,
    Value<String?>? updatedAt,
  }) {
    return TeleCasesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      diagnosticDoctorId: diagnosticDoctorId ?? this.diagnosticDoctorId,
      patientUuid: patientUuid ?? this.patientUuid,
      reporterDoctorId: reporterDoctorId ?? this.reporterDoctorId,
      status: status ?? this.status,
      submissionNotes: submissionNotes ?? this.submissionNotes,
      reportFindings: reportFindings ?? this.reportFindings,
      reportImpression: reportImpression ?? this.reportImpression,
      reportRemarks: reportRemarks ?? this.reportRemarks,
      slaDeadline: slaDeadline ?? this.slaDeadline,
      completedAt: completedAt ?? this.completedAt,
      creditsUsed: creditsUsed ?? this.creditsUsed,
      syncStatus: syncStatus ?? this.syncStatus,
      cloudId: cloudId ?? this.cloudId,
      submittedAt: submittedAt ?? this.submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (diagnosticDoctorId.present) {
      map['diagnostic_doctor_id'] = Variable<String>(diagnosticDoctorId.value);
    }
    if (patientUuid.present) {
      map['patient_uuid'] = Variable<String>(patientUuid.value);
    }
    if (reporterDoctorId.present) {
      map['reporter_doctor_id'] = Variable<String>(reporterDoctorId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (submissionNotes.present) {
      map['submission_notes'] = Variable<String>(submissionNotes.value);
    }
    if (reportFindings.present) {
      map['report_findings'] = Variable<String>(reportFindings.value);
    }
    if (reportImpression.present) {
      map['report_impression'] = Variable<String>(reportImpression.value);
    }
    if (reportRemarks.present) {
      map['report_remarks'] = Variable<String>(reportRemarks.value);
    }
    if (slaDeadline.present) {
      map['sla_deadline'] = Variable<String>(slaDeadline.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<String>(completedAt.value);
    }
    if (creditsUsed.present) {
      map['credits_used'] = Variable<int>(creditsUsed.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<String>(submittedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeleCasesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('diagnosticDoctorId: $diagnosticDoctorId, ')
          ..write('patientUuid: $patientUuid, ')
          ..write('reporterDoctorId: $reporterDoctorId, ')
          ..write('status: $status, ')
          ..write('submissionNotes: $submissionNotes, ')
          ..write('reportFindings: $reportFindings, ')
          ..write('reportImpression: $reportImpression, ')
          ..write('reportRemarks: $reportRemarks, ')
          ..write('slaDeadline: $slaDeadline, ')
          ..write('completedAt: $completedAt, ')
          ..write('creditsUsed: $creditsUsed, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('cloudId: $cloudId, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $MediaFilesTable mediaFiles = $MediaFilesTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $TeleCasesTable teleCases = $TeleCasesTable(this);
  late final PatientDao patientDao = PatientDao(this as AppDatabase);
  late final MediaFileDao mediaFileDao = MediaFileDao(this as AppDatabase);
  late final TeleCaseDao teleCaseDao = TeleCaseDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    patients,
    users,
    mediaFiles,
    syncQueue,
    teleCases,
  ];
}

typedef $$PatientsTableCreateCompanionBuilder =
    PatientsCompanion Function({
      Value<int> id,
      required String uuid,
      required String doctorId,
      Value<String> syncStatus,
      Value<String?> cloudId,
      Value<String?> deletedAt,
      required String patientName,
      Value<String?> patientId,
      Value<String?> dateOfBirth,
      Value<String?> dateOfVisit,
      required String mobileNo,
      Value<String?> email,
      Value<String?> address,
      Value<String?> doctorName,
      Value<String?> referredBy,
      Value<String?> smoking,
      Value<String?> bloodGroup,
      Value<String?> medication,
      Value<String?> allergies,
      Value<String?> menopause,
      Value<String?> lastMenstrualDate,
      Value<String?> sexuallyActive,
      Value<String?> contraception,
      Value<String?> hivStatus,
      Value<String?> pregnant,
      Value<int?> liveBirths,
      Value<int?> stillBirths,
      Value<int?> abortions,
      Value<int?> cesareans,
      Value<int?> miscarriages,
      Value<String?> hpvVaccination,
      Value<String?> referralReason,
      Value<String?> symptoms,
      Value<String?> hpvTest,
      Value<String?> hpvResult,
      Value<String?> hpvDate,
      Value<String?> hcgTest,
      Value<String?> hcgDate,
      Value<double?> hcgLevel,
      Value<String?> patientSummary,
      Value<String?> chiefComplaint,
      Value<String?> cytologyReport,
      Value<String?> pathologicalReport,
      Value<String?> colposcopyFindings,
      Value<String?> finalImpression,
      Value<String?> remarks,
      Value<String?> treatmentProvided,
      Value<String?> precautions,
      Value<String?> examiningPhysician,
      Value<String?> forensicExamination,
      Value<String?> examinationImages,
      Value<String?> imageMetadata,
      Value<String?> createdAt,
      Value<String?> updatedAt,
    });
typedef $$PatientsTableUpdateCompanionBuilder =
    PatientsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> doctorId,
      Value<String> syncStatus,
      Value<String?> cloudId,
      Value<String?> deletedAt,
      Value<String> patientName,
      Value<String?> patientId,
      Value<String?> dateOfBirth,
      Value<String?> dateOfVisit,
      Value<String> mobileNo,
      Value<String?> email,
      Value<String?> address,
      Value<String?> doctorName,
      Value<String?> referredBy,
      Value<String?> smoking,
      Value<String?> bloodGroup,
      Value<String?> medication,
      Value<String?> allergies,
      Value<String?> menopause,
      Value<String?> lastMenstrualDate,
      Value<String?> sexuallyActive,
      Value<String?> contraception,
      Value<String?> hivStatus,
      Value<String?> pregnant,
      Value<int?> liveBirths,
      Value<int?> stillBirths,
      Value<int?> abortions,
      Value<int?> cesareans,
      Value<int?> miscarriages,
      Value<String?> hpvVaccination,
      Value<String?> referralReason,
      Value<String?> symptoms,
      Value<String?> hpvTest,
      Value<String?> hpvResult,
      Value<String?> hpvDate,
      Value<String?> hcgTest,
      Value<String?> hcgDate,
      Value<double?> hcgLevel,
      Value<String?> patientSummary,
      Value<String?> chiefComplaint,
      Value<String?> cytologyReport,
      Value<String?> pathologicalReport,
      Value<String?> colposcopyFindings,
      Value<String?> finalImpression,
      Value<String?> remarks,
      Value<String?> treatmentProvided,
      Value<String?> precautions,
      Value<String?> examiningPhysician,
      Value<String?> forensicExamination,
      Value<String?> examinationImages,
      Value<String?> imageMetadata,
      Value<String?> createdAt,
      Value<String?> updatedAt,
    });

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doctorId => $composableBuilder(
    column: $table.doctorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientName => $composableBuilder(
    column: $table.patientName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateOfVisit => $composableBuilder(
    column: $table.dateOfVisit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doctorName => $composableBuilder(
    column: $table.doctorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referredBy => $composableBuilder(
    column: $table.referredBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get smoking => $composableBuilder(
    column: $table.smoking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medication => $composableBuilder(
    column: $table.medication,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get menopause => $composableBuilder(
    column: $table.menopause,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMenstrualDate => $composableBuilder(
    column: $table.lastMenstrualDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sexuallyActive => $composableBuilder(
    column: $table.sexuallyActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contraception => $composableBuilder(
    column: $table.contraception,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hivStatus => $composableBuilder(
    column: $table.hivStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pregnant => $composableBuilder(
    column: $table.pregnant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get liveBirths => $composableBuilder(
    column: $table.liveBirths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stillBirths => $composableBuilder(
    column: $table.stillBirths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get abortions => $composableBuilder(
    column: $table.abortions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cesareans => $composableBuilder(
    column: $table.cesareans,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get miscarriages => $composableBuilder(
    column: $table.miscarriages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hpvVaccination => $composableBuilder(
    column: $table.hpvVaccination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referralReason => $composableBuilder(
    column: $table.referralReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hpvTest => $composableBuilder(
    column: $table.hpvTest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hpvResult => $composableBuilder(
    column: $table.hpvResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hpvDate => $composableBuilder(
    column: $table.hpvDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hcgTest => $composableBuilder(
    column: $table.hcgTest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hcgDate => $composableBuilder(
    column: $table.hcgDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hcgLevel => $composableBuilder(
    column: $table.hcgLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientSummary => $composableBuilder(
    column: $table.patientSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cytologyReport => $composableBuilder(
    column: $table.cytologyReport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pathologicalReport => $composableBuilder(
    column: $table.pathologicalReport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colposcopyFindings => $composableBuilder(
    column: $table.colposcopyFindings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finalImpression => $composableBuilder(
    column: $table.finalImpression,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treatmentProvided => $composableBuilder(
    column: $table.treatmentProvided,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get precautions => $composableBuilder(
    column: $table.precautions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examiningPhysician => $composableBuilder(
    column: $table.examiningPhysician,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get forensicExamination => $composableBuilder(
    column: $table.forensicExamination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examinationImages => $composableBuilder(
    column: $table.examinationImages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageMetadata => $composableBuilder(
    column: $table.imageMetadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doctorId => $composableBuilder(
    column: $table.doctorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientName => $composableBuilder(
    column: $table.patientName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateOfVisit => $composableBuilder(
    column: $table.dateOfVisit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doctorName => $composableBuilder(
    column: $table.doctorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referredBy => $composableBuilder(
    column: $table.referredBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get smoking => $composableBuilder(
    column: $table.smoking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medication => $composableBuilder(
    column: $table.medication,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get menopause => $composableBuilder(
    column: $table.menopause,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMenstrualDate => $composableBuilder(
    column: $table.lastMenstrualDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sexuallyActive => $composableBuilder(
    column: $table.sexuallyActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contraception => $composableBuilder(
    column: $table.contraception,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hivStatus => $composableBuilder(
    column: $table.hivStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pregnant => $composableBuilder(
    column: $table.pregnant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get liveBirths => $composableBuilder(
    column: $table.liveBirths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stillBirths => $composableBuilder(
    column: $table.stillBirths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get abortions => $composableBuilder(
    column: $table.abortions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cesareans => $composableBuilder(
    column: $table.cesareans,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get miscarriages => $composableBuilder(
    column: $table.miscarriages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hpvVaccination => $composableBuilder(
    column: $table.hpvVaccination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referralReason => $composableBuilder(
    column: $table.referralReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hpvTest => $composableBuilder(
    column: $table.hpvTest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hpvResult => $composableBuilder(
    column: $table.hpvResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hpvDate => $composableBuilder(
    column: $table.hpvDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hcgTest => $composableBuilder(
    column: $table.hcgTest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hcgDate => $composableBuilder(
    column: $table.hcgDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hcgLevel => $composableBuilder(
    column: $table.hcgLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientSummary => $composableBuilder(
    column: $table.patientSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cytologyReport => $composableBuilder(
    column: $table.cytologyReport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pathologicalReport => $composableBuilder(
    column: $table.pathologicalReport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colposcopyFindings => $composableBuilder(
    column: $table.colposcopyFindings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finalImpression => $composableBuilder(
    column: $table.finalImpression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treatmentProvided => $composableBuilder(
    column: $table.treatmentProvided,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get precautions => $composableBuilder(
    column: $table.precautions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examiningPhysician => $composableBuilder(
    column: $table.examiningPhysician,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forensicExamination => $composableBuilder(
    column: $table.forensicExamination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examinationImages => $composableBuilder(
    column: $table.examinationImages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageMetadata => $composableBuilder(
    column: $table.imageMetadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get doctorId =>
      $composableBuilder(column: $table.doctorId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get patientName => $composableBuilder(
    column: $table.patientName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateOfVisit => $composableBuilder(
    column: $table.dateOfVisit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mobileNo =>
      $composableBuilder(column: $table.mobileNo, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get doctorName => $composableBuilder(
    column: $table.doctorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referredBy => $composableBuilder(
    column: $table.referredBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get smoking =>
      $composableBuilder(column: $table.smoking, builder: (column) => column);

  GeneratedColumn<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medication => $composableBuilder(
    column: $table.medication,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allergies =>
      $composableBuilder(column: $table.allergies, builder: (column) => column);

  GeneratedColumn<String> get menopause =>
      $composableBuilder(column: $table.menopause, builder: (column) => column);

  GeneratedColumn<String> get lastMenstrualDate => $composableBuilder(
    column: $table.lastMenstrualDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sexuallyActive => $composableBuilder(
    column: $table.sexuallyActive,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contraception => $composableBuilder(
    column: $table.contraception,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hivStatus =>
      $composableBuilder(column: $table.hivStatus, builder: (column) => column);

  GeneratedColumn<String> get pregnant =>
      $composableBuilder(column: $table.pregnant, builder: (column) => column);

  GeneratedColumn<int> get liveBirths => $composableBuilder(
    column: $table.liveBirths,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stillBirths => $composableBuilder(
    column: $table.stillBirths,
    builder: (column) => column,
  );

  GeneratedColumn<int> get abortions =>
      $composableBuilder(column: $table.abortions, builder: (column) => column);

  GeneratedColumn<int> get cesareans =>
      $composableBuilder(column: $table.cesareans, builder: (column) => column);

  GeneratedColumn<int> get miscarriages => $composableBuilder(
    column: $table.miscarriages,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hpvVaccination => $composableBuilder(
    column: $table.hpvVaccination,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referralReason => $composableBuilder(
    column: $table.referralReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get symptoms =>
      $composableBuilder(column: $table.symptoms, builder: (column) => column);

  GeneratedColumn<String> get hpvTest =>
      $composableBuilder(column: $table.hpvTest, builder: (column) => column);

  GeneratedColumn<String> get hpvResult =>
      $composableBuilder(column: $table.hpvResult, builder: (column) => column);

  GeneratedColumn<String> get hpvDate =>
      $composableBuilder(column: $table.hpvDate, builder: (column) => column);

  GeneratedColumn<String> get hcgTest =>
      $composableBuilder(column: $table.hcgTest, builder: (column) => column);

  GeneratedColumn<String> get hcgDate =>
      $composableBuilder(column: $table.hcgDate, builder: (column) => column);

  GeneratedColumn<double> get hcgLevel =>
      $composableBuilder(column: $table.hcgLevel, builder: (column) => column);

  GeneratedColumn<String> get patientSummary => $composableBuilder(
    column: $table.patientSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cytologyReport => $composableBuilder(
    column: $table.cytologyReport,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pathologicalReport => $composableBuilder(
    column: $table.pathologicalReport,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colposcopyFindings => $composableBuilder(
    column: $table.colposcopyFindings,
    builder: (column) => column,
  );

  GeneratedColumn<String> get finalImpression => $composableBuilder(
    column: $table.finalImpression,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get treatmentProvided => $composableBuilder(
    column: $table.treatmentProvided,
    builder: (column) => column,
  );

  GeneratedColumn<String> get precautions => $composableBuilder(
    column: $table.precautions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examiningPhysician => $composableBuilder(
    column: $table.examiningPhysician,
    builder: (column) => column,
  );

  GeneratedColumn<String> get forensicExamination => $composableBuilder(
    column: $table.forensicExamination,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examinationImages => $composableBuilder(
    column: $table.examinationImages,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageMetadata => $composableBuilder(
    column: $table.imageMetadata,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PatientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientsTable,
          PatientRow,
          $$PatientsTableFilterComposer,
          $$PatientsTableOrderingComposer,
          $$PatientsTableAnnotationComposer,
          $$PatientsTableCreateCompanionBuilder,
          $$PatientsTableUpdateCompanionBuilder,
          (
            PatientRow,
            BaseReferences<_$AppDatabase, $PatientsTable, PatientRow>,
          ),
          PatientRow,
          PrefetchHooks Function()
        > {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> doctorId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> patientName = const Value.absent(),
                Value<String?> patientId = const Value.absent(),
                Value<String?> dateOfBirth = const Value.absent(),
                Value<String?> dateOfVisit = const Value.absent(),
                Value<String> mobileNo = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> doctorName = const Value.absent(),
                Value<String?> referredBy = const Value.absent(),
                Value<String?> smoking = const Value.absent(),
                Value<String?> bloodGroup = const Value.absent(),
                Value<String?> medication = const Value.absent(),
                Value<String?> allergies = const Value.absent(),
                Value<String?> menopause = const Value.absent(),
                Value<String?> lastMenstrualDate = const Value.absent(),
                Value<String?> sexuallyActive = const Value.absent(),
                Value<String?> contraception = const Value.absent(),
                Value<String?> hivStatus = const Value.absent(),
                Value<String?> pregnant = const Value.absent(),
                Value<int?> liveBirths = const Value.absent(),
                Value<int?> stillBirths = const Value.absent(),
                Value<int?> abortions = const Value.absent(),
                Value<int?> cesareans = const Value.absent(),
                Value<int?> miscarriages = const Value.absent(),
                Value<String?> hpvVaccination = const Value.absent(),
                Value<String?> referralReason = const Value.absent(),
                Value<String?> symptoms = const Value.absent(),
                Value<String?> hpvTest = const Value.absent(),
                Value<String?> hpvResult = const Value.absent(),
                Value<String?> hpvDate = const Value.absent(),
                Value<String?> hcgTest = const Value.absent(),
                Value<String?> hcgDate = const Value.absent(),
                Value<double?> hcgLevel = const Value.absent(),
                Value<String?> patientSummary = const Value.absent(),
                Value<String?> chiefComplaint = const Value.absent(),
                Value<String?> cytologyReport = const Value.absent(),
                Value<String?> pathologicalReport = const Value.absent(),
                Value<String?> colposcopyFindings = const Value.absent(),
                Value<String?> finalImpression = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> treatmentProvided = const Value.absent(),
                Value<String?> precautions = const Value.absent(),
                Value<String?> examiningPhysician = const Value.absent(),
                Value<String?> forensicExamination = const Value.absent(),
                Value<String?> examinationImages = const Value.absent(),
                Value<String?> imageMetadata = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => PatientsCompanion(
                id: id,
                uuid: uuid,
                doctorId: doctorId,
                syncStatus: syncStatus,
                cloudId: cloudId,
                deletedAt: deletedAt,
                patientName: patientName,
                patientId: patientId,
                dateOfBirth: dateOfBirth,
                dateOfVisit: dateOfVisit,
                mobileNo: mobileNo,
                email: email,
                address: address,
                doctorName: doctorName,
                referredBy: referredBy,
                smoking: smoking,
                bloodGroup: bloodGroup,
                medication: medication,
                allergies: allergies,
                menopause: menopause,
                lastMenstrualDate: lastMenstrualDate,
                sexuallyActive: sexuallyActive,
                contraception: contraception,
                hivStatus: hivStatus,
                pregnant: pregnant,
                liveBirths: liveBirths,
                stillBirths: stillBirths,
                abortions: abortions,
                cesareans: cesareans,
                miscarriages: miscarriages,
                hpvVaccination: hpvVaccination,
                referralReason: referralReason,
                symptoms: symptoms,
                hpvTest: hpvTest,
                hpvResult: hpvResult,
                hpvDate: hpvDate,
                hcgTest: hcgTest,
                hcgDate: hcgDate,
                hcgLevel: hcgLevel,
                patientSummary: patientSummary,
                chiefComplaint: chiefComplaint,
                cytologyReport: cytologyReport,
                pathologicalReport: pathologicalReport,
                colposcopyFindings: colposcopyFindings,
                finalImpression: finalImpression,
                remarks: remarks,
                treatmentProvided: treatmentProvided,
                precautions: precautions,
                examiningPhysician: examiningPhysician,
                forensicExamination: forensicExamination,
                examinationImages: examinationImages,
                imageMetadata: imageMetadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String doctorId,
                Value<String> syncStatus = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                required String patientName,
                Value<String?> patientId = const Value.absent(),
                Value<String?> dateOfBirth = const Value.absent(),
                Value<String?> dateOfVisit = const Value.absent(),
                required String mobileNo,
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> doctorName = const Value.absent(),
                Value<String?> referredBy = const Value.absent(),
                Value<String?> smoking = const Value.absent(),
                Value<String?> bloodGroup = const Value.absent(),
                Value<String?> medication = const Value.absent(),
                Value<String?> allergies = const Value.absent(),
                Value<String?> menopause = const Value.absent(),
                Value<String?> lastMenstrualDate = const Value.absent(),
                Value<String?> sexuallyActive = const Value.absent(),
                Value<String?> contraception = const Value.absent(),
                Value<String?> hivStatus = const Value.absent(),
                Value<String?> pregnant = const Value.absent(),
                Value<int?> liveBirths = const Value.absent(),
                Value<int?> stillBirths = const Value.absent(),
                Value<int?> abortions = const Value.absent(),
                Value<int?> cesareans = const Value.absent(),
                Value<int?> miscarriages = const Value.absent(),
                Value<String?> hpvVaccination = const Value.absent(),
                Value<String?> referralReason = const Value.absent(),
                Value<String?> symptoms = const Value.absent(),
                Value<String?> hpvTest = const Value.absent(),
                Value<String?> hpvResult = const Value.absent(),
                Value<String?> hpvDate = const Value.absent(),
                Value<String?> hcgTest = const Value.absent(),
                Value<String?> hcgDate = const Value.absent(),
                Value<double?> hcgLevel = const Value.absent(),
                Value<String?> patientSummary = const Value.absent(),
                Value<String?> chiefComplaint = const Value.absent(),
                Value<String?> cytologyReport = const Value.absent(),
                Value<String?> pathologicalReport = const Value.absent(),
                Value<String?> colposcopyFindings = const Value.absent(),
                Value<String?> finalImpression = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> treatmentProvided = const Value.absent(),
                Value<String?> precautions = const Value.absent(),
                Value<String?> examiningPhysician = const Value.absent(),
                Value<String?> forensicExamination = const Value.absent(),
                Value<String?> examinationImages = const Value.absent(),
                Value<String?> imageMetadata = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => PatientsCompanion.insert(
                id: id,
                uuid: uuid,
                doctorId: doctorId,
                syncStatus: syncStatus,
                cloudId: cloudId,
                deletedAt: deletedAt,
                patientName: patientName,
                patientId: patientId,
                dateOfBirth: dateOfBirth,
                dateOfVisit: dateOfVisit,
                mobileNo: mobileNo,
                email: email,
                address: address,
                doctorName: doctorName,
                referredBy: referredBy,
                smoking: smoking,
                bloodGroup: bloodGroup,
                medication: medication,
                allergies: allergies,
                menopause: menopause,
                lastMenstrualDate: lastMenstrualDate,
                sexuallyActive: sexuallyActive,
                contraception: contraception,
                hivStatus: hivStatus,
                pregnant: pregnant,
                liveBirths: liveBirths,
                stillBirths: stillBirths,
                abortions: abortions,
                cesareans: cesareans,
                miscarriages: miscarriages,
                hpvVaccination: hpvVaccination,
                referralReason: referralReason,
                symptoms: symptoms,
                hpvTest: hpvTest,
                hpvResult: hpvResult,
                hpvDate: hpvDate,
                hcgTest: hcgTest,
                hcgDate: hcgDate,
                hcgLevel: hcgLevel,
                patientSummary: patientSummary,
                chiefComplaint: chiefComplaint,
                cytologyReport: cytologyReport,
                pathologicalReport: pathologicalReport,
                colposcopyFindings: colposcopyFindings,
                finalImpression: finalImpression,
                remarks: remarks,
                treatmentProvided: treatmentProvided,
                precautions: precautions,
                examiningPhysician: examiningPhysician,
                forensicExamination: forensicExamination,
                examinationImages: examinationImages,
                imageMetadata: imageMetadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PatientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientsTable,
      PatientRow,
      $$PatientsTableFilterComposer,
      $$PatientsTableOrderingComposer,
      $$PatientsTableAnnotationComposer,
      $$PatientsTableCreateCompanionBuilder,
      $$PatientsTableUpdateCompanionBuilder,
      (PatientRow, BaseReferences<_$AppDatabase, $PatientsTable, PatientRow>),
      PatientRow,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String fullName,
      required String email,
      required String password,
      required String medicalLicense,
      required String hospital,
      Value<String> role,
      Value<bool> isActive,
      Value<String?> lastLogin,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<String?> profileImage,
      Value<String?> phoneNumber,
      Value<String?> specialization,
      Value<String?> department,
      Value<String?> reportHeaderImage,
      Value<String?> reportFooterImage,
      Value<bool> useReportHeaderFooter,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> fullName,
      Value<String> email,
      Value<String> password,
      Value<String> medicalLicense,
      Value<String> hospital,
      Value<String> role,
      Value<bool> isActive,
      Value<String?> lastLogin,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<String?> profileImage,
      Value<String?> phoneNumber,
      Value<String?> specialization,
      Value<String?> department,
      Value<String?> reportHeaderImage,
      Value<String?> reportFooterImage,
      Value<bool> useReportHeaderFooter,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicalLicense => $composableBuilder(
    column: $table.medicalLicense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hospital => $composableBuilder(
    column: $table.hospital,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastLogin => $composableBuilder(
    column: $table.lastLogin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileImage => $composableBuilder(
    column: $table.profileImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialization => $composableBuilder(
    column: $table.specialization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportHeaderImage => $composableBuilder(
    column: $table.reportHeaderImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportFooterImage => $composableBuilder(
    column: $table.reportFooterImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get useReportHeaderFooter => $composableBuilder(
    column: $table.useReportHeaderFooter,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicalLicense => $composableBuilder(
    column: $table.medicalLicense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hospital => $composableBuilder(
    column: $table.hospital,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastLogin => $composableBuilder(
    column: $table.lastLogin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileImage => $composableBuilder(
    column: $table.profileImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialization => $composableBuilder(
    column: $table.specialization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportHeaderImage => $composableBuilder(
    column: $table.reportHeaderImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportFooterImage => $composableBuilder(
    column: $table.reportFooterImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get useReportHeaderFooter => $composableBuilder(
    column: $table.useReportHeaderFooter,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get medicalLicense => $composableBuilder(
    column: $table.medicalLicense,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hospital =>
      $composableBuilder(column: $table.hospital, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get lastLogin =>
      $composableBuilder(column: $table.lastLogin, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get profileImage => $composableBuilder(
    column: $table.profileImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialization => $composableBuilder(
    column: $table.specialization,
    builder: (column) => column,
  );

  GeneratedColumn<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reportHeaderImage => $composableBuilder(
    column: $table.reportHeaderImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reportFooterImage => $composableBuilder(
    column: $table.reportFooterImage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get useReportHeaderFooter => $composableBuilder(
    column: $table.useReportHeaderFooter,
    builder: (column) => column,
  );
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<String> medicalLicense = const Value.absent(),
                Value<String> hospital = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> lastLogin = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> profileImage = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> specialization = const Value.absent(),
                Value<String?> department = const Value.absent(),
                Value<String?> reportHeaderImage = const Value.absent(),
                Value<String?> reportFooterImage = const Value.absent(),
                Value<bool> useReportHeaderFooter = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                fullName: fullName,
                email: email,
                password: password,
                medicalLicense: medicalLicense,
                hospital: hospital,
                role: role,
                isActive: isActive,
                lastLogin: lastLogin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                profileImage: profileImage,
                phoneNumber: phoneNumber,
                specialization: specialization,
                department: department,
                reportHeaderImage: reportHeaderImage,
                reportFooterImage: reportFooterImage,
                useReportHeaderFooter: useReportHeaderFooter,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fullName,
                required String email,
                required String password,
                required String medicalLicense,
                required String hospital,
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> lastLogin = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> profileImage = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> specialization = const Value.absent(),
                Value<String?> department = const Value.absent(),
                Value<String?> reportHeaderImage = const Value.absent(),
                Value<String?> reportFooterImage = const Value.absent(),
                Value<bool> useReportHeaderFooter = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                fullName: fullName,
                email: email,
                password: password,
                medicalLicense: medicalLicense,
                hospital: hospital,
                role: role,
                isActive: isActive,
                lastLogin: lastLogin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                profileImage: profileImage,
                phoneNumber: phoneNumber,
                specialization: specialization,
                department: department,
                reportHeaderImage: reportHeaderImage,
                reportFooterImage: reportFooterImage,
                useReportHeaderFooter: useReportHeaderFooter,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;
typedef $$MediaFilesTableCreateCompanionBuilder =
    MediaFilesCompanion Function({
      Value<int> id,
      required String uuid,
      required String patientUuid,
      required String doctorId,
      required String fileType,
      Value<String?> localPath,
      Value<String?> cloudUrl,
      required String fileName,
      Value<String?> mimeType,
      Value<int?> fileSize,
      Value<String?> checksum,
      Value<String> syncStatus,
      Value<int> uploadAttempts,
      Value<String?> deletedAt,
      Value<String?> capturedAt,
      Value<String?> createdAt,
      Value<String?> updatedAt,
    });
typedef $$MediaFilesTableUpdateCompanionBuilder =
    MediaFilesCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> patientUuid,
      Value<String> doctorId,
      Value<String> fileType,
      Value<String?> localPath,
      Value<String?> cloudUrl,
      Value<String> fileName,
      Value<String?> mimeType,
      Value<int?> fileSize,
      Value<String?> checksum,
      Value<String> syncStatus,
      Value<int> uploadAttempts,
      Value<String?> deletedAt,
      Value<String?> capturedAt,
      Value<String?> createdAt,
      Value<String?> updatedAt,
    });

class $$MediaFilesTableFilterComposer
    extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientUuid => $composableBuilder(
    column: $table.patientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doctorId => $composableBuilder(
    column: $table.doctorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudUrl => $composableBuilder(
    column: $table.cloudUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uploadAttempts => $composableBuilder(
    column: $table.uploadAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientUuid => $composableBuilder(
    column: $table.patientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doctorId => $composableBuilder(
    column: $table.doctorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudUrl => $composableBuilder(
    column: $table.cloudUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uploadAttempts => $composableBuilder(
    column: $table.uploadAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get patientUuid => $composableBuilder(
    column: $table.patientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doctorId =>
      $composableBuilder(column: $table.doctorId, builder: (column) => column);

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get cloudUrl =>
      $composableBuilder(column: $table.cloudUrl, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get uploadAttempts => $composableBuilder(
    column: $table.uploadAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MediaFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaFilesTable,
          MediaFileRow,
          $$MediaFilesTableFilterComposer,
          $$MediaFilesTableOrderingComposer,
          $$MediaFilesTableAnnotationComposer,
          $$MediaFilesTableCreateCompanionBuilder,
          $$MediaFilesTableUpdateCompanionBuilder,
          (
            MediaFileRow,
            BaseReferences<_$AppDatabase, $MediaFilesTable, MediaFileRow>,
          ),
          MediaFileRow,
          PrefetchHooks Function()
        > {
  $$MediaFilesTableTableManager(_$AppDatabase db, $MediaFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MediaFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MediaFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MediaFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> patientUuid = const Value.absent(),
                Value<String> doctorId = const Value.absent(),
                Value<String> fileType = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> cloudUrl = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<String?> checksum = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> uploadAttempts = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> capturedAt = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => MediaFilesCompanion(
                id: id,
                uuid: uuid,
                patientUuid: patientUuid,
                doctorId: doctorId,
                fileType: fileType,
                localPath: localPath,
                cloudUrl: cloudUrl,
                fileName: fileName,
                mimeType: mimeType,
                fileSize: fileSize,
                checksum: checksum,
                syncStatus: syncStatus,
                uploadAttempts: uploadAttempts,
                deletedAt: deletedAt,
                capturedAt: capturedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String patientUuid,
                required String doctorId,
                required String fileType,
                Value<String?> localPath = const Value.absent(),
                Value<String?> cloudUrl = const Value.absent(),
                required String fileName,
                Value<String?> mimeType = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<String?> checksum = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> uploadAttempts = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> capturedAt = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => MediaFilesCompanion.insert(
                id: id,
                uuid: uuid,
                patientUuid: patientUuid,
                doctorId: doctorId,
                fileType: fileType,
                localPath: localPath,
                cloudUrl: cloudUrl,
                fileName: fileName,
                mimeType: mimeType,
                fileSize: fileSize,
                checksum: checksum,
                syncStatus: syncStatus,
                uploadAttempts: uploadAttempts,
                deletedAt: deletedAt,
                capturedAt: capturedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaFilesTable,
      MediaFileRow,
      $$MediaFilesTableFilterComposer,
      $$MediaFilesTableOrderingComposer,
      $$MediaFilesTableAnnotationComposer,
      $$MediaFilesTableCreateCompanionBuilder,
      $$MediaFilesTableUpdateCompanionBuilder,
      (
        MediaFileRow,
        BaseReferences<_$AppDatabase, $MediaFilesTable, MediaFileRow>,
      ),
      MediaFileRow,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String entityType,
      required String entityUuid,
      required String operation,
      required String payload,
      Value<int> attempts,
      Value<String?> lastAttemptAt,
      Value<String?> lastError,
      required String createdAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> entityUuid,
      Value<String> operation,
      Value<String> payload,
      Value<int> attempts,
      Value<String?> lastAttemptAt,
      Value<String?> lastError,
      Value<String> createdAt,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityUuid => $composableBuilder(
    column: $table.entityUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityUuid => $composableBuilder(
    column: $table.entityUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityUuid => $composableBuilder(
    column: $table.entityUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueRow,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueRow,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
          ),
          SyncQueueRow,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityUuid = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityType: entityType,
                entityUuid: entityUuid,
                operation: operation,
                payload: payload,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entityUuid,
                required String operation,
                required String payload,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required String createdAt,
              }) => SyncQueueCompanion.insert(
                id: id,
                entityType: entityType,
                entityUuid: entityUuid,
                operation: operation,
                payload: payload,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueRow,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueRow,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
      ),
      SyncQueueRow,
      PrefetchHooks Function()
    >;
typedef $$TeleCasesTableCreateCompanionBuilder =
    TeleCasesCompanion Function({
      Value<int> id,
      required String uuid,
      required String diagnosticDoctorId,
      required String patientUuid,
      Value<String?> reporterDoctorId,
      Value<String> status,
      Value<String?> submissionNotes,
      Value<String?> reportFindings,
      Value<String?> reportImpression,
      Value<String?> reportRemarks,
      Value<String?> slaDeadline,
      Value<String?> completedAt,
      Value<int> creditsUsed,
      Value<String> syncStatus,
      Value<String?> cloudId,
      Value<String?> submittedAt,
      Value<String?> updatedAt,
    });
typedef $$TeleCasesTableUpdateCompanionBuilder =
    TeleCasesCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> diagnosticDoctorId,
      Value<String> patientUuid,
      Value<String?> reporterDoctorId,
      Value<String> status,
      Value<String?> submissionNotes,
      Value<String?> reportFindings,
      Value<String?> reportImpression,
      Value<String?> reportRemarks,
      Value<String?> slaDeadline,
      Value<String?> completedAt,
      Value<int> creditsUsed,
      Value<String> syncStatus,
      Value<String?> cloudId,
      Value<String?> submittedAt,
      Value<String?> updatedAt,
    });

class $$TeleCasesTableFilterComposer
    extends Composer<_$AppDatabase, $TeleCasesTable> {
  $$TeleCasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosticDoctorId => $composableBuilder(
    column: $table.diagnosticDoctorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientUuid => $composableBuilder(
    column: $table.patientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reporterDoctorId => $composableBuilder(
    column: $table.reporterDoctorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get submissionNotes => $composableBuilder(
    column: $table.submissionNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportFindings => $composableBuilder(
    column: $table.reportFindings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportImpression => $composableBuilder(
    column: $table.reportImpression,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportRemarks => $composableBuilder(
    column: $table.reportRemarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slaDeadline => $composableBuilder(
    column: $table.slaDeadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditsUsed => $composableBuilder(
    column: $table.creditsUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeleCasesTableOrderingComposer
    extends Composer<_$AppDatabase, $TeleCasesTable> {
  $$TeleCasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosticDoctorId => $composableBuilder(
    column: $table.diagnosticDoctorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientUuid => $composableBuilder(
    column: $table.patientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reporterDoctorId => $composableBuilder(
    column: $table.reporterDoctorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get submissionNotes => $composableBuilder(
    column: $table.submissionNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportFindings => $composableBuilder(
    column: $table.reportFindings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportImpression => $composableBuilder(
    column: $table.reportImpression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportRemarks => $composableBuilder(
    column: $table.reportRemarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slaDeadline => $composableBuilder(
    column: $table.slaDeadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditsUsed => $composableBuilder(
    column: $table.creditsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeleCasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeleCasesTable> {
  $$TeleCasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get diagnosticDoctorId => $composableBuilder(
    column: $table.diagnosticDoctorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patientUuid => $composableBuilder(
    column: $table.patientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reporterDoctorId => $composableBuilder(
    column: $table.reporterDoctorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get submissionNotes => $composableBuilder(
    column: $table.submissionNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reportFindings => $composableBuilder(
    column: $table.reportFindings,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reportImpression => $composableBuilder(
    column: $table.reportImpression,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reportRemarks => $composableBuilder(
    column: $table.reportRemarks,
    builder: (column) => column,
  );

  GeneratedColumn<String> get slaDeadline => $composableBuilder(
    column: $table.slaDeadline,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creditsUsed => $composableBuilder(
    column: $table.creditsUsed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TeleCasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeleCasesTable,
          TeleCaseRow,
          $$TeleCasesTableFilterComposer,
          $$TeleCasesTableOrderingComposer,
          $$TeleCasesTableAnnotationComposer,
          $$TeleCasesTableCreateCompanionBuilder,
          $$TeleCasesTableUpdateCompanionBuilder,
          (
            TeleCaseRow,
            BaseReferences<_$AppDatabase, $TeleCasesTable, TeleCaseRow>,
          ),
          TeleCaseRow,
          PrefetchHooks Function()
        > {
  $$TeleCasesTableTableManager(_$AppDatabase db, $TeleCasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TeleCasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TeleCasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$TeleCasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> diagnosticDoctorId = const Value.absent(),
                Value<String> patientUuid = const Value.absent(),
                Value<String?> reporterDoctorId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> submissionNotes = const Value.absent(),
                Value<String?> reportFindings = const Value.absent(),
                Value<String?> reportImpression = const Value.absent(),
                Value<String?> reportRemarks = const Value.absent(),
                Value<String?> slaDeadline = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
                Value<int> creditsUsed = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> submittedAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => TeleCasesCompanion(
                id: id,
                uuid: uuid,
                diagnosticDoctorId: diagnosticDoctorId,
                patientUuid: patientUuid,
                reporterDoctorId: reporterDoctorId,
                status: status,
                submissionNotes: submissionNotes,
                reportFindings: reportFindings,
                reportImpression: reportImpression,
                reportRemarks: reportRemarks,
                slaDeadline: slaDeadline,
                completedAt: completedAt,
                creditsUsed: creditsUsed,
                syncStatus: syncStatus,
                cloudId: cloudId,
                submittedAt: submittedAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String diagnosticDoctorId,
                required String patientUuid,
                Value<String?> reporterDoctorId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> submissionNotes = const Value.absent(),
                Value<String?> reportFindings = const Value.absent(),
                Value<String?> reportImpression = const Value.absent(),
                Value<String?> reportRemarks = const Value.absent(),
                Value<String?> slaDeadline = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
                Value<int> creditsUsed = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> submittedAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => TeleCasesCompanion.insert(
                id: id,
                uuid: uuid,
                diagnosticDoctorId: diagnosticDoctorId,
                patientUuid: patientUuid,
                reporterDoctorId: reporterDoctorId,
                status: status,
                submissionNotes: submissionNotes,
                reportFindings: reportFindings,
                reportImpression: reportImpression,
                reportRemarks: reportRemarks,
                slaDeadline: slaDeadline,
                completedAt: completedAt,
                creditsUsed: creditsUsed,
                syncStatus: syncStatus,
                cloudId: cloudId,
                submittedAt: submittedAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeleCasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeleCasesTable,
      TeleCaseRow,
      $$TeleCasesTableFilterComposer,
      $$TeleCasesTableOrderingComposer,
      $$TeleCasesTableAnnotationComposer,
      $$TeleCasesTableCreateCompanionBuilder,
      $$TeleCasesTableUpdateCompanionBuilder,
      (
        TeleCaseRow,
        BaseReferences<_$AppDatabase, $TeleCasesTable, TeleCaseRow>,
      ),
      TeleCaseRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$MediaFilesTableTableManager get mediaFiles =>
      $$MediaFilesTableTableManager(_db, _db.mediaFiles);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$TeleCasesTableTableManager get teleCases =>
      $$TeleCasesTableTableManager(_db, _db.teleCases);
}
