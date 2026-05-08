import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' show sin, cos, min;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'config/app_config.dart';

// ---------------------------------------------------------------------------
// Annotation model
// ---------------------------------------------------------------------------

enum AnnotationSymbol { scj, quad, bx, aw, iodineNeg, av, os, mosaic, punctation }

class _SymbolMeta {
  final String label;
  final Color textColor;
  final String description;
  const _SymbolMeta(this.label, this.textColor, this.description);
}

const Map<AnnotationSymbol, _SymbolMeta> _kSymbolMeta = {
  AnnotationSymbol.scj:        _SymbolMeta('SCJ',  Color(0xFFFFD700), 'Squamous columnar junction'),
  AnnotationSymbol.quad:       _SymbolMeta('Quad', Color(0xFF87CEEB), 'Quadrant overlay'),
  AnnotationSymbol.bx:         _SymbolMeta('Bx',   Color(0xFF1A1A1A), 'Site of biopsy'),
  AnnotationSymbol.aw:         _SymbolMeta('AW',   Color(0xFFFFFFFF), 'Acetowhitening'),
  AnnotationSymbol.iodineNeg:  _SymbolMeta('I',    Color(0xFF2C2C2C), 'Iodine negative'),
  AnnotationSymbol.av:         _SymbolMeta('AV',   Color(0xFFFF8C00), 'Abnormal vessels'),
  AnnotationSymbol.os:         _SymbolMeta('OS',   Color(0xFF2563EB), 'Cervical os'),
  AnnotationSymbol.mosaic:     _SymbolMeta('M',    Color(0xFF16A34A), 'Blood vessel mosaic'),
  AnnotationSymbol.punctation: _SymbolMeta('P',    Color(0xFFE91E63), 'Blood vessel punctation'),
};

class _Annotation {
  final String id;
  final AnnotationSymbol symbol;
  Offset position; // canvas-pixel coordinates
  double scale;    // 1.0 = 60 logical px diameter

  _Annotation({
    required this.symbol,
    required this.position,
    this.scale = 1.0,
  }) : id = UniqueKey().toString();
}

// ---------------------------------------------------------------------------
// Custom painters
// ---------------------------------------------------------------------------

class _QuadIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF87CEEB)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.shortestSide / 2 - 2;
    canvas.drawCircle(Offset(cx, cy), r, paint);
    canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), paint);
    canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), paint);
  }
  @override bool shouldRepaint(_) => false;
}

class _QuadOverlayPainter extends CustomPainter {
  final Rect imageRect;
  const _QuadOverlayPainter(this.imageRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF87CEEB).withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final center = imageRect.center;
    final radius = imageRect.shortestSide * 0.45;
    canvas.drawCircle(center, radius, paint);
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), paint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), paint);
    // Degree ticks
    final tickPaint = Paint()..color = const Color(0xFF87CEEB).withOpacity(0.5)..strokeWidth = 1;
    for (int deg = 0; deg < 360; deg += 10) {
      final angle = deg * 3.14159 / 180;
      final outer = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      final tickLen = deg % 90 == 0 ? 10.0 : 5.0;
      final inner = Offset(center.dx + (radius - tickLen) * cos(angle), center.dy + (radius - tickLen) * sin(angle));
      canvas.drawLine(inner, outer, tickPaint);
    }
    // Degree labels
    final labels = ['0°', '90°', '180°', '270°'];
    final angles = [270.0, 0.0, 90.0, 180.0];
    for (int i = 0; i < labels.length; i++) {
      final a = angles[i] * 3.14159 / 180;
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: const TextStyle(color: Color(0xFF87CEEB), fontSize: 9)),
        textDirection: TextDirection.ltr,
      )..layout();
      final pos = Offset(
        center.dx + (radius + 12) * cos(a) - tp.width / 2,
        center.dy + (radius + 12) * sin(a) - tp.height / 2,
      );
      tp.paint(canvas, pos);
    }
  }
  @override
  bool shouldRepaint(_QuadOverlayPainter old) => old.imageRect != imageRect;
}

// ---------------------------------------------------------------------------
// Image processing
// ---------------------------------------------------------------------------

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
      final maxVal = r > g ? (r > b ? r : b) : (g > b ? g : b);
      final minVal = r < g ? (r < b ? r : b) : (g < b ? g : b);
      final diff = maxVal - minVal;
      if (diff == 0) continue;
      double h = 0;
      if (maxVal == r) h = ((g - b) / diff) % 6;
      else if (maxVal == g) h = (b - r) / diff + 2;
      else h = (r - g) / diff + 4;
      h = (h * 60 + hueShift) % 360;
      if (h < 0) h += 360;
      final s = diff / maxVal;
      final v = maxVal / 255.0;
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

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

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

  // Annotate mode
  bool _annotateMode = false;
  AnnotationSymbol? _activeSymbol;
  final List<_Annotation> _annotations = [];
  final GlobalKey _repaintKey = GlobalKey();
  Size? _imageNaturalSize;

  @override
  void initState() {
    super.initState();
    _originalBytes = widget.imageBytes;
    _previewBytes = widget.imageBytes;
    _currentBytes = widget.imageBytes;
    _buildPreview();
    _loadImageNaturalSize();
  }

  Future<void> _buildPreview() async {
    final preview = await compute(_downscaleIsolate, _originalBytes);
    if (mounted) setState(() { _previewBytes = preview; _previewReady = true; });
  }

  Future<void> _loadImageNaturalSize() async {
    try {
      final codec = await ui.instantiateImageCodec(widget.imageBytes);
      final frame = await codec.getNextFrame();
      if (mounted) setState(() => _imageNaturalSize = Size(frame.image.width.toDouble(), frame.image.height.toDouble()));
    } catch (_) {}
  }

  Rect _imageRect(Size containerSize) {
    if (_imageNaturalSize == null) return Rect.fromLTWH(0, 0, containerSize.width, containerSize.height);
    final scale = min(containerSize.width / _imageNaturalSize!.width, containerSize.height / _imageNaturalSize!.height);
    final w = _imageNaturalSize!.width * scale;
    final h = _imageNaturalSize!.height * scale;
    return Rect.fromLTWH((containerSize.width - w) / 2, (containerSize.height - h) / 2, w, h);
  }

  Future<Uint8List?> _captureAnnotatedImage() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final ratio = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
      final image = await boundary.toImage(pixelRatio: ratio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) { return null; }
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

  // ---------------------------------------------------------------------------
  // Annotate panel & canvas
  // ---------------------------------------------------------------------------

  Widget _buildAnnotatePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.edit_location_alt, color: Color(0xFF6B46C1), size: 20),
              const SizedBox(width: 8),
              const Text('Annotations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            ],
          ),
        ),
        if (_activeSymbol != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EDFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.touch_app, color: Color(0xFF6B46C1), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap image to place ${_kSymbolMeta[_activeSymbol]!.label}',
                    style: const TextStyle(color: Color(0xFF6B46C1), fontSize: 12),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _activeSymbol = null),
                  child: const Icon(Icons.close, size: 16, color: Color(0xFF6B46C1)),
                ),
              ],
            ),
          ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: AnnotationSymbol.values.map((sym) {
            final meta = _kSymbolMeta[sym]!;
            final isActive = _activeSymbol == sym;
            return GestureDetector(
              onTap: () => setState(() => _activeSymbol = isActive ? null : sym),
              child: Container(
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF6B46C1) : const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? const Color(0xFF6B46C1) : Colors.grey.shade700,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    sym == AnnotationSymbol.quad
                      ? SizedBox(
                          width: 32, height: 32,
                          child: CustomPaint(painter: _QuadIconPainter()),
                        )
                      : Text(
                          meta.label,
                          style: TextStyle(
                            color: meta.textColor,
                            fontWeight: FontWeight.w900,
                            fontSize: meta.label.length > 2 ? 14 : 20,
                            shadows: const [Shadow(color: Colors.black54, blurRadius: 2)],
                          ),
                        ),
                    const SizedBox(height: 4),
                    Text(
                      meta.label == 'Quad' ? 'Quad' : meta.label.length > 2 ? meta.label : _shortDesc(sym),
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_annotations.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Placed (${_annotations.length})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              TextButton.icon(
                onPressed: () => setState(() => _annotations.clear()),
                icon: const Icon(Icons.delete_sweep, size: 16),
                label: const Text('Clear all', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 8)),
              ),
            ],
          ),
          ..._annotations.map((ann) {
            final meta = _kSymbolMeta[ann.symbol]!;
            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                child: ann.symbol == AnnotationSymbol.quad
                  ? CustomPaint(painter: _QuadIconPainter())
                  : Center(child: Text(meta.label, style: TextStyle(color: meta.textColor, fontWeight: FontWeight.bold, fontSize: 11))),
              ),
              title: Text(meta.description, style: const TextStyle(fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => setState(() => _annotations.remove(ann)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            );
          }),
        ],
      ],
    );
  }

  String _shortDesc(AnnotationSymbol sym) {
    switch (sym) {
      case AnnotationSymbol.scj:        return 'SCJ';
      case AnnotationSymbol.bx:         return 'Biopsy';
      case AnnotationSymbol.aw:         return 'Aceto W';
      case AnnotationSymbol.iodineNeg:  return 'Iodine-';
      case AnnotationSymbol.av:         return 'Abn Vessels';
      case AnnotationSymbol.os:         return 'Cervical Os';
      case AnnotationSymbol.mosaic:     return 'Mosaic';
      case AnnotationSymbol.punctation: return 'Punctation';
      default: return '';
    }
  }

  Widget _buildAnnotateCanvas() {
    return LayoutBuilder(builder: (context, constraints) {
      final containerSize = Size(constraints.maxWidth, constraints.maxHeight);
      final imgRect = _imageRect(containerSize);
      final hasQuad = _annotations.any((a) => a.symbol == AnnotationSymbol.quad);

      return GestureDetector(
        onTapDown: _activeSymbol == null ? null : (d) {
          if (!imgRect.contains(d.localPosition)) return;
          setState(() {
            _annotations.add(_Annotation(symbol: _activeSymbol!, position: d.localPosition));
            if (_activeSymbol != AnnotationSymbol.quad) _activeSymbol = null;
          });
        },
        child: RepaintBoundary(
          key: _repaintKey,
          child: Stack(
            children: [
              // Base image
              Positioned.fromRect(
                rect: imgRect,
                child: Image.memory(_currentBytes, fit: BoxFit.fill),
              ),
              // Quad overlay (if any quad annotation placed)
              if (hasQuad) ...[
                CustomPaint(
                  size: containerSize,
                  painter: _QuadOverlayPainter(imgRect),
                ),
                Positioned(
                  left: imgRect.center.dx - 14,
                  top: imgRect.top + 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _annotations.removeWhere((a) => a.symbol == AnnotationSymbol.quad)),
                    child: Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
              // Symbol markers
              ..._annotations.where((a) => a.symbol != AnnotationSymbol.quad).map((ann) {
                final meta = _kSymbolMeta[ann.symbol]!;
                final diameter = 56.0 * ann.scale;
                final half = diameter / 2;
                return Positioned(
                  left: ann.position.dx - half,
                  top: ann.position.dy - half,
                  child: GestureDetector(
                    onScaleUpdate: (d) {
                      setState(() {
                        if (d.pointerCount >= 2) {
                          ann.scale = (ann.scale * d.scale).clamp(0.4, 3.0);
                        } else {
                          ann.position += d.focalPointDelta;
                        }
                      });
                    },
                    child: SizedBox(
                      width: diameter,
                      height: diameter,
                      child: Stack(
                        children: [
                          Container(
                            width: diameter,
                            height: diameter,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                meta.label,
                                style: TextStyle(
                                  color: meta.textColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16 * ann.scale,
                                  shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                                ),
                              ),
                            ),
                          ),
                          // Delete X button
                          Positioned(
                            top: 0, left: 0,
                            child: GestureDetector(
                              onTap: () => setState(() => _annotations.remove(ann)),
                              child: Container(
                                width: 18, height: 18,
                                decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              // Tap hint cursor when a symbol is active
              if (_activeSymbol != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF6B46C1).withOpacity(0.4), width: 2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

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
          // Mode toggle
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Edit'), icon: Icon(Icons.tune, size: 16)),
              ButtonSegment(value: true, label: Text('Annotate'), icon: Icon(Icons.edit_location_alt, size: 16)),
            ],
            selected: {_annotateMode},
            onSelectionChanged: (s) => setState(() { _annotateMode = s.first; _activeSymbol = null; }),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(width: 8),
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
            onPressed: () async {
              if (_annotateMode && _annotations.isNotEmpty) {
                final captured = await _captureAnnotatedImage();
                if (mounted) Navigator.pop(context, captured ?? _currentBytes);
              } else {
                Navigator.pop(context, _currentBytes);
              }
            },
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
              children: _annotateMode
                ? [_buildAnnotatePanel()]
                : [
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
              child: _annotateMode
                ? _buildAnnotateCanvas()
                : Center(
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
