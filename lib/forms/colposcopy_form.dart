import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import '../swede_score_modal.dart';
import '../gallery_screen.dart';
import '../ui_constants.dart';

// Top-level enums (Dart requires enums at file scope)
enum Sedation { none, topical, other }
enum CervixVisibility { fully, partially, notVisible }
enum ZoneMargins { type1, type2, type3 }
enum Suspicion { low, high, invasive, inflammation, normal }
enum CervicalFinding { normal, erythema, nabothianCysts, polyps, leukoplakia, atrophy, ectopy, suspicious }
enum VascularPattern { finePunctation, coarsePunctation, mosaicPattern, atypicalVessels, none }
enum ImmediateComplication { bleeding, pain, none, other }
const double _qGap = 12.0; // uniform gap between questions
const int _kMaxImages = 5; // image limit

class ColposcopyForm extends StatefulWidget {
  final String? initialPatientName;
  final String? initialPatientId;
  final DateTime? initialDob;
  final DateTime? initialVisitDate;
  final String? initialFindingsSummary;
  final List<Uint8List>? initialImages;
  final ValueChanged<List<Uint8List>>? onImagesChanged;
  final ValueChanged<String>? onChiefComplaintChanged;
  final ValueChanged<String>? onFindingsChanged;
  final ValueChanged<String>? onFinalImpressionChanged;
  final ValueChanged<String>? onRemarksChanged;
  /// When false the image preview strip is not rendered (parent owns it).
  final bool showImagePreview;
  /// Called when the user taps "Preview Report" — parent should generate+open the PDF.
  final VoidCallback? onPreviewReport;
  const ColposcopyForm({super.key, this.initialPatientName, this.initialPatientId, this.initialDob, this.initialVisitDate, this.initialFindingsSummary, this.initialImages, this.onImagesChanged, this.onChiefComplaintChanged, this.onFindingsChanged, this.onFinalImpressionChanged, this.onRemarksChanged, this.showImagePreview = true, this.onPreviewReport});

  @override
  State<ColposcopyForm> createState() => _ColposcopyFormState();
}

class _ColposcopyFormState extends State<ColposcopyForm> {
  // Images shown in the fixed preview row
  final List<ImageProvider> _images = <ImageProvider>[];
  // Keep the raw bytes in sync so parent can receive accurate selection
  List<Uint8List> _currentImagesBytes = <Uint8List>[];

  // Form state
  final TextEditingController _patientNameCtrl = TextEditingController(text: '');
  final TextEditingController _patientIdCtrl = TextEditingController(text: '');
  DateTime? _dob;
  DateTime? _visitDate;

  bool _indPapSmear = false;
  bool _indHpv = false;
  bool _indPostcoital = false;
  bool _indSuspicious = false;
  bool _indFollowUp = false;
  bool _indOther = false;
  final TextEditingController _otherCtrl = TextEditingController();

  // New sections state
  bool? _consentYes; // 2.1
  bool? _allergiesYes; // 2.2
  final TextEditingController _allergiesText = TextEditingController();
  bool? _supportYes; // 2.3

  Sedation _sedation = Sedation.none; // 2.4
  final TextEditingController _sedationOther = TextEditingController();

  CervixVisibility? _cervixVisibility; // 3.1

  // 3.2 cervical findings (multi)
  final bool _cfNormal = false;
  final bool _cfErythema = false;
  final bool _cfNabothian = false;
  final bool _cfPolyps = false;
  final bool _cfLeukoplakia = false;
  final bool _cfAtrophy = false;
  final bool _cfEctopy = false;
  final bool _cfSuspicious = false;
  final TextEditingController _cfSuspiciousText = TextEditingController();
  CervicalFinding? _cervicalFinding; // radio for 3.2

  bool? _aceticUsed; // 3.3
  bool? _awYes; // 3.4
  final TextEditingController _awLocations = TextEditingController();

  ZoneMargins? _zoneMargins; // 3.5

  // 3.6 vascular patterns
  final bool _vpFine = false;
  final bool _vpCoarse = false;
  final bool _vpMosaic = false;
  final bool _vpAtypical = false;
  final bool _vpNone = false;
  VascularPattern? _vascularPattern; // radio for 3.6

  bool? _lugolsYes; // 3.7
  bool? _iodineNegYes; // 3.8
  final TextEditingController _iodineLocations = TextEditingController();

  Suspicion? _suspicion; // 3.9

  bool? _biopsiesYes; // 3.10
  final TextEditingController _biopsiesSites = TextEditingController();

  bool? _eccYes; // 3.11

  bool? _specimensYes; // 3.12
  final TextEditingController _specimensType = TextEditingController();

  int? _savedScore; // for 4.1 display
  late final TextEditingController _savedScoreCtrl;

  // Section 5 & 6 additions
  final TextEditingController _findingsSummaryCtrl = TextEditingController(); // 5
  ImmediateComplication? _immediateComplication; // 6.1
  final TextEditingController _immediateOtherCtrl = TextEditingController();

  bool _fuAwaitResults = false; // 6.2
  bool _fuRepeatPap = false;
  bool _fuEducation = false;
  bool _fuRoutine = false;
  bool _fuReferral = false;
  bool _fuTreatment = false;
  bool _fuOther = false;
  final TextEditingController _fuTreatmentSpecifyCtrl = TextEditingController();
  final TextEditingController _fuOtherSpecifyCtrl = TextEditingController();

  bool? _advisedYes; // 6.3

  final ScrollController _reportScrollCtrl = ScrollController();
  bool _imageValidationError = false;
  OverlayEntry? _toastEntry;
  @override
  void initState() {
    super.initState();
    _savedScoreCtrl = TextEditingController(text: _savedScore?.toString() ?? '');
    // Emit chief complaint when 'Other' text changes
    _otherCtrl.addListener(_emitChiefComplaintFromIndications);
    // Emit remarks when findings summary changes
    _findingsSummaryCtrl.addListener(_emitRemarksSummary);
    // Prefill from provided initial values
    if (widget.initialPatientName != null) {
      _patientNameCtrl.text = widget.initialPatientName!;
    }
    if (widget.initialPatientId != null) {
      _patientIdCtrl.text = widget.initialPatientId!;
    }
    if (widget.initialDob != null) {
      _dob = widget.initialDob;
    }
    if (widget.initialVisitDate != null) {
      _visitDate = widget.initialVisitDate;
    }
    if (widget.initialFindingsSummary != null) {
      _findingsSummaryCtrl.text = widget.initialFindingsSummary!;
    }
    // Load initial images (selected by user) into preview row
    if (widget.initialImages != null && widget.initialImages!.isNotEmpty) {
      _currentImagesBytes = widget.initialImages!.take(_kMaxImages).toList();
      final List<ImageProvider> selectedProviders = _currentImagesBytes
          .map((bytes) => MemoryImage(bytes) as ImageProvider)
          .toList();
      _images
        ..clear()
        ..addAll(selectedProviders);
      _imageValidationError = false;
    }
  }

  @override
  void didUpdateWidget(covariant ColposcopyForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When parent provides a new list of images, refresh preview
    if (widget.initialImages != null && widget.initialImages != oldWidget.initialImages) {
      _currentImagesBytes = widget.initialImages!.take(_kMaxImages).toList();
      final providers = _currentImagesBytes
          .map((bytes) => MemoryImage(bytes) as ImageProvider)
          .toList();
      setState(() {
        _images
          ..clear()
          ..addAll(providers);
        _imageValidationError = _images.isEmpty;
      });
    }
  }

  @override
  void dispose() {
    _otherCtrl.removeListener(_emitChiefComplaintFromIndications);
    _findingsSummaryCtrl.removeListener(_emitRemarksSummary);
    _patientNameCtrl.dispose();
    _patientIdCtrl.dispose();
    _otherCtrl.dispose();
    _allergiesText.dispose();
    _sedationOther.dispose();
    _cfSuspiciousText.dispose();
    _awLocations.dispose();
    _iodineLocations.dispose();
    _biopsiesSites.dispose();
    _specimensType.dispose();
    _findingsSummaryCtrl.dispose();
    _immediateOtherCtrl.dispose();
    _fuTreatmentSpecifyCtrl.dispose();
    _fuOtherSpecifyCtrl.dispose();
    _reportScrollCtrl.dispose();
    _toastEntry?.remove();
    _savedScoreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showImagePreview) ...[
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: DiagnosisImagePreviewRow(
              images: _images,
              canAdd: _images.length < _kMaxImages,
              onAdd: _tryAddPlaceholderImage,
              onRemove: (idx) {
                setState(() {
                  _images.removeAt(idx);
                  if (idx >= 0 && idx < _currentImagesBytes.length) {
                    _currentImagesBytes.removeAt(idx);
                  }
                  if (_images.isEmpty) {
                    _imageValidationError = true;
                  }
                });
                if (widget.onImagesChanged != null) {
                  widget.onImagesChanged!(_currentImagesBytes);
                }
              },
              onOpen: _openImage,
            ),
          ),
          if (_imageValidationError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  border: Border.all(color: Colors.redAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Text('Please add at least 1 image to proceed.',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: _reportViewportHeight(context),
          child: Scrollbar(
            controller: _reportScrollCtrl,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _reportScrollCtrl,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
            _outlinedReport(context),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: widget.onPreviewReport,
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kYesNoPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          label: const Text('Preview Report'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _reportViewportHeight(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;
    double h = vh * 0.55;
    if (h < 320) h = 320;
    if (h > 720) h = 720;
    return h;
  }

  Widget _outlinedReport(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Colposcopy Report',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Patient info row responsive
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth >= 800;
                final Widget nameField = _LabeledField(
                  label: 'Patient Name',
                  child: TextField(
                    controller: _patientNameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                );
                final Widget idField = _LabeledField(
                  label: 'Patient ID',
                  child: TextField(
                    controller: _patientIdCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                );
                if (isWide) {
                  return Row(children: [Expanded(child: nameField), const SizedBox(width: 16), Expanded(child: idField)]);
                }
                return Column(children: [nameField, const SizedBox(height: 12), idField]);
              },
            ),
            const SizedBox(height: 16),
            // Dates row responsive
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth >= 800;
                final Widget dobField = _LabeledField(
                  label: 'Date of Birth',
                  child: _DateField(
                    date: _dob,
                    onPick: (d) => setState(() => _dob = d),
                  ),
                );
                final Widget visitField = _LabeledField(
                  label: 'Date of Visit',
                  child: _DateField(
                    date: _visitDate,
                    onPick: (d) => setState(() => _visitDate = d),
                  ),
                );
                if (isWide) {
                  return Row(children: [Expanded(child: dobField), const SizedBox(width: 16), Expanded(child: visitField)]);
                }
                return Column(children: [dobField, const SizedBox(height: 12), visitField]);
              },
            ),

            const SizedBox(height: 24),
            Text(
              '1. Indication for Colposcopy: (Check all that apply)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              runSpacing: 12,
              spacing: 24,
              children: [
                _checkbox('Abnormal Pap smear', _indPapSmear, (v) => setState(() { _indPapSmear = v; _emitChiefComplaintFromIndications(); })),
                _checkbox('Positive HPV test', _indHpv, (v) => setState(() { _indHpv = v; _emitChiefComplaintFromIndications(); })),
                _checkbox('Postcoital bleeding', _indPostcoital, (v) => setState(() { _indPostcoital = v; _emitChiefComplaintFromIndications(); })),
                _checkbox('Suspicious lesion on exam', _indSuspicious, (v) => setState(() { _indSuspicious = v; _emitChiefComplaintFromIndications(); })),
                _checkbox('Follow-up of previous abnormal findings', _indFollowUp, (v) => setState(() { _indFollowUp = v; _emitChiefComplaintFromIndications(); })),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(value: _indOther, onChanged: (v) => setState(() { _indOther = v ?? false; _emitChiefComplaintFromIndications(); })),
                    const SizedBox(width: 4),
                    const Text('Other'),
                    const SizedBox(width: 8),
                    if (_indOther)
                      SizedBox(
                        width: 260,
                        child: TextField(
                          controller: _otherCtrl,
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'If other, specify',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // ================= New Sections start =================
            const SizedBox(height: 24),
            Text('2. Pre-Procedure Assessment:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _InlineField(
              label: '2.1. Patient informed and consent obtained',
              child: _SegmentedToggle(
                labels: const ['Yes', 'No'],
                selectedIndex: _consentYes == null ? -1 : _consentYes! ? 0 : 1,
                onChanged: (i) => setState(() => _consentYes = i == 0),
              ),
            ),
            const SizedBox(height: _qGap),
            _InlineField(
              label: '2.2. Allergies reviewed',
              child: Row(children: [
                _SegmentedToggle(
                  labels: const ['Yes', 'No'],
                  selectedIndex: _allergiesYes == null ? -1 : _allergiesYes! ? 0 : 1,
                  onChanged: (i) => setState(() => _allergiesYes = i == 0),
                ),
                const SizedBox(width: 12),
                if (_allergiesYes == true)
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: _allergiesText,
                      decoration: const InputDecoration(isDense: true, hintText: 'If yes, specify', border: OutlineInputBorder()),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: _qGap),
            _InlineField(
              label: '2.3. Support person present (if applicable)',
              child: _SegmentedToggle(
                labels: const ['Yes', 'No'],
                selectedIndex: _supportYes == null ? -1 : _supportYes! ? 0 : 1,
                onChanged: (i) => setState(() => _supportYes = i == 0),
              ),
            ),

            const SizedBox(height: 16),
            _InlineField(
              label: '2.4. Sedation or anesthesia:',
              child: _SegmentedToggle(
                labels: const ['None', 'Topical', 'Other'],
                selectedIndex: _sedation == Sedation.none ? 0 : _sedation == Sedation.topical ? 1 : 2,
                onChanged: (i) => setState(() => _sedation = i == 0 ? Sedation.none : i == 1 ? Sedation.topical : Sedation.other),
              ),
            ),
            const SizedBox(height: _qGap),
            if (_sedation == Sedation.other)
              SizedBox(width: 320, child: TextField(controller: _sedationOther, decoration: const InputDecoration(isDense: true, hintText: 'If other, specify', border: OutlineInputBorder()))),

            const SizedBox(height: 24),
            Text('3. Examination Details:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _InlineField(
              label: '3.1. Cervix visibility',
              child: _SegmentedToggle(
                labels: const ['Fully Visible', 'Partially Visible', 'Not Visible'],
                selectedIndex: _cervixVisibility == null ? -1 : _cervixVisibility == CervixVisibility.fully ? 0 : _cervixVisibility == CervixVisibility.partially ? 1 : 2,
                onChanged: (i) => setState(() { _cervixVisibility = i == 0 ? CervixVisibility.fully : i == 1 ? CervixVisibility.partially : CervixVisibility.notVisible; _emitFindingsFromExam(); }),
              ),
            ),
            const SizedBox(height: _qGap),
            _LabeledField(
              label: '3.2. Cervical findings (pre-acetic acid)',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(spacing: 16, runSpacing: 8, children: [
                  _radio<CervicalFinding>('Normal', CervicalFinding.normal, _cervicalFinding, (v) => setState(() { _cervicalFinding = v; _emitFindingsFromExam(); })),
                  _radio<CervicalFinding>('Erythema', CervicalFinding.erythema, _cervicalFinding, (v) => setState(() { _cervicalFinding = v; _emitFindingsFromExam(); })),
                  _radio<CervicalFinding>('Nabothian cysts', CervicalFinding.nabothianCysts, _cervicalFinding, (v) => setState(() { _cervicalFinding = v; _emitFindingsFromExam(); })),
                  _radio<CervicalFinding>('Polyps', CervicalFinding.polyps, _cervicalFinding, (v) => setState(() { _cervicalFinding = v; _emitFindingsFromExam(); })),
                  _radio<CervicalFinding>('Leukoplakia', CervicalFinding.leukoplakia, _cervicalFinding, (v) => setState(() { _cervicalFinding = v; _emitFindingsFromExam(); })),
                  _radio<CervicalFinding>('Atrophy', CervicalFinding.atrophy, _cervicalFinding, (v) => setState(() { _cervicalFinding = v; _emitFindingsFromExam(); })),
                  _radio<CervicalFinding>('Cervical ectopy', CervicalFinding.ectopy, _cervicalFinding, (v) => setState(() { _cervicalFinding = v; _emitFindingsFromExam(); })),
                  _radio<CervicalFinding>('Suspicious lesion(s)', CervicalFinding.suspicious, _cervicalFinding, (v) => setState(() { _cervicalFinding = v; _emitFindingsFromExam(); })),
                ]),
                const SizedBox(height: _qGap),
                if (_cervicalFinding == CervicalFinding.suspicious)
                  SizedBox(width: 260, child: TextField(controller: _cfSuspiciousText, decoration: const InputDecoration(isDense: true, hintText: 'describe', border: OutlineInputBorder()))),
              ]),
            ),
            const SizedBox(height: _qGap),
            _InlineField(label: '3.3. Acetic acid application (3–5%)', child: _SegmentedToggle(labels: const ['Used', 'Not used'], selectedIndex: _aceticUsed == null ? -1 : _aceticUsed! ? 0 : 1, onChanged: (i) => setState(() { _aceticUsed = i == 0; _emitFindingsFromExam(); }))),
            const SizedBox(height: _qGap),
            _InlineField(
              label: '3.4. Acetowhite areas observed',
              child: Row(children: [
                _SegmentedToggle(labels: const ['Yes', 'No'], selectedIndex: _awYes == null ? -1 : _awYes! ? 0 : 1, onChanged: (i) => setState(() { _awYes = i == 0; _emitFindingsFromExam(); })),
                const SizedBox(width: 12),
                if (_awYes == true) SizedBox(width: 260, child: TextField(controller: _awLocations, decoration: const InputDecoration(isDense: true, hintText: 'If yes, Locations', border: OutlineInputBorder()))),
              ]),
            ),
            const SizedBox(height: _qGap),
            _LabeledField(
              label: '3.5. Margins of transformation zone',
              child: Wrap(spacing: 24, runSpacing: 8, children: [
                _radio<ZoneMargins>('Fully seen (Type 1)', ZoneMargins.type1, _zoneMargins, (v) => setState(() { _zoneMargins = v; _emitFindingsFromExam(); })),
                _radio<ZoneMargins>('Partially seen (Type 2)', ZoneMargins.type2, _zoneMargins, (v) => setState(() { _zoneMargins = v; _emitFindingsFromExam(); })),
                _radio<ZoneMargins>('Not seen (Type 3)', ZoneMargins.type3, _zoneMargins, (v) => setState(() { _zoneMargins = v; _emitFindingsFromExam(); })),
              ]),
            ),
            const SizedBox(height: _qGap),
            _LabeledField(
              label: '3.6. Vascular patterns observed',
              child: Wrap(spacing: 16, runSpacing: 8, children: [
                _radio<VascularPattern>('Fine punctation', VascularPattern.finePunctation, _vascularPattern, (v) => setState(() { _vascularPattern = v; _emitFindingsFromExam(); })),
                _radio<VascularPattern>('Coarse punctation', VascularPattern.coarsePunctation, _vascularPattern, (v) => setState(() { _vascularPattern = v; _emitFindingsFromExam(); })),
                _radio<VascularPattern>('Mosaic pattern', VascularPattern.mosaicPattern, _vascularPattern, (v) => setState(() { _vascularPattern = v; _emitFindingsFromExam(); })),
                _radio<VascularPattern>('Atypical vessels', VascularPattern.atypicalVessels, _vascularPattern, (v) => setState(() { _vascularPattern = v; _emitFindingsFromExam(); })),
                _radio<VascularPattern>('None', VascularPattern.none, _vascularPattern, (v) => setState(() { _vascularPattern = v; _emitFindingsFromExam(); })),
              ]),
            ),

            const SizedBox(height: 24),
            _InlineField(label: "3.7. Lugol's iodine applied", child: _SegmentedToggle(labels: const ['Yes', 'No'], selectedIndex: _lugolsYes == null ? -1 : _lugolsYes! ? 0 : 1, onChanged: (i) => setState(() => _lugolsYes = i == 0))),
            const SizedBox(height: _qGap),
            _InlineField(
              label: '3.8. Iodine-negative areas (glycogen-depleted)',
              child: Row(children: [
                _SegmentedToggle(labels: const ['Yes', 'No'], selectedIndex: _iodineNegYes == null ? -1 : _iodineNegYes! ? 0 : 1, onChanged: (i) => setState(() => _iodineNegYes = i == 0)),
                const SizedBox(width: 12),
                if (_iodineNegYes == true) SizedBox(width: 260, child: TextField(controller: _iodineLocations, decoration: const InputDecoration(isDense: true, hintText: 'Location(s)', border: OutlineInputBorder()))),
              ]),
            ),
            const SizedBox(height: _qGap),
            _LabeledField(
              label: '3.9. Suspicion of',
              child: Wrap(spacing: 24, runSpacing: 8, children: [
                _radio<Suspicion>('Low-grade lesion', Suspicion.low, _suspicion, (v) => setState(() { _suspicion = v; _emitFinalImpression(); })),
                _radio<Suspicion>('High-grade lesion', Suspicion.high, _suspicion, (v) => setState(() { _suspicion = v; _emitFinalImpression(); })),
                _radio<Suspicion>('Invasive cancer', Suspicion.invasive, _suspicion, (v) => setState(() { _suspicion = v; _emitFinalImpression(); })),
                _radio<Suspicion>('Inflammation/benign', Suspicion.inflammation, _suspicion, (v) => setState(() { _suspicion = v; _emitFinalImpression(); })),
                _radio<Suspicion>('Normal', Suspicion.normal, _suspicion, (v) => setState(() { _suspicion = v; _emitFinalImpression(); })),
              ]),
            ),
            const SizedBox(height: _qGap),
            _InlineField(
              label: '3.10. Biopsies taken',
              child: Row(children: [
                _SegmentedToggle(labels: const ['Yes', 'No'], selectedIndex: _biopsiesYes == null ? -1 : _biopsiesYes! ? 0 : 1, onChanged: (i) => setState(() => _biopsiesYes = i == 0)),
                const SizedBox(width: 12),
                if (_biopsiesYes == true) SizedBox(width: 260, child: TextField(controller: _biopsiesSites, decoration: const InputDecoration(isDense: true, hintText: 'Site(s)', border: OutlineInputBorder()))),
              ]),
            ),
            const SizedBox(height: _qGap),
            _InlineField(label: '3.11. Endocervical curettage (ECC) performed', child: _SegmentedToggle(labels: const ['Yes', 'No'], selectedIndex: _eccYes == null ? -1 : _eccYes! ? 0 : 1, onChanged: (i) => setState(() => _eccYes = i == 0))),
            const SizedBox(height: _qGap),
            _InlineField(
              label: '3.12. Specimens collected (HPV typing, cytology, culture)',
              child: Row(children: [
                _SegmentedToggle(labels: const ['Yes', 'No'], selectedIndex: _specimensYes == null ? -1 : _specimensYes! ? 0 : 1, onChanged: (i) => setState(() => _specimensYes = i == 0)),
                const SizedBox(width: 12),
                if (_specimensYes == true) SizedBox(width: 260, child: TextField(controller: _specimensType, decoration: const InputDecoration(isDense: true, hintText: 'Type', border: OutlineInputBorder()))),
              ]),
            ),

            const SizedBox(height: 24),
            Text('4. Swede Score Assessment', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('4.1. Open scoring criteria and calculate Swede Score'),
                SizedBox(
                  width: 72,
                  child: TextField(
                    enabled: false,
                    textAlign: TextAlign.center,
                    controller: _savedScoreCtrl,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: '-',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _openSwedeScore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A45E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Define Swede Score', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ================= Section 5: Findings Summary =================
            Text('5. Findings Summary: (Brief narrative description)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: TextField(
                controller: _findingsSummaryCtrl,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Add description',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 24),
            // ================= Section 6: Post-Procedure Plan =================
            Text('6. Post-Procedure Plan:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: _qGap),
            _LabeledField(
              label: '6.1. Immediate complications:',
              child: Wrap(spacing: 24, runSpacing: 8, children: [
                _radio<ImmediateComplication>('Bleeding', ImmediateComplication.bleeding, _immediateComplication,
                    (v) => setState(() => _immediateComplication = v)),
                _radio<ImmediateComplication>('Pain', ImmediateComplication.pain, _immediateComplication,
                    (v) => setState(() => _immediateComplication = v)),
                _radio<ImmediateComplication>('None', ImmediateComplication.none, _immediateComplication,
                    (v) => setState(() => _immediateComplication = v)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  _radio<ImmediateComplication>('Other', ImmediateComplication.other, _immediateComplication,
                      (v) => setState(() => _immediateComplication = v)),
                  const SizedBox(width: 8),
                  if (_immediateComplication == ImmediateComplication.other)
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: _immediateOtherCtrl,
                        decoration: const InputDecoration(isDense: true, hintText: 'If other, specify', border: OutlineInputBorder()),
                      ),
                    ),
                ]),
              ]),
            ),

            const SizedBox(height: _qGap),
            _LabeledField(
              label: '6.2. Follow-up recommendations:',
              child: Wrap(spacing: 24, runSpacing: 12, children: [
                _checkbox('Await biopsy/histopathology results', _fuAwaitResults, (v) => setState(() { _fuAwaitResults = v; _emitRemarksSummary(); })),
                _checkbox('Repeat Pap/HPV test in 6–12 months', _fuRepeatPap, (v) => setState(() { _fuRepeatPap = v; _emitRemarksSummary(); })),
                _checkbox('Patient education provided', _fuEducation, (v) => setState(() { _fuEducation = v; _emitRemarksSummary(); })),
                _checkbox('Routine surveillance', _fuRoutine, (v) => setState(() { _fuRoutine = v; _emitRemarksSummary(); })),
                _checkbox('Referral to gynecologic oncologist', _fuReferral, (v) => setState(() { _fuReferral = v; _emitRemarksSummary(); })),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  _checkbox('Treatment', _fuTreatment, (v) => setState(() { _fuTreatment = v; _emitRemarksSummary(); })),
                  const SizedBox(width: 8),
                  if (_fuTreatment)
                    SizedBox(
                      width: 200,
                      child: TextField(controller: _fuTreatmentSpecifyCtrl, decoration: const InputDecoration(isDense: true, hintText: 'specify', border: OutlineInputBorder()), onChanged: (_) => _emitRemarksSummary()),
                    ),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  _checkbox('Other', _fuOther, (v) => setState(() { _fuOther = v; _emitRemarksSummary(); })),
                  const SizedBox(width: 8),
                  if (_fuOther)
                    SizedBox(
                      width: 220,
                      child: TextField(controller: _fuOtherSpecifyCtrl, decoration: const InputDecoration(isDense: true, hintText: 'If other, specify', border: OutlineInputBorder()), onChanged: (_) => _emitRemarksSummary()),
                    ),
                ]),
              ]),
            ),

            const SizedBox(height: _qGap),
            _InlineField(
              label: '6.3. Patient advised and discharge instructions given:',
              child: _SegmentedToggle(
                labels: const ['Yes', 'No'],
                selectedIndex: _advisedYes == null ? -1 : _advisedYes! ? 0 : 1,
                onChanged: (i) => setState(() => _advisedYes = i == 0),
              ),
            ),

            // ================= New Sections end =================
          ],
        ),
      ),
    );
  }

  Future<void> _openSwedeScore() async {
    final int? result = await showDialog<int>(
      context: context,
      builder: (context) => SwedeScoreModal(images: _currentImagesBytes),
    );
    if (result != null && context.mounted) {
      setState(() => _savedScore = result);
      _savedScoreCtrl.text = result.toString();
      _showToast(
        context,
        title: 'Swede Score Saved',
        message: 'Doctor score updated to $result',
      );
    }
  }

  void _showToast(BuildContext context, {required String title, required String message}) {
    _toastEntry?.remove();
    final OverlayState overlay = Overlay.of(context);
    if (overlay == null) return;
    late Timer timer;
    _toastEntry = OverlayEntry(
      builder: (_) => Positioned(
        right: 24,
        bottom: 24,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 360,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8)),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(message, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    timer.cancel();
                    _toastEntry?.remove();
                    _toastEntry = null;
                  },
                  child: const Icon(Icons.close, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(_toastEntry!);
    timer = Timer(const Duration(seconds: 5), () {
      _toastEntry?.remove();
      _toastEntry = null;
    });
  }

  Widget _checkbox(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return kYesNoPurple;
            return Colors.white;
          }),
          checkColor: Colors.white,
          side: const BorderSide(color: Colors.black38, width: 1),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  void _tryAddPlaceholderImage() {
    _pickMoreImages();
  }

  void _openImage(ImageProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black54),
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: provider,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 24,
              right: 24,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMoreImages() async {
    final selected = await Navigator.push<List<Uint8List>>(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryScreen(
          images: widget.initialImages ?? const <Uint8List>[],
          pickerMode: true,
          pickerActionLabel: 'Use Selected',
        ),
      ),
    );
    if (selected == null || selected.isEmpty) return;

    _currentImagesBytes = selected.take(_kMaxImages).toList();
    final providers = _currentImagesBytes.map((b) => MemoryImage(b) as ImageProvider).toList();
    setState(() {
      _images
        ..clear()
        ..addAll(providers);
      _imageValidationError = false;
    });
    widget.onImagesChanged?.call(_currentImagesBytes);
  }

  // Derive chief complaint string from Indication checkboxes
  String _buildChiefComplaintFromIndications() {
    final List<String> reasons = [];
    if (_indPapSmear) reasons.add('Abnormal Pap smear');
    if (_indHpv) reasons.add('Positive HPV test');
    if (_indPostcoital) reasons.add('Postcoital bleeding');
    if (_indSuspicious) reasons.add('Suspicious lesion on exam');
    if (_indFollowUp) reasons.add('Follow-up of previous abnormal findings');
    if (_indOther && _otherCtrl.text.trim().isNotEmpty) reasons.add(_otherCtrl.text.trim());
    if (reasons.isEmpty) return '';
    return reasons.join(', ');
  }

  void _emitChiefComplaintFromIndications() {
    if (widget.onChiefComplaintChanged != null) {
      widget.onChiefComplaintChanged!(_buildChiefComplaintFromIndications());
    }
  }

  // Build a summarized Colposcopy Findings from 3.1–3.6
  String _buildFindingsSummary() {
    final List<String> parts = [];
    if (_cervixVisibility != null) {
      final vis = _cervixVisibility == CervixVisibility.fully
          ? 'Cervix fully visible'
          : _cervixVisibility == CervixVisibility.partially
              ? 'Cervix partially visible'
              : 'Cervix not visible';
      parts.add(vis);
    }
    if (_cervicalFinding != null) {
      String cfLabel;
      switch (_cervicalFinding) {
        case CervicalFinding.normal:
          cfLabel = 'Pre-acetic findings normal';
          break;
        case CervicalFinding.erythema:
          cfLabel = 'Erythema present';
          break;
        case CervicalFinding.nabothianCysts:
          cfLabel = 'Nabothian cysts present';
          break;
        case CervicalFinding.polyps:
          cfLabel = 'Polyps present';
          break;
        case CervicalFinding.leukoplakia:
          cfLabel = 'Leukoplakia present';
          break;
        case CervicalFinding.atrophy:
          cfLabel = 'Atrophic changes';
          break;
        case CervicalFinding.ectopy:
          cfLabel = 'Cervical ectopy present';
          break;
        case CervicalFinding.suspicious:
          final extra = _cfSuspiciousText.text.trim();
          cfLabel = extra.isEmpty ? 'Suspicious lesion(s)' : 'Suspicious lesion(s): $extra';
          break;
        default:
          cfLabel = '';
      }
      if (cfLabel.isNotEmpty) parts.add(cfLabel);
    }
    if (_aceticUsed != null) {
      parts.add(_aceticUsed! ? 'Acetic acid applied' : 'Acetic acid not used');
    }
    if (_awYes != null) {
      final loc = _awYes == true && _awLocations.text.trim().isNotEmpty ? ' (${_awLocations.text.trim()})' : '';
      parts.add(_awYes! ? 'Acetowhite areas observed$loc' : 'No acetowhite areas');
    }
    if (_zoneMargins != null) {
      final zm = _zoneMargins == ZoneMargins.type1
          ? 'TZ margins fully seen (Type 1)'
          : _zoneMargins == ZoneMargins.type2
              ? 'TZ margins partially seen (Type 2)'
              : 'TZ margins not seen (Type 3)';
      parts.add(zm);
    }
    if (_vascularPattern != null) {
      String vp;
      switch (_vascularPattern) {
        case VascularPattern.finePunctation:
          vp = 'Vascular pattern: fine punctation';
          break;
        case VascularPattern.coarsePunctation:
          vp = 'Vascular pattern: coarse punctation';
          break;
        case VascularPattern.mosaicPattern:
          vp = 'Vascular pattern: mosaic';
          break;
        case VascularPattern.atypicalVessels:
          vp = 'Vascular pattern: atypical vessels';
          break;
        case VascularPattern.none:
          vp = 'No abnormal vascular pattern';
          break;
        default:
          vp = '';
      }
      if (vp.isNotEmpty) parts.add(vp);
    }
    return parts.join('; ');
  }

  void _emitFindingsFromExam() {
    if (widget.onFindingsChanged != null) {
      widget.onFindingsChanged!(_buildFindingsSummary());
    }
  }

  // Build Final Impression from 3.9 Suspicion and 4.1 Swede Score
  String _buildFinalImpression() {
    final List<String> bits = [];
    if (_suspicion != null) {
      switch (_suspicion) {
        case Suspicion.low:
          bits.add('Suspicion: Low-grade lesion');
          break;
        case Suspicion.high:
          bits.add('Suspicion: High-grade lesion');
          break;
        case Suspicion.invasive:
          bits.add('Suspicion: Invasive cancer');
          break;
        case Suspicion.inflammation:
          bits.add('Suspicion: Inflammation/benign');
          break;
        case Suspicion.normal:
          bits.add('Suspicion: Normal');
          break;
        default:
          break;
      }
    }
    if (_savedScore != null) {
      bits.add('Swede Score: $_savedScore');
    }
    return bits.join(' | ');
  }

  void _emitFinalImpression() {
    if (widget.onFinalImpressionChanged != null) {
      widget.onFinalImpressionChanged!(_buildFinalImpression());
    }
  }

  // Build Remarks from Section 5 text + 6.2 selected follow-ups (if any)
  String _buildRemarks() {
    final List<String> rem = [];
    final text = _findingsSummaryCtrl.text.trim();
    if (text.isNotEmpty) rem.add(text);

    final List<String> followUps = [];
    if (_fuAwaitResults) followUps.add('Await biopsy/histopathology results');
    if (_fuRepeatPap) followUps.add('Repeat Pap/HPV test in 6–12 months');
    if (_fuEducation) followUps.add('Patient education provided');
    if (_fuRoutine) followUps.add('Routine surveillance');
    if (_fuReferral) followUps.add('Referral to gynecologic oncologist');
    if (_fuTreatment) {
      final t = _fuTreatmentSpecifyCtrl.text.trim();
      followUps.add(t.isNotEmpty ? 'Treatment: $t' : 'Treatment');
    }
    if (_fuOther) {
      final o = _fuOtherSpecifyCtrl.text.trim();
      followUps.add(o.isNotEmpty ? 'Other: $o' : 'Other');
    }
    if (followUps.isNotEmpty) rem.add('Follow-up: ${followUps.join('; ')}');
    return rem.join('\n');
  }

  void _emitRemarksSummary() {
    if (widget.onRemarksChanged != null) {
      widget.onRemarksChanged!(_buildRemarks());
    }
  }
}

// Image preview row — can be embedded in ColposcopyForm or pinned by a parent.
class DiagnosisImagePreviewRow extends StatefulWidget {
  final List<ImageProvider> images;
  final bool canAdd;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final void Function(ImageProvider provider) onOpen;
  const DiagnosisImagePreviewRow({
    super.key,
    required this.images,
    required this.canAdd,
    required this.onAdd,
    required this.onRemove,
    required this.onOpen,
  });

  @override
  State<DiagnosisImagePreviewRow> createState() => _DiagnosisImagePreviewRowState();
}

class _DiagnosisImagePreviewRowState extends State<DiagnosisImagePreviewRow> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double kFixedW = 260; // fixed preview width
    const double kFixedH = 160; // fixed preview height
    const double spacing = 12;

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true),
        trackVisibility: WidgetStateProperty.all(false),
        thickness: WidgetStateProperty.all(4.0),
        radius: const Radius.circular(2.0),
        thumbColor: WidgetStateProperty.all(const Color(0xFF7A45E5).withOpacity(0.6)),
        trackColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: kFixedW,
                height: kFixedH,
                child: _AddTile(onTap: widget.canAdd ? widget.onAdd : null, disabled: !widget.canAdd),
              ),
              const SizedBox(width: spacing),
              ...widget.images.asMap().entries.map((entry) {
                final int i = entry.key;
                final ImageProvider image = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: spacing),
                  child: SizedBox(
                    width: kFixedW,
                    height: kFixedH,
                    child: _Thumb(
                      image: image,
                      onRemove: () => widget.onRemove(i),
                      onOpen: () => widget.onOpen(image),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback onRemove;
  final VoidCallback onOpen;
  const _Thumb({required this.image, required this.onRemove, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: onOpen,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Image(image: image, fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback? onTap;
  final bool disabled;
  const _AddTile({required this.onTap, this.disabled = false});
  @override
  Widget build(BuildContext context) {
    final tile = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid, width: 2),
          color: disabled ? Colors.grey.shade100 : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF7A45E5), size: 36),
            SizedBox(height: 6),
            Text('Add image to Report', style: TextStyle(color: Color(0xFF7A45E5))),
          ],
        ),
      );
    final wrapped = disabled
        ? Tooltip(
            message: 'Maximum 5 images',
            textStyle: const TextStyle(fontSize: 14, color: Colors.white),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.85), borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
              child: Opacity(opacity: 0.6, child: tile),
            ),
          )
        : InkWell(onTap: onTap, child: tile);
    return wrapped;
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _InlineField extends StatelessWidget {
  final String label;
  final Widget child;
  const _InlineField({required this.label, required this.child});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final bool wide = c.maxWidth >= 800;
      final labelWidget = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
      );
      if (wide) {
        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(flex: 0, child: labelWidget), child]);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [labelWidget, child]);
    });
  }
}

class _SegmentedToggle extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex; // -1 when nothing selected
  final ValueChanged<int> onChanged;
  const _SegmentedToggle({required this.labels, required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isSelected = List<bool>.generate(labels.length, (i) => i == selectedIndex);
    return ToggleButtons(
      isSelected: isSelected,
      onPressed: (i) => onChanged(i),
      borderRadius: BorderRadius.circular(10),
      selectedColor: Colors.white,
      color: kYesNoPurple,
      fillColor: kYesNoPurple,
      constraints: const BoxConstraints(minHeight: 36, minWidth: 64),
      children: [for (final l in labels) Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(l))],
    );
  }
}

// Update display format to DD/MM/YYYY as requested
class _DateField extends StatefulWidget {
  final DateTime? date;
  final ValueChanged<DateTime> onPick;
  const _DateField({required this.date, required this.onPick});

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  late final TextEditingController _ctrl;

  static String _format(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.date == null ? '' : _format(widget.date!));
  }

  @override
  void didUpdateWidget(covariant _DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.date != oldWidget.date) {
      _ctrl.text = widget.date == null ? '' : _format(widget.date!);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      readOnly: true,
      decoration: const InputDecoration(
        hintText: 'DD/MM/YYYY',
        suffixIcon: Icon(Icons.calendar_today_outlined),
        border: OutlineInputBorder(),
      ),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: widget.date ?? now,
          firstDate: DateTime(1900),
          lastDate: DateTime(now.year + 5),
        );
        if (picked != null) widget.onPick(picked);
      },
    );
  }
}

// Helper controls
class _YesNoRow extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;
  const _YesNoRow({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final bool? v = value;
    return Wrap(spacing: 6, children: [
      ChoiceChip(label: const Text('Yes'), selected: v == true, onSelected: (_) => onChanged(true)),
      ChoiceChip(label: const Text('No'), selected: v == false, onSelected: (_) => onChanged(false)),
    ]);
  }
}

Widget _radio<T>(String label, T option, T? group, ValueChanged<T?> onChanged) {
  return Row(mainAxisSize: MainAxisSize.min, children: [
    Radio<T>(value: option, groupValue: group, onChanged: onChanged, activeColor: kYesNoPurple),
    Text(label),
  ]);
}

Widget _chip(String label, bool selected, ValueChanged<bool> onSelected) {
  return ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onSelected(!selected));
}



