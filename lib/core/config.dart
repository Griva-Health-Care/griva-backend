import 'dart:io';

class Config {
  // ── Backend URL ───────────────────────────────────────────────────────────────
  // Pass at build time:
  //   flutter run --dart-define=BACKEND_URL=http://3.6.1.238:5000
  static String get backendUrl {
    const env = String.fromEnvironment('BACKEND_URL');
    if (env.isNotEmpty) return env;
    return 'https://api.grivahealth.com';
  }

  // ── Raspberry Pi hardware controller ─────────────────────────────────────────
  /// flutter run --dart-define=GRIVA_HOST=192.168.x.x
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
