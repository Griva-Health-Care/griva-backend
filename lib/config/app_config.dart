class AppConfig {
  // Base IP/host for the camera/control server
  // static const String baseHost = '192.168.1.54';
  static const String _defaultHost = '10.42.1.1';
  static const String baseHost = String.fromEnvironment('GRIVA_HOST', defaultValue: _defaultHost);
  // static const String baseHost = '127.0.0.1';
  static const int httpPort = int.fromEnvironment('GRIVA_PORT', defaultValue: 5000);
  static const bool useHttps = bool.fromEnvironment('GRIVA_HTTPS', defaultValue: false);

  // Derived base URL
  static String get baseUrl => '${useHttps ? 'https' : 'http'}://$baseHost:$httpPort';

  // Camera/control endpoints
  static String ledStageUrl(int stage) => '$baseUrl/led?stage=$stage';
  static String greenFilterUrl(int level) => '$baseUrl/green?level=$level';
  static String get captureUrl => '$baseUrl/capture';
  static String get recordingStartUrl => '$baseUrl/recording/start';
  static String get recordingStopUrl => '$baseUrl/recording/stop';
  static String get recordingVideoUrl => '$baseUrl/recording/video';

  // Streaming endpoints (choose one as needed)
  static String get mjpegStreamUrl => 'http://$baseHost:$httpPort/?action=stream';
  static String get videoFeedUrl => '$baseUrl/video_feed';
  static String get altCamUrl => 'http://$baseHost:8889/cam1/';

  // AI inference endpoints
  static String get aiSendUrl => '$baseUrl/ai/send';
  static String get aiStatusUrl => '$baseUrl/ai/status';
  static String get aiResultUrl => '$baseUrl/result.jpg';

  // Socket.IO endpoint
  static String get socketIoUrl => 'http://$baseHost:$httpPort';
}

