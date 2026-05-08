/// A provider-agnostic push notification message.
class PushMessage {
  final String? title;
  final String? body;
  final Map<String, dynamic> data;

  const PushMessage({this.title, this.body, this.data = const {}});
}

/// Abstract interface for push notification services.
///
/// Swap the implementation in [CloudRegistry] to migrate providers.
abstract interface class IPushProvider {
  /// Request permissions, register the device token, and start listeners.
  Future<void> initialize();

  /// The current device push token, or null if unavailable.
  Future<String?> getToken();

  /// Emits a new token whenever the provider rotates it.
  Stream<String> get onTokenRefresh;

  /// Messages received while the app is in the foreground.
  Stream<PushMessage> get onMessage;

  /// Messages tapped by the user that open/resume the app.
  Stream<PushMessage> get onMessageOpenedApp;
}
