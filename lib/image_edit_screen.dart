import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'config/app_config.dart';

// Passed to the isolate — all fields must be sendable (primitives + Uint8List)
class _EditParams {
  final Uint8List imageBytes;
  final double brightness, contrast, saturation, hue;
  final double rotation;
  final bool flipH, flipV;
  final double sharpness, blur;
  final bool grayscale, sepia;
  final int previewSize; // 0 = full resolution

  const _EditParams({
    required this.imageBytes,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.hue,
    required this.rotation,
    required this.flipH,
    required this.flipV,
    required this.sharpness,
    required this.blur,
    required this.grayscale,
    required this.sepia,
    this.previewSize = 0,
  });
}

Uint8List _downscaleIsolate(Uint8List bytes) {
  final src = img.decodeImage(bytes);
  if (src == null) return bytes;
  final long = src.width > src.height ? src.width : src.height;
  if (long <= 512) return bytes;
  final scaled = src.width > src.height
      ? img.copyResize(src, width: 512)
      : img.copyResize(src, height: 512);
  return Uint8List.fromList(img.encodeJpg(scaled, quality: 85));
}

Uint8List _processImageIsolate(_EditParams p) {
  img.Image working = img.decodeImage(p.imageBytes) ?? img.Image(width: 1, height: 1);

  if (p.flipH) working = img.flipHorizontal(working);
  if (p.flipV) working = img.flipVertical(working);
  if (p.rotation != 0) working = img.copyRotate(working, angle: p.rotation.toInt());

  if (p.brightness != 0.0 || p.contrast != 1.0 || p.saturation != 1.0) {
    working = img.adjustColor(
      working,
      brightness: p.brightness.clamp(-1, 1),
      contrast: p.contrast.clamp(0.1, 3.0),
      saturation: p.saturation.clamp(0, 3),
    );
  }

  if (p.hue != 0.0) {
    final hueShift = p.hue;
    for (final pixel in working) {
      final r = pixel.r.toDouble();
      final g = pixel.g.toDouble();
      final b = pixel.b.toDouble();
      final max = r > g ? (r > b ? r : b) : (g > b ? g : b);
      final min = r < g ? (r < b ? r : b) : (g < b ? g : b);
      final diff = max - min;
      if (diff == 0) continue;
      double h = 0;
      if (max == r) h = ((g - b) / diff) % 6;
      else if (max == g) h = (b - r) / diff + 2;
      else h = (r - g) / diff + 4;
      h = (h * 60 + hueShift) % 360;
      if (h < 0) h += 360;
      final s = diff / max;
      final v = max / 255.0;
      final c = v * s;
      final x = c * (1 - ((h / 60) % 2 - 1).abs());
      final m = v - c;
      double nr, ng, nb;
      if (h < 60) { nr = c; ng = x; nb = 0; }
      else if (h < 120) { nr = x; ng = c; nb = 0; }
      else if (h < 180) { nr = 0; ng = c; nb = x; }
      else if (h < 240) { nr = 0; ng = x; nb = c; }
      else if (h < 300) { nr = x; ng = 0; nb = c; }
      else { nr = c; ng = 0; nb = x; }
      pixel.r = ((nr + m) * 255).round().clamp(0, 255);
      pixel.g = ((ng + m) * 255).round().clamp(0, 255);
      pixel.b = ((nb + m) * 255).round().clamp(0, 255);
    }
  }

  if (p.grayscale) working = img.grayscale(working);
  if (p.sepia) working = img.sepia(working);
  if (p.sharpness > 0) working = img.adjustColor(working, contrast: 1.0 + p.sharpness * 0.5);
  if (p.blur > 0) {
    // Cap blur radius during preview (previewSize > 0) to avoid stalling UI
    final blurRadius = (p.previewSize > 0 ? p.blur.clamp(0, 4) : p.blur).toInt();
    if (blurRadius > 0) working = img.gaussianBlur(working, radius: blurRadius);
  }

  return Uint8List.fromList(img.encodeJpg(working, quality: 90));
}

class ImageEditScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const ImageEditScreen({super.key, required this.imageBytes});

  @override
  State<ImageEditScreen> createState() => _ImageEditScreenState();
}

class _ImageEditScreenState extends State<ImageEditScreen> {
  late Uint8List _originalBytes;
  late Uint8List _previewBytes;  // downscaled, used during live drag
  late Uint8List _currentBytes;  // full-res, used for display when not dragging
  bool _previewReady = false;

  // Color adjustments
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  double _hue = 0.0;

  // Transform
  double _rotation = 0.0;
  bool _flipH = false;
  bool _flipV = false;

  // Filters
  double _sharpness = 0.0;
  double _blur = 0.0;
  bool _grayscale = false;
  bool _sepia = false;

  bool _isProcessing = false;
  bool _isDragging = false;
  bool _previewInFlight = false;  // guard: at most one preview isolate at a time
  int _previewGeneration = 0;     // discard stale results
  Timer? _debounce;
  final CropController _cropController = CropController();

  @override
  void initState() {
    super.initState();
    _originalBytes = widget.imageBytes;
    _previewBytes = widget.imageBytes;
    _currentBytes = widget.imageBytes;
    _buildPreview();
  }

  Future<void> _buildPreview() async {
    final preview = await compute(_downscaleIsolate, _originalBytes);
    if (mounted) setState(() { _previewBytes = preview; _previewReady = true; });
  }

  _EditParams _makeParams({required bool preview}) => _EditParams(
    imageBytes: preview ? _previewBytes : _originalBytes,
    brightness: _brightness,
    contrast: _contrast,
    saturation: _saturation,
    hue: _hue,
    rotation: _rotation,
    flipH: _flipH,
    flipV: _flipV,
    sharpness: _sharpness,
    blur: _blur,
    grayscale: _grayscale,
    sepia: _sepia,
    previewSize: preview ? 512 : 0,
  );

  // Called on every slider tick — updates preview quickly
  void _scheduleLivePreview() {
    if (!_previewReady) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), () async {
      if (_previewInFlight) return; // skip if previous compute still running
      _previewInFlight = true;
      final gen = ++_previewGeneration;
      try {
        final result = await compute(_processImageIsolate, _makeParams(preview: true));
        if (mounted && _isDragging && gen == _previewGeneration) {
          setState(() => _currentBytes = result);
        }
      } finally {
        _previewInFlight = false;
      }
    });
  }

  // Called on slider release — applies full-res quietly in background
  void _applyFullRes() {
    _debounce?.cancel();
    ++_previewGeneration; // invalidate any in-flight preview so it won't overwrite
    compute(_processImageIsolate, _makeParams(preview: false)).then((result) {
      if (mounted) setState(() { _currentBytes = result; _isProcessing = false; });
    }).catchError((e) {
      debugPrint('Error processing image: $e');
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _resetAll() {
    setState(() {
      _brightness = 0.0;
      _contrast = 1.0;
      _saturation = 1.0;
      _hue = 0.0;
      _rotation = 0.0;
      _flipH = false;
      _flipV = false;
      _sharpness = 0.0;
      _blur = 0.0;
      _grayscale = false;
      _sepia = false;
    });
    _applyFullRes();
  }


  Future<void> _runInference() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      // Step 1: Send image to AI server via Port 5000 /ai/send endpoint
      final uri = Uri.parse(AppConfig.aiSendUrl);
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            _currentBytes,
            filename: 'edited.jpg',
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
      await _pollResultImage();
      
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inference error: $e')),
        );
      }
    }
  }

  Future<void> _pollResultImage() async {
    const maxAttempts = 30; // 30 seconds max wait time
    const pollInterval = Duration(seconds: 1);
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        // Directly try to fetch the result image
        final resultResponse = await http.get(Uri.parse(AppConfig.aiResultUrl));
        
        if (resultResponse.statusCode == 200) {
          // Result is ready!
          final resultBytes = resultResponse.bodyBytes;
          
          if (mounted) {
            setState(() {
              _currentBytes = resultBytes;
              _isProcessing = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('AI inference completed successfully')),
            );
          }
          return; // Success, exit polling loop
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
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI inference timed out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        title: const Text('Medical Image Editor'),
        actions: [
          Tooltip(
            message: 'Run server-side inference and update image',
            child: TextButton(
              onPressed: _runInference,
              style: TextButton.styleFrom(
                backgroundColor: Colors.purple[50],
                foregroundColor: const Color(0xFF6B46C1),
              ),
              child: const Text('Infer'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _resetAll,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset All',
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, _currentBytes),
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Controls Panel
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionHeader('Transform', Icons.transform),
                _buildTransformControls(),
                const SizedBox(height: 20),
                
                _buildSectionHeader('Color Adjustments', Icons.palette),
                _buildColorControls(),
                const SizedBox(height: 20),
                
                                 _buildSectionHeader('Filters', Icons.filter_alt),
                 _buildFilterControls(),
                 const SizedBox(height: 20),
                 
                 // Info section about save options
                 Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: Colors.blue[50],
                     borderRadius: BorderRadius.circular(8),
                     border: Border.all(color: Colors.blue[200]!),
                   ),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                           const SizedBox(width: 8),
                           Text(
                             'Save Options',
                             style: TextStyle(
                               fontWeight: FontWeight.bold,
                               color: Colors.blue[700],
                               fontSize: 14,
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 8),
                       Text(
                         '• Save: Creates a new copy and adds to gallery\n'
                         '• Apply to Current: Updates current image and adds to gallery\n'
                         '• Apply & Return: Returns edited image without saving',
                         style: TextStyle(
                           color: Colors.blue[700],
                           fontSize: 12,
                         ),
                       ),
                     ],
                   ),
                 ),
                 const SizedBox(height: 20),
                 
                 if (_isProcessing)
                   const Center(
                     child: Column(
                       children: [
                         CircularProgressIndicator(),
                         SizedBox(height: 8),
                         Text('Processing...'),
                       ],
                     ),
                   ),
              ],
            ),
          ),
          
          // Image Area
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child: Crop(
                  image: _currentBytes,
                  controller: _cropController,
                  onCropped: (cropped) {
                    Navigator.pop(context, cropped);
                  },
                  withCircleUi: false,
                  baseColor: Colors.black,
                  maskColor: Colors.black.withOpacity(0.35),
                  interactive: true,
                  aspectRatio: 4 / 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6B46C1), size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransformControls() {
    return Column(
      children: [
        _buildSlider(
          label: 'Rotation',
          value: _rotation,
          onChanged: (v) { setState(() { _isDragging = true; _rotation = v; }); _scheduleLivePreview(); },
          onChangeEnd: (_) { setState(() => _isDragging = false); _applyFullRes(); },
          min: -180,
          max: 180,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () { setState(() => _flipH = !_flipH); _applyFullRes(); },
                icon: const Icon(Icons.flip),
                label: Text(_flipH ? 'Flipped H' : 'Flip H'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () { setState(() => _flipV = !_flipV); _applyFullRes(); },
                icon: const Icon(Icons.flip_camera_android),
                label: Text(_flipV ? 'Flipped V' : 'Flip V'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorControls() {
    return Column(
      children: [
        _buildSlider(
          label: 'Brightness',
          value: _brightness,
          onChanged: (v) { setState(() { _isDragging = true; _brightness = v; }); _scheduleLivePreview(); },
          onChangeEnd: (_) { setState(() => _isDragging = false); _applyFullRes(); },
          min: -1,
          max: 1,
        ),
        _buildSlider(
          label: 'Contrast',
          value: _contrast,
          onChanged: (v) { setState(() { _isDragging = true; _contrast = v; }); _scheduleLivePreview(); },
          onChangeEnd: (_) { setState(() => _isDragging = false); _applyFullRes(); },
          min: 0.1,
          max: 3.0,
        ),
        _buildSlider(
          label: 'Saturation',
          value: _saturation,
          onChanged: (v) { setState(() { _isDragging = true; _saturation = v; }); _scheduleLivePreview(); },
          onChangeEnd: (_) { setState(() => _isDragging = false); _applyFullRes(); },
          min: 0,
          max: 3,
        ),
        _buildSlider(
          label: 'Hue',
          value: _hue,
          onChanged: (v) { setState(() { _isDragging = true; _hue = v; }); _scheduleLivePreview(); },
          onChangeEnd: (_) { setState(() => _isDragging = false); _applyFullRes(); },
          min: -180,
          max: 180,
        ),
      ],
    );
  }

  Widget _buildFilterControls() {
    return Column(
      children: [
        _buildSlider(
          label: 'Sharpness',
          value: _sharpness,
          onChanged: (v) { setState(() { _isDragging = true; _sharpness = v; }); _scheduleLivePreview(); },
          onChangeEnd: (_) { setState(() => _isDragging = false); _applyFullRes(); },
          min: 0,
          max: 2,
        ),
        _buildSlider(
          label: 'Blur',
          value: _blur,
          onChanged: (v) { setState(() { _isDragging = true; _blur = v; }); _scheduleLivePreview(); },
          onChangeEnd: (_) { setState(() => _isDragging = false); _applyFullRes(); },
          min: 0,
          max: 10,
        ),
        SwitchListTile(
          title: const Text('Grayscale'),
          value: _grayscale,
          onChanged: (value) { setState(() => _grayscale = value); _applyFullRes(); },
        ),
        SwitchListTile(
          title: const Text('Sepia'),
          value: _sepia,
          onChanged: (value) { setState(() => _sepia = value); _applyFullRes(); },
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
          activeColor: const Color(0xFF6B46C1),
          inactiveColor: Colors.grey[300],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

