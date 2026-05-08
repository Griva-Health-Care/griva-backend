/// Abstract interface for cloud database operations.
///
/// Swap the implementation in [CloudRegistry] to migrate providers.
abstract interface class IDatabaseProvider {
  /// Fetch rows from [table].
  ///
  /// [eq]      — equality filters  `{'col': value, ...}`
  /// [isNull]  — columns that must be NULL `['deleted_at', ...]`
  /// [orderBy] — column name for ordering
  /// [limit]   — max rows to return
  Future<List<Map<String, dynamic>>> select(
    String table, {
    Map<String, dynamic>? eq,
    List<String>? isNull,
    String? orderBy,
    bool ascending = true,
    int? limit,
  });

  /// Fetch exactly one row, or null if none matches.
  Future<Map<String, dynamic>?> selectSingle(
    String table, {
    required Map<String, dynamic> eq,
  });

  /// Insert or update a row. [onConflict] names the column used for conflict
  /// resolution (e.g. `'uuid'` or `'uid'`).
  Future<void> upsert(
    String table,
    Map<String, dynamic> data, {
    String? onConflict,
  });

  /// Update rows matching [eq] with [data].
  Future<void> update(
    String table,
    Map<String, dynamic> data, {
    required Map<String, dynamic> eq,
  });

  /// Watch a single row for real-time changes.
  /// Emits the new row map each time it changes.
  Stream<Map<String, dynamic>> watchRow(
    String table,
    String idColumn,
    String idValue,
  );

  /// Release any open real-time subscriptions.
  Future<void> dispose();
}
