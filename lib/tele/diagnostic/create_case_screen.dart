import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/griva_api_service.dart';

class CreateCaseScreen extends StatefulWidget {
  const CreateCaseScreen({super.key});

  @override
  State<CreateCaseScreen> createState() => _CreateCaseScreenState();
}

class _CreateCaseScreenState extends State<CreateCaseScreen> {
  final _notesCtrl  = TextEditingController();
  final _picker     = ImagePicker();
  final List<File>  _files     = [];
  bool   _submitting  = false;
  int    _uploaded    = 0;
  String? _error;

  // ── Image picking ─────────────────────────────────────────────────────────

  Future<void> _pickImages({bool camera = false}) async {
    if (camera) {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked != null) setState(() => _files.add(File(picked.path)));
    } else {
      final picked = await _picker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() => _files.addAll(picked.map((x) => File(x.path))));
      }
    }
  }

  void _removeFile(int index) => setState(() => _files.removeAt(index));

  // ── Submission ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_files.isEmpty) {
      setState(() => _error = 'Please attach at least one image.');
      return;
    }
    setState(() { _submitting = true; _uploaded = 0; _error = null; });
    try {
      final ts       = DateTime.now().millisecondsSinceEpoch;
      final uploaded = <GrivaFile>[];

      for (var i = 0; i < _files.length; i++) {
        final file     = _files[i];
        final filename = '${ts}_$i${_ext(file.path)}';
        final bytes    = await file.readAsBytes();
        final grivaFile = await GrivaApiService.instance.uploadFile(bytes, filename, 'image/jpeg');
        uploaded.add(grivaFile);
        if (mounted) setState(() => _uploaded = i + 1);
      }

      await GrivaApiService.instance.submitCase(
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        files: uploaded,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _ext(String path) {
    final dot = path.lastIndexOf('.');
    return dot != -1 ? path.substring(dot) : '.jpg';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: const Text('New Tele-Report Case'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Clinical notes ──────────────────────────────────────────────
          _label('Clinical Notes (optional)'),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDec('Describe findings, history, reason for referral…'),
          ),

          const SizedBox(height: 24),

          // ── Image section ───────────────────────────────────────────────
          Row(children: [
            _label('Images'),
            const Spacer(),
            if (_files.isNotEmpty)
              Text('${_files.length} selected',
                  style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12)),
          ]),
          const SizedBox(height: 10),

          // Thumbnail grid + add tile
          _buildImageGrid(),

          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Camera'),
                onPressed: _submitting ? null : () => _pickImages(camera: true),
                style: _outlineStyle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Gallery'),
                onPressed: _submitting ? null : () => _pickImages(),
                style: _outlineStyle,
              ),
            ),
          ]),

          // ── Progress / error ────────────────────────────────────────────
          if (_submitting) ...[
            const SizedBox(height: 16),
            Row(children: [
              const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6))),
              const SizedBox(width: 10),
              Text(
                'Uploading image $_uploaded of ${_files.length}…',
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13),
              ),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _files.isNotEmpty ? _uploaded / _files.length : null,
                backgroundColor: const Color(0xFF1E293B),
                color: const Color(0xFF3B82F6),
                minHeight: 4,
              ),
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
          ],

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _submitting
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_outlined, size: 18),
              label: Text(
                _submitting ? 'Submitting…' : 'Submit Case',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildImageGrid() {
    if (_files.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blueGrey.shade800),
        ),
        child: Center(
          child: Text('No images selected',
              style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 13)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _files.length,
      itemBuilder: (_, i) => Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(_files[i], fit: BoxFit.cover),
          ),
          Positioned(
            top: 4, right: 4,
            child: GestureDetector(
              onTap: _submitting ? null : () => _removeFile(i),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(160),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(3),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5));

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.blueGrey.shade500),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blueGrey.shade700)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blueGrey.shade700)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3B82F6))),
      );

  ButtonStyle get _outlineStyle => OutlinedButton.styleFrom(
        foregroundColor: Colors.blueGrey.shade300,
        side: BorderSide(color: Colors.blueGrey.shade700),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
}
