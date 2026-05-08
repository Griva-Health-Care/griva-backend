import 'package:flutter/material.dart';

class _LibraryEntry {
  final String name;
  final String definition;
  final String details;
  final IconData icon;
  final Color color;
  final List<String> imagePaths;

  const _LibraryEntry({
    required this.name,
    required this.definition,
    required this.details,
    required this.icon,
    required this.color,
    this.imagePaths = const [],
  });
}

const List<_LibraryEntry> _kEntries = [
  _LibraryEntry(
    name: 'Necrosis or Ulceration',
    definition: 'Death of cervical tissue resulting in ulcerative breakdown of the epithelial surface.',
    details:
        'Necrosis refers to localised death of cervical tissue, often appearing as grey or yellow slough on the cervix. Ulceration is the erosive breakdown of epithelium exposing the underlying stroma, which may bleed on contact. Both findings can be associated with invasive carcinoma, severe infection (e.g. herpes, syphilis), or post-treatment changes. Contact bleeding and purulent discharge are common clinical features. Biopsy is mandatory to exclude malignancy.',
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFB71C1C),
    imagePaths: ['assets/images/necrosis.png'],
  ),
  _LibraryEntry(
    name: 'Erosion',
    definition: 'Loss of surface epithelium on the cervix, exposing the underlying stroma.',
    details:
        'True erosion (ulceration) represents focal or diffuse loss of the squamous or columnar epithelium. On colposcopy, it appears as a raw, red, and often bleeding area. It must be distinguished from ectropion (columnar ectopy), which is a normal variant. Causes include trauma, infection, or malignancy. Any suspicious erosion should be biopsied to exclude CIN or invasive disease.',
    icon: Icons.circle_outlined,
    color: Color(0xFFE53935),
    imagePaths: ['assets/images/erosion.png'],
  ),
  _LibraryEntry(
    name: 'Tumour or Gross Neoplasm',
    definition: 'A visible macroscopic tumour or growth on the cervix indicating possible invasive malignancy.',
    details:
        'A gross neoplasm is a clinically visible tumour on the cervix, which may appear as an exophytic (cauliflower-like), endophytic (ulcerating), or mixed lesion. It represents advanced cervical disease and is highly suspicious for invasive squamous cell carcinoma or adenocarcinoma. Colposcopy may reveal atypical vessels, irregular surface contour, and friable tissue with contact bleeding. Biopsy is mandatory for histological diagnosis and staging.',
    icon: Icons.biotech_outlined,
    color: Color(0xFF4A148C),
    imagePaths: ['assets/images/Tumor.jpg'],
  ),
  _LibraryEntry(
    name: 'Leukoplakia',
    definition: 'A white plaque on the cervix visible before application of acetic acid.',
    details:
        'Leukoplakia appears as a raised white patch on the cervix before acetic acid is applied, caused by abnormal keratinisation (hyperkeratosis) of the epithelium. It can obscure the underlying transformation zone. It may be associated with HPV infection, CIN, or rarely invasive carcinoma. Because acetic acid cannot penetrate the keratin layer, colposcopic assessment is incomplete, and directed biopsy is recommended to exclude high-grade disease beneath.',
    icon: Icons.brightness_high_outlined,
    color: Color(0xFF6D4C41),
    imagePaths: ['assets/images/leukoplakia.png'],
  ),
  _LibraryEntry(
    name: 'Coarse Punctation',
    definition: 'An abnormal vascular pattern with widely spaced, irregular red dots within acetowhite epithelium.',
    details:
        'Punctation describes capillary loops seen end-on within the transformation zone. Fine punctation is often associated with low-grade lesions (CIN 1), while coarse punctation — with wider intercapillary distances, greater variation in vessel calibre, and irregular spacing — is a colposcopic feature suggestive of high-grade CIN (CIN 2/3) or early invasive carcinoma. Coarse punctation is an indication for directed biopsy.',
    icon: Icons.grid_4x4,
    color: Color(0xFFAD1457),
    imagePaths: ['assets/images/coarse_punctuation.png'],
  ),
  _LibraryEntry(
    name: 'CIN 1',
    definition: 'Cervical Intraepithelial Neoplasia Grade 1 — mild dysplasia confined to the lower third of the epithelium.',
    details:
        'CIN 1 represents low-grade squamous intraepithelial lesion (LSIL). Dysplastic cells are limited to the lower one-third of the cervical epithelium with a preserved upper two-thirds. On colposcopy, it may appear as faint acetowhite epithelium with fine mosaic or fine punctation. Most CIN 1 lesions regress spontaneously (approximately 60%) and are caused by transient HPV infection. Management is typically observation with repeat cytology/HPV testing rather than immediate treatment.',
    icon: Icons.looks_one_outlined,
    color: Color(0xFF1565C0),
    imagePaths: [
      'assets/images/cin1_1.jpg',
      'assets/images/cin1_2.jpg',
      'assets/images/cin1_3.jpg',
      'assets/images/cin1_4.jpg',
    ],
  ),
  _LibraryEntry(
    name: 'CIN 2',
    definition: 'Cervical Intraepithelial Neoplasia Grade 2 — moderate dysplasia involving the lower two-thirds of the epithelium.',
    details:
        'CIN 2 is classified as a high-grade squamous intraepithelial lesion (HSIL) in current terminology. Abnormal cells extend through the lower two-thirds of the cervical epithelium. Colposcopic features include dense acetowhite epithelium, coarse mosaic, and/or coarse punctation. CIN 2 has a significant risk of progression to CIN 3 or invasive carcinoma if untreated. Treatment (LLETZ/LEEP, cryotherapy, or cold coagulation) is generally recommended, particularly in women over 25.',
    icon: Icons.looks_two_outlined,
    color: Color(0xFF6A1B9A),
    imagePaths: [
      'assets/images/cin2_1.jpg',
      'assets/images/cin2_2.jpg',
      'assets/images/cin2_3.jpg',
    ],
  ),
  _LibraryEntry(
    name: 'CIN 3',
    definition: 'Cervical Intraepithelial Neoplasia Grade 3 — severe dysplasia/carcinoma in situ involving the full thickness of the epithelium.',
    details:
        'CIN 3 (including carcinoma in situ) is the most advanced pre-invasive lesion where full-thickness epithelial dysplasia is present without basement membrane invasion. Colposcopic features include thick, oyster-white or dense acetowhite epithelium, atypical vessels, coarse mosaic, coarse punctation, and irregular surface contour. CIN 3 carries the highest risk of progression to invasive squamous cell carcinoma. Excisional treatment (LLETZ/LEEP or cold knife conisation) is mandatory. Post-treatment surveillance with cytology and HPV testing is essential.',
    icon: Icons.looks_3_outlined,
    color: Color(0xFF880E4F),
    imagePaths: [
      'assets/images/cin3_1.jpg',
      'assets/images/cin3_2.jpg',
      'assets/images/cin3_3.jpg',
    ],
  ),
];

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedIndex = 0;
  int _imagePageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectEntry(int i) {
    setState(() {
      _selectedIndex = i;
      _imagePageIndex = 0;
    });
    _pageController.jumpToPage(0);
  }

  Widget _buildImagePlaceholder(_LibraryEntry entry) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(entry.icon, size: 56, color: entry.color),
        const SizedBox(height: 10),
        Text(
          'Reference Picture',
          style: TextStyle(color: entry.color, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          entry.name,
          style: TextStyle(color: entry.color.withOpacity(0.7), fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImageGallery(_LibraryEntry entry) {
    // Filter to paths that are non-empty; missing files show placeholder via errorBuilder
    final paths = entry.imagePaths.where((p) => p.isNotEmpty).toList();

    if (paths.isEmpty) {
      return _buildFrame(entry, child: _buildImagePlaceholder(entry));
    }

    return Column(
      children: [
        _buildFrame(
          entry,
          child: paths.length == 1
              ? Image.asset(
                  paths[0],
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(entry),
                )
              : PageView.builder(
                  controller: _pageController,
                  itemCount: paths.length,
                  onPageChanged: (i) => setState(() => _imagePageIndex = i),
                  itemBuilder: (_, i) => Image.asset(
                    paths[i],
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(entry),
                  ),
                ),
        ),
        if (paths.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(paths.length, (i) {
              final isActive = i == _imagePageIndex;
              return GestureDetector(
                onTap: () => _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? entry.color : entry.color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            '${_imagePageIndex + 1} / ${paths.length}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ],
    );
  }

  Widget _buildFrame(_LibraryEntry entry, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: entry.color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: entry.color.withOpacity(0.25)),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _kEntries[_selectedIndex];
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        title: const Text(
          'Colposcopy Library',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Row(
        children: [
          // ── Left: diagnosis list ────────────────────────────────────────
          Container(
            width: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  color: const Color(0xFF6B46C1),
                  child: const Text(
                    'Diagnosis Master',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _kEntries.length,
                    itemBuilder: (context, i) {
                      final isSelected = i == _selectedIndex;
                      return GestureDetector(
                        onTap: () => _selectEntry(i),
                        child: Container(
                          color: isSelected ? const Color(0xFF6B46C1) : Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                          child: Text(
                            _kEntries[i].name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Right: detail panel ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(selected),
                  const SizedBox(height: 20),

                  Text(
                    selected.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected.color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: selected.color.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: selected.color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selected.definition,
                            style: TextStyle(fontSize: 13, color: Colors.grey[800], fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Explanation',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selected.details,
                    style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.65),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
