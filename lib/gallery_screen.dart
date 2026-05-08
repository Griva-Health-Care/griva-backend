import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:video_player/video_player.dart';
// video_player_win is automatically used on Windows when both packages are in pubspec.yaml
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'services/pdf_service.dart';
import 'services/patient_service.dart';
import 'services/image_service.dart';
import 'services/video_service.dart';
import 'image_edit_screen.dart';
import 'screens/patient_selection_screen.dart';
import 'screens/image_comparison_screen.dart';
import 'diagnosis_page.dart';
import 'services/medical_report_service.dart';
import 'custom_app_bar.dart';
import 'custom_drawer.dart';
import 'config/app_config.dart';
import 'tele/diagnostic/gallery_tele_report_sheet.dart';

class GalleryScreen extends StatefulWidget {
  final List<Uint8List> images;
  final List<Uint8List>? videos;
  final Function(int)? onDelete;
  final Function(int)? onDeleteVideo;
  final List<Map<String, dynamic>>? unlinkedImages; // Cached images with metadata
  final List<Map<String, dynamic>>? unlinkedVideos; // Cached videos with metadata
  final bool pickerMode; // When true, return selected images to caller
  final String? pickerActionLabel;
  final Patient? initialPatient; // Pre-linked patient — skips the "link to patient" dialog

  const GalleryScreen({
    super.key,
    required this.images,
    this.videos,
    this.onDelete,
    this.onDeleteVideo,
    this.unlinkedImages,
    this.unlinkedVideos,
    this.pickerMode = false,
    this.pickerActionLabel,
    this.initialPatient,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late List<Uint8List> _images;
  late List<Uint8List> _videos;
  Set<int> _selectedIndices = {};
  Set<int> _selectedVideoIndices = {};
  bool _isSelectionMode = false;
  final PatientService _patientService = PatientService();
  List<Map<String, dynamic>> _unlinkedImages = [];
  List<Map<String, dynamic>> _unlinkedVideos = [];
  bool _isAiProcessing = false;
  Map<int, VideoPlayerController> _videoControllers = {};
  Map<int, bool> _videoPlayingStates = {};

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.images);
    _videos = List.from(widget.videos ?? []);
    _unlinkedImages = List.from(widget.unlinkedImages ?? []);
    _unlinkedVideos = List.from(widget.unlinkedVideos ?? []);
    print('Gallery initialized with ${_images.length} images and ${_videos.length} videos');
    if (widget.initialPatient != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoLinkToPatient(widget.initialPatient!);
      });
    }
  }

  Future<void> _autoLinkToPatient(Patient patient) async {
    if (_unlinkedImages.isNotEmpty) {
      await _saveUnlinkedImagesToPatient(patient);
    }
    if (_unlinkedVideos.isNotEmpty) {
      await _saveUnlinkedVideosToPatient(patient);
    }
  }

  @override
  void dispose() {
    // Dispose all video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(GalleryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images != widget.images) {
      setState(() {
        _images = List.from(widget.images);
      });
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
      _selectedIndices.remove(index);
      // Adjust indices for selected items after deletion
      _selectedIndices = _selectedIndices.map((i) => i > index ? i - 1 : i).toSet();
    });
    if (widget.onDelete != null) {
      widget.onDelete!(index);
    }
  }

  void _deleteVideo(int index) {
    // Dispose video controller if exists
    if (_videoControllers.containsKey(index)) {
      _videoControllers[index]!.dispose();
      _videoControllers.remove(index);
      _videoPlayingStates.remove(index);
    }
    
    setState(() {
      _videos.removeAt(index);
      _selectedVideoIndices.remove(index);
      // Adjust indices for selected items after deletion
      _selectedVideoIndices = _selectedVideoIndices.map((i) => i > index ? i - 1 : i).toSet();
      
      // Rebuild video controllers map
      final newControllers = <int, VideoPlayerController>{};
      final newPlayingStates = <int, bool>{};
      for (var i = 0; i < _videos.length; i++) {
        if (i < index && _videoControllers.containsKey(i)) {
          newControllers[i] = _videoControllers[i]!;
          newPlayingStates[i] = _videoPlayingStates[i] ?? false;
        } else if (i >= index && _videoControllers.containsKey(i + 1)) {
          newControllers[i] = _videoControllers[i + 1]!;
          newPlayingStates[i] = _videoPlayingStates[i + 1] ?? false;
        }
      }
      _videoControllers = newControllers;
      _videoPlayingStates = newPlayingStates;
    });
    
    if (widget.onDeleteVideo != null) {
      widget.onDeleteVideo!(index);
    }
  }

  Future<void> _initializeVideoPlayer(int index) async {
    if (_videoControllers.containsKey(index)) {
      return; // Already initialized
    }

    try {
      // Check if platform supports video player
      // video_player_win provides Windows support
      if (Platform.isLinux) {
        print('Video player not fully supported on Linux. Showing fallback UI.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video playback not available on Linux'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Save video bytes to temporary file
      final tempDir = await getTemporaryDirectory();
      final videoFile = File(path.join(tempDir.path, 'video_$index.mp4'));
      await videoFile.writeAsBytes(_videos[index]);

      // Create video player controller
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      
      controller.addListener(() {
        if (mounted) {
          setState(() {
            _videoPlayingStates[index] = controller.value.isPlaying;
          });
        }
      });

      if (mounted) {
        setState(() {
          _videoControllers[index] = controller;
          _videoPlayingStates[index] = false;
        });
      }
    } catch (e) {
      print('Error initializing video player: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video playback not available: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _toggleVideoPlayback(int index) {
    if (!_videoControllers.containsKey(index)) {
      _initializeVideoPlayer(index);
      return;
    }

    final controller = _videoControllers[index]!;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIndices.clear();
      }
    });
  }

  void _toggleImageSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _editSelectedImages() {
    if (_selectedIndices.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select exactly one image to edit')),
      );
      return;
    }

    final index = _selectedIndices.first;
    final bytes = _images[index];
    Navigator.push<Uint8List?>(
      context,
      MaterialPageRoute(
        builder: (context) => ImageEditScreen(imageBytes: bytes),
      ),
    ).then((editedBytes) {
      if (editedBytes == null) return;
      setState(() {
        _images.add(editedBytes);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edited copy added to gallery')),
      );
    });
  }

  void _compareSelectedImages() {
    if (_selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image to compare')),
      );
      return;
    }
    
    final selectedImages = _selectedIndices.map((index) => _images[index]).toList();
    final currentImage = selectedImages.first; // Use first selected as current
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageComparisonScreen(
          images: selectedImages,
          currentImage: currentImage,
        ),
      ),
    );
  }

  void _proceedToDiagnosis() {
    if (_selectedIndices.isEmpty) return;

    final selectedImages = _selectedIndices.map((index) => _images[index]).toList();
    if (widget.pickerMode) {
      Navigator.pop(context, selectedImages);
      return;
    }

    if (widget.initialPatient != null) {
      // Patient already known — go straight to diagnosis without re-asking
      Navigator.push<String?>(
        context,
        MaterialPageRoute(
          builder: (context) => DiagnosisPage(
            patient: widget.initialPatient!,
            images: selectedImages,
          ),
        ),
      ).then((filePath) {
        if (filePath != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Report generated successfully!'),
              action: SnackBarAction(
                label: 'Open',
                onPressed: () => MedicalReportService.openReport(filePath),
              ),
            ),
          );
        }
        setState(() {
          _isSelectionMode = false;
          _selectedIndices.clear();
        });
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientSelectionScreen(images: selectedImages),
        ),
      ).then((_) {
        setState(() {
          _isSelectionMode = false;
          _selectedIndices.clear();
        });
      });
    }
  }

  // Open tele report bottom sheet with given images/videos
  Future<void> _openTeleReportSheet({
    required List<Uint8List> images,
    required List<Uint8List> videos,
  }) async {
    if (images.isEmpty && videos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No files selected for tele report')),
      );
      return;
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GalleryTeleReportSheet(
          selectedImages: images,
          selectedVideos: videos,
        ),
      ),
    );
  }

  // Link unlinked images to a patient
  Future<void> _linkImagesToPatient() async {
    if (_unlinkedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No unlinked images to save')),
      );
      return;
    }

    try {
      final patients = await _patientService.getAllPatients();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Link ${_unlinkedImages.length} Images to Patient'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return ListTile(
                      title: Text(patient.patientName),
                      subtitle: Text('ID: ${patient.patientId ?? 'N/A'}'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await _saveUnlinkedImagesToPatient(patient);
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error loading patients: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading patients: $e")),
        );
      }
    }
  }

  // Save unlinked images to selected patient
  Future<void> _saveUnlinkedImagesToPatient(Patient patient) async {
    try {
      for (final imageData in _unlinkedImages) {
        final imageBytes = imageData['bytes'] as Uint8List;
        final metadata = imageData['metadata'] as Map<String, dynamic>;

        // Save image to device storage
        final imagePath = await ImageService.saveExaminationImage(
          imageBytes, 
          patient.id!, 
          metadata
        );

        // Add image path to patient database
        await _patientService.addExaminationImage(
          patient.id!, 
          imagePath, 
          metadata
        );
      }

      final savedCount = _unlinkedImages.length;
      
      // Clear unlinked images after successful save
      setState(() {
        _unlinkedImages.clear();
      });
      
      print('All unlinked images saved successfully for patient: ${patient.patientName}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$savedCount images linked to ${patient.patientName}"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error saving unlinked images to patient: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error linking images: $e")),
        );
      }
    }
  }

  // Link unlinked videos to a patient (filesystem only)
  Future<void> _linkVideosToPatient() async {
    if (_unlinkedVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No unlinked videos to save')),
      );
      return;
    }

    try {
      final patients = await _patientService.getAllPatients();

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:
                  Text('Link ${_unlinkedVideos.length} Videos to Patient'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return ListTile(
                      title: Text(patient.patientName),
                      subtitle:
                          Text('ID: ${patient.patientId ?? 'N/A'}'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await _saveUnlinkedVideosToPatient(patient);
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error loading patients for videos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading patients: $e")),
        );
      }
    }
  }

  Future<void> _saveUnlinkedVideosToPatient(Patient patient) async {
    try {
      for (final videoData in _unlinkedVideos) {
        final videoBytes = videoData['bytes'] as Uint8List;
        // metadata is currently not persisted, but kept for future use
        final metadata =
            (videoData['metadata'] as Map<String, dynamic>?);

        await VideoService.saveExaminationVideo(
          videoBytes,
          patient.id!,
          metadata: metadata,
        );
      }

      final savedCount = _unlinkedVideos.length;

      setState(() {
        _unlinkedVideos.clear();
      });

      print(
        'All unlinked videos saved successfully for patient: ${patient.patientName}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$savedCount videos linked to ${patient.patientName}",
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error saving unlinked videos to patient: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error linking videos: $e")),
        );
      }
    }
  }

  Future<void> _runAiInference() async {
    if (_selectedIndices.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select exactly one image for AI processing')),
      );
      return;
    }

    if (_isAiProcessing) return;
    
    setState(() => _isAiProcessing = true);
    
    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              const SizedBox(height: 16),
              const Text(
                'Processing with AI...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This may take a few moments',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    try {
      final index = _selectedIndices.first;
      final imageBytes = _images[index];
      
      // Step 1: Send image to AI server
      final uri = Uri.parse(AppConfig.aiSendUrl);
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'image.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      
      final streamed = await request.send();
      if (streamed.statusCode != 200) {
        throw Exception('Failed to send image to AI server: HTTP ${streamed.statusCode}');
      }
      
      final response = await streamed.stream.bytesToString();
      debugPrint('AI send response: $response');
      
      // Step 2: Poll result.jpg directly until it's ready
      final resultBytes = await _pollResultImage();
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }
      
      if (mounted && resultBytes != null) {
        setState(() => _isAiProcessing = false);
        _showAiResultModal(resultBytes, index);
      } else if (mounted) {
        setState(() => _isAiProcessing = false);
      }
      
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        setState(() => _isAiProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI inference error: $e')),
        );
      }
    }
  }

  Future<Uint8List?> _pollResultImage() async {
    const maxAttempts = 30; // 30 seconds max wait time
    const pollInterval = Duration(seconds: 1);
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        // Directly try to fetch the result image
        final resultResponse = await http.get(Uri.parse(AppConfig.aiResultUrl));
        
        if (resultResponse.statusCode == 200) {
          // Result is ready!
          return resultResponse.bodyBytes;
        } else {
          // Result not ready yet (might be 404 or other status)
          debugPrint('Result not ready yet (HTTP ${resultResponse.statusCode}), attempt ${attempt + 1}/$maxAttempts');
        }
      } catch (e) {
        // Result not ready yet (connection error, 404, etc.)
        debugPrint('Result not ready yet (error: $e), attempt ${attempt + 1}/$maxAttempts');
      }
      
      // Wait before next poll
      await Future.delayed(pollInterval);
    }
    
    // Timeout reached
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI inference timed out')),
      );
    }
    return null;
  }

  void _showAiResultModal(Uint8List resultBytes, int originalIndex) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.orange, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'AI Processing Result',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Image preview
              Flexible(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      resultBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Save'),
                      onPressed: () {
                        setState(() {
                          _images[originalIndex] = resultBytes;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Image updated with AI result')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Save as Copy'),
                      onPressed: () {
                        setState(() {
                          _images.add(resultBytes);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('AI result saved as new image')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPdfOptions() async {
    if (_selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.white),
              title: const Text(
                'Simple PDF',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Images only',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                _createSimplePdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.white),
              title: const Text(
                'Detailed Report',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'With patient information',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                _createDetailedPdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services, color: Colors.white),
              title: const Text(
                'Comprehensive Medical Report',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'SQL data + images + clinical findings',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                _createComprehensiveReport();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSimplePdf() async {
    try {
      final selectedImages = _selectedIndices.map((index) => _images[index]).toList();
      final filePath = await PdfService.createImagePdf(selectedImages, 'gallery_images');
      
      if (mounted && filePath != null) {
        final pdfDir = await PdfService.getPdfDirectoryPath();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved successfully\nLocation: $pdfDir'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => PdfService.openPdf(filePath),
            ),
          ),
        );
        
        // Exit selection mode
        setState(() {
          _isSelectionMode = false;
          _selectedIndices.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating PDF: $e')),
        );
      }
    }
  }

  Future<void> _createDetailedPdf() async {
    // Show dialog to get patient information
    final patientName = await _showPatientInfoDialog('Patient Name');
    if (patientName == null) return;
    
    final patientId = await _showPatientInfoDialog('Patient ID');
    if (patientId == null) return;
    
    final notes = await _showPatientInfoDialog('Notes (optional)', isRequired: false);

    try {
      final selectedImages = _selectedIndices.map((index) => _images[index]).toList();
      final filePath = await PdfService.createDetailedPdf(
        images: selectedImages,
        patientName: patientName,
        patientId: patientId,
        dateOfVisit: DateTime.now().toString().split(' ')[0],
        notes: notes,
      );
      
      if (mounted && filePath != null) {
        final pdfDir = await PdfService.getPdfDirectoryPath();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Detailed PDF saved successfully\nLocation: $pdfDir'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => PdfService.openPdf(filePath),
            ),
          ),
        );
        
        // Exit selection mode
        setState(() {
          _isSelectionMode = false;
          _selectedIndices.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating detailed PDF: $e')),
        );
      }
    }
  }

  void _createComprehensiveReport() {
    final selectedImages = _selectedIndices.map((index) => _images[index]).toList();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientSelectionScreen(
          images: selectedImages,
        ),
      ),
    ).then((_) {
      // Exit selection mode when returning from patient selection
      setState(() {
        _isSelectionMode = false;
        _selectedIndices.clear();
      });
    });
  }

  Future<String?> _showPatientInfoDialog(String title, {bool isRequired = true}) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: isRequired ? 'Required' : 'Optional',
            hintStyle: const TextStyle(color: Colors.white70),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (isRequired && value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This field is required')),
                );
                return;
              }
              Navigator.pop(context, value.isEmpty ? null : value);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail(int index) {
    if (_videoControllers.containsKey(index) && 
        _videoControllers[index]!.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(
            aspectRatio: _videoControllers[index]!.value.aspectRatio,
            child: VideoPlayer(_videoControllers[index]!),
          ),
          Center(
            child: IconButton(
              icon: Icon(
                _videoPlayingStates[index] == true 
                    ? Icons.pause_circle_filled 
                    : Icons.play_circle_filled,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () => _toggleVideoPlayback(index),
            ),
          ),
        ],
      );
    } else {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.black,
            child: const Icon(
              Icons.videocam,
              color: Colors.white54,
              size: 30,
            ),
          ),
          const Center(
            child: Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      );
    }
  }

  String _getPlatformInfo() {
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        onLogout: () {
          // TODO: Implement logout logic
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout clicked')),
          );
        },
      ),
      appBar: CustomAppBar(
        userEmail: null, // Pass user email if available
        title: _isSelectionMode 
          ? Text(
              'Select Images (${_selectedIndices.length}/${_images.length})',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            )
          : null, // Use default title when not in selection mode
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button - always visible
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF6B46C1)),
                  tooltip: 'Back',
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                ),
              ],
            ),
          ),
          
          // Main content
          if (_images.isEmpty && _videos.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No images or videos captured yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selection mode indicator
                  if (_isSelectionMode)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: const Color(0xFF6B46C1).withOpacity(0.1),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: const Color(0xFF6B46C1),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Selection Mode - Tap images to select/deselect',
                            style: const TextStyle(
                              color: Color(0xFF6B46C1),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _toggleSelectionMode,
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF6B46C1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Section title and selection count
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Review and edit captured ${_images.isNotEmpty && _videos.isNotEmpty ? "Media" : _images.isNotEmpty ? "Images" : "Videos"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_selectedIndices.length + _selectedVideoIndices.length}/${_images.length + _videos.length} Selected for Report',
                              style: const TextStyle(
                                color: Color(0xFF6B46C1),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (_unlinkedImages.isNotEmpty ||
                            _unlinkedVideos.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                ),
                                child: Text(
                                  '${_unlinkedImages.length} unlinked images',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.link, size: 16),
                                label: const Text('Link to Patient'),
                                onPressed: _linkImagesToPatient,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: const Size(0, 28),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.send_to_mobile_rounded, size: 16),
                                label: const Text('Tele Report'),
                                onPressed: () => _openTeleReportSheet(
                                  images: _isSelectionMode && _selectedIndices.isNotEmpty
                                      ? _selectedIndices.map((i) => _images[i]).toList()
                                      : _unlinkedImages
                                          .map((m) => m['bytes'] as Uint8List)
                                          .toList(),
                                  videos: _isSelectionMode && _selectedVideoIndices.isNotEmpty
                                      ? _selectedVideoIndices.map((i) => _videos[i]).toList()
                                      : [],
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: const Size(0, 28),
                                ),
                              ),
                              if (_unlinkedVideos.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          Colors.blueAccent.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    '${_unlinkedVideos.length} unlinked videos',
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.movie, size: 16),
                                  label: const Text('Link Videos'),
                                  onPressed: _linkVideosToPatient,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    minimumSize: const Size(0, 28),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Action buttons when images are selected
                  if (_selectedIndices.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                            onPressed: _editSelectedImages,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B46C1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.compare, size: 16),
                            label: const Text('Compare'),
                            onPressed: _compareSelectedImages,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B46C1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: _isAiProcessing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.auto_awesome, size: 16),
                            label: const Text('AI Process'),
                            onPressed: (_selectedIndices.length == 1 && !_isAiProcessing)
                                ? _runAiInference
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: const Size(0, 32),
                              disabledBackgroundColor: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.send_to_mobile_rounded, size: 16),
                            label: const Text('Tele Report'),
                            onPressed: () => _openTeleReportSheet(
                              images: _selectedIndices.map((i) => _images[i]).toList(),
                              videos: _selectedVideoIndices.map((i) => _videos[i]).toList(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Combined grid for images and videos
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: _images.length + _videos.length,
                      itemBuilder: (context, index) {
                        // Determine if this is an image or video
                        final isImage = index < _images.length;
                        final itemIndex = isImage ? index : index - _images.length;
                        
                        if (isImage) {
                          final isSelected = _selectedIndices.contains(itemIndex);
                          return GestureDetector(
                            onTap: () {
                              if (_isSelectionMode) {
                                _toggleImageSelection(itemIndex);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageDetailScreen(
                                      imageBytes: _images[itemIndex],
                                      onDelete: () {
                                        _deleteImage(itemIndex);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                _toggleSelectionMode();
                                _toggleImageSelection(itemIndex);
                              }
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected ? const Color(0xFF6B46C1) : Colors.grey.shade300,
                                            width: isSelected ? 2 : 1,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.memory(
                                            _images[itemIndex],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF6B46C1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image ${itemIndex + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Video item
                          final isSelected = _selectedVideoIndices.contains(itemIndex);
                          return GestureDetector(
                            onTap: () {
                              if (_isSelectionMode) {
                                setState(() {
                                  if (_selectedVideoIndices.contains(itemIndex)) {
                                    _selectedVideoIndices.remove(itemIndex);
                                  } else {
                                    _selectedVideoIndices.add(itemIndex);
                                  }
                                });
                              } else {
                                // Show video detail screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoDetailScreen(
                                      videoBytes: _videos[itemIndex],
                                      onDelete: () {
                                        _deleteVideo(itemIndex);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                _toggleSelectionMode();
                                setState(() {
                                  _selectedVideoIndices.add(itemIndex);
                                });
                              }
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected ? Colors.red : Colors.grey.shade300,
                                            width: isSelected ? 2 : 1,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.black,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: _buildVideoThumbnail(itemIndex),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Video ${itemIndex + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: _showHelpDialog,
              icon: const Icon(Icons.help_outline, color: Colors.grey),
              tooltip: 'Help',
            ),
            const Expanded(
              child: Text(
                '© 2025 Griya. All rights reserved.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(widget.pickerMode ? Icons.check : Icons.arrow_forward, size: 16),
              label: Text(widget.pickerMode ? (widget.pickerActionLabel ?? 'Use Selected') : 'Proceed to Diagnosis'),
              onPressed: _selectedIndices.isNotEmpty ? _proceedToDiagnosis : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B46C1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                minimumSize: const Size(0, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Gallery Help',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How to use:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Tap the select button to enter selection mode\n'
              '• Long press any image to quickly select it\n'
              '• Tap images to select/deselect them\n'
              '• Use the PDF button to create reports\n'
              '• Choose from three report types:\n'
              '  - Simple PDF: Images only\n'
              '  - Detailed Report: With patient info\n'
              '  - Comprehensive Report: SQL data + images\n\n'
              'Image Editor Features:\n'
              '• Advanced color adjustments (brightness, contrast, saturation, hue, gamma, exposure)\n'
              '• Medical filters (sharpening, blur, histogram equalization)\n'
              '• Transform tools (rotate, flip)\n'
              '• Annotation tools for marking areas of interest\n'
              '• Undo/Redo functionality\n'
              '• Save edited images locally',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              'Platform:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Running on: ${_getPlatformInfo()}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: PdfService.getPdfDirectoryPath(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'PDFs saved to:\n${snapshot.data}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  );
                }
                return const Text(
                  'Loading PDF directory...',
                  style: TextStyle(color: Colors.white70),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class ImageDetailScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback onDelete;

  const ImageDetailScreen({
    super.key,
    required this.imageBytes,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: const Text(
                    'Delete Image',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Are you sure you want to delete this image?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        onDelete();
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Image.memory(
          imageBytes,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class VideoDetailScreen extends StatefulWidget {
  final Uint8List videoBytes;
  final VoidCallback onDelete;

  const VideoDetailScreen({
    super.key,
    required this.videoBytes,
    required this.onDelete,
  });

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Check if platform supports video player
      // video_player_win provides Windows support
      if (Platform.isLinux) {
        print('Video player not fully supported on Linux.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video playback not available on Linux. Video file is saved.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Save video bytes to temporary file
      final tempDir = await getTemporaryDirectory();
      final videoFile = File(path.join(tempDir.path, 'video_detail_${DateTime.now().millisecondsSinceEpoch}.mp4'));
      await videoFile.writeAsBytes(widget.videoBytes);

      // Create video player controller
      _controller = VideoPlayerController.file(videoFile);
      await _controller!.initialize();
      
      _controller!.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
          });
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video playback not available: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video playback not available on this platform'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: const Text(
                    'Delete Video',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Are you sure you want to delete this video?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        widget.onDelete();
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _isInitialized && _controller != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                  // Play/Pause overlay
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      color: Colors.transparent,
                      child: Icon(
                        _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: Colors.white.withOpacity(0.8),
                        size: 80,
                      ),
                    ),
                  ),
                ],
              )
                : Platform.isLinux
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.videocam,
                        color: Colors.white54,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Video playback not available',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Video file is saved and can be viewed\non supported platforms',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(
                    color: Colors.white,
                  ),
      ),
      floatingActionButton: _isInitialized && _controller != null
          ? FloatingActionButton(
              onPressed: _togglePlayPause,
              backgroundColor: Colors.white.withOpacity(0.8),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
} 