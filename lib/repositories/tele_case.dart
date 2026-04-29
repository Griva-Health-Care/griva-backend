/// Domain model for a tele-reporting case.
///
/// Created when a diagnostic center submits a patient's colposcopy images
/// for remote review by a Griva tele-reporter.
class TeleCase {
  final int?    id;
  final String  uuid;

  // ── Ownership ──────────────────────────────────────────────────────────────
  final String  diagnosticDoctorId;
  final String  patientUuid;
  final String? reporterDoctorId;

  // ── Status ─────────────────────────────────────────────────────────────────
  /// 'pending' | 'in_progress' | 'completed' | 'cancelled'
  final String status;

  // ── Clinical content ───────────────────────────────────────────────────────
  final String? submissionNotes;
  final String? reportFindings;
  final String? reportImpression;
  final String? reportRemarks;

  // ── SLA ────────────────────────────────────────────────────────────────────
  final DateTime? slaDeadline;
  final DateTime? completedAt;

  // ── Credits ────────────────────────────────────────────────────────────────
  final int creditsUsed;

  // ── Sync ───────────────────────────────────────────────────────────────────
  final String  syncStatus;
  final String? cloudId;

  // ── Timestamps ─────────────────────────────────────────────────────────────
  final DateTime? submittedAt;
  final DateTime? updatedAt;

  const TeleCase({
    this.id,
    required this.uuid,
    required this.diagnosticDoctorId,
    required this.patientUuid,
    this.reporterDoctorId,
    this.status = 'pending',
    this.submissionNotes,
    this.reportFindings,
    this.reportImpression,
    this.reportRemarks,
    this.slaDeadline,
    this.completedAt,
    this.creditsUsed = 1,
    this.syncStatus = 'local_only',
    this.cloudId,
    this.submittedAt,
    this.updatedAt,
  });

  /// Whether the SLA deadline has passed without completion.
  bool get isSlaBreached =>
      slaDeadline != null &&
      status != 'completed' &&
      DateTime.now().isAfter(slaDeadline!);

  /// Minutes remaining before the SLA deadline.  Negative = overdue.
  int get minutesUntilSla => slaDeadline == null
      ? 0
      : slaDeadline!.difference(DateTime.now()).inMinutes;

  TeleCase copyWith({
    int?     id,
    String?  uuid,
    String?  diagnosticDoctorId,
    String?  patientUuid,
    String?  reporterDoctorId,
    String?  status,
    String?  submissionNotes,
    String?  reportFindings,
    String?  reportImpression,
    String?  reportRemarks,
    DateTime? slaDeadline,
    DateTime? completedAt,
    int?     creditsUsed,
    String?  syncStatus,
    String?  cloudId,
    DateTime? submittedAt,
    DateTime? updatedAt,
  }) => TeleCase(
    id:                  id                  ?? this.id,
    uuid:                uuid                ?? this.uuid,
    diagnosticDoctorId:  diagnosticDoctorId  ?? this.diagnosticDoctorId,
    patientUuid:         patientUuid         ?? this.patientUuid,
    reporterDoctorId:    reporterDoctorId    ?? this.reporterDoctorId,
    status:              status              ?? this.status,
    submissionNotes:     submissionNotes     ?? this.submissionNotes,
    reportFindings:      reportFindings      ?? this.reportFindings,
    reportImpression:    reportImpression    ?? this.reportImpression,
    reportRemarks:       reportRemarks       ?? this.reportRemarks,
    slaDeadline:         slaDeadline         ?? this.slaDeadline,
    completedAt:         completedAt         ?? this.completedAt,
    creditsUsed:         creditsUsed         ?? this.creditsUsed,
    syncStatus:          syncStatus          ?? this.syncStatus,
    cloudId:             cloudId             ?? this.cloudId,
    submittedAt:         submittedAt         ?? this.submittedAt,
    updatedAt:           updatedAt           ?? this.updatedAt,
  );

  Map<String, dynamic> toMap() => {
    'uuid':                uuid,
    'diagnostic_doctor_id': diagnosticDoctorId,
    'patient_uuid':         patientUuid,
    'reporter_doctor_id':   reporterDoctorId,
    'status':               status,
    'submission_notes':     submissionNotes,
    'report_findings':      reportFindings,
    'report_impression':    reportImpression,
    'report_remarks':       reportRemarks,
    'sla_deadline':         slaDeadline?.toIso8601String(),
    'completed_at':         completedAt?.toIso8601String(),
    'credits_used':         creditsUsed,
    'sync_status':          syncStatus,
    'cloud_id':             cloudId,
    'submitted_at':         submittedAt?.toIso8601String(),
    'updated_at':           updatedAt?.toIso8601String(),
  };
}
