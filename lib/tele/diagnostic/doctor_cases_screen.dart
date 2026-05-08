import '../../../cloud/cloud_registry.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';


import '../../screens/report_pdf_viewer_screen.dart';
import '../../services/griva_api_service.dart';
import 'create_case_screen.dart';

/// Dashboard for doctors to track their submitted tele-report cases and
/// read completed reports from reporters.
class DoctorCasesScreen extends StatefulWidget {
  const DoctorCasesScreen({super.key});

  @override
  State<DoctorCasesScreen> createState() => _DoctorCasesScreenState();
}

class _DoctorCasesScreenState extends State<DoctorCasesScreen> {
  List<GrivaCase> _cases = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final cases = await GrivaApiService.instance.listCases();
      if (mounted) setState(() { _cases = cases; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _newCase() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateCaseScreen()),
    );
    if (ok == true) _load();
  }

  void _viewReport(GrivaCase c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ReportSheet(c: c, onDownloadPdf: () => _downloadPdf(c)),
    );
  }

  Future<void> _downloadPdf(GrivaCase c) async {
    try {
      final token = CloudRegistry.instance.auth.accessToken;
      if (token == null) throw Exception('Not signed in');

      final url = GrivaApiService.instance.reportPdfUrl(c.id);
      final res = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode != 200) throw Exception('Server returned ${res.statusCode}');

      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/tele-report-${c.id.substring(0, 8)}.pdf');
      await file.writeAsBytes(res.bodyBytes);

      if (!mounted) return;
      Navigator.pop(context); // close the bottom sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportPdfViewerScreen(
            filePath: file.path,
            title: 'Tele Report',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF download failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _load, child: const Text('Retry')),
                ]))
              : _cases.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.inbox_outlined, size: 56, color: Colors.blueGrey.shade700),
                        const SizedBox(height: 12),
                        Text('No cases submitted yet.',
                            style: TextStyle(color: Colors.blueGrey.shade400)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Submit First Case'),
                          onPressed: _newCase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ]),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cases.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _CaseTile(
                          c: _cases[i],
                          onViewReport: _viewReport,
                        ),
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newCase,
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Case'),
      ),
    );
  }
}

// ── Case tile ─────────────────────────────────────────────────────────────────

class _CaseTile extends StatelessWidget {
  final GrivaCase c;
  final void Function(GrivaCase) onViewReport;
  const _CaseTile({required this.c, required this.onViewReport});

  @override
  Widget build(BuildContext context) {
    final completed = c.status == 'completed';
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: completed
            ? Border.all(color: const Color(0xFF10B981).withAlpha(80), width: 1.5)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
              DateFormat('dd MMM yyyy').format(c.createdAt.toLocal()),
              style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12),
            ),
          ]),

          const SizedBox(height: 10),

          Row(children: [
            Icon(Icons.attach_file, size: 14, color: Colors.blueGrey.shade400),
            const SizedBox(width: 4),
            Text('${c.files.length} file${c.files.length != 1 ? 's' : ''}',
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12)),
          ]),

          if (c.notes != null && c.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(c.notes!, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],

          if (completed && c.reporterNote != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Report ready',
                      style: TextStyle(color: Color(0xFF10B981), fontSize: 13)),
                ),
                TextButton(
                  onPressed: () => onViewReport(c),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('View', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Report bottom sheet ───────────────────────────────────────────────────────

class _ReportSheet extends StatelessWidget {
  final GrivaCase c;
  final VoidCallback onDownloadPdf;
  const _ReportSheet({required this.c, required this.onDownloadPdf});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scroll) => Column(children: [
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            const Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 10),
            const Text('Reporter Findings',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const Spacer(),
            // PDF download button
            TextButton.icon(
              onPressed: onDownloadPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
              label: const Text('PDF'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              c.completedAt != null
                  ? DateFormat('dd MMM yyyy').format(c.completedAt!.toLocal())
                  : '',
              style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12),
            ),
          ),
        ),
        const Divider(color: Color(0xFF2D3B55), height: 1),
        Expanded(
          child: SingleChildScrollView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Text(
              c.reporterNote ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
            ),
          ),
        ),
      ]),
    );
  }
}
