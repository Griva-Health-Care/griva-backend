import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../services/patient_service.dart' show Patient;
import '../i_patient_repository.dart';

/// Firestore-backed implementation of [IPatientRepository].
///
/// Collection layout:
///   doctors/{doctorId}/patients/{patientUuid}
///
/// This class is the "cloud" half of the synced architecture.
/// In normal use, [SyncedPatientRepository] (Phase 5) calls this class when
/// it needs to push a local change upstream or pull from the cloud.
/// Screens should never touch this class directly.
class FirestorePatientRepository implements IPatientRepository {
  FirestorePatientRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String doctorId) =>
      _db.collection('doctors').doc(doctorId).collection('patients');

  // ── Queries ─────────────────────────────────────────────────────────────────

  @override
  Future<List<Patient>> getAll(String doctorId) async {
    try {
      final snap = await _col(doctorId)
          .where('deletedAt', isNull: true)
          .orderBy('updatedAt', descending: true)
          .get();
      return snap.docs.map((d) => _docToPatient(d.data())).toList();
    } catch (e) {
      debugPrint('[FIRESTORE] getAll failed: $e');
      return [];
    }
  }

  @override
  Future<Patient?> getByUuid(String uuid) async {
    // We need the doctorId to locate the document; callers must ensure the
    // patient has a doctorId set, or we return null.
    try {
      // Query across all doctor sub-collections is not supported — use local
      // repo for cross-doctor lookups. This method is only used within a known
      // doctor context. Callers should prefer the local repo for by-uuid lookups.
      throw UnimplementedError(
        'getByUuid on Firestore requires a doctorId. '
        'Use SyncedPatientRepository which falls back to the local copy.',
      );
    } catch (e) {
      debugPrint('[FIRESTORE] getByUuid: $e');
      return null;
    }
  }

  // ── Writes ──────────────────────────────────────────────────────────────────

  @override
  Future<Patient> create(Patient patient) async {
    final map = patient.toMap()
      ..['updatedAt'] = FieldValue.serverTimestamp()
      ..['createdAt'] = FieldValue.serverTimestamp();
    await _col(patient.doctorId).doc(patient.uuid).set(map);
    debugPrint('[FIRESTORE] Created patient ${patient.uuid}');
    return patient;
  }

  @override
  Future<Patient> update(Patient patient) async {
    final map = patient.toMap()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await _col(patient.doctorId).doc(patient.uuid).set(map, SetOptions(merge: true));
    debugPrint('[FIRESTORE] Updated patient ${patient.uuid}');
    return patient;
  }

  @override
  Future<void> delete(String uuid) async {
    // We cannot soft-delete without knowing the doctorId.
    // SyncedPatientRepository handles this by calling update() with a
    // deletedAt timestamp already set on the patient object.
    throw UnimplementedError(
      'Call update() with deletedAt set instead of delete() on Firestore.',
    );
  }

  // ── Sync helpers ─────────────────────────────────────────────────────────────

  @override
  Future<List<Patient>> getPendingUpload(String doctorId) async {
    // Firestore is the source of truth for cloud — pending state lives locally.
    return [];
  }

  @override
  Future<void> markSynced(String uuid, String cloudId) async {
    // Cloud repo is always "synced" by definition.
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Patient _docToPatient(Map<String, dynamic> data) {
    // Firestore Timestamps → ISO strings for the local Patient.fromMap parser.
    String? tsToIso(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate().toIso8601String();
      return v.toString();
    }

    final normalized = Map<String, dynamic>.from(data);
    for (final key in [
      'created_at', 'updated_at', 'deleted_at', 'date_of_birth',
      'date_of_visit', 'last_menstrual_date', 'hpv_date', 'hcg_date',
    ]) {
      if (normalized.containsKey(key)) {
        normalized[key] = tsToIso(normalized[key]);
      }
    }
    return Patient.fromMap(normalized);
  }
}
