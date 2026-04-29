import 'dart:typed_data';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'config/app_config.dart';

class ImageEditScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const ImageEditScreen({super.key, required this.imageBytes});

  @override
  State<ImageEditScreen> createState() => _ImageEditScreenState();
}

class _ImageEditScreenState extends State<ImageEditScreen> {
  late Uint8List _originalBytes;
  late Uint8List _currentBytes;
  late img.Image _originalImage;
  
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
  final CropController _cropController = CropController();

  @override
  void initState() {
    super.initState();
    _originalBytes = widget.imageBytes;
    _currentBytes = widget.imageBytes;
    _initializeImage();
  }

  Future<void> _initializeImage() async {
    try {
      final decoded = img.decodeImage(widget.imageBytes);
      if (decoded != null) {
        _originalImage = decoded;
      }
    } catch (e) {
      debugPrint('Error initializing image: $e');
    }
  }

  Future<void> _applyChanges() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      // Create a copy of the original image
      img.Image working = img.copyResize(_originalImage, 
        width: _originalImage.width, 
        height: _originalImage.height
      );

      // Apply transformations
      if (_flipH) working = img.flipHorizontal(working);
      if (_flipV) working = img.flipVertical(working);
      if (_rotation != 0) {
        working = img.copyRotate(working, angle: _rotation.toInt());
      }

      // Apply color adjustments
      if (_brightness != 0.0 || _contrast != 1.0 || _saturation != 1.0) {
        working = img.adjustColor(
          working,
          brightness: _brightness.clamp(-1, 1),
          contrast: _contrast.clamp(0.1, 3.0),
          saturation: _saturation.clamp(0, 3),
        );
      }

      // Apply hue shift
      if (_hue != 0.0) {
        working = _applyHueShift(working, _hue);
      }

      // Apply filters
      if (_grayscale) {
        working = img.grayscale(working);
      }
      if (_sepia) {
        working = _applySepia(working);
      }
      if (_sharpness > 0) {
        working = _applySharpness(working, _sharpness);
      }
      if (_blur > 0) {
        working = img.gaussianBlur(working, radius: _blur.toInt());
      }

      // Encode with high quality
      final processedBytes = Uint8List.fromList(img.encodeJpg(working, quality: 95));
      
      setState(() {
        _currentBytes = processedBytes;
        _isProcessing = false;
      });
    } catch (e) {
      debugPrint('Error processing image: $e');
      setState(() => _isProcessing = false);
    }
  }

  img.Image _applyHueShift(img.Image image, double hue) {
    // Simple hue shift implementation
    final pixels = image.getBytes();
    for (int i = 0; i < pixels.length; i += 4) {
      if (pixels[i + 3] > 0) { // Skip transparent pixels
        final hsv = _rgbToHsv(pixels[i], pixels[i + 1], pixels[i + 2]);
        hsv[0] = (hsv[0] + hue) % 360;
        final rgb = _hsvToRgb(hsv[0], hsv[1], hsv[2]);
        pixels[i] = rgb[0];
        pixels[i + 1] = rgb[1];
        pixels[i + 2] = rgb[2];
      }
    }
    return image;
  }

  img.Image _applySepia(img.Image image) {
    final pixels = image.getBytes();
    for (int i = 0; i < pixels.length; i += 4) {
      if (pixels[i + 3] > 0) {
        final r = pixels[i];
        final g = pixels[i + 1];
        final b = pixels[i + 2];
        
        final tr = (r * 0.393 + g * 0.769 + b * 0.189).round().clamp(0, 255);
        final tg = (r * 0.349 + g * 0.686 + b * 0.168).round().clamp(0, 255);
        final tb = (r * 0.272 + g * 0.534 + b * 0.131).round().clamp(0, 255);
        
        pixels[i] = tr;
        pixels[i + 1] = tg;
        pixels[i + 2] = tb;
      }
    }
    return image;
  }

  img.Image _applySharpness(img.Image image, double amount) {
    // Simple sharpening using contrast adjustment
    final factor = 1.0 + (amount * 0.5);
    return img.adjustColor(image, contrast: factor);
  }

  List<double> _rgbToHsv(int r, int g, int b) {
    final rNorm = r / 255.0;
    final gNorm = g / 255.0;
    final bNorm = b / 255.0;
    
    final max = math.max(math.max(rNorm, gNorm), bNorm);
    final min = math.min(math.min(rNorm, gNorm), bNorm);
    final diff = max - min;
    
    double h = 0;
    if (diff != 0) {
      if (max == rNorm) {
        h = ((gNorm - bNorm) / diff) % 6;
      } else if (max == gNorm) {
        h = (bNorm - rNorm) / diff + 2;
      } else {
        h = (rNorm - gNorm) / diff + 4;
      }
      h *= 60;
    }
    
    final s = max == 0 ? 0.0 : diff / max;
    final v = max;
    
    return [h, s, v];
  }

  List<int> _hsvToRgb(double h, double s, double v) {
    final c = v * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = v - c;
    
    double r, g, b;
    if (h < 60) {
      r = c; g = x; b = 0;
    } else if (h < 120) {
      r = x; g = c; b = 0;
    } else if (h < 180) {
      r = 0; g = c; b = x;
    } else if (h < 240) {
      r = 0; g = x; b = c;
    } else if (h < 300) {
      r = x; g = 0; b = c;
    } else {
      r = c; g = 0; b = x;
    }
    
    return [
      ((r + m) * 255).round().clamp(0, 255),
      ((g + m) * 255).round().clamp(0, 255),
      ((b + m) * 255).round().clamp(0, 255),
    ];
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
    _applyChanges();
  }

  Future<void> _saveAsCopy() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/edited_image_copy_$timestamp.jpg');
      await file.writeAsBytes(_currentBytes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved as copy and added to gallery: ${file.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Return the edited image bytes so the gallery updates with the copy
        Navigator.pop(context, _currentBytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    }
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

  Future<void> _applyToCurrentImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/current_edited_image.jpg');
      await file.writeAsBytes(_currentBytes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Current image updated and added to gallery: ${file.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Return the edited image bytes so the gallery updates with the current image
        Navigator.pop(context, _currentBytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    }
  }

  Future<void> _saveAndAddToGallery() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/edited_image_$timestamp.jpg');
      await file.writeAsBytes(_currentBytes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved and added to gallery: ${file.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Return the edited image bytes so the gallery updates
        Navigator.pop(context, _currentBytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    }
  }

  void _openFile(String path) {
    debugPrint('Opening file: $path');
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
          Tooltip(
            message: 'Save a copy of the edited image and add to gallery',
            child: TextButton(
              onPressed: _saveAsCopy,
              style: TextButton.styleFrom(
                backgroundColor: Colors.green[50],
                foregroundColor: Colors.green[700],
              ),
              child: const Text('Save as Copy'),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Apply edits to current image and add to gallery',
            child: TextButton(
              onPressed: _applyToCurrentImage,
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange[50],
                foregroundColor: Colors.orange[700],
              ),
              child: const Text('Apply to Current'),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => Navigator.pop(context, _currentBytes),
            child: const Text('Apply & Return'),
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
                         '• Save as Copy: Creates a new copy and adds to gallery\n'
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
          min: -180,
          max: 180,
          onChanged: (v) {
            setState(() => _rotation = v);
            _applyChanges();
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _flipH = !_flipH);
                  _applyChanges();
                },
                icon: Icon(_flipH ? Icons.flip : Icons.flip),
                label: Text(_flipH ? 'Flipped H' : 'Flip H'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _flipV = !_flipV);
                  _applyChanges();
                },
                icon: Icon(_flipV ? Icons.flip_camera_android : Icons.flip_camera_android),
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
          min: -1,
          max: 1,
          onChanged: (v) {
            setState(() => _brightness = v);
            _applyChanges();
          },
        ),
        _buildSlider(
          label: 'Contrast',
          value: _contrast,
          min: 0.1,
          max: 3.0,
          onChanged: (v) {
            setState(() => _contrast = v);
            _applyChanges();
          },
        ),
        _buildSlider(
          label: 'Saturation',
          value: _saturation,
          min: 0,
          max: 3,
          onChanged: (v) {
            setState(() => _saturation = v);
            _applyChanges();
          },
        ),
        _buildSlider(
          label: 'Hue',
          value: _hue,
          min: -180,
          max: 180,
          onChanged: (v) {
            setState(() => _hue = v);
            _applyChanges();
          },
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
          min: 0,
          max: 2,
          onChanged: (v) {
            setState(() => _sharpness = v);
            _applyChanges();
          },
        ),
        _buildSlider(
          label: 'Blur',
          value: _blur,
          min: 0,
          max: 10,
          onChanged: (v) {
            setState(() => _blur = v);
            _applyChanges();
          },
        ),
        SwitchListTile(
          title: const Text('Grayscale'),
          value: _grayscale,
          onChanged: (value) {
            setState(() => _grayscale = value);
            _applyChanges();
          },
        ),
        SwitchListTile(
          title: const Text('Sepia'),
          value: _sepia,
          onChanged: (value) {
            setState(() => _sepia = value);
            _applyChanges();
          },
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
                // fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: const Color(0xFF6B46C1),
          inactiveColor: Colors.grey[300],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

