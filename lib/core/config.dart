import 'dart:io';

class Config {
  /// Firebase Web API key — used for REST auth on Linux.
  static const String firebaseWebApiKey = 'AIzaSyDzzqjNQNL4-Jgjq7D98Ns6sPkcZ0LkdSQ';

  /// Raspberry Pi hardware controller base URL.
  /// Set GRIVA_HOST at build time for physical device:
  ///   flutter run --dart-define=GRIVA_HOST=192.168.x.x
  static String get piBaseUrl {
    const envHost = String.fromEnvironment('GRIVA_HOST');
    if (envHost.isNotEmpty) return 'http://$envHost:5000';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    return 'http://localhost:5000';
  }

  /// Your ABDM backend base URL.
  /// Set ABDM_HOST at build time:
  ///   flutter run --dart-define=ABDM_HOST=https://api.yourabdm.com
  static const String abdmBaseUrl = String.fromEnvironment(
    'ABDM_HOST',
    defaultValue: 'https://api.yourabdm.com',
  );
}
