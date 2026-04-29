import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum NetworkType { wifi, bluetooth, mobileData }

enum ColposcopeConnectionStatus { connected, notConnected }

const String _colposcopeHotspotName = 'GRIVAVISION';

class NetworkService {
  /// Returns [ColposcopeConnectionStatus.connected] if the device is currently
  /// connected to a hotspot whose name starts with "GRIVAVISION".
  ///
  /// On Android 8.1+ reading the WiFi SSID requires ACCESS_FINE_LOCATION
  /// to be granted at runtime. This method requests it if needed.
  static Future<ColposcopeConnectionStatus> checkColposcopeConnection() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return ColposcopeConnectionStatus.notConnected;
    }
    try {
      // Check permission status — the request itself must happen BEFORE this
      // call (done in HomePage.initState) so the system dialog doesn't clash
      // with the Flutter overlay.
      final permStatus = await Permission.locationWhenInUse.status;
      debugPrint('[NetworkService] Location permission status: $permStatus');
      if (!permStatus.isGranted) {
        debugPrint('[NetworkService] Location permission not granted — cannot read SSID');
        return ColposcopeConnectionStatus.notConnected;
      }

      // Also check that Location Services are enabled at the system level.
      // Android returns "<unknown ssid>" when location services are OFF even
      // if the app permission is granted.
      final serviceEnabled = await Permission.locationWhenInUse.serviceStatus;
      debugPrint('[NetworkService] Location service status: $serviceEnabled');
      if (!serviceEnabled.isEnabled) {
        debugPrint('[NetworkService] Location services disabled — SSID unreadable');
        return ColposcopeConnectionStatus.notConnected;
      }

      final info = NetworkInfo();
      final ssid = await info.getWifiName();
      // Always print so we can see what SSID the device reports.
      debugPrint('[NetworkService] Raw SSID from device: "$ssid"');

      if (ssid != null) {
        // Android wraps SSID in double-quotes: "GRIVAVISION_SN123"
        final cleaned = ssid.replaceAll('"', '').trim();
        debugPrint('[NetworkService] Cleaned SSID: "$cleaned"');
        if (cleaned.startsWith(_colposcopeHotspotName)) {
          debugPrint('[NetworkService] Colposcope hotspot detected ✓');
          return ColposcopeConnectionStatus.connected;
        }
      }
    } catch (e, st) {
      debugPrint('[NetworkService] SSID check error: $e\n$st');
    }
    return ColposcopeConnectionStatus.notConnected;
  }

  static Future<bool> openSpecificNetworkSettings(NetworkType type) async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        return false;
      }

      final shared = OpenSettingsPlus.shared;
      switch (type) {
        case NetworkType.wifi:
          if (shared is OpenSettingsPlusAndroid) {
            await shared.wifi();
          } else if (shared is OpenSettingsPlusIOS) {
            await shared.wifi();
          } else {
            return false;
          }
          break;
        case NetworkType.bluetooth:
          if (shared is OpenSettingsPlusAndroid) {
            await shared.bluetooth();
          } else if (shared is OpenSettingsPlusIOS) {
            await shared.bluetooth();
          } else {
            return false;
          }
          break;
        case NetworkType.mobileData:
          if (shared is OpenSettingsPlusAndroid) {
            // await shared.mobileData();
          } else {
            return false;
          }
          break;
      }
      return true;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Failed to open settings: $e');
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
