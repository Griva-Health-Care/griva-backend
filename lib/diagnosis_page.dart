import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:typed_data';
import 'ui_constants.dart';
import 'forms/colposcopy_form.dart';
import 'forms/vulvoscopy_form.dart';
import 'forms/vaginoscopy_form.dart';
import 'forms/hra_form.dart';
import 'forms/laser_therapy_form.dart';
import 'forms/sexual_assault_form.dart';
import 'services/medical_report_service.dart';
import 'services/patient_service.dart';
import 'gallery_screen.dart';

class DiagnosisPage extends StatefulWidget {
  final Patient patient;
  final List<Uint8List> images;
  const DiagnosisPage({super.key, required this.patient, required this.images});

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

enum Procedure {
  none,
  colposcopy,
  vulvoscopy,
  vaginoscopy,
  hra,
  laserTherapy,
  sexualAssault,
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  Procedure _selected = Procedure.colposcopy; // default form
  final ScrollController _pageScrollController = ScrollController();

  // Clinical data controllers (matching ClinicalDataFormScreen keys)
  final TextEditingController _chiefComplaintController = TextEditingController();
  final TextEditingController _cytologyReportController = TextEditingController();
  final TextEditingController _pathologicalReportController = TextEditingController();
  final TextEditingController _colposcopyFindingsController = TextEditingController();
  final TextEditingController _finalImpressionController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _treatmentProvidedController = TextEditingController();
  final TextEditingController _precautionsController = TextEditingController();
  final TextEditingController _examiningPhysicianController = TextEditingController();

  // Forensic Examination controllers
  final TextEditingController _foreignBodiesController = TextEditingController();
  final TextEditingController _greenFilterController = TextEditingController();
  final TextEditingController _traumaController = TextEditingController();
  final TextEditingController _analInjuriesController = TextEditingController();
  final TextEditingController _swabSampleController = TextEditingController();
  final TextEditingController _posteriorFourchetteController = TextEditingController();
  final TextEditingController _stainingEffectController = TextEditingController();
  final TextEditingController _erythemaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prefill top clinical data fields from the selected patient when available
    final p = widget.patient;
    if (p.chiefComplaint != null) _chiefComplaintController.text = p.chiefComplaint!;
    if (p.cytologyReport != null) _cytologyReportController.text = p.cytologyReport!;
    if (p.pathologicalReport != null) _pathologicalReportController.text = p.pathologicalReport!;
    if (p.colposcopyFindings != null) _colposcopyFindingsController.text = p.colposcopyFindings!;
    if (p.finalImpression != null) _finalImpressionController.text = p.finalImpression!;
    if (p.remarks != null) _remarksController.text = p.remarks!;
    if (p.treatmentProvided != null) _treatmentProvidedController.text = p.treatmentProvided!;
    if (p.precautions != null) _precautionsController.text = p.precautions!;
    if (p.doctorName != null) _examiningPhysicianController.text = p.doctorName!;

    // Prefill forensic map into individual fields if present
    final forensic = p.forensicExamination;
    if (forensic != null) {
      _foreignBodiesController.text = forensic['Foreign Bodies'] ?? '';
      _greenFilterController.text = forensic['Green Filter'] ?? '';
      _traumaController.text = forensic['Skin/Mucosal Trauma'] ?? '';
      _analInjuriesController.text = forensic['Anal Injuries'] ?? '';
      _swabSampleController.text = forensic['Swab Sample'] ?? '';
      _posteriorFourchetteController.text = forensic['Posterior Fourchette'] ?? '';
      _stainingEffectController.text = forensic['Staining Effect'] ?? '';
      _erythemaController.text = forensic['Erythema'] ?? '';
    }
  }

  Future<void> _onSave() async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      final filePath = await MedicalReportService.generateComprehensiveReport(
        patient: widget.patient,
        images: widget.images,
        chiefComplaint: _chiefComplaintController.text,
        cytologyReport: _cytologyReportController.text,
        pathologicalReport: _pathologicalReportController.text,
        colposcopyFindings: _colposcopyFindingsController.text,
        finalImpression: _finalImpressionController.text,
        remarks: _remarksController.text,
        treatmentProvided: _treatmentProvidedController.text,
        precautions: _precautionsController.text,
        examiningPhysician: _examiningPhysicianController.text,
        forensicExamination: {
          'Foreign Bodies': _foreignBodiesController.text,
          'Green Filter': _greenFilterController.text,
          'Skin/Mucosal Trauma': _traumaController.text,
          'Anal Injuries': _analInjuriesController.text,
          'Swab Sample': _swabSampleController.text,
          'Posterior Fourchette': _posteriorFourchetteController.text,
          'Staining Effect': _stainingEffectController.text,
          'Erythema': _erythemaController.text,
        },
      );

      if (!mounted) return;
      if (filePath != null) {
        scaffold.showSnackBar(
          SnackBar(
            content: const Text('Comprehensive report generated successfully!'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => MedicalReportService.openReport(filePath),
            ),
          ),
        );
        Navigator.pop(context, filePath);
      }
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Error creating report: $e')),
      );
    }
  }

  Future<void> _addImagesFromGallery() async {
    final result = await Navigator.push<List<Uint8List>>(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryScreen(
          images: widget.images,
          onDelete: (_) {},
          pickerMode: true,
          pickerActionLabel: 'Use Selected Images',
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        // Replace the images used for the report and preview with the newly selected
        widget.images
          ..clear()
          ..addAll(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxContentWidth =
                constraints.maxWidth > kContentMaxWidth ? kContentMaxWidth : constraints.maxWidth;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Scrollbar(
                  controller: _pageScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _pageScrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(child: _TopBar()),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _addImagesFromGallery,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7A45E5),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('Add Images'),
                            ),
                          ],
                        ),
                        const Divider(height: 1, thickness: 1, color: kHeaderDivider),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Diagnosis',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      color: const Color(0xFF7A45E5),
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(children: [
                                    TextButton.icon(
                                      onPressed: () => Navigator.maybePop(context),
                                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF7A45E5)),
                                      icon: const Icon(Icons.arrow_back),
                                      label: const Text('Back'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: _onSave,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF7A45E5),
                                        foregroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.save),
                                      label: const Text('Save'),
                                    ),
                                  ]),
                                ],
                              ),
                              const SizedBox(height: 28),
                              LayoutBuilder(
                                builder: (context, c) {
                                  final bool wide = c.maxWidth >= 720;
                                  final label = Text(
                                    'Select the Procedure:',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  );
                                  final dropdownField = DropdownButtonFormField<Procedure>(
                                      value: _selected,
                                      items: const [
                                        DropdownMenuItem(value: Procedure.colposcopy, child: Text('Colposcopy')),
                                        DropdownMenuItem(value: Procedure.vulvoscopy, child: Text('Vulvoscopy')),
                                        DropdownMenuItem(value: Procedure.vaginoscopy, child: Text('Vaginoscopy')),
                                        DropdownMenuItem(value: Procedure.hra, child: Text('High-Resolution Anoscopy (HRA)')),
                                        DropdownMenuItem(value: Procedure.laserTherapy, child: Text('Laser Therapy')),
                                        DropdownMenuItem(value: Procedure.sexualAssault, child: Text('Sexual Assault')),
                                      ],
                                      onChanged: (p) => setState(() => _selected = p ?? Procedure.colposcopy),
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        isDense: true,
                                      ),
                                    );
                                  if (wide) {
                                    return Row(children: [
                                      Flexible(flex: 0, child: label),
                                      const SizedBox(width: 16),
                                      Expanded(child: dropdownField),
                                    ]);
                                  }
                                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [label, const SizedBox(height: 8), dropdownField]);
                                },
                              ),
                              const SizedBox(height: 24),
                              _clinicalDataSection(theme),
                              const SizedBox(height: 24),
                              _buildFormFor(_selected),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 24),
                          child: Text(
                            '© 2025 Griva. All rights reserved.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    _chiefComplaintController.dispose();
    _cytologyReportController.dispose();
    _pathologicalReportController.dispose();
    _colposcopyFindingsController.dispose();
    _finalImpressionController.dispose();
    _remarksController.dispose();
    _treatmentProvidedController.dispose();
    _precautionsController.dispose();
    _examiningPhysicianController.dispose();
    _foreignBodiesController.dispose();
    _greenFilterController.dispose();
    _traumaController.dispose();
    _analInjuriesController.dispose();
    _swabSampleController.dispose();
    _posteriorFourchetteController.dispose();
    _stainingEffectController.dispose();
    _erythemaController.dispose();
    super.dispose();
  }

  Widget _buildFormFor(Procedure p) {
    switch (p) {
      case Procedure.colposcopy:
        return ColposcopyForm(
          initialPatientName: widget.patient.patientName,
          initialPatientId: widget.patient.patientId,
          initialDob: widget.patient.dateOfBirth,
          initialVisitDate: widget.patient.dateOfVisit,
          initialFindingsSummary: _finalImpressionController.text.isNotEmpty ? _finalImpressionController.text : null,
          initialImages: widget.images,
          onImagesChanged: (imgs) {
            setState(() {
              widget.images
                ..clear()
                ..addAll(imgs);
            });
          },
          onChiefComplaintChanged: (value) {
            setState(() {
              _chiefComplaintController.text = value;
            });
          },
          onFindingsChanged: (value) {
            setState(() {
              _colposcopyFindingsController.text = value;
            });
          },
          onFinalImpressionChanged: (value) {
            setState(() {
              _finalImpressionController.text = value;
            });
          },
          onRemarksChanged: (value) {
            setState(() {
              _remarksController.text = value;
            });
          },
        );
      case Procedure.vulvoscopy:
        return const VulvoscopyForm();
      case Procedure.vaginoscopy:
        return const VaginoscopyForm();
      case Procedure.hra:
        return const HraForm();
      case Procedure.laserTherapy:
        return const LaserTherapyForm();
      case Procedure.sexualAssault:
        return const SexualAssaultForm();
      case Procedure.none:
        return const SizedBox.shrink();
    }
  }
}

extension on _DiagnosisPageState {
  Widget _clinicalDataSection(ThemeData theme) {
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
            _sectionTitle('Clinical Findings & Examination', theme),
            const SizedBox(height: 8),
            const SizedBox(height: 12),
            TextField(controller: _cytologyReportController, decoration: _lightInputDecoration('Cytology Report')),
            const SizedBox(height: 12),
            TextField(controller: _pathologicalReportController, decoration: _lightInputDecoration('Pathological Report')),
            const SizedBox(height: 12),
            // Colposcopy Findings field removed; now derived from 3.1–3.6 in ColposcopyForm
            const SizedBox(height: 12),
            // Final Impression field removed; now derived from 3.9 + 4.1 in ColposcopyForm
            const SizedBox(height: 12),
            // Remarks field removed; now derived from Section 5 + 6.2 in ColposcopyForm

            const SizedBox(height: 20),
            _sectionTitle('Forensic Examination', theme),
            const SizedBox(height: 8),
            TextField(controller: _foreignBodiesController, decoration: _lightInputDecoration('Foreign Bodies')),
            const SizedBox(height: 12),
            TextField(controller: _greenFilterController, decoration: _lightInputDecoration('Green Filter')),
            const SizedBox(height: 12),
            TextField(controller: _traumaController, decoration: _lightInputDecoration('Skin/Mucosal Trauma')),
            const SizedBox(height: 12),
            TextField(controller: _analInjuriesController, decoration: _lightInputDecoration('Anal Injuries')),
            const SizedBox(height: 12),
            TextField(controller: _swabSampleController, decoration: _lightInputDecoration('Swab Sample')),
            const SizedBox(height: 12),
            TextField(controller: _posteriorFourchetteController, decoration: _lightInputDecoration('Posterior Fourchette')),
            const SizedBox(height: 12),
            TextField(controller: _stainingEffectController, decoration: _lightInputDecoration('Staining Effect')),
            const SizedBox(height: 12),
            TextField(controller: _erythemaController, decoration: _lightInputDecoration('Erythema')),

            const SizedBox(height: 20),
            _sectionTitle('Treatment & Follow-up', theme),
            const SizedBox(height: 8),
            TextField(controller: _treatmentProvidedController, decoration: _lightInputDecoration('Treatment Provided')),
            const SizedBox(height: 12),
            TextField(controller: _precautionsController, decoration: _lightInputDecoration('Precautions & Follow-up')),

            const SizedBox(height: 20),
            _sectionTitle('Physician Details', theme),
            const SizedBox(height: 8),
            TextField(controller: _examiningPhysicianController, decoration: _lightInputDecoration('Examining Physician')),
          ],
        ),
      ),
    );
  }
}

Widget _sectionTitle(String title, ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
  );
}

InputDecoration _lightInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );
}


class _TopBar extends StatelessWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    const double topBarHeight = kTopBarHeight;
    final double logoHeight = math.min(topBarHeight - 8, math.max(36, w * 0.04));
    return SizedBox(
      height: topBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            const _IconCircle(icon: Icons.menu),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: logoHeight,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            Row(
              children: const [
                _IconCircle(icon: Icons.settings),
                SizedBox(width: 8),
                _IconCircle(icon: Icons.account_circle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  const _IconCircle({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF2EDF9),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF5A2EA6)),
    );
  }
}
