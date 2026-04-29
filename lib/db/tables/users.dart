import 'package:drift/drift.dart';

@DataClassName('UserRow')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get fullName => text().named('full_name')();
  TextColumn get email => text().named('email')();
  TextColumn get password => text()();

  TextColumn get medicalLicense => text().named('medical_license')();
  TextColumn get hospital => text()();

  TextColumn get role => text().withDefault(const Constant('pending'))();

  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(false))();

  TextColumn get lastLogin => text().named('last_login').nullable()();

  TextColumn get createdAt => text().named('created_at').nullable()();
  TextColumn get updatedAt => text().named('updated_at').nullable()();

  TextColumn get profileImage => text().named('profile_image').nullable()();
  TextColumn get phoneNumber => text().named('phone_number').nullable()();
  TextColumn get specialization => text().nullable()();
  TextColumn get department => text().nullable()();
}
