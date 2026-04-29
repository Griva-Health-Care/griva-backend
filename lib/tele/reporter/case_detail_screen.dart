import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../services/griva_api_service.dart';

class CaseDetailScreen extends StatefulWidget {
  final GrivaCase teleCase;
  const CaseDetailScreen({super.key, required this.teleCase});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  static const _purple      = Color(0xFF6B46C1);
  static const _purpleLight = Color(0xFFF3EEFF);
  static const _border      = Color(0xFFE2D9F3);
  static const _textDark    = Color(0xFF1A1035);
  static const _textMid     = Color(0xFF6B7280);
  static const _bg          = Color(0xFFF8F5FF);

  late GrivaCase _case;
  bool _submitting = false;
  bool _updatingStatus = false;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _case = widget.teleCase;
    if (_case.reporterNote != null) {
      _noteCtrl.text = _case.reporterNote!;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _isCompleted => _case.status == 'completed';

  Future<void> _submitReport() async {
    final note = _noteCtrl.text.trim();
    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your findings.'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final updated = await GrivaApiService.instance.submitReport(_case.id, note);
      setState(() { _case = updated; _submitting = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully.'),
              backgroundColor: Color(0xFF10B981)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _setStatus(String status) async {
    setState(() => _updatingStatus = true);
    try {
      final updated = await GrivaApiService.instance.updateStatus(_case.id, status);
      setState(() { _case = updated; _updatingStatus = false; });
    } catch (e) {
      setState(() => _updatingStatus = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgFiles = _case.files.where((f) => f.type.startsWith('image/')).toList();
    final vidFiles = _case.files.where((f) => f.type.startsWith('video/')).toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Case Detail',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            Text(_case.id.substring(0, 8).toUpperCase(),
                style: const TextStyle(fontSize: 11, color: _textMid, fontFamily: 'monospace')),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _StatusChip(status: _case.status),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status actions
          if (!_isCompleted) _buildStatusRow(),

          // Notes from submitter
          if (_case.notes != null && _case.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.notes_rounded,
              title: 'Submitter Notes',
              child: Text(_case.notes!,
                  style: const TextStyle(color: _textDark, fontSize: 14, height: 1.5)),
            ),
          ],

          // Images
          if (imgFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.image_outlined,
              title: 'Images (${imgFiles.length})',
              child: _buildImageGrid(imgFiles),
            ),
          ],

          // Videos
          if (vidFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.videocam_outlined,
              title: 'Videos (${vidFiles.length})',
              child: _buildFileList(vidFiles),
            ),
          ],

          // Reporter note / findings
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.edit_note_rounded,
            title: 'Findings / Report',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isCompleted && _case.reporterNote != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _purpleLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    child: Text(_case.reporterNote!,
                        style: const TextStyle(color: _textDark, fontSize: 14, height: 1.5)),
                  )
                else ...[
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 6,
                    style: const TextStyle(color: _textDark, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter your findings, diagnosis, or recommendations…',
                      hintStyle: const TextStyle(color: _textMid, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _purple, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _submitting
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(_submitting ? 'Submitting…' : 'Submit Report'),
                      onPressed: _submitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Metadata
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.info_outline_rounded,
            title: 'Case Info',
            child: _buildMetaTable(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    final nextStatuses = <String, String>{
      'assigned': 'in_review',
      'in_review': 'in_review',
    };
    final nextStatus = nextStatuses[_case.status];

    return Row(
      children: [
        if (nextStatus != null && _case.status != 'in_review')
          Expanded(
            child: _ActionButton(
              label: 'Start Review',
              icon: Icons.play_arrow_rounded,
              color: const Color(0xFF8B5CF6),
              loading: _updatingStatus,
              onTap: () => _setStatus('in_review'),
            ),
          ),
        if (_case.status == 'in_review') ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.visibility_rounded, color: Color(0xFF8B5CF6), size: 16),
                SizedBox(width: 6),
                Text('In Review', style: TextStyle(color: Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w600, fontSize: 13)),
              ]),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6B46C1).withValues(alpha: 0.05),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(children: [
              Icon(icon, color: _purple, size: 16),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(
                  color: _textDark, fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          ),
          const Divider(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<GrivaFile> imgs) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6,
      ),
      itemCount: imgs.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => _openImageViewer(imgs, i),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: imgs[i].url,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: _purpleLight,
              child: const Center(
                child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _purple)),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              color: _purpleLight,
              child: const Icon(Icons.broken_image_rounded, color: _purple),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileList(List<GrivaFile> files) {
    return Column(
      children: files.map((f) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: _purpleLight, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.videocam_outlined, color: _purple, size: 18),
        ),
        title: Text(f.name,
            style: const TextStyle(color: _textDark, fontSize: 13), maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text(_formatSize(f.size),
            style: const TextStyle(color: _textMid, fontSize: 11)),
      )).toList(),
    );
  }

  Widget _buildMetaTable() {
    final rows = <_MetaRow>[
      _MetaRow('Case ID', _case.id.substring(0, 8).toUpperCase()),
      _MetaRow('Status', _case.statusLabel),
      _MetaRow('Submitted', _formatDate(_case.createdAt)),
      _MetaRow('Last updated', _formatDate(_case.updatedAt)),
      if (_case.completedAt != null)
        _MetaRow('Completed', _formatDate(_case.completedAt!)),
    ];

    return Column(
      children: rows.map((r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(r.label,
                style: const TextStyle(color: _textMid, fontSize: 12))),
            Expanded(child: Text(r.value,
                style: const TextStyle(color: _textDark, fontSize: 12,
                    fontWeight: FontWeight.w500))),
          ],
        ),
      )).toList(),
    );
  }

  void _openImageViewer(List<GrivaFile> imgs, int initialIndex) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _ImageViewerScreen(images: imgs, initialIndex: initialIndex),
    ));
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _MetaRow {
  final String label;
  final String value;
  const _MetaRow(this.label, this.value);
}

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Text(_label(), style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Color _color() {
    switch (status) {
      case 'pending':   return const Color(0xFFF59E0B);
      case 'assigned':  return const Color(0xFF3B82F6);
      case 'in_review': return const Color(0xFF8B5CF6);
      case 'completed': return const Color(0xFF10B981);
      default:          return const Color(0xFF6B7280);
    }
  }

  String _label() {
    switch (status) {
      case 'pending':   return 'Pending';
      case 'assigned':  return 'Assigned';
      case 'in_review': return 'In Review';
      case 'completed': return 'Completed';
      default:          return status;
    }
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          loading
              ? SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(color: color, strokeWidth: 2))
              : Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    );
  }
}

// ── Full-screen image viewer ──────────────────────────────────────────────────

class _ImageViewerScreen extends StatefulWidget {
  final List<GrivaFile> images;
  final int initialIndex;
  const _ImageViewerScreen({required this.images, required this.initialIndex});

  @override
  State<_ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<_ImageViewerScreen> {
  late PageController _page;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _page = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_current + 1} / ${widget.images.length}',
            style: const TextStyle(fontSize: 14)),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: _page,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: CachedNetworkImage(
              imageUrl: widget.images[i].url,
              fit: BoxFit.contain,
              placeholder: (_, __) => const CircularProgressIndicator(color: Colors.white54),
              errorWidget: (_, __, ___) => const Icon(
                  Icons.broken_image_rounded, color: Colors.white54, size: 64),
            ),
          ),
        ),
      ),
    );
  }
}
