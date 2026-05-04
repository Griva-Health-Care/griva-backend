import 'dart:io';

class Config {
  // ── Supabase ─────────────────────────────────────────────────────────────────
  /// Public URL of your Supabase project.
  /// Set SUPABASE_URL at build time:
  ///   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://kivcxcdcvypnazpbuhey.supabase.co',
  );

  /// Supabase anon key (safe to embed in client apps).
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtpdmN4Y2RjdnlwbmF6cGJ1aGV5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4NzA0OTcsImV4cCI6MjA5MzQ0NjQ5N30.vS43Nig7AZfTTEHsk8C9hLeMCULOQxSe89egvq-VTSs',
  );

  // ── Raspberry Pi hardware controller ─────────────────────────────────────────
  /// Set GRIVA_HOST at build time for physical device:
  ///   flutter run --dart-define=GRIVA_HOST=192.168.x.x
  static String get piBaseUrl {
    const envHost = String.fromEnvironment('GRIVA_HOST');
    if (envHost.isNotEmpty) return 'http://$envHost:5000';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    return 'http://localhost:5000';
  }

  /// Your ABDM backend base URL.
  static const String abdmBaseUrl = String.fromEnvironment(
    'ABDM_HOST',
    defaultValue: 'https://api.yourabdm.com',
  );
}
