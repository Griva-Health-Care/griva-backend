import 'i_auth_provider.dart';
import 'i_database_provider.dart';
import 'i_push_provider.dart';
import 'i_storage_provider.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// CloudRegistry — the single place to swap cloud providers.
///
/// HOW TO MIGRATE:
///   1. Write a new class implementing the relevant interface
///      (IAuthProvider / IDatabaseProvider / IStorageProvider / IPushProvider).
///   2. Open [configure] below and swap the constructor — nothing else changes.
///
/// Current stack:
///   Auth      → FirebaseAuthProvider
///   Database  → BackendDatabaseProvider
///   Storage   → BackendStorageProvider
///   Push      → FcmPushProvider
/// ─────────────────────────────────────────────────────────────────────────────
class CloudRegistry {
  CloudRegistry._();
  static final CloudRegistry instance = CloudRegistry._();

  late IAuthProvider     auth;
  late IDatabaseProvider database;
  late IStorageProvider  storage;
  late IPushProvider     push;

  bool _configured = false;

  /// Call once in [main] after all platform SDKs are initialized.
  void configure({
    required IAuthProvider     auth,
    required IDatabaseProvider database,
    required IStorageProvider  storage,
    required IPushProvider     push,
  }) {
    this.auth     = auth;
    this.database = database;
    this.storage  = storage;
    this.push     = push;
    _configured   = true;
  }

  /// Guards against accidental access before [configure] is called.
  void assertConfigured() {
    assert(_configured, 'CloudRegistry.configure() must be called in main()');
  }
}
