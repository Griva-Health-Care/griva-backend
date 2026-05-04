import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/griva_api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<GrivaCase> _cases = [];
  List<GrivaReporter> _reporters = [];
  bool _loading = true;
  String? _error;
  int _tab = 0; // 0=Cases 1=Reporters

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        GrivaApiService.instance.listCases(),
        GrivaApiService.instance.listReporters(),
      ]);
      if (!mounted) return;
      setState(() {
        _cases     = results[0] as List<GrivaCase>;
        _reporters = results[1] as List<GrivaReporter>;
        _loading   = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _assign(GrivaCase c) async {
    final available = _reporters.where((r) => r.isAvailable).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available reporters.')));
      return;
    }
    final picked = await showModalBottomSheet<GrivaReporter>(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _PickReporterSheet(reporters: available),
    );
    if (picked == null) return;
    try {
      await GrivaApiService.instance.assignCase(c.id, picked.supabaseUid);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    const tabs = ['Cases', 'Reporters'];
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          Row(
            children: List.generate(tabs.length, (i) {
              final active = _tab == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: active ? const Color(0xFF3B82F6) : Colors.blueGrey.shade800,
                          width: active ? 2 : 1,
                        ),
                      ),
                    ),
                    child: Text(tabs[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: active ? const Color(0xFF3B82F6) : Colors.blueGrey,
                          fontWeight: active ? FontWeight.bold : FontWeight.normal,
                        )),
                  ),
                ),
              );
            }),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _load, child: const Text('Retry')),
                      ]))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: _tab == 0
                            ? _CasesList(cases: _cases, onAssign: _assign)
                            : _ReportersList(reporters: _reporters),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Cases list ────────────────────────────────────────────────────────────────

class _CasesList extends StatelessWidget {
  final List<GrivaCase> cases;
  final Future<void> Function(GrivaCase) onAssign;
  const _CasesList({required this.cases, required this.onAssign});

  @override
  Widget build(BuildContext context) {
    if (cases.isEmpty) {
      return Center(child: Text('No cases.', style: TextStyle(color: Colors.blueGrey.shade400)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cases.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final c = cases[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: c.statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(c.statusLabel,
                    style: TextStyle(color: c.statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text(
                DateFormat('dd MMM, HH:mm').format(c.createdAt.toLocal()),
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11),
              ),
            ]),
            const SizedBox(height: 8),
            Text('${c.files.length} file${c.files.length != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            if (c.notes != null && c.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(c.notes!, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12)),
            ],
            if (c.status == 'pending') ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text('Assign'),
                  onPressed: () => onAssign(c),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ]),
        );
      },
    );
  }
}

// ── Reporters list ────────────────────────────────────────────────────────────

class _ReportersList extends StatelessWidget {
  final List<GrivaReporter> reporters;
  const _ReportersList({required this.reporters});

  @override
  Widget build(BuildContext context) {
    if (reporters.isEmpty) {
      return Center(child: Text('No reporters found.', style: TextStyle(color: Colors.blueGrey.shade400)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reporters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final r = reporters[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            CircleAvatar(
              backgroundColor: Colors.blueGrey.shade800,
              child: Text(
                r.displayName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.displayName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                if (r.hospital != null)
                  Text(r.hospital!, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (r.isAvailable ? Colors.green : Colors.grey).withAlpha(30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                r.isAvailable ? 'Available' : 'Busy',
                style: TextStyle(
                  color: r.isAvailable ? Colors.green : Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

// ── Pick reporter bottom sheet ────────────────────────────────────────────────

class _PickReporterSheet extends StatelessWidget {
  final List<GrivaReporter> reporters;
  const _PickReporterSheet({required this.reporters});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Assign to Reporter',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      ...reporters.map((r) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey.shade800,
          child: Text(r.displayName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
        ),
        title: Text(r.displayName, style: const TextStyle(color: Colors.white)),
        subtitle: r.hospital != null
            ? Text(r.hospital!, style: const TextStyle(color: Colors.white54))
            : null,
        onTap: () => Navigator.pop(context, r),
      )),
      const SizedBox(height: 16),
    ]);
  }
}
