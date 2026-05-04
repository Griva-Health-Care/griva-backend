import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/fcm_service.dart';
import '../services/griva_api_service.dart';
import 'admin/admin_dashboard_screen.dart';
import 'diagnostic/doctor_cases_screen.dart';
import 'reporter/tele_reporter_dashboard.dart';
import 'tele_login_screen.dart';

/// Root widget for the tele-reporting module.
/// Reads the logged-in user's role from the backend and routes to the
/// correct dashboard. Uses Firebase Auth — no separate tele login needed.
class TeleApp extends StatefulWidget {
  const TeleApp({super.key});

  @override
  State<TeleApp> createState() => _TeleAppState();
}

class _TeleAppState extends State<TeleApp> {
  String _role = '';
  bool _loading = true;
  String? _error;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _refreshNotifCount();
  }

  Future<void> _loadRole() async {
    setState(() { _loading = true; _error = null; });
    try {
      final me = await GrivaApiService.instance.getMe();
      FcmService.instance.init();
      if (mounted) setState(() { _role = me['role'] as String? ?? ''; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _refreshNotifCount() async {
    try {
      final notifs = await GrivaApiService.instance.listNotifications();
      final count  = notifs.where((n) => !n.isRead).length;
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TeleLoginScreen()),
    );
  }

  void _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _NotificationsScreen(onRead: _refreshNotifCount),
      ),
    );
    _refreshNotifCount();
  }

  Widget _body() {
    switch (_role) {
      case 'tele_reporter':
        return const TeleReporterDashboard();
      case 'admin':
      case 'superadmin':
        return const AdminDashboardScreen();
      case 'doctor':
      case 'diagnostic':
      default:
        return const DoctorCasesScreen();
    }
  }

  String get _title {
    switch (_role) {
      case 'tele_reporter': return 'My Cases';
      case 'admin':
      case 'superadmin':   return 'Admin';
      default:             return 'Tele Reports';
    }
  }

  String get _roleLabel {
    switch (_role) {
      case 'tele_reporter': return 'Reporter';
      case 'admin':         return 'Admin';
      case 'superadmin':    return 'Super Admin';
      case 'diagnostic':    return 'Diagnostic';
      default:              return 'Doctor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          const Text('Griva', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 6),
          Text(_title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ]),
        actions: [
          if (_role.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _roleLabel,
                style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: _openNotifications,
            icon: Badge(
              isLabelVisible: _unreadCount > 0,
              label: Text('$_unreadCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _loadRole, child: const Text('Retry')),
                  ]))
              : _body(),
    );
  }
}

// ── Notifications screen ──────────────────────────────────────────────────────

class _NotificationsScreen extends StatefulWidget {
  final VoidCallback onRead;
  const _NotificationsScreen({required this.onRead});

  @override
  State<_NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<_NotificationsScreen> {
  List<GrivaNotification> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final n = await GrivaApiService.instance.listNotifications();
      if (mounted) setState(() { _notifs = n; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(GrivaNotification n) async {
    if (n.isRead) return;
    await GrivaApiService.instance.markNotificationRead(n.id);
    widget.onRead();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Notifications'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifs.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.notifications_none_outlined, size: 52, color: Colors.blueGrey.shade700),
                    const SizedBox(height: 12),
                    Text('No notifications yet.', style: TextStyle(color: Colors.blueGrey.shade400)),
                  ]),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final n = _notifs[i];
                    return GestureDetector(
                      onTap: () => _markRead(n),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: n.isRead ? const Color(0xFF1E293B) : const Color(0xFF1E3A5F),
                          borderRadius: BorderRadius.circular(12),
                          border: n.isRead
                              ? null
                              : Border.all(color: const Color(0xFF3B82F6).withAlpha(80)),
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(
                            n.isRead ? Icons.notifications_none_outlined : Icons.notifications_outlined,
                            color: n.isRead ? Colors.blueGrey : const Color(0xFF3B82F6),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(n.title,
                                  style: TextStyle(
                                      color: n.isRead ? Colors.white70 : Colors.white,
                                      fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(n.body,
                                  style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMM, HH:mm').format(n.createdAt.toLocal()),
                                style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 11),
                              ),
                            ]),
                          ),
                          if (!n.isRead)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(Icons.circle, color: Color(0xFF3B82F6), size: 8),
                            ),
                        ]),
                      ),
                    );
                  },
                ),
    );
  }
}
