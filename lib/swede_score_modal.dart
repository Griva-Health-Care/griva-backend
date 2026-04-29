import 'package:flutter/material.dart';
import 'ui_constants.dart';
import 'data_swede_score.dart';
import 'feature_row.dart';

class SwedeScoreModal extends StatefulWidget {
  const SwedeScoreModal({super.key});

  @override
  State<SwedeScoreModal> createState() => _SwedeScoreModalState();
}

class _SwedeScoreModalState extends State<SwedeScoreModal> {
  final Map<String, bool> _checks = {};

  int get _reidScore {
    // Sum points per feature: any 1-point tick adds 1; any 2-point tick adds 2 (cap once per column)
    final Map<String, Set<int>> featureToPoints = {};

    _checks.forEach((key, isChecked) {
      if (!isChecked) return;
      final parts = key.split('|'); // [featureId, '1pt#i']
      if (parts.length < 2) return;
      final featureId = parts[0];
      final colPart = parts[1];
      final match = RegExp(r'(\d)pt').firstMatch(colPart);
      if (match == null) return;
      final points = int.parse(match.group(1)!);
      featureToPoints.putIfAbsent(featureId, () => <int>{}).add(points);
    });

    int total = 0;
    for (final selectedPoints in featureToPoints.values) {
      if (selectedPoints.contains(1)) total += 1;
      if (selectedPoints.contains(2)) total += 2;
      // 0-point selections do not contribute
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F6FD),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Swede Score',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5A2EA6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rate each parameter to calculate the total score',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
            ),
            // Fixed Images Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) => _ImageThumbnail(index: index)),
              ),
            ),
            // Fixed Table Header (inset to match table margins)
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  decoration: const BoxDecoration(
                    color: kBrandPurple,
                    border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
                  ),
                  child: Table(
                border: const TableBorder(
                  verticalInside: BorderSide(color: Colors.white30, width: 1),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(1.0),
                  2: FlexColumnWidth(1.0),
                  3: FlexColumnWidth(1.0),
                },
                children: [
                  TableRow(
                    children: [
                      _HeaderCell('Feature', Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                      _HeaderCell('0 points', Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                      _HeaderCell('1 point', Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                      _HeaderCell('2 points', Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                    ],
                  ),
                ],
                  ),
                ),
              ),
            ),
            // Scrollable Table Rows
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: _DiagnosisTable(
                  checks: _checks,
                  onToggle: (id, value) => setState(() => _checks[id] = value),
                ),
              ),
            ),
            // Bottom Right Score and Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F6FD),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Doctor's Score
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Doctor\'s Score: ',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _reidScore.toString(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5A2EA6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Buttons
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(_reidScore);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A2EA6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Save Score'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final int index;
  const _ImageThumbnail({required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageModal(context),
      child: Container(
        width: 150,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _getColposcopeImage(),
      ),
    );
  }

  Widget _getColposcopeImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/images/colposcope_reference.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  void _showImageModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Backdrop
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // Image only
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/colposcope_reference.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 40,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 32,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosisTable extends StatelessWidget {
  final Map<String, bool> checks;
  final void Function(String id, bool value) onToggle;
  const _DiagnosisTable({required this.checks, required this.onToggle});

  List<FeatureRow> _rows() => kSwedeFeatures;

  @override
  Widget build(BuildContext context) {
    final table = Table(
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(1.0),
        2: FlexColumnWidth(1.0),
        3: FlexColumnWidth(1.0),
      },
      border: kTableBorder,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Data rows only (header is fixed above)
        for (final row in _rows())
          _featureRow(
            context: context,
            title: row.title,
            col0: row.col0,
            col1: row.col1,
            col2: row.col2,
            idPrefix: row.id,
          ),
      ],
    );

    return SingleChildScrollView(
      child: table,
    );
  }

  TableRow _featureRow({
    required BuildContext context,
    required String title,
    required List<String> col0,
    required List<String> col1,
    required List<String> col2,
    required String idPrefix,
  }) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Align(
            alignment: Alignment.topLeft,
            child: _TitleCell(title),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Align(
            alignment: Alignment.topLeft,
            child: _CheckListCell(
              items: col0,
              idPrefix: '$idPrefix|0pt',
              checks: checks,
              onToggle: onToggle,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Align(
            alignment: Alignment.topLeft,
            child: _CheckListCell(
              items: col1,
              idPrefix: '$idPrefix|1pt',
              checks: checks,
              onToggle: onToggle,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Align(
            alignment: Alignment.topLeft,
            child: _CheckListCell(
              items: col2,
              idPrefix: '$idPrefix|2pt',
              checks: checks,
              onToggle: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const _HeaderCell(this.text, this.style);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: kHeaderPaddingH, vertical: kHeaderPaddingV),
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TitleCell extends StatelessWidget {
  final String text;
  const _TitleCell(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kFeatureCellPaddingH, vertical: kFeatureCellPaddingV),
      alignment: Alignment.topLeft,
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CheckListCell extends StatelessWidget {
  final List<String> items;
  final String idPrefix;
  final Map<String, bool> checks;
  final void Function(String id, bool value) onToggle;
  const _CheckListCell({
    required this.items,
    required this.idPrefix,
    required this.checks,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _CheckItem(
              id: '$idPrefix#$i',
              label: items[i],
              value: checks['$idPrefix#$i'] ?? false,
              onChanged: (v) => onToggle('$idPrefix#$i', v ?? false),
            ),
            if (i < items.length - 1) const SizedBox(height: kChecklistRowGap),
          ],
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String id;
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _CheckItem({
    required this.id,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14);

    return Row(
      key: ValueKey(id),
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          height: kCheckboxGlyph,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
            ),
          ),
        ),
        const SizedBox(width: kCheckboxToLabelGap),
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              label,
              textAlign: TextAlign.left,
              style: baseStyle.copyWith(height: kLabelLineHeight),
            ),
          ),
        ),
      ],
    );
  }
}


// Data now imported from data_swede_score.dart
