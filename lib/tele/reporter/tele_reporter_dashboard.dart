import 'package:flutter/material.dart';
import '../../services/griva_api_service.dart';
import 'case_detail_screen.dart';

class TeleReporterDashboard extends StatefulWidget {
  const TeleReporterDashboard({super.key});

  @override
  State<TeleReporterDashboard> createState() => _TeleReporterDashboardState();
}

class _TeleReporterDashboardState extends State<TeleReporterDashboard>
    with SingleTickerProviderStateMixin {
  // ── Colours ───────────────────────────────────────────────────────────────
  static const _purple      = Color(0xFF6B46C1);
  static const _purpleLight = Color(0xFFF3EEFF);
  static const _border      = Color(0xFFE2D9F3);
  static const _textDark    = Color(0xFF1A1035);
  static const _textMid     = Color(0xFF6B7280);
  static const _bg          = Color(0xFFF8F5FF);

  // ── State ─────────────────────────────────────────────────────────────────
  late TabController _tabs;
  bool   _isAvailable  = true;
  bool   _togglingAvail= false;
  bool   _loadingMe    = true;

  List<GrivaCase> _activeCases    = [];
  List<GrivaCase> _completedCases = [];
  bool   _loadingCases = true;
  String? _casesError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadInitial();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  Future<void> _loadInitial() async {
    await Future.wait([_loadMe(), _loadCases()]);
  }

  Future<void> _loadMe() async {
    setState(() => _loadingMe = true);
    try {
      final me = await GrivaApiService.instance.getMe();
      setState(() {
        _isAvailable = (me['isAvailable'] as bool?) ?? true;
        _loadingMe   = false;
      });
    } catch (_) {
      setState(() => _loadingMe = false);
    }
  }

  Future<void> _loadCases() async {
    setState(() { _loadingCases = true; _casesError = null; });
    try {
      final all = await GrivaApiService.instance.listCases();
      setState(() {
        _activeCases    = all.where((c) => c.status != 'completed').toList();
        _completedCases = all.where((c) => c.status == 'completed').toList();
        _loadingCases   = false;
      });
    } catch (e) {
      setState(() { _casesError = e.toString(); _loadingCases = false; });
    }
  }

  Future<void> _toggleAvailability() async {
    setState(() => _togglingAvail = true);
    try {
      final next = !_isAvailable;
      await GrivaApiService.instance.setAvailability(next);
      setState(() => _isAvailable = next);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _togglingAvail = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation      : 0,
        title          : const Text('Tele Reporter',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          // Availability toggle
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _togglingAvail || _loadingMe
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: _purple, strokeWidth: 2))
                : GestureDetector(
                    onTap: _toggleAvailability,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color       : _isAvailable ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                        border      : Border.all(
                          color: _isAvailable ? const Color(0xFF16A34A) : const Color(0xFFD1D5DB),
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 7, height: 7,
                          decoration: BoxDecoration(
                            color: _isAvailable ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isAvailable ? 'Available' : 'Offline',
                          style: TextStyle(
                            color     : _isAvailable ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
                            fontSize  : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),
                    ),
                  ),
          ),
          IconButton(
            icon    : const Icon(Icons.refresh_rounded),
            onPressed: _loadCases,
            color   : _purple,
          ),
        ],
        bottom: TabBar(
          controller : _tabs,
          labelColor : _purple,
          unselectedLabelColor: _textMid,
          indicatorColor: _purple,
          indicatorWeight: 3,
          labelStyle : const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: 'Active (${_activeCases.length})'),
            Tab(text: 'Completed (${_completedCases.length})'),
          ],
        ),
      ),
      body: _loadingCases
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : _casesError != null
              ? _buildError()
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _buildCaseList(_activeCases, emptyMsg: 'No active cases assigned to you.'),
                    _buildCaseList(_completedCases, emptyMsg: 'No completed cases yet.'),
                  ],
                ),
    );
  }

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded, color: _purple, size: 48),
        const SizedBox(height: 16),
        Text('Could not load cases', style: const TextStyle(
            color: _textDark, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(_casesError!, style: const TextStyle(color: _textMid, fontSize: 13),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon     : const Icon(Icons.refresh_rounded, size: 16),
          label    : const Text('Retry'),
          onPressed: _loadCases,
          style    : ElevatedButton.styleFrom(
            backgroundColor: _purple, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ]),
    ),
  );

  Widget _buildCaseList(List<GrivaCase> cases, {required String emptyMsg}) {
    if (cases.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_rounded, color: _border, size: 56),
          const SizedBox(height: 12),
          Text(emptyMsg, style: const TextStyle(color: _textMid, fontSize: 14)),
        ]),
      );
    }

    return RefreshIndicator(
      color    : _purple,
      onRefresh: _loadCases,
      child: ListView.separated(
        padding        : const EdgeInsets.all(16),
        itemCount      : cases.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _CaseCard(
          teleCase: cases[i],
          onTap   : () async {
            final changed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => CaseDetailScreen(teleCase: cases[i]),
              ),
            );
            if (changed == true) _loadCases();
          },
        ),
      ),
    );
  }
}

// ── Case card ─────────────────────────────────────────────────────────────────

class _CaseCard extends StatelessWidget {
  final GrivaCase teleCase;
  final VoidCallback onTap;

  const _CaseCard({required this.teleCase, required this.onTap});

  static const _purple      = Color(0xFF6B46C1);
  static const _purpleLight = Color(0xFFF3EEFF);
  static const _border      = Color(0xFFE2D9F3);
  static const _textDark    = Color(0xFF1A1035);
  static const _textMid     = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final files    = teleCase.files;
    final imgFiles = files.where((f) => f.type.startsWith('image/')).toList();
    final vidCount = files.where((f) => f.type.startsWith('video/')).length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color       : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border      : Border.all(color: _border),
          boxShadow   : [BoxShadow(color: const Color(0xFF6B46C1).withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(children: [
                Container(
                  padding    : const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration : BoxDecoration(
                    color        : teleCase.statusColor.withOpacity(0.12),
                    borderRadius : BorderRadius.circular(20),
                  ),
                  child: Text(teleCase.statusLabel,
                      style: TextStyle(
                          color: teleCase.statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  teleCase.id.substring(0, 8).toUpperCase(),
                  style: const TextStyle(color: _textMid, fontSize: 11, fontFamily: 'monospace'),
                )),
                Text(
                  _formatDate(teleCase.createdAt),
                  style: const TextStyle(color: _textMid, fontSize: 11),
                ),
              ]),
            ),

            // Notes preview
            if (teleCase.notes != null && teleCase.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Text(
                  teleCase.notes!,
                  maxLines : 2,
                  overflow : TextOverflow.ellipsis,
                  style    : const TextStyle(color: _textDark, fontSize: 13),
                ),
              ),

            // Thumbnail strip
            if (imgFiles.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection : Axis.horizontal,
                  padding         : const EdgeInsets.fromLTRB(14, 0, 14, 0),
                  itemCount       : imgFiles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imgFiles[i].url,
                      width    : 80,
                      height   : 80,
                      fit      : BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80, height: 80,
                        color: _purpleLight,
                        child: const Icon(Icons.broken_image_rounded, color: _purple),
                      ),
                    ),
                  ),
                ),
              ),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(children: [
                Icon(Icons.image_outlined, size: 14, color: _textMid),
                const SizedBox(width: 4),
                Text('${imgFiles.length} image${imgFiles.length != 1 ? 's' : ''}',
                    style: const TextStyle(color: _textMid, fontSize: 12)),
                if (vidCount > 0) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.videocam_outlined, size: 14, color: _textMid),
                  const SizedBox(width: 4),
                  Text('$vidCount video${vidCount != 1 ? 's' : ''}',
                      style: const TextStyle(color: _textMid, fontSize: 12)),
                ],
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: _purple, size: 20),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inHours < 1)    return '${diff.inMinutes}m ago';
    if (diff.inDays < 1)     return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
