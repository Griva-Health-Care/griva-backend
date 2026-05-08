import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../i_push_provider.dart';

/// Firebase Cloud Messaging implementation of [IPushProvider].
///
/// To switch to a different push provider (OneSignal, AWS SNS, etc.)
/// create a new class implementing [IPushProvider] and register it in
/// [CloudRegistry] — nothing else needs to change.
class FcmPushProvider implements IPushProvider {
  FcmPushProvider();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final _tokenRefreshController =
      StreamController<String>.broadcast();
  final _messageController =
      StreamController<PushMessage>.broadcast();
  final _messageOpenedController =
      StreamController<PushMessage>.broadcast();

  @override
  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      _fcm.onTokenRefresh.listen((token) {
        _tokenRefreshController.add(token);
      });

      FirebaseMessaging.onMessage.listen((msg) {
        _messageController.add(_convert(msg));
      });

      FirebaseMessaging.onMessageOpenedApp.listen((msg) {
        _messageOpenedController.add(_convert(msg));
      });

      debugPrint('[FCM] Initialized');
    } catch (e) {
      debugPrint('[FCM] Init error: $e');
    }
  }

  @override
  Future<String?> getToken() => _fcm.getToken();

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Stream<PushMessage> get onMessage => _messageController.stream;

  @override
  Stream<PushMessage> get onMessageOpenedApp =>
      _messageOpenedController.stream;

  PushMessage _convert(RemoteMessage msg) => PushMessage(
        title: msg.notification?.title,
        body:  msg.notification?.body,
        data:  msg.data,
      );
}
