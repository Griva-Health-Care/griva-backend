import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import '../custom_app_bar.dart';
import '../custom_drawer.dart';
import '../widgets/centralized_footer.dart';

class ImageComparisonScreen extends StatefulWidget {
  final List<Uint8List> images;
  final Uint8List? currentImage;

  const ImageComparisonScreen({
    super.key,
    required this.images,
    this.currentImage,
  });

  @override
  State<ImageComparisonScreen> createState() => _ImageComparisonScreenState();
}

class _ImageComparisonScreenState extends State<ImageComparisonScreen> {
  late List<Uint8List?> _comparisonImages;
  bool _isGridView = true; // Toggle between single, grid, and side-by-side view
  String? _selectedTag;
  int _selectedComparisonMode = 0; // 0: Grid, 1: Single, 2: Side-by-side
  
  // Medical imaging features
  bool _showGrid = false;
  bool _showRulers = false;
  
  // Tab selection state
  bool _isCurrentGalleryTab = true;
  
  // Zoom controllers for each image slot
  final List<GlobalKey<State<InteractiveViewer>>> _zoomKeys = List.generate(
    4, 
    (index) => GlobalKey<State<InteractiveViewer>>()
  );
  
  // Available tags for medical imaging
  final List<String> _availableTags = [
    'Erosion',
    'Tumor or gross neoplasm',
    'Leukoplakia',
    'Coarse punctation',
    'CIN1',
    'CIN2',
    'CIN3',
  ];
  
  // Image tags storage
  final Map<int, String> _imageTags = {};
  final Map<int, String> _imageCustomTags = {};

  @override
  void initState() {
    super.initState();
    _comparisonImages = List.filled(4, null);
    
    // Set the first image if available
    if (widget.images.isNotEmpty) {
      _comparisonImages[0] = widget.images.first;
    }
    
    // Set current image if provided
    if (widget.currentImage != null) {
      _comparisonImages[0] = widget.currentImage;
    }
  }

  void _addImageToSlot(int slotIndex) {
    if (slotIndex == 0) return; // Don't allow changing the first slot
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header with close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Image to Compare',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Tab selector
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTabButton(
                              title: 'Current Gallery Images',
                              isSelected: _isCurrentGalleryTab,
                              onTap: () {
                                setModalState(() {
                                  _isCurrentGalleryTab = true;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildTabButton(
                              title: 'Reference Images',
                              isSelected: !_isCurrentGalleryTab,
                              onTap: () {
                                setModalState(() {
                                  _isCurrentGalleryTab = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Image gallery content
                    Expanded(
                      child: _buildImageGallery(slotIndex),
                    ),
                    
                    // Action buttons
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Copy selected image to reference gallery
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copy to Ref functionality coming soon')),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy to Ref'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B46C1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? const Border(
                  bottom: BorderSide(
                    color: Color(0xFF6B46C1),
                    width: 2,
                  ),
                )
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(int slotIndex) {
    if (_isCurrentGalleryTab) {
      return _buildCurrentGalleryImages(slotIndex);
    } else {
      return _buildReferenceImages(slotIndex);
    }
  }

  Widget _buildCurrentGalleryImages(int slotIndex) {
    if (widget.images.isEmpty) {
      return const Center(
        child: Text(
          'No images available in current gallery',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.6,
      ),
      itemCount: widget.images.length,
      itemBuilder: (context, index) {
        final image = widget.images[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _comparisonImages[slotIndex] = image;
            });
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: Image.memory(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: Text(
                    'Cervix Image ${index + 1}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReferenceImages(int slotIndex) {
    // TODO: Implement reference images gallery
    // This will be populated from a separate reference images collection
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_search,
            color: Colors.grey,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Reference Images Gallery',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon!\n\nThis will contain a curated collection\nof reference images for comparison.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _removeImageFromSlot(int slotIndex) {
    if (slotIndex == 0) return; // Don't allow removing the first slot
    setState(() {
      _comparisonImages[slotIndex] = null;
    });
  }

  void _setComparisonMode(int mode) {
    setState(() {
      _selectedComparisonMode = mode;
      _isGridView = mode == 0;
    });
  }

  void _toggleGrid() {
    setState(() {
      _showGrid = !_showGrid;
    });
  }

  void _toggleRulers() {
    setState(() {
      _showRulers = !_showRulers;
    });
  }

  void _resetZoom() {
    // Reset zoom on all image slots
    for (int i = 0; i < _zoomKeys.length; i++) {
      final key = _zoomKeys[i];
      if (key.currentState != null) {
        // Force rebuild to reset zoom
        setState(() {});
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All zoom levels reset')),
    );
  }

  void _saveComparison() {
    // Save comparison data with tags
    final taggedImages = <Map<String, dynamic>>[];
    
    for (int i = 0; i < _comparisonImages.length; i++) {
      if (_comparisonImages[i] != null) {
        taggedImages.add({
          'slotIndex': i,
          'imageData': _comparisonImages[i],
          'tag': _imageTags[i],
          'customTag': _imageCustomTags[i],
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    }
    
    // TODO: Save to local storage or database
    print('Saving comparison with ${taggedImages.length} tagged images');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comparison saved with ${taggedImages.length} tagged images'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportComparison() {
    // TODO: Implement exporting comparison
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }
  
        void _tagImage(int slotIndex) {
     if (_comparisonImages[slotIndex] == null) return;
     
     // Show dropdown menu positioned below the tag button
     final RenderBox button = context.findRenderObject() as RenderBox;
     final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
     final RelativeRect position = RelativeRect.fromRect(
       Rect.fromPoints(
         button.localToGlobal(Offset.zero, ancestor: overlay),
         button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
       ),
       Offset.zero & overlay.size,
     );
     
     showMenu(
       context: context,
       position: position,
       items: [
         // Tag selection items
         ..._availableTags.map((tag) => PopupMenuItem<String>(
           value: tag,
           child: Row(
             children: [
               Icon(
                 Icons.label,
                 color: const Color(0xFF6B46C1),
                 size: 18,
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: Text(
                   tag,
                   style: const TextStyle(
                     fontSize: 14,
                     fontWeight: FontWeight.w500,
                   ),
                 ),
               ),
               if (_imageTags[slotIndex] == tag)
                 Icon(
                   Icons.check_circle,
                   color: const Color(0xFF6B46C1),
                   size: 18,
                 ),
             ],
           ),
         )),
         
         // Divider
         const PopupMenuItem<String>(
           enabled: false,
           child: Divider(height: 1),
         ),
         
         // Custom tag option
         PopupMenuItem<String>(
           value: 'custom',
           child: Row(
             children: [
               Icon(
                 Icons.edit,
                 color: const Color(0xFF6B46C1),
                 size: 18,
               ),
               const SizedBox(width: 12),
               const Text(
                 'Custom Tag',
                 style: TextStyle(
                   fontSize: 14,
                   fontWeight: FontWeight.w500,
                 ),
               ),
             ],
           ),
         ),
         
         // Remove tag option (only if tag exists)
         if (_imageTags.containsKey(slotIndex))
           PopupMenuItem<String>(
             value: 'remove',
             child: Row(
               children: [
                 Icon(
                   Icons.remove_circle_outline,
                   color: Colors.red[600],
                   size: 18,
                 ),
                 const SizedBox(width: 12),
                 Text(
                   'Remove Tag',
                   style: TextStyle(
                     fontSize: 14,
                     fontWeight: FontWeight.w500,
                     color: Colors.red[600],
                   ),
                 ),
               ],
             ),
           ),
       ],
     ).then((selectedValue) {
       if (selectedValue == null) return;
       
       if (selectedValue == 'custom') {
         _showCustomTagDialog(slotIndex);
       } else if (selectedValue == 'remove') {
         setState(() {
           _imageTags.remove(slotIndex);
           _imageCustomTags.remove(slotIndex);
         });
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Tag removed')),
         );
       } else {
         setState(() {
           _imageTags[slotIndex] = selectedValue;
         });
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Tagged as: $selectedValue')),
         );
       }
     });
   }
   
   void _showCustomTagDialog(int slotIndex) {
     String customTag = _imageCustomTags[slotIndex] ?? '';
     
     showDialog(
       context: context,
       builder: (context) {
         return AlertDialog(
           title: const Text('Add Custom Tag'),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextFormField(
                 initialValue: customTag,
                 decoration: const InputDecoration(
                   labelText: 'Custom Tag',
                   border: OutlineInputBorder(),
                   hintText: 'Enter your custom tag',
                 ),
                 onChanged: (value) {
                   customTag = value;
                 },
               ),
             ],
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text('Cancel'),
             ),
             ElevatedButton(
               onPressed: () {
                 if (customTag.trim().isNotEmpty) {
                   setState(() {
                     _imageCustomTags[slotIndex] = customTag.trim();
                   });
                   Navigator.pop(context);
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Custom tag added: $customTag')),
                   );
                 }
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: const Color(0xFF6B46C1),
                 foregroundColor: Colors.white,
               ),
               child: const Text('Add Tag'),
             ),
           ],
         );
       },
     );
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
        userEmail: null,
        title: null,
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Compare Images',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 20),
                
                // View mode toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _setComparisonMode(0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedComparisonMode == 0 ? const Color(0xFF6B46C1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.grid_view,
                            color: _selectedComparisonMode == 0 ? Colors.white : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _setComparisonMode(1),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedComparisonMode == 1 ? const Color(0xFF6B46C1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.crop_square,
                            color: _selectedComparisonMode == 1 ? Colors.white : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _setComparisonMode(2),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedComparisonMode == 2 ? const Color(0xFF6B46C1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.compare_arrows,
                            color: _selectedComparisonMode == 2 ? Colors.white : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Medical imaging tools
                if (_selectedComparisonMode == 1 || _selectedComparisonMode == 2) ...[
                  IconButton(
                    onPressed: _toggleGrid,
                    icon: Icon(
                      _showGrid ? Icons.grid_on : Icons.grid_off,
                      color: _showGrid ? const Color(0xFF6B46C1) : Colors.grey[600],
                    ),
                    tooltip: 'Toggle Grid',
                  ),
                  IconButton(
                    onPressed: _toggleRulers,
                    icon: Icon(
                      _showRulers ? Icons.straighten : Icons.straighten_outlined,
                      color: _showRulers ? const Color(0xFF6B46C1) : Colors.grey[600],
                    ),
                    tooltip: 'Toggle Rulers',
                  ),
                  const SizedBox(width: 8),
                ],
                
                // Zoom controls for all modes
                IconButton(
                  onPressed: _resetZoom,
                  icon: Icon(Icons.zoom_out, color: Colors.grey[600]),
                  tooltip: 'Reset All Zoom',
                ),
                const SizedBox(width: 8),
                
                // Back button
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('← Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // Main comparison area
          Expanded(
            child: _buildComparisonArea(),
          ),



                     // Centralized footer
           const CentralizedFooter(),
        ],
      ),
    );
  }

  Widget _buildComparisonArea() {
    switch (_selectedComparisonMode) {
      case 0:
        return _buildGridView();
      case 1:
        return _buildSingleView();
      case 2:
        return _buildSideBySideView();
      default:
        return _buildGridView();
    }
  }

  Widget _buildGridView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top row
          Expanded(
            child: Row(
              children: [
                // Top-left: Current image
                Expanded(
                  child: _buildImageSlot(0, 'Current', true),
                ),
                const SizedBox(width: 16),
                // Top-right: Add image slot
                Expanded(
                  child: _buildImageSlot(1, 'Add Image to Compare', false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Bottom row
          Expanded(
            child: Row(
              children: [
                // Bottom-left: Add image slot
                Expanded(
                  child: _buildImageSlot(2, 'Add Image to Compare', false),
                ),
                const SizedBox(width: 16),
                // Bottom-right: Add image slot
                Expanded(
                  child: _buildImageSlot(3, 'Add Image to Compare', false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleView() {
    if (_comparisonImages[0] == null) {
      return const Center(
        child: Text(
          'No image selected for comparison',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Image with zoom capability - centered and no background container
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Stack(
                children: [
                  Center(
                    child: Image.memory(
                      _comparisonImages[0]!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Grid overlay that scales with zoom
                  if (_showGrid) 
                    Positioned.fill(
                      child: _buildGridOverlay(),
                    ),
                ],
              ),
            ),
            // Static rulers that don't scale with zoom
            if (_showRulers) _buildStaticRulers(),
          ],
        ),
      ),
    );
  }

  Widget _buildSideBySideView() {
    final hasFirstImage = _comparisonImages[0] != null;
    final hasSecondImage = _comparisonImages[1] != null;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left image
          Expanded(
            child: hasFirstImage
              ? _buildImageSlot(0, 'Current', true)
              : _buildImageSlot(0, 'Add Image to Compare', false),
          ),
          const SizedBox(width: 16),
          // Right image
          Expanded(
            child: hasSecondImage
              ? _buildImageSlot(1, 'Comparison', false)
              : _buildImageSlot(1, 'Add Image to Compare', false),
          ),
        ],
      ),
    );
  }

  Widget _buildGridOverlay() {
    return CustomPaint(
      painter: GridPainter(),
      child: Container(),
    );
  }

  Widget _buildRulersOverlay() {
    return CustomPaint(
      painter: RulersPainter(),
      child: Container(),
    );
  }

  Widget _buildStaticRulers() {
    return Positioned.fill(
      child: CustomPaint(
        painter: StaticRulersPainter(),
        child: Container(),
      ),
    );
  }

    Widget _buildImageSlot(int slotIndex, String label, bool isCurrent) {
    final hasImage = _comparisonImages[slotIndex] != null;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: hasImage ? const Color(0xFF6B46C1) : Colors.grey[300]!,
          width: hasImage ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: hasImage ? [
          BoxShadow(
            color: const Color(0xFF6B46C1).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (hasImage)
              // Display image with zoom capability
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(
                  _comparisonImages[slotIndex]!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            else
              // Add image placeholder
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate,
                        size: 32,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            
            // Current tag for first slot
            if (isCurrent && hasImage)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B46C1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            
            // Tag button for all images
            if (hasImage)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => _tagImage(slotIndex),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.label,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            
            // Remove button for non-current slots
            if (hasImage && !isCurrent)
              Positioned(
                top: 12,
                right: 60,
                child: GestureDetector(
                  onTap: () => _removeImageFromSlot(slotIndex),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            
            // Add button for empty slots
            if (!hasImage)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _addImageToSlot(slotIndex),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            
                         // Display current tags at the bottom
             if (hasImage && _imageTags.containsKey(slotIndex))
               Positioned(
                 bottom: 16,
                 left: 16,
                 right: 16,
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                       colors: [
                         const Color(0xFF6B46C1).withOpacity(0.95),
                         const Color(0xFF553C9A).withOpacity(0.95),
                       ],
                     ),
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(
                       color: Colors.white.withOpacity(0.3),
                       width: 1,
                     ),
                     boxShadow: [
                       BoxShadow(
                         color: const Color(0xFF6B46C1).withOpacity(0.4),
                         blurRadius: 12,
                         offset: const Offset(0, 4),
                         spreadRadius: 2,
                       ),
                     ],
                   ),
                   child: Row(
                     children: [
                       Container(
                         padding: const EdgeInsets.all(6),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.2),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Icon(
                           Icons.label,
                           color: Colors.white,
                           size: 16,
                         ),
                       ),
                       const SizedBox(width: 10),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Text(
                               _imageTags[slotIndex]!,
                               style: const TextStyle(
                                 color: Colors.white,
                                 fontSize: 13,
                                 fontWeight: FontWeight.w600,
                                 letterSpacing: 0.5,
                               ),
                             ),
                             if (_imageCustomTags.containsKey(slotIndex) && 
                                 _imageCustomTags[slotIndex]!.isNotEmpty)
                               Text(
                                 _imageCustomTags[slotIndex]!,
                                 style: TextStyle(
                                   color: Colors.white.withOpacity(0.9),
                                   fontSize: 11,
                                   fontStyle: FontStyle.italic,
                                   letterSpacing: 0.3,
                                 ),
                               ),
                           ],
                         ),
                       ),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.2),
                           borderRadius: BorderRadius.circular(12),
                         ),
                         child: Text(
                           'Tagged',
                           style: TextStyle(
                             color: Colors.white.withOpacity(0.9),
                             fontSize: 10,
                             fontWeight: FontWeight.w500,
                           ),
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for grid overlay
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.0;

    // Vertical lines
    for (int i = 0; i <= 10; i++) {
      final x = (size.width / 10) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (int i = 0; i <= 10; i++) {
      final y = (size.height / 10) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for rulers overlay
class RulersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2.0;

    // Top ruler
    canvas.drawLine(Offset(0, 20), Offset(size.width, 20), paint);
    // Left ruler
    canvas.drawLine(Offset(20, 0), Offset(20, size.height), paint);

    // Ruler markings
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Top ruler markings
    for (int i = 0; i <= 10; i++) {
      final x = (size.width / 10) * i;
      canvas.drawLine(Offset(x, 15), Offset(x, 25), paint);
      
      textPainter.text = TextSpan(
        text: '${(i * 10).toInt()}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 5, 5));
    }

    // Left ruler markings
    for (int i = 0; i <= 10; i++) {
      final y = (size.height / 10) * i;
      canvas.drawLine(Offset(15, y), Offset(25, y), paint);
      
      textPainter.text = TextSpan(
        text: '${(i * 10).toInt()}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - 5));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for static rulers that don't scale with zoom
class StaticRulersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2.0;

    // Top ruler line (horizontal)
    canvas.drawLine(Offset(0, 25), Offset(size.width, 25), paint);
    // Left ruler line (vertical)
    canvas.drawLine(Offset(25, 0), Offset(25, size.height), paint);

    // Ruler markings and numbers
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Top ruler markings (horizontal)
    for (int i = 0; i <= 10; i++) {
      final x = size.width / 10 * i;
      // Draw tick mark
      canvas.drawLine(Offset(x, 20), Offset(x, 30), paint);
      
      // Draw number
      textPainter.text = TextSpan(
        text: '${i * 10}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 3,
            ),
          ],
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, 2));
    }

    // Left ruler markings (vertical)
    for (int i = 0; i <= 10; i++) {
      final y = size.height / 10 * i;
      // Draw tick mark
      canvas.drawLine(Offset(20, y), Offset(30, y), paint);
      
      // Draw number
      textPainter.text = TextSpan(
        text: '${i * 10}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 3,
            ),
          ],
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
