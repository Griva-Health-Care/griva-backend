import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages the mandatory doctor/diagnostic-center profile stored in Supabase
/// Postgres.
///
/// Table: node_app.doctor_profiles (uid PK = Supabase user UUID)
///
/// This replaces the previous Firestore `doctor_profiles/{uid}` collection.
class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  SupabaseClient get _db => Supabase.instance.client;

  /// Save (or merge) the profile for [uid].
  Future<void> saveProfile(String uid, DoctorProfile profile) async {
    final data = profile.toMap();
    data['uid']       = uid;
    data['updatedAt'] = DateTime.now().toIso8601String();

    await _db.from('doctor_profiles').upsert(data, onConflict: 'uid');
    debugPrint('[PROFILE] Saved profile for $uid');
  }

  /// Returns the profile if it exists and all mandatory fields are filled,
  /// or null if the user still needs to complete their profile.
  Future<DoctorProfile?> getProfile(String uid) async {
    try {
      final row = await _db
          .from('doctor_profiles')
          .select()
          .eq('uid', uid)
          .maybeSingle();
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
  final String accountType;
  final String licenseNumber;
  final String city;
  final String state;
  final String colposcopeSerialNo;

  const DoctorProfile({
    required this.fullName,
    required this.phone,
    required this.hospital,
    required this.accountType,
    required this.licenseNumber,
    required this.city,
    required this.state,
    this.colposcopeSerialNo = '',
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
        fullName:           (map['fullName']           as String?) ??
                            (map['full_name']          as String?) ?? '',
        phone:              (map['phone']              as String?) ?? '',
        hospital:           (map['hospital']           as String?) ?? '',
        accountType:        (map['accountType']        as String?) ??
                            (map['account_type']       as String?) ?? '',
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
        'accountType':        accountType,
        'licenseNumber':      licenseNumber,
        'city':               city,
        'state':              state,
        'colposcopeSerialNo': colposcopeSerialNo,
      };
}
