import 'package:flutter/material.dart';
import '../custom_app_bar.dart';

class ClinicalDataFormScreen extends StatefulWidget {
  const ClinicalDataFormScreen({super.key});

  @override
  State<ClinicalDataFormScreen> createState() => _ClinicalDataFormScreenState();
}

class _ClinicalDataFormScreenState extends State<ClinicalDataFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all the new fields
  final _chiefComplaintController = TextEditingController();
  final _cytologyReportController = TextEditingController();
  final _pathologicalReportController = TextEditingController();
  final _colposcopyFindingsController = TextEditingController();
  final _finalImpressionController = TextEditingController();
  final _remarksController = TextEditingController();
  final _treatmentProvidedController = TextEditingController();
  final _precautionsController = TextEditingController();
  final _examiningPhysicianController = TextEditingController();

  // Controllers for Forensic Examination
  final _foreignBodiesController = TextEditingController();
  final _greenFilterController = TextEditingController();
  final _traumaController = TextEditingController();
  final _analInjuriesController = TextEditingController();
  final _swabSampleController = TextEditingController();
  final _posteriorFourchetteController = TextEditingController();
  final _stainingEffectController = TextEditingController();
  final _erythemaController = TextEditingController();

  @override
  void dispose() {
    // Dispose all controllers
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

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final reportData = {
        'chiefComplaint': _chiefComplaintController.text,
        'cytologyReport': _cytologyReportController.text,
        'pathologicalReport': _pathologicalReportController.text,
        'colposcopyFindings': _colposcopyFindingsController.text,
        'finalImpression': _finalImpressionController.text,
        'remarks': _remarksController.text,
        'treatmentProvided': _treatmentProvidedController.text,
        'precautions': _precautionsController.text,
        'examiningPhysician': _examiningPhysicianController.text,
        'forensicExamination': {
          'Foreign Bodies': _foreignBodiesController.text,
          'Green Filter': _greenFilterController.text,
          'Skin/Mucosal Trauma': _traumaController.text,
          'Anal Injuries': _analInjuriesController.text,
          'Swab Sample': _swabSampleController.text,
          'Posterior Fourchette': _posteriorFourchetteController.text,
          'Staining Effect': _stainingEffectController.text,
          'Erythema': _erythemaController.text,
        },
      };
      Navigator.pop(context, reportData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        extraActions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _onSave,
            tooltip: 'Save and Generate Report',
          ),
        ],
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Diagnosis screen is opened from report workflow')),
                  );
                },
                child: const Text('Open Diagnosis'),
              ),
              _buildSectionTitle('Clinical Findings & Examination'),
              _buildTextFormField(controller: _chiefComplaintController, label: 'Chief Complaint', color: Colors.green),
              _buildTextFormField(controller: _cytologyReportController, label: 'Cytology Report', color: Colors.blue),
              _buildTextFormField(controller: _pathologicalReportController, label: 'Pathological Report', color: Colors.purple),
              _buildTextFormField(controller: _colposcopyFindingsController, label: 'Colposcopy Findings', color: Colors.orange, maxLines: 3),
              _buildTextFormField(controller: _finalImpressionController, label: 'Final Impression', color: Colors.red),
              _buildTextFormField(controller: _remarksController, label: 'Remarks', color: Colors.grey),
              const SizedBox(height: 20),
              
              _buildSectionTitle('Forensic Examination'),
              _buildTextFormField(controller: _foreignBodiesController, label: 'Foreign Bodies'),
              _buildTextFormField(controller: _greenFilterController, label: 'Green Filter'),
              _buildTextFormField(controller: _traumaController, label: 'Skin/Mucosal Trauma'),
              _buildTextFormField(controller: _analInjuriesController, label: 'Anal Injuries'),
              _buildTextFormField(controller: _swabSampleController, label: 'Swab Sample'),
              _buildTextFormField(controller: _posteriorFourchetteController, label: 'Posterior Fourchette'),
              _buildTextFormField(controller: _stainingEffectController, label: 'Staining Effect'),
              _buildTextFormField(controller: _erythemaController, label: 'Erythema'),
              const SizedBox(height: 20),
              
              _buildSectionTitle('Treatment & Follow-up'),
              _buildTextFormField(controller: _treatmentProvidedController, label: 'Treatment Provided', color: Colors.blue[100]),
              _buildTextFormField(controller: _precautionsController, label: 'Precautions & Follow-up', color: Colors.amber[100]),
              const SizedBox(height: 20),
              
              _buildSectionTitle('Physician Details'),
              _buildTextFormField(controller: _examiningPhysicianController, label: 'Examining Physician'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    Color? color,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: color ?? Colors.white70),
          filled: true,
          fillColor: Colors.grey[850],
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: color?.withOpacity(0.5) ?? Colors.grey[700]!),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: color ?? Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
} 
