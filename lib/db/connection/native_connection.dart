import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<QueryExecutor> openPlatformConnection() async {
  final dir = await getApplicationDocumentsDirectory();
  final dbDir = Directory(p.join(dir.path, 'db'));
  if (!await dbDir.exists()) {
    await dbDir.create(recursive: true);
  }
  final dbFile = File(p.join(dbDir.path, 'patient_database.db'));
  return NativeDatabase.createInBackground(dbFile);
}
