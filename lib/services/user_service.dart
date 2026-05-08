import 'package:intl/intl.dart';

import '../db/app_database.dart';
import '../db/daos/user_dao.dart';
import 'password_service.dart';

class User {
  final int? id;
  final String fullName;
  final String email;
  final String password;
  final String medicalLicense;
  final String hospital;
  final String role; // 'admin', 'doctor', 'pending'
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? profileImage;
  final String? phoneNumber;
  final String? specialization;
  final String? department;
  final String? reportHeaderImage;
  final String? reportFooterImage;
  final bool useReportHeaderFooter;

  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.medicalLicense,
    required this.hospital,
    this.role = 'pending',
    this.isActive = false,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.profileImage,
    this.phoneNumber,
    this.specialization,
    this.department,
    this.reportHeaderImage,
    this.reportFooterImage,
    this.useReportHeaderFooter = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'password': password,
      'medical_license': medicalLicense,
      'hospital': hospital,
      'role': role,
      'is_active': isActive ? 1 : 0,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'profile_image': profileImage,
      'phone_number': phoneNumber,
      'specialization': specialization,
      'department': department,
      'report_header_image': reportHeaderImage,
      'report_footer_image': reportFooterImage,
      'use_report_header_footer': useReportHeaderFooter ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        try {
          return DateFormat('yyyy-MM-dd').parse(dateStr);
        } catch (e) {
          return null;
        }
      }
    }

    return User(
      id: map['id'],
      fullName: map['full_name'],
      email: map['email'],
      password: map['password'],
      medicalLicense: map['medical_license'],
      hospital: map['hospital'],
      role: map['role'] ?? 'pending',
      isActive: map['is_active'] == 1,
      lastLogin: parseDate(map['last_login']),
      createdAt: parseDate(map['created_at']),
      updatedAt: parseDate(map['updated_at']),
      profileImage: map['profile_image'],
      phoneNumber: map['phone_number'],
      specialization: map['specialization'],
      department: map['department'],
      reportHeaderImage: map['report_header_image'],
      reportFooterImage: map['report_footer_image'],
      useReportHeaderFooter: (map['use_report_header_footer'] ?? 0) == 1,
    );
  }

  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? password,
    String? medicalLicense,
    String? hospital,
    String? role,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImage,
    String? phoneNumber,
    String? specialization,
    String? department,
    String? reportHeaderImage,
    String? reportFooterImage,
    bool? useReportHeaderFooter,
  }) {
    return User(
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
      useReportHeaderFooter: useReportHeaderFooter ?? this.useReportHeaderFooter,
    );
  }
}

class UserService {
  static final AppDatabase _db = AppDatabase.instance;
  static final UserDao _dao = UserDao(_db);

  // Authentication methods
  Future<User?> authenticateUser(String email, String password) async {
    return _dao.authenticateUser(email, password);
  }

  Future<void> updateLastLogin(int userId) async {
    await _dao.updateLastLogin(userId);
  }

  // User management methods
  Future<User> createUser(User user) async {
    final hashed = PasswordService.hashPassword(user.password);
    return _dao.createUser(user.copyWith(password: hashed));
  }

  Future<User> getUser(int id) async {
    return _dao.getUser(id);
  }

  Future<User?> getUserByEmail(String email) async {
    return _dao.getUserByEmail(email);
  }

  Future<List<User>> getAllUsers() async {
    return _dao.getAllUsers();
  }

  Future<List<User>> getPendingUsers() async {
    return _dao.getPendingUsers();
  }

  Future<User> updateUser(int id, User user) async {
    return _dao.updateUser(id, user);
  }

  Future<void> approveUser(int userId) async {
    await _dao.approveUser(userId);
  }

  Future<void> rejectUser(int userId) async {
    await _dao.rejectUser(userId);
  }

  Future<void> deactivateUser(int userId) async {
    await _dao.deactivateUser(userId);
  }

  Future<void> deleteUser(int userId) async {
    await _dao.deleteUser(userId);
  }

  Future<bool> emailExists(String email) async {
    return _dao.emailExists(email);
  }

  Future<void> changePassword(int userId, String newPassword) async {
    await _dao.changePassword(
      userId,
      PasswordService.hashPassword(newPassword),
    );
  }

  Future<bool> resetPassword(String email) async {
    return _dao.resetPassword(email);
  }

  // Admin methods
  Future<List<User>> getUsersByRole(String role) async {
    return _dao.getUsersByRole(role);
  }

  Future<int> getUserCount() async {
    return _dao.getUserCount();
  }

  Future<int> getActiveUserCount() async {
    return _dao.getActiveUserCount();
  }
}
