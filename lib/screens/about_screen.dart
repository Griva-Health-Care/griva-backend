import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _purple = Color(0xFF8B44F7);
  static const _lightPurple = Color(0xFFF5E6FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // App logo / branding block
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: _lightPurple,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Griva Pi',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          _sectionLabel('About the App'),
          const SizedBox(height: 8),
          _infoCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Information will be added here.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          _sectionLabel('Company'),
          const SizedBox(height: 8),
          _infoCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Information will be added here.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          _sectionLabel('Legal'),
          const SizedBox(height: 8),
          _infoCard(
            child: Column(
              children: [
                _legalRow(context, 'Privacy Policy'),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _legalRow(context, 'Terms of Service'),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _legalRow(context, 'Licenses'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Center(
            child: Text(
              '© 2025 Griva Health. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey[500],
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _infoCard({required Widget child}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: child,
    );
  }

  Widget _legalRow(BuildContext context, String title) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // TODO: navigate to respective legal page
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}
