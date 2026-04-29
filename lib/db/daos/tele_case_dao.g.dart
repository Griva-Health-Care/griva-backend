// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tele_case_dao.dart';

// ignore_for_file: type=lint
mixin _$TeleCaseDaoMixin on DatabaseAccessor<AppDatabase> {
  $TeleCasesTable get teleCases => attachedDatabase.teleCases;
  TeleCaseDaoManager get managers => TeleCaseDaoManager(this);
}

class TeleCaseDaoManager {
  final _$TeleCaseDaoMixin _db;
  TeleCaseDaoManager(this._db);
  $$TeleCasesTableTableManager get teleCases =>
      $$TeleCasesTableTableManager(_db.attachedDatabase, _db.teleCases);
}
