import '../cloud/cloud_registry.dart';
import 'package:flutter/material.dart';


import 'tele_app.dart';

/// Entry point for the tele-reporting module.
/// If the user is already signed in, goes straight to TeleApp.
/// Otherwise shows a prompt to sign in through the main app first.
class TeleLoginScreen extends StatefulWidget {
  const TeleLoginScreen({super.key});

  @override
  State<TeleLoginScreen> createState() => _TeleLoginScreenState();
}

class _TeleLoginScreenState extends State<TeleLoginScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    if (CloudRegistry.instance.auth.isSignedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goHome());
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TeleApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If already signed in we navigate away in initState; this screen only
    // shows when the user is not authenticated.
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.lock_outline, color: Color(0xFF3B82F6), size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                'Griva Tele-Reporting',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Please sign in from the main app first, then return here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Go to Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
