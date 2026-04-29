import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'griva_api_service.dart';

/// Handles Firebase Cloud Messaging lifecycle:
///   1. Request permission on first run.
///   2. Upload the device token to the backend so the server can send pushes.
///   3. Listen for token refreshes and re-upload automatically.
///   4. Expose a stream for foreground messages so UI can react.
///
/// Call [init] once after the user signs in successfully.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Request permission, register the token, and start listeners.
  Future<void> init() async {
    // Skip on web and Linux (no FCM support).
    if (kIsWeb) return;

    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      // Upload current token.
      final token = await _fcm.getToken();
      if (token != null) await _uploadToken(token);

      // Re-upload whenever the token rotates.
      _fcm.onTokenRefresh.listen(_uploadToken);

      // Handle messages received while the app is open.
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Handle taps on notifications that opened the app from background.
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    } catch (e) {
      debugPrint('[FCM] init error: $e');
    }
  }

  Future<void> _uploadToken(String token) async {
    try {
      await GrivaApiService.instance.updateFcmToken(token);
      debugPrint('[FCM] Token uploaded');
    } catch (e) {
      debugPrint('[FCM] Token upload failed: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground message: ${message.notification?.title}');
    // The in-app notification bell in TeleApp will pick this up on next poll.
    // For a richer experience, show a local snackbar or local notification here.
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] Notification tapped: ${message.data}');
    // Navigate to the relevant case if caseId is present in message.data.
    // Navigation context is not available here; use a global navigator key
    // or an event bus if deep-linking is needed.
  }
}
