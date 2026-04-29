import 'package:drift/drift.dart';
import 'native_connection.dart' if (dart.library.html) 'web_connection.dart';

/// Opens a Drift [QueryExecutor] in a cross-platform safe way.
///
/// - On web, uses IndexedDB.
/// - On mobile and desktop platforms, this uses the application documents directory.
/// The actual SQLite runtime is provided by `sqlite3_flutter_libs`.
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    return await openPlatformConnection();
  });
}
