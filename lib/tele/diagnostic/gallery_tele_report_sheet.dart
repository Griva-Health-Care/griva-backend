import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/griva_api_service.dart';

/// Bottom sheet launched from GalleryScreen.
/// Uploads selected images/videos to Firebase Storage, then POSTs case
/// metadata to the Griva Node.js backend.
/// Reporter selection is optional — leave on "Auto-assign" to let the
/// backend pick the first available reporter.
class GalleryTeleReportSheet extends StatefulWidget {
  final List<Uint8List> selectedImages;
  final List<Uint8List> selectedVideos;

  const GalleryTeleReportSheet({
    super.key,
    required this.selectedImages,
    required this.selectedVideos,
  });

  @override
  State<GalleryTeleReportSheet> createState() => _GalleryTeleReportSheetState();
}

class _GalleryTeleReportSheetState extends State<GalleryTeleReportSheet> {
  // ── App colour palette ────────────────────────────────────────────────────
  static const _purple     = Color(0xFF6B46C1);
  static const _purpleLight= Color(0xFFF3EEFF);
  static const _border     = Color(0xFFE2D9F3);
  static const _textDark   = Color(0xFF1A1035);
  static const _textMid    = Color(0xFF6B7280);
  static const _errorRed   = Color(0xFFDC2626);

  // ── State ─────────────────────────────────────────────────────────────────
  final _notesCtrl = TextEditingController();
  String _priority = 'ROUTINE';

  List<GrivaReporter> _reporters = [];
  /// null  = "Auto-assign"
  GrivaReporter? _selectedReporter;
  bool _loadingReporters = true;
  String? _reporterError;

  bool   _submitting    = false;
  String? _submitError;
  int    _uploadedCount = 0;
  String _statusLabel   = '';

  @override
  void initState() {
    super.initState();
    _fetchReporters();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _fetchReporters() async {
    setState(() { _loadingReporters = true; _reporterError = null; });
    try {
      final list = await GrivaApiService.instance.listReporters();
      setState(() { _reporters = list; _loadingReporters = false; });
    } catch (e) {
      // ignore: avoid_print
      print('[GrivaReporters] ERROR type=${e.runtimeType} msg=$e');
      final msg = e is GrivaApiException
          ? '${e.statusCode}: ${e.message}'
          : 'Network error: $e';
      setState(() { _reporterError = msg; _loadingReporters = false; });
    }
  }

  // ── Submission ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final totalFiles = widget.selectedImages.length + widget.selectedVideos.length;
    if (totalFiles == 0) {
      setState(() => _submitError = 'No files selected.');
      return;
    }

    setState(() {
      _submitting    = true;
      _submitError   = null;
      _uploadedCount = 0;
      _statusLabel   = 'Preparing upload…';
    });

    try {
      final ts       = DateTime.now().millisecondsSinceEpoch;
      final uploaded = <GrivaFile>[];

      // Upload images to backend
      for (var i = 0; i < widget.selectedImages.length; i++) {
        setState(() => _statusLabel = 'Uploading image ${i + 1} of ${widget.selectedImages.length}…');
        final file = await GrivaApiService.instance.uploadFile(
            widget.selectedImages[i], 'img_${ts}_$i.jpg', 'image/jpeg');
        uploaded.add(file);
        setState(() => _uploadedCount = i + 1);
      }

      // Upload videos to backend
      for (var i = 0; i < widget.selectedVideos.length; i++) {
        setState(() => _statusLabel = 'Uploading video ${i + 1} of ${widget.selectedVideos.length}…');
        final file = await GrivaApiService.instance.uploadFile(
            widget.selectedVideos[i], 'vid_${ts}_$i.mp4', 'video/mp4');
        uploaded.add(file);
        setState(() => _uploadedCount = widget.selectedImages.length + i + 1);
      }

      setState(() => _statusLabel = 'Submitting case to backend…');

      final result = await GrivaApiService.instance.submitCase(
        assignedUid: _selectedReporter?.firebaseUid,
        notes      : _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        files      : uploaded,
      );

      if (!mounted) return;
      Navigator.pop(context, true);

      final msg = result.unassigned
          ? 'Case queued — no reporters available right now. Admin will assign manually.'
          : result.autoAssigned
              ? 'Auto-assigned to an available reporter. $totalFiles file${totalFiles > 1 ? 's' : ''} uploaded.'
              : 'Case sent to ${_selectedReporter!.displayName}. $totalFiles file${totalFiles > 1 ? 's' : ''} uploaded.';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content    : Text(msg),
        backgroundColor: result.unassigned ? Colors.orange : _purple,
        duration   : const Duration(seconds: 4),
      ));
    } catch (e) {
      setState(() => _submitError = e.toString());
    } finally {
      if (mounted) setState(() { _submitting = false; _statusLabel = ''; });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final totalFiles = widget.selectedImages.length + widget.selectedVideos.length;

    return Container(
      decoration: const BoxDecoration(
        color           : Colors.white,
        borderRadius    : BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────────────────────────
          Center(
            child: Container(
              margin     : const EdgeInsets.only(top: 10, bottom: 4),
              width      : 36, height: 4,
              decoration : BoxDecoration(
                color        : _border,
                borderRadius : BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color        : _purpleLight,
                  borderRadius : BorderRadius.circular(10),
                ),
                child: const Icon(Icons.send_to_mobile_rounded, color: _purple, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Send for Tele Report',
                  style: TextStyle(color: _textDark, fontSize: 17, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding    : const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration : BoxDecoration(color: _purpleLight, borderRadius: BorderRadius.circular(20)),
                child      : Text('$totalFiles file${totalFiles != 1 ? 's' : ''}',
                    style: const TextStyle(color: _purple, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF0EBF8), height: 1),

          // ── Scrollable body ──────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Image thumbnails
                  if (widget.selectedImages.isNotEmpty) ...[
                    _label('Selected Images'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 76,
                      child: ListView.separated(
                        scrollDirection : Axis.horizontal,
                        itemCount       : widget.selectedImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border      : Border.all(color: _border, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.memory(widget.selectedImages[i],
                                width: 76, height: 76, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Video thumbnails
                  if (widget.selectedVideos.isNotEmpty) ...[
                    _label('Selected Videos'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing : 8,
                      children: List.generate(widget.selectedVideos.length, (i) =>
                        Container(
                          width: 76, height: 76,
                          decoration: BoxDecoration(
                            color        : _purpleLight,
                            borderRadius : BorderRadius.circular(10),
                            border       : Border.all(color: _border, width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.videocam_rounded, color: _purple, size: 28),
                              const SizedBox(height: 2),
                              Text('Video ${i + 1}',
                                  style: const TextStyle(color: _purple, fontSize: 10, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Priority chips
                  _label('Priority'),
                  const SizedBox(height: 8),
                  Row(
                    children: ['ROUTINE', 'URGENT'].map((p) {
                      final sel        = _priority == p;
                      final activeColor= p == 'URGENT' ? _errorRed : _purple;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _priority = p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color        : sel ? activeColor : Colors.white,
                              borderRadius : BorderRadius.circular(20),
                              border       : Border.all(color: sel ? activeColor : _border, width: 1.5),
                            ),
                            child: Text(p,
                                style: TextStyle(
                                  color      : sel ? Colors.white : _textMid,
                                  fontWeight : FontWeight.w600,
                                  fontSize   : 13,
                                )),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Reporter dropdown (no label — auto-assign is first option)
                  _buildReporterPicker(),

                  const SizedBox(height: 16),

                  // Clinical notes
                  _label('Clinical Notes (optional)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller : _notesCtrl,
                    maxLines   : 3,
                    style      : const TextStyle(color: _textDark, fontSize: 14),
                    decoration : InputDecoration(
                      hintText   : 'Patient history, findings, reason for referral…',
                      hintStyle  : const TextStyle(color: Color(0xFFBDB4CC), fontSize: 13),
                      filled     : true,
                      fillColor  : const Color(0xFFF9F7FE),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border        : OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _border, width: 1.5)),
                      enabledBorder : OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _border, width: 1.5)),
                      focusedBorder : OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _purple, width: 1.5)),
                    ),
                  ),

                  // Progress bar
                  if (_submitting) ...[
                    const SizedBox(height: 14),
                    Row(children: [
                      const SizedBox(width: 14, height: 14,
                          child: CircularProgressIndicator(color: _purple, strokeWidth: 2)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_statusLabel,
                          style: const TextStyle(color: _textMid, fontSize: 13))),
                    ]),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value          : totalFiles > 0 ? _uploadedCount / totalFiles : null,
                        backgroundColor: _purpleLight,
                        color          : _purple,
                        minHeight      : 4,
                      ),
                    ),
                  ],

                  if (_submitError != null) ...[
                    const SizedBox(height: 10),
                    Text(_submitError!,
                        style: const TextStyle(color: _errorRed, fontSize: 13)),
                  ],

                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width : double.infinity,
                    height: 52,
                    child : ElevatedButton.icon(
                      icon : _submitting
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        _submitting ? 'Submitting…' : 'Submit Tele Report Case',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor        : _purple,
                        foregroundColor        : Colors.white,
                        disabledBackgroundColor: const Color(0xFFD1C4E9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reporter picker ───────────────────────────────────────────────────────

  Widget _buildReporterPicker() {
    if (_loadingReporters) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color        : const Color(0xFFF9F7FE),
          borderRadius : BorderRadius.circular(12),
          border       : Border.all(color: _border),
        ),
        child: const Center(
          child: SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(color: _purple, strokeWidth: 2)),
        ),
      );
    }

    if (_reporterError != null) {
      return Container(
        padding    : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration : BoxDecoration(
          color        : const Color(0xFFFFF1F1),
          borderRadius : BorderRadius.circular(12),
          border       : Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: Row(children: [
          const Icon(Icons.wifi_off_rounded, color: _errorRed, size: 16),
          const SizedBox(width: 8),
          const Expanded(child: Text('Could not load reporters. Is the server running?',
              style: TextStyle(color: _errorRed, fontSize: 12))),
          TextButton(
            onPressed : _fetchReporters,
            style     : TextButton.styleFrom(foregroundColor: _errorRed,
                padding: EdgeInsets.zero, minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
      );
    }

    // Build items: first entry is always "Auto-assign"
    final items = <DropdownMenuItem<GrivaReporter?>>[
      DropdownMenuItem<GrivaReporter?>(
        value: null,
        child: Row(children: [
          Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 10),
              decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle)),
          const Text('Auto-assign (recommended)',
              style: TextStyle(color: _textDark, fontWeight: FontWeight.w500)),
        ]),
      ),
      ..._reporters.map((r) => DropdownMenuItem<GrivaReporter?>(
        value: r,
        child: Row(children: [
          Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color : r.isAvailable ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF),
                shape : BoxShape.circle,
              )),
          Expanded(child: Text(r.displayName,
              style: const TextStyle(color: _textDark), overflow: TextOverflow.ellipsis)),
          if (r.hospital != null)
            Text('  ${r.hospital}',
                style: const TextStyle(color: _textMid, fontSize: 12)),
          if (!r.isAvailable)
            const Text('  Busy',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
        ]),
      )),
    ];

    return Container(
      decoration: BoxDecoration(
        color        : const Color(0xFFF9F7FE),
        borderRadius : BorderRadius.circular(12),
        border       : Border.all(color: _border, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<GrivaReporter?>(
          value       : _selectedReporter,
          isExpanded  : true,
          dropdownColor: Colors.white,
          padding     : const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          icon        : const Icon(Icons.keyboard_arrow_down_rounded, color: _purple),
          items       : items,
          onChanged   : (v) => setState(() => _selectedReporter = v),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: _textMid, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4));
}
