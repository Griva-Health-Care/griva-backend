import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

import 'cloud/backend/backend_database_provider.dart';
import 'cloud/backend/backend_storage_provider.dart';
import 'cloud/cloud_registry.dart';
import 'cloud/firebase/fcm_push_provider.dart';
import 'cloud/firebase/firebase_auth_provider.dart';
import 'core/app_router.dart';
import 'core/config.dart';
import 'login_page.dart';
import 'launch_screen.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';
import 'tele/tele_login_screen.dart';

const _teleMode = bool.fromEnvironment('TELE_MODE', defaultValue: false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Initialize platform SDKs ──────────────────────────────────────────
  if (!Platform.isLinux) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // ── 2. Wire up cloud providers ────────────────────────────────────────────
  final backendUrl   = Config.backendUrl;
  final authProvider = FirebaseAuthProvider();
  await authProvider.restoreSession(); // re-hydrate cached ID token on startup

  CloudRegistry.instance.configure(
    auth:     authProvider,
    database: BackendDatabaseProvider(baseUrl: backendUrl),
    storage:  BackendStorageProvider(baseUrl: backendUrl),
    push:     FcmPushProvider(),
  );

  if (_teleMode) {
    runApp(const _TeleRoot());
    return;
  }

  runApp(MyApp(authService: AuthService()));
}

class _TeleRoot extends StatelessWidget {
  const _TeleRoot();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Griva Tele-Reporting',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const TeleLoginScreen(),
    );
  }
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 800),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen(authService: authService),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final AuthService authService;

  const SplashScreen({super.key, required this.authService});

  @override
  
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth = CloudRegistry.instance.auth;
    if (auth.isSignedIn) {
      AppRouter.navigateToHome(context, userEmail: auth.currentUserEmail ?? '');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GrivaLoginPage(authService: widget.authService),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LaunchScreen();
  }
}
