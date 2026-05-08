import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../services/user_service.dart';

class ReportHeaderFooterScreen extends StatefulWidget {
  final String userEmail;

  const ReportHeaderFooterScreen({super.key, required this.userEmail});

  @override
  State<ReportHeaderFooterScreen> createState() => _ReportHeaderFooterScreenState();
}

class _ReportHeaderFooterScreenState extends State<ReportHeaderFooterScreen> {
  static const _purple = Color(0xFF8B44F7);
  static const _lightPurple = Color(0xFFF5E6FF);

  final _userService = UserService();
  User? _user;
  bool _loading = true;
  bool _saving = false;

  bool _useHeaderFooter = false;
  String? _headerImagePath;
  String? _footerImagePath;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getUserByEmail(widget.userEmail);
    if (user != null) {
      setState(() {
        _user = user;
        _useHeaderFooter = user.useReportHeaderFooter;
        _headerImagePath = user.reportHeaderImage;
        _footerImagePath = user.reportFooterImage;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<String> _getSettingsImageDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'report_settings'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  Future<void> _pickImage(bool isHeader) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final dir = await _getSettingsImageDir();
    final userId = _user?.id ?? 0;
    final label = isHeader ? 'header' : 'footer';
    final dest = File(p.join(dir, 'user_${userId}_$label.jpg'));
    await dest.writeAsBytes(bytes);

    setState(() {
      if (isHeader) {
        _headerImagePath = dest.path;
      } else {
        _footerImagePath = dest.path;
      }
    });
  }

  Future<void> _removeImage(bool isHeader) async {
    final path = isHeader ? _headerImagePath : _footerImagePath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    setState(() {
      if (isHeader) {
        _headerImagePath = null;
      } else {
        _footerImagePath = null;
      }
    });
  }

  Future<void> _save() async {
    if (_user == null) return;
    setState(() => _saving = true);
    try {
      final updated = _user!.copyWith(
        useReportHeaderFooter: _useHeaderFooter,
        reportHeaderImage: _headerImagePath,
        reportFooterImage: _footerImagePath,
      );
      await _userService.updateUser(_user!.id!, updated);
      setState(() {
        _user = updated;
        _saving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report header & footer saved')),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
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
          'Report Header & Footer',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _lightPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: _purple, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Upload your clinic letterhead or logo as a header and footer image. They will be applied to every report you generate.',
                          style: TextStyle(fontSize: 12.5, color: Colors.purple[700], height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Enable toggle
                _buildCard(
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    title: const Text('Enable Header & Footer', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: Text(
                      'Apply custom branding to all generated reports',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    value: _useHeaderFooter,
                    activeColor: _purple,
                    onChanged: (val) => setState(() => _useHeaderFooter = val),
                  ),
                ),
                const SizedBox(height: 16),

                // Image cards
                AnimatedOpacity(
                  opacity: _useHeaderFooter ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_useHeaderFooter,
                    child: Column(
                      children: [
                        _buildImageCard(
                          label: 'Header Image',
                          description: 'Appears at the top of every page in the report',
                          hint: 'Best size: 2480 × 200 px (A4 width)',
                          imagePath: _headerImagePath,
                          isHeader: true,
                        ),
                        const SizedBox(height: 14),
                        _buildImageCard(
                          label: 'Footer Image',
                          description: 'Appears at the bottom of every page in the report',
                          hint: 'Best size: 2480 × 150 px (A4 width)',
                          imagePath: _footerImagePath,
                          isHeader: false,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: child,
    );
  }

  Widget _buildImageCard({
    required String label,
    required String description,
    required String hint,
    required String? imagePath,
    required bool isHeader,
  }) {
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: _lightPurple, borderRadius: BorderRadius.circular(7)),
                  child: Icon(
                    isHeader ? Icons.vertical_align_top : Icons.vertical_align_bottom,
                    color: _purple,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(description, style: TextStyle(fontSize: 11.5, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (hasImage) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(imagePath), width: double.infinity, height: 120, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _removeImage(isHeader),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(isHeader),
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Replace Image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _purple,
                    side: const BorderSide(color: _purple),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: () => _pickImage(isHeader),
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade400, size: 30),
                      const SizedBox(height: 6),
                      Text(
                        'Tap to upload ${isHeader ? "header" : "footer"}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
