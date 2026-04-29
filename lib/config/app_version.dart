class AppVersion {
  // Update this version number when pushing new Shorebird patches
  static const String version = '1.1.3';
  static const String buildNumber = '1';
  
  // Get full version string
  static String get fullVersion => 'v$version+$buildNumber';
  
  // Get short version string
  static String get shortVersion => 'v$version';
}
