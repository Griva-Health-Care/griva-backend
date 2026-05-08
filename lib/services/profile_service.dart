import 'package:flutter/foundation.dart';

import '../cloud/cloud_registry.dart';

/// Manages the mandatory doctor/diagnostic-center profile stored in the cloud
/// database.
///
/// Table: doctor_profiles (uid PK = auth provider user UUID)
class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  /// Save (or merge) the profile for [uid].
  Future<void> saveProfile(String uid, DoctorProfile profile) async {
    final data = profile.toMap();
    data['uid']       = uid;
    data['updatedAt'] = DateTime.now().toIso8601String();

    await CloudRegistry.instance.database.upsert(
      'doctor_profiles',
      data,
      onConflict: 'uid',
    );
    debugPrint('[PROFILE] Saved profile for $uid');
  }

  /// Returns the profile if it exists and all mandatory fields are filled,
  /// or null if the user still needs to complete their profile.
  Future<DoctorProfile?> getProfile(String uid) async {
    try {
      final row = await CloudRegistry.instance.database.selectSingle(
        'doctor_profiles',
        eq: {'uid': uid},
      );
      if (row == null) return null;
      final profile = DoctorProfile.fromMap(row);
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
  final String fullName;
  final String phone;
  final String hospital;
  final String role;
  final String licenseNumber;
  final String city;
  final String state;
  final String colposcopeSerialNo;

  const DoctorProfile({
    required this.fullName,
    required this.phone,
    required this.hospital,
    required this.role,
    required this.licenseNumber,
    required this.city,
    required this.state,
    this.colposcopeSerialNo = '',
  });

  // licenseNumber, city, state, colposcopeSerialNo are optional — not required here
  bool get isComplete =>
      fullName.isNotEmpty &&
      phone.isNotEmpty &&
      hospital.isNotEmpty &&
      role.isNotEmpty;

  static String _normalizeRole(String v) =>
      v == 'diagnostic_center' ? 'diagnostic' : v;

  factory DoctorProfile.fromMap(Map<String, dynamic> map) => DoctorProfile(
        fullName:           (map['fullName']           as String?) ??
                            (map['full_name']          as String?) ?? '',
        phone:              (map['phone']              as String?) ?? '',
        hospital:           (map['hospital']           as String?) ?? '',
        // Normalize legacy 'diagnostic_center' → 'diagnostic' and accept old key names
        role: _normalizeRole(
                (map['role']         as String?) ??
                (map['accountType']  as String?) ??
                (map['account_type'] as String?) ?? ''),
        licenseNumber:      (map['licenseNumber']      as String?) ??
                            (map['license_number']     as String?) ?? '',
        city:               (map['city']               as String?) ?? '',
        state:              (map['state']              as String?) ?? '',
        colposcopeSerialNo: (map['colposcopeSerialNo'] as String?) ??
                            (map['colposcope_serial_no'] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {
        'fullName':           fullName,
        'phone':              phone,
        'hospital':           hospital,
        'role':        role,
        'licenseNumber':      licenseNumber,
        'city':               city,
        'state':              state,
        'colposcopeSerialNo': colposcopeSerialNo,
      };
}
