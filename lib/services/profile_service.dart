import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Manages the mandatory doctor/diagnostic-center profile stored in Firestore.
///
/// Firestore path: `doctor_profiles/{uid}`
///
/// This is separate from `doctor_config` (which is admin-managed for
/// cloudSyncEnabled / role / credits). `doctor_profiles` is user-submitted
/// identity data collected at sign-up or first Google sign-in.
class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  static const _collection = 'doctor_profiles';
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Save (or overwrite) the profile for [uid].
  Future<void> saveProfile(String uid, DoctorProfile profile) async {
    await _db.collection(_collection).doc(uid).set(
      profile.toMap()..['updatedAt'] = FieldValue.serverTimestamp(),
      SetOptions(merge: true),
    );
    debugPrint('[PROFILE] Saved profile for $uid');
  }

  /// Returns the profile if it exists and all mandatory fields are filled,
  /// or null if the user still needs to complete their profile.
  Future<DoctorProfile?> getProfile(String uid) async {
    try {
      final doc = await _db.collection(_collection).doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      final profile = DoctorProfile.fromMap(doc.data()!);
      return profile.isComplete ? profile : null;
    } catch (e) {
      debugPrint('[PROFILE] Failed to fetch profile for $uid: $e');
      return null;
    }
  }

  /// True if the profile exists and all mandatory fields are present.
  Future<bool> isProfileComplete(String uid) async {
    final p = await getProfile(uid);
    return p != null;
  }
}

class DoctorProfile {
  final String  fullName;
  final String  phone;
  final String  hospital;        // hospital or clinic/diagnostic center name
  final String  accountType;     // 'doctor' | 'diagnostic_center'
  final String  licenseNumber;   // medical registration / license number
  final String  city;
  final String  state;

  const DoctorProfile({
    required this.fullName,
    required this.phone,
    required this.hospital,
    required this.accountType,
    required this.licenseNumber,
    required this.city,
    required this.state,
  });

  bool get isComplete =>
      fullName.isNotEmpty &&
      phone.isNotEmpty &&
      hospital.isNotEmpty &&
      accountType.isNotEmpty &&
      licenseNumber.isNotEmpty &&
      city.isNotEmpty &&
      state.isNotEmpty;

  factory DoctorProfile.fromMap(Map<String, dynamic> map) => DoctorProfile(
        fullName:      (map['fullName']      as String?) ?? '',
        phone:         (map['phone']         as String?) ?? '',
        hospital:      (map['hospital']      as String?) ?? '',
        accountType:   (map['accountType']   as String?) ?? '',
        licenseNumber: (map['licenseNumber'] as String?) ?? '',
        city:          (map['city']          as String?) ?? '',
        state:         (map['state']         as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {
        'fullName':      fullName,
        'phone':         phone,
        'hospital':      hospital,
        'accountType':   accountType,
        'licenseNumber': licenseNumber,
        'city':          city,
        'state':         state,
        'createdAt':     FieldValue.serverTimestamp(),
      };
}
