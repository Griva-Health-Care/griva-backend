import 'package:drift/drift.dart';
import 'package:drift/web.dart';

Future<QueryExecutor> openPlatformConnection() async {
  return WebDatabase('patient_database');
}
