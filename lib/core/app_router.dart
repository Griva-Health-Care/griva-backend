import 'package:flutter/material.dart';

import '../home_page.dart';
import '../services/cloud_config_service.dart';
import '../tele/diagnostic/doctor_cases_screen.dart';
import '../tele/reporter/tele_reporter_dashboard.dart';

/// Central routing hub.  After a successful login call [navigateToHome] and
/// the correct home screen is pushed based on the doctor's role.
///
/// Role → Screen mapping
/// ─────────────────────────────────────────────────────────────────────────
///   solo / clinic   │ HomePage              (patient-management UI)
///   doctor          │ HomePage              (same — doctors use the full UI)
///   diagnostic      │ DoctorCasesScreen     (tele-report submission & tracking)
///   tele_reporter   │ TeleReporterDashboard (reporter review queue)
/// ─────────────────────────────────────────────────────────────────────────
class AppRouter {
  AppRouter._();

  /// Replace the current route with the role-appropriate home screen.
  static void navigateToHome(BuildContext context, {required String userEmail}) {
    final role = CloudConfigService.instance.current.role;
    debugPrint('[ROUTER] Navigating to home for role: $role');

    final Widget home = switch (role) {
      'tele_reporter' => const TeleReporterDashboard(),
      'diagnostic'    => const DoctorCasesScreen(),
      _               => HomePage(userEmail: userEmail), // solo / clinic / doctor / fallback
    };

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => home),
    );
  }
}
