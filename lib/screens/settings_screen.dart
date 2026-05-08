import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/user_service.dart';
import 'about_screen.dart';
import 'report_header_footer_screen.dart';
import 'user_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String userEmail;

  const SettingsScreen({super.key, required this.userEmail});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _purple = Color(0xFF8B44F7);
  static const _lightPurple = Color(0xFFF5E6FF);

  final _userService = UserService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getUserByEmail(widget.userEmail);
    if (mounted) setState(() => _user = user);
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserProfileScreen(userEmail: widget.userEmail)),
    ).then((_) => _loadUser());
  }

  void _openReportHeader() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportHeaderFooterScreen(userEmail: widget.userEmail),
      ),
    );
  }

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _lightPurple, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.support_agent, color: _purple, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Customer Support', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _contactRow(ctx, Icons.email_outlined, 'Email', 'support@grivahealth.com'),
            const SizedBox(height: 12),
            _contactRow(ctx, Icons.phone_outlined, 'Phone', '+91 98765 43210'),
            const SizedBox(height: 12),
            _contactRow(ctx, Icons.access_time_outlined, 'Hours', 'Mon–Fri, 9 AM – 6 PM IST'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: _purple)),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(BuildContext ctx, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _purple),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('$label copied'), duration: const Duration(seconds: 1)),
                );
              },
              child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ],
    );
  }

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
          'Settings',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // ── Account ──────────────────────────────────────────────────
          _sectionLabel('Account'),
          const SizedBox(height: 8),
          _buildGroup(children: [
            _navTile(
              icon: Icons.person_outline,
              label: 'Profile',
              subtitle: _user?.fullName ?? 'Manage your personal details',
              trailing: _buildAvatar(),
              onTap: _openProfile,
            ),
          ]),
          const SizedBox(height: 24),

          // ── Reports ───────────────────────────────────────────────────
          _sectionLabel('Reports'),
          const SizedBox(height: 8),
          _buildGroup(children: [
            _navTile(
              icon: Icons.picture_in_picture_alt_outlined,
              label: 'Report Header & Footer',
              subtitle: _user != null && _user!.useReportHeaderFooter
                  ? 'Custom branding enabled'
                  : 'Set your clinic letterhead for reports',
              statusDot: _user != null && _user!.useReportHeaderFooter,
              onTap: _openReportHeader,
            ),
          ]),
          const SizedBox(height: 24),

          // ── General ───────────────────────────────────────────────────
          _sectionLabel('General'),
          const SizedBox(height: 8),
          _buildGroup(children: [
            _navTile(
              icon: Icons.support_agent_outlined,
              label: 'Customer Support',
              subtitle: 'Get help from the Griva team',
              onTap: _showSupportDialog,
              trailingIcon: Icons.open_in_new,
            ),
            const Divider(height: 1, indent: 56),
            _navTile(
              icon: Icons.info_outline,
              label: 'About',
              subtitle: 'App version, legal & company info',
              onTap: _openAbout,
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (_user?.profileImage != null) {
      ImageProvider img;
      final path = _user!.profileImage!;
      img = path.startsWith('http') ? NetworkImage(path) : FileImage(File(path)) as ImageProvider;
      return CircleAvatar(radius: 18, backgroundImage: img);
    }
    return const CircleAvatar(
      radius: 18,
      backgroundColor: _lightPurple,
      child: Icon(Icons.person, color: _purple, size: 18),
    );
  }

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[500], letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildGroup({required List<Widget> children}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    IconData? trailingIcon,
    bool statusDot = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _lightPurple, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: _purple, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      if (statusDot) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ?? Icon(trailingIcon ?? Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}
