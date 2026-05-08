import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/users.dart';
import '../../services/user_service.dart' show User;
import '../../services/password_service.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<User?> authenticateUser(String email, String password) async {
    final row =
        await (select(users)
          ..where((u) => u.email.equals(email))).getSingleOrNull();
    if (row == null) return null;
    if (!row.isActive) return null;

    final stored = row.password;
    bool isValid = false;

    if (PasswordService.isHashed(stored)) {
      isValid = PasswordService.verifyPassword(password, stored);
    } else {
      // Legacy plaintext passwords (from older builds).
      isValid = stored == password;
      if (isValid) {
        // Upgrade to hashed password on successful login.
        await (update(users)..where((u) => u.id.equals(row.id))).write(
          UsersCompanion(
            password: Value(PasswordService.hashPassword(password)),
            updatedAt: Value(DateTime.now().toIso8601String()),
          ),
        );
      }
    }

    if (!isValid) return null;

    await updateLastLogin(row.id);
    return _mapRowToUser(row);
  }

  Future<void> updateLastLogin(int userId) async {
    final now = DateTime.now().toIso8601String();
    await (update(users)..where(
      (u) => u.id.equals(userId),
    )).write(UsersCompanion(lastLogin: Value(now), updatedAt: Value(now)));
  }

  Future<User> createUser(User user) async {
    final now = DateTime.now().toIso8601String();
    final companion = _mapUserToCompanion(
      user,
      createdAt: now,
      updatedAt: now,
      includeId: false,
    );
    final id = await into(users).insert(companion);
    return getUser(id);
  }

  Future<User> getUser(int id) async {
    final row =
        await (select(users)..where((u) => u.id.equals(id))).getSingle();
    return _mapRowToUser(row);
  }

  Future<User?> getUserByEmail(String email) async {
    final row =
        await (select(users)
          ..where((u) => u.email.equals(email))).getSingleOrNull();
    return row == null ? null : _mapRowToUser(row);
  }

  Future<List<User>> getAllUsers() async {
    final rows =
        await (select(users)
          ..orderBy([(u) => OrderingTerm.desc(u.createdAt)])).get();
    return rows.map(_mapRowToUser).toList();
  }

  Future<List<User>> getPendingUsers() async {
    final rows =
        await (select(users)
              ..where((u) => u.role.equals('pending'))
              ..orderBy([(u) => OrderingTerm.desc(u.createdAt)]))
            .get();
    return rows.map(_mapRowToUser).toList();
  }

  Future<User> updateUser(int id, User user) async {
    final now = DateTime.now().toIso8601String();
    final companion = _mapUserToCompanion(
      user,
      updatedAt: now,
      includeId: false,
    );
    await (update(users)..where((u) => u.id.equals(id))).write(companion);
    return getUser(id);
  }

  Future<void> approveUser(int userId) async {
    final now = DateTime.now().toIso8601String();
    await (update(users)..where((u) => u.id.equals(userId))).write(
      const UsersCompanion(
        role: Value('doctor'),
        isActive: Value(true),
      ).copyWith(updatedAt: Value(now)),
    );
  }

  Future<void> rejectUser(int userId) async {
    await (delete(users)..where((u) => u.id.equals(userId))).go();
  }

  Future<void> deactivateUser(int userId) async {
    final now = DateTime.now().toIso8601String();
    await (update(users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(isActive: const Value(false), updatedAt: Value(now)),
    );
  }

  Future<void> deleteUser(int userId) async {
    await (delete(users)..where((u) => u.id.equals(userId))).go();
  }

  Future<bool> emailExists(String email) async {
    final count = await (select(users)
      ..where((u) => u.email.equals(email))).get().then((rows) => rows.length);
    return count > 0;
  }

  Future<void> changePassword(int userId, String newPassword) async {
    final now = DateTime.now().toIso8601String();
    await (update(users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(password: Value(newPassword), updatedAt: Value(now)),
    );
  }

  Future<List<User>> getUsersByRole(String role) async {
    final rows =
        await (select(users)
              ..where((u) => u.role.equals(role))
              ..orderBy([(u) => OrderingTerm.desc(u.createdAt)]))
            .get();
    return rows.map(_mapRowToUser).toList();
  }

  Future<int> getUserCount() async {
    final exp = users.id.count();
    final query = selectOnly(users)..addColumns([exp]);
    final row = await query.getSingle();
    return row.read(exp) ?? 0;
  }

  Future<int> getActiveUserCount() async {
    final exp = users.id.count();
    final query =
        selectOnly(users)
          ..where(users.isActive.equals(true))
          ..addColumns([exp]);
    final row = await query.getSingle();
    return row.read(exp) ?? 0;
  }

  User _mapRowToUser(UserRow row) {
    DateTime? parseDate(String? value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }

    return User(
      id: row.id,
      fullName: row.fullName,
      email: row.email,
      password: row.password,
      medicalLicense: row.medicalLicense,
      hospital: row.hospital,
      role: row.role,
      isActive: row.isActive,
      lastLogin: parseDate(row.lastLogin),
      createdAt: parseDate(row.createdAt),
      updatedAt: parseDate(row.updatedAt),
      profileImage: row.profileImage,
      phoneNumber: row.phoneNumber,
      specialization: row.specialization,
      department: row.department,
      reportHeaderImage: row.reportHeaderImage,
      reportFooterImage: row.reportFooterImage,
      useReportHeaderFooter: row.useReportHeaderFooter,
    );
  }

  UsersCompanion _mapUserToCompanion(
    User user, {
    String? createdAt,
    String? updatedAt,
    required bool includeId,
  }) {
    return UsersCompanion(
      id: includeId && user.id != null ? Value(user.id!) : const Value.absent(),
      fullName: Value(user.fullName),
      email: Value(user.email),
      password: Value(user.password),
      medicalLicense: Value(user.medicalLicense),
      hospital: Value(user.hospital),
      role: Value(user.role),
      isActive: Value(user.isActive),
      lastLogin: Value(
        user.lastLogin?.toIso8601String(),
      ),
      createdAt: Value(createdAt ?? user.createdAt?.toIso8601String()),
      updatedAt: Value(updatedAt ?? user.updatedAt?.toIso8601String()),
      profileImage: Value(user.profileImage),
      phoneNumber: Value(user.phoneNumber),
      specialization: Value(user.specialization),
      department: Value(user.department),
      reportHeaderImage: Value(user.reportHeaderImage),
      reportFooterImage: Value(user.reportFooterImage),
      useReportHeaderFooter: Value(user.useReportHeaderFooter),
    );
  }

  Future<bool> resetPassword(String email) async {
    final user =
        await (select(users)
          ..where((u) => u.email.equals(email))).getSingleOrNull();
    if (user == null) return false;
    final hashed = PasswordService.hashPassword('reset123');
    await (update(users)..where((u) => u.id.equals(user.id))).write(
      UsersCompanion(
        password: Value(hashed),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
    return true;
  }
}
