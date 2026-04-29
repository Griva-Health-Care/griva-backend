import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tele_cases.dart';
import '../../repositories/tele_case.dart';

part 'tele_case_dao.g.dart';

@DriftAccessor(tables: [TeleCases])
class TeleCaseDao extends DatabaseAccessor<AppDatabase>
    with _$TeleCaseDaoMixin {
  TeleCaseDao(super.db);

  // ── Queries ───────────────────────────────────────────────────────────────

  /// All cases submitted by [diagnosticDoctorId], newest first.
  Future<List<TeleCase>> getForDoctor(String diagnosticDoctorId) async {
    final rows = await (select(teleCases)
          ..where((t) => t.diagnosticDoctorId.equals(diagnosticDoctorId))
          ..orderBy([(t) => OrderingTerm.desc(t.submittedAt)]))
        .get();
    return rows.map(_rowToModel).toList();
  }

  /// All pending cases assigned to [reporterDoctorId], oldest first (SLA order).
  Future<List<TeleCase>> getPendingForReporter(String reporterDoctorId) async {
    final rows = await (select(teleCases)
          ..where((t) =>
              t.reporterDoctorId.equals(reporterDoctorId) &
              t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.submittedAt)]))
        .get();
    return rows.map(_rowToModel).toList();
  }

  Future<TeleCase?> getByUuid(String uuid) async {
    final row = await (select(teleCases)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    return row == null ? null : _rowToModel(row);
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  Future<TeleCase> createCase(TeleCase c) async {
    final id  = await into(teleCases).insert(_modelToCompanion(c));
    final row = await (select(teleCases)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return _rowToModel(row!);
  }

  Future<TeleCase> updateCase(TeleCase c) async {
    final now = DateTime.now().toIso8601String();
    await (update(teleCases)..where((t) => t.uuid.equals(c.uuid)))
        .write(_modelToCompanion(c).copyWith(updatedAt: Value(now)));
    return (await getByUuid(c.uuid))!;
  }

  Future<void> markSynced(String uuid, String cloudId) async {
    final now = DateTime.now().toIso8601String();
    await (update(teleCases)..where((t) => t.uuid.equals(uuid))).write(
      TeleCasesCompanion(
        syncStatus: const Value('synced'),
        cloudId:    Value(cloudId),
        updatedAt:  Value(now),
      ),
    );
  }

  // ── Mapping ───────────────────────────────────────────────────────────────

  TeleCase _rowToModel(TeleCaseRow r) {
    DateTime? d(String? v) {
      if (v == null) return null;
      try { return DateTime.parse(v); } catch (_) { return null; }
    }
    return TeleCase(
      id:                 r.id,
      uuid:               r.uuid,
      diagnosticDoctorId: r.diagnosticDoctorId,
      patientUuid:        r.patientUuid,
      reporterDoctorId:   r.reporterDoctorId,
      status:             r.status,
      submissionNotes:    r.submissionNotes,
      reportFindings:     r.reportFindings,
      reportImpression:   r.reportImpression,
      reportRemarks:      r.reportRemarks,
      slaDeadline:        d(r.slaDeadline),
      completedAt:        d(r.completedAt),
      creditsUsed:        r.creditsUsed,
      syncStatus:         r.syncStatus,
      cloudId:            r.cloudId,
      submittedAt:        d(r.submittedAt),
      updatedAt:          d(r.updatedAt),
    );
  }

  TeleCasesCompanion _modelToCompanion(TeleCase c) => TeleCasesCompanion(
    uuid:               Value(c.uuid),
    diagnosticDoctorId: Value(c.diagnosticDoctorId),
    patientUuid:        Value(c.patientUuid),
    reporterDoctorId:   Value(c.reporterDoctorId),
    status:             Value(c.status),
    submissionNotes:    Value(c.submissionNotes),
    reportFindings:     Value(c.reportFindings),
    reportImpression:   Value(c.reportImpression),
    reportRemarks:      Value(c.reportRemarks),
    slaDeadline:        Value(c.slaDeadline?.toIso8601String()),
    completedAt:        Value(c.completedAt?.toIso8601String()),
    creditsUsed:        Value(c.creditsUsed),
    syncStatus:         Value(c.syncStatus),
    cloudId:            Value(c.cloudId),
    submittedAt:        Value(c.submittedAt?.toIso8601String()),
    updatedAt:          Value(c.updatedAt?.toIso8601String()),
  );
}

