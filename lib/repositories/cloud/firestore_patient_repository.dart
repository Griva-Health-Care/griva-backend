import 'package:flutter/foundation.dart';

import '../../cloud/cloud_registry.dart';
import '../../services/patient_service.dart' show Patient;
import '../i_patient_repository.dart';

/// Cloud-backed implementation of [IPatientRepository].
///
/// Delegates all operations to [CloudRegistry.instance.database].
/// To migrate to a different cloud database, swap the [IDatabaseProvider]
/// in [CloudRegistry] — this file does not need to change.
///
/// Table: patients — uuid (PK), patient_name, user_id, has_report
class SupabasePatientRepository implements IPatientRepository {
  @override
  Future<List<Patient>> getAll(String doctorId) async {
    try {
      final rows = await CloudRegistry.instance.database.select(
        'patients',
        eq:      {'user_id': doctorId},
        isNull:  ['deleted_at'],
        orderBy: 'updated_at',
        ascending: false,
      );
      return rows.map(Patient.fromMap).toList();
    } catch (e) {
      debugPrint('[CLOUD_PATIENT] getAll failed: $e');
      return [];
    }
  }

  @override
  Future<Patient?> getByUuid(String uuid) async {
    try {
      final rows = await CloudRegistry.instance.database.select(
        'patients',
        eq:    {'uuid': uuid},
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return Patient.fromMap(rows.first);
    } catch (e) {
      debugPrint('[CLOUD_PATIENT] getByUuid failed: $e');
      return null;
    }
  }

  @override
  Future<Patient> create(Patient patient) async {
    final hasReport = (patient.finalImpression?.isNotEmpty ?? false) ||
        (patient.colposcopyFindings?.isNotEmpty ?? false);
    await CloudRegistry.instance.database.upsert('patients', {
      'uuid':         patient.uuid,
      'patient_name': patient.patientName,
      'user_id':      patient.doctorId,
      'has_report':   hasReport,
    }, onConflict: 'uuid');
    debugPrint('[CLOUD_PATIENT] Upserted ${patient.uuid}');
    return patient;
  }

  @override
  Future<Patient> update(Patient patient) => create(patient);

  @override
  Future<void> delete(String uuid) async {
    await CloudRegistry.instance.database.update(
      'patients',
      {'deleted_at': DateTime.now().toIso8601String()},
      eq: {'uuid': uuid},
    );
  }

  @override
  Future<List<Patient>> getPendingUpload(String doctorId) async => [];

  @override
  Future<void> markSynced(String uuid, String cloudId) async {}
}
