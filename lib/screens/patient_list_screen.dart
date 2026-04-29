import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:typed_data';

import '../services/patient_service.dart';
import '../services/image_service.dart';
import '../services/video_service.dart';
import '../new_patient_form.dart';
import '../widgets/centralized_footer.dart';
import '../custom_app_bar.dart';
import 'patient_details_screen.dart';
import '../exam_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final PatientService _patientService = PatientService();
  List<Patient> _patients = [];
  bool _isLoading = true;
  String? _error;
  Patient? _selectedPatient;
  Future<List<String>>? _previewImagePathsFuture;
  Future<List<String>>? _previewVideoPathsFuture;
  final Map<int, VideoPlayerController> _previewVideoControllers = {};

  final TextEditingController _searchController = TextEditingController();
  String _timeFilter = 'All time';
  String _ageFilter = 'All ages';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _disposePreviewVideoControllers();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final patients = await _patientService.getAllPatients();
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _disposePreviewVideoControllers() {
    for (final controller in _previewVideoControllers.values) {
      controller.dispose();
    }
    _previewVideoControllers.clear();
  }

  Widget _buildStaticVideoTile({bool isLoading = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.deepPurple.withOpacity(0.3),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: isLoading
                ? const CircularProgressIndicator(strokeWidth: 2)
                : const Icon(
                    Icons.videocam,
                    color: Colors.deepPurple,
                    size: 36,
                  ),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'VID',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializePreviewVideoController(
    int index,
    String videoPath,
  ) async {
    if (_previewVideoControllers.containsKey(index)) return;

    try {
      if (Platform.isLinux) {
        // No video playback thumbnails on Linux; rely on static icon.
        return;
      }

      final controller = VideoPlayerController.file(File(videoPath));
      await controller.initialize();
      controller.setLooping(true);
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _previewVideoControllers[index] = controller;
      });
    } catch (e) {
      // Fallback to static icon if anything fails.
      debugPrint('Error initializing preview video controller: $e');
    }
  }

  Future<void> _navigateToAddPatient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewPatientForm(),
      ),
    );
    if (result == true) {
      _loadPatients();
    }
  }

  // Note: edit/delete actions are handled in the details screen and/or other flows.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        // title: const Text('Patient Database', style: TextStyle(color: Colors.black)),
        
      ),
      body: _buildBody(),
      bottomNavigationBar: const CentralizedFooter(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPatients,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_patients.isEmpty) {
      return const Center(
        child: Text('No patients found'),
      );
    }

    final filtered = _applyFilters(_patients);

    final leftPane = Expanded(
      flex: 6,
      child: Column(
        children: [
          _buildToolbar(),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildHeading(filtered.length),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildDataGrid(filtered),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Compose the main content area (list only or split view)
    final Widget mainArea = (_selectedPatient == null)
        ? Row(children: [leftPane])
        : Row(
            children: [
              leftPane,
              Container(width: 1, color: Colors.grey.shade300),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildPreview(),
                ),
              ),
            ],
          );

    // Return with top header under custom app bar
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopHeader(),
        const SizedBox(height: 8),
        Expanded(child: mainArea),
      ],
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    hintText: 'Search with patient name, ID, phone number or condition…',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF8B44F7)),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _exportCsv,
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export CSV'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  foregroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Filter by:', style: TextStyle(color: Color(0xFF475569))),
              const SizedBox(width: 16),
              const Text('Time Period:', style: TextStyle(color: Color(0xFF475569))),
              const SizedBox(width: 8),
              _buildDropdown<String>(
                value: _timeFilter,
                items: const ['All time', 'Last 7 days', 'Last 30 days', 'This year'],
                onChanged: (v) => setState(() => _timeFilter = v ?? 'All time'),
                label: '',
              ),
              const SizedBox(width: 24),
              const Text('Age Group:', style: TextStyle(color: Color(0xFF475569))),
              const SizedBox(width: 8),
              _buildDropdown<String>(
                value: _ageFilter,
                items: const ['All ages', '18-30', '31-45', '46+'],
                onChanged: (v) => setState(() => _ageFilter = v ?? 'All ages'),
                label: '',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String label,
  }) {
    return SizedBox(
      width: 180,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label.isEmpty ? null : label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF8B44F7)),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            items: items
                .map((e) => DropdownMenuItem<T>(value: e, child: Text('$e')))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  List<Patient> _applyFilters(List<Patient> input) {
    Iterable<Patient> result = input;

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((p) {
        final name = p.patientName.toLowerCase();
        final id = (p.patientId ?? '').toString().toLowerCase();
        final mobile = p.mobileNo.toString().toLowerCase();
        return name.contains(query) || id.contains(query) || mobile.contains(query);
      });
    }

    final now = DateTime.now();
    if (_timeFilter != 'All time') {
      result = result.where((p) {
        final d = p.dateOfVisit;
        if (d == null) return false;
        switch (_timeFilter) {
          case 'Last 7 days':
            return d.isAfter(now.subtract(const Duration(days: 7)));
          case 'Last 30 days':
            return d.isAfter(now.subtract(const Duration(days: 30)));
          case 'This year':
            return d.year == now.year;
          default:
            return true;
        }
      });
    }

    // Age filter is a placeholder until age is available in model
    // Kept for UI completeness; it does not filter the list yet.

    return result.toList();
  }

  Widget _buildHeading(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Image.asset('assets/images/icons/users.png'),
            ),
            const SizedBox(width: 8),
            const Text(
              'Patient Records',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                '$count patients',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _navigateToAddPatient,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New Patient'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B44F7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Center(
              child: const Text(
                'Patient Database',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildDataGrid(List<Patient> rows) {
    final headerStyle = TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w600,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Container(
              height: 44,
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _gridCell('Patient Name', flex: 3, style: headerStyle),
                  _gridCell('Patient ID', flex: 2, style: headerStyle),
                  _gridCell('Issue Name', flex: 3, style: headerStyle),
                  _gridCell('Latest Visit Date', flex: 2, style: headerStyle, align: TextAlign.right),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
      itemBuilder: (context, index) {
                  final p = rows[index];
                  final isSelected = _selectedPatient?.id == p.id;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _disposePreviewVideoControllers();
                        _selectedPatient = p;
                        if (p.id == null) {
                          _previewImagePathsFuture = Future.value(<String>[]);
                          _previewVideoPathsFuture = Future.value(<String>[]);
                        } else {
                          _previewImagePathsFuture =
                              ImageService.getPatientImages(p.id!);
                          _previewVideoPathsFuture =
                              VideoService.getPatientVideos(p.id!);
                        }
                      });
                    },
                    child: Container(
                      color: isSelected ? const Color(0xFFF1F5FF) : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          _gridCell(p.patientName, flex: 3),
                          _gridCell(p.patientId ?? '-', flex: 2),
                          _gridCell(p.referralReason ?? p.finalImpression ?? '—', flex: 3),
                          _gridCell(
                            p.dateOfVisit != null ? p.dateOfVisit!.toLocal().toString().split(' ')[0] : '—',
                            flex: 2,
                            align: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridCell(String text, {int flex = 1, TextAlign align = TextAlign.left, TextStyle? style}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: style,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
  Widget _buildPreview() {
    if (_selectedPatient == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.image, size: 72, color: Colors.deepPurple),
            SizedBox(height: 12),
            Text('Select a patient to preview their latest report images'),
          ],
        ),
      );
    }

    final p = _selectedPatient!;
    _previewImagePathsFuture ??= (p.id == null)
        ? Future.value(<String>[])
        : ImageService.getPatientImages(p.id!);
    _previewVideoPathsFuture ??= (p.id == null)
        ? Future.value(<String>[])
        : VideoService.getPatientVideos(p.id!);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 28),
                const SizedBox(width: 8),
                Text(p.patientName, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (p.patientId != null) Text('ID: ${p.patientId}'),
                if (p.mobileNo.toString().trim().isNotEmpty) Text('Mobile: ${p.mobileNo}'),
                if (p.dateOfVisit != null) Text('Visit: ${p.dateOfVisit!.toLocal().toString().split(' ')[0]}'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FutureBuilder<List<List<String>>>(
                  future: Future.wait<List<String>>([
                    _previewImagePathsFuture ?? Future.value(<String>[]),
                    _previewVideoPathsFuture ?? Future.value(<String>[]),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final images = (snapshot.data != null && snapshot.data!.isNotEmpty)
                        ? snapshot.data![0]
                        : const <String>[];
                    final videos = (snapshot.data != null && snapshot.data!.length > 1)
                        ? snapshot.data![1]
                        : const <String>[];

                    // Combine most-recent-first, capped for performance.
                    final recentImages = images.reversed.take(4).toList();
                    final recentVideos = videos.reversed.take(3).toList();
                    final total = recentImages.length + recentVideos.length;

                    if (total == 0) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.perm_media_outlined,
                              size: 64,
                              color: Colors.deepPurple,
                            ),
                            SizedBox(height: 8),
                            Text('No examination media yet'),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: total,
                        itemBuilder: (context, index) {
                          final isImage = index < recentImages.length;
                          if (isImage) {
                            final imagePath = recentImages[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: FutureBuilder<Uint8List?>(
                                future: ImageService.loadImage(imagePath),
                                builder: (context, imgSnap) {
                                  if (imgSnap.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container(
                                      color: Colors.white,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    );
                                  }
                                  if (imgSnap.hasError || imgSnap.data == null) {
                                    return Container(
                                      color: Colors.white,
                                      child: const Center(
                                        child: Icon(Icons.broken_image,
                                            color: Colors.deepPurple),
                                      ),
                                    );
                                  }
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.memory(
                                        imgSnap.data!,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'IMG',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          }

                          // Video tile with motion thumbnail when supported.
                          final videoIndex = index - recentImages.length;
                          final videoPath = recentVideos[videoIndex];

                          // For Linux or if something goes wrong, show static fallback.
                          if (Platform.isLinux) {
                            return _buildStaticVideoTile();
                          }

                          _initializePreviewVideoController(
                            videoIndex,
                            videoPath,
                          );

                          final controller =
                              _previewVideoControllers[videoIndex];
                          if (controller == null ||
                              !controller.value.isInitialized) {
                            return _buildStaticVideoTile(isLoading: true);
                          }

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: controller.value.size.width,
                                    height: controller.value.size.height,
                                    child: VideoPlayer(controller),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'VID',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientDetailsScreen(patient: p),
                      ),
                    );
                    if (changed == true) {
                      setState(() { _selectedPatient = null; });
                      _loadPatients();
                    }
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B44F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PiCameraScreen()),
                    );
                  },
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Start Exam'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    side: const BorderSide(color: Color(0xFF8B44F7)),
                    foregroundColor: const Color(0xFF8B44F7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsv() async {
    try {
      final buffer = StringBuffer('Name,PatientID,Mobile,VisitDate\n');
      for (final p in _applyFilters(_patients)) {
        final date = p.dateOfVisit?.toIso8601String() ?? '';
        final id = p.patientId?.toString() ?? '';
        final mobile = p.mobileNo.toString();
        buffer.writeln('"${p.patientName}","$id","$mobile","$date"');
      }

      final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}patients.csv');
      await file.writeAsString(buffer.toString());
      await OpenFile.open(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV exported to ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export CSV: $e')),
        );
      }
    }
  }
} 