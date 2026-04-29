import 'package:drift/drift.dart';

/// Tracks colposcopy cases submitted by diagnostic centers to Griva
/// tele-reporters for remote reporting.
///
/// One row = one submitted case = one credit deducted from the diagnostic
/// center's balance.
@DataClassName('TeleCaseRow')
class TeleCases extends Table {
  // ── Identity ───────────────────────────────────────────────────────────────
  IntColumn get id   => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();

  // ── Ownership ──────────────────────────────────────────────────────────────
  TextColumn get diagnosticDoctorId => text().named('diagnostic_doctor_id')();
  TextColumn get patientUuid        => text().named('patient_uuid')();

  // ── Assignment ─────────────────────────────────────────────────────────────
  // Firebase UID of the Griva tele-reporter assigned to this case.
  // Null until a reporter picks it up.
  TextColumn get reporterDoctorId => text().named('reporter_doctor_id').nullable()();

  // ── Status lifecycle ───────────────────────────────────────────────────────
  // pending | in_progress | completed | cancelled
  TextColumn get status => text().withDefault(const Constant('pending'))();

  // ── Clinical notes sent with the submission ────────────────────────────────
  TextColumn get submissionNotes => text().named('submission_notes').nullable()();

  // ── Report fields written by the tele-reporter ────────────────────────────
  TextColumn get reportFindings   => text().named('report_findings').nullable()();
  TextColumn get reportImpression => text().named('report_impression').nullable()();
  TextColumn get reportRemarks    => text().named('report_remarks').nullable()();

  // ── SLA tracking ──────────────────────────────────────────────────────────
  // ISO-8601 deadline = submittedAt + 20 minutes
  TextColumn get slaDeadline => text().named('sla_deadline').nullable()();
  TextColumn get completedAt => text().named('completed_at').nullable()();

  // ── Credits ────────────────────────────────────────────────────────────────
  IntColumn get creditsUsed => integer().named('credits_used').withDefault(const Constant(1))();

  // ── Cloud sync ─────────────────────────────────────────────────────────────
  TextColumn get syncStatus => text().named('sync_status').withDefault(const Constant('local_only'))();
  TextColumn get cloudId    => text().named('cloud_id').nullable()();

  // ── Timestamps ─────────────────────────────────────────────────────────────
  TextColumn get submittedAt => text().named('submitted_at').nullable()();
  TextColumn get updatedAt   => text().named('updated_at').nullable()();
}
