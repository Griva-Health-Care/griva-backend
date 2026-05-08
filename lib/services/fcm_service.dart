import 'package:flutter/foundation.dart';

import '../cloud/cloud_registry.dart';
import 'griva_api_service.dart';

/// Manages push notification lifecycle using [CloudRegistry.instance.push].
///
/// Call [init] once after the user signs in successfully.
/// To swap push providers, change the [IPushProvider] registered in
/// [CloudRegistry] — nothing here needs to change.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  Future<void> init() async {
    if (kIsWeb) return;

    try {
      final push = CloudRegistry.instance.push;
      await push.initialize();

      final token = await push.getToken();
      if (token != null) await _uploadToken(token);

      push.onTokenRefresh.listen(_uploadToken);
      push.onMessage.listen((msg) {
        debugPrint('[PUSH] Foreground message: ${msg.title}');
      });
      push.onMessageOpenedApp.listen((msg) {
        debugPrint('[PUSH] Notification tapped: ${msg.data}');
      });
    } catch (e) {
      debugPrint('[PUSH] init error: $e');
    }
  }

  Future<void> _uploadToken(String token) async {
    try {
      await GrivaApiService.instance.updateFcmToken(token);
      debugPrint('[PUSH] Token uploaded');
    } catch (e) {
      debugPrint('[PUSH] Token upload failed: $e');
    }
  }
}
