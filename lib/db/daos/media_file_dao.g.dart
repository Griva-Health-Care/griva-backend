// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_file_dao.dart';

// ignore_for_file: type=lint
mixin _$MediaFileDaoMixin on DatabaseAccessor<AppDatabase> {
  $MediaFilesTable get mediaFiles => attachedDatabase.mediaFiles;
  MediaFileDaoManager get managers => MediaFileDaoManager(this);
}

class MediaFileDaoManager {
  final _$MediaFileDaoMixin _db;
  MediaFileDaoManager(this._db);
  $$MediaFilesTableTableManager get mediaFiles =>
      $$MediaFilesTableTableManager(_db.attachedDatabase, _db.mediaFiles);
}
