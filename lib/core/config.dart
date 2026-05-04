import 'dart:io';

class Config {
  // ── Supabase ─────────────────────────────────────────────────────────────────
  // Pass these at build time — never hardcode defaults here:
  //   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  //               --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
  static const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static String get supabaseUrl {
    assert(_supabaseUrl.isNotEmpty, 'SUPABASE_URL must be set via --dart-define');
    return _supabaseUrl;
  }

  static String get supabaseAnonKey {
    assert(_supabasePublishableKey.isNotEmpty, 'SUPABASE_PUBLISHABLE_KEY must be set via --dart-define');
    return _supabasePublishableKey;
  }

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
