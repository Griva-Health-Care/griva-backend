import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../services/patient_service.dart';
import '../../services/credit_service.dart';
import '../../repositories/tele_case.dart';
import '../../services/session_service.dart';

/// Form for a diagnostic center to submit a patient case for tele-reporting.
///
/// Pops with [true] on successful submission so the caller can refresh its
/// list and credit balance.
class CaseSubmissionScreen extends StatefulWidget {
  /// Pre-selected patient (passed when launched from the patient row).
  /// If null the user picks a patient from the list.
  final Patient? patient;

  const CaseSubmissionScreen({super.key, this.patient});

  @override
  State<CaseSubmissionScreen> createState() => _CaseSubmissionScreenState();
}

class _CaseSubmissionScreenState extends State<CaseSubmissionScreen> {
  final _notesController = TextEditingController();
  final _creditService   = CreditService.instance;
  final _patientService  = PatientService();

  List<Patient> _patients   = [];
  Patient?      _selected;
  bool          _isLoading  = false;
  bool          _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.patient;
    if (widget.patient == null) _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    final list = await _patientService.getAllPatients();
    if (mounted) setState(() { _patients = list; _isLoading = false; });
  }

  Future<void> _submit() async {
    if (_selected == null) {
      _showError('Please select a patient.');
      return;
    }
    if (_creditService.balance <= 0) {
      _showError('No credits remaining. Please purchase credits to submit cases.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final draft = TeleCase(
        uuid:               const Uuid().v4(),
        diagnosticDoctorId: SessionService.instance.currentDoctorId,
        patientUuid:        _selected!.uuid,
        submissionNotes:    _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await _creditService.submitCase(draft);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Case submitted successfully. A reporter will respond within 20 minutes.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } on InsufficientCreditsException catch (e) {
      _showError(e.toString());
    } catch (e) {
      _showError('Submission failed: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cannot Submit'),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Case for Tele-Report'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Credit notice ──────────────────────────────────────────
                  _CreditBanner(balance: _creditService.balance),
                  const SizedBox(height: 24),

                  // ── Patient selector ───────────────────────────────────────
                  const Text('Patient',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  if (widget.patient != null)
                    _PatientTile(patient: widget.patient!)
                  else
                    DropdownButtonFormField<Patient>(
                      value: _selected,
                      hint: const Text('Select patient'),
                      isExpanded: true,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: _patients
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  '${p.patientName}${p.patientId != null ? ' · ${p.patientId}' : ''}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (p) => setState(() => _selected = p),
                    ),
                  const SizedBox(height: 24),

                  // ── Clinical notes ─────────────────────────────────────────
                  const Text('Notes for the reporter (optional)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Describe any specific concerns or findings…',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Submit ─────────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _creditService.balance <= 0)
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Submit Case  (1 credit)',
                              style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

class _CreditBanner extends StatelessWidget {
  final int balance;
  const _CreditBanner({required this.balance});

  @override
  Widget build(BuildContext context) {
    final ok    = balance > 0;
    final color = ok ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        border: Border.all(color: color.withAlpha(80)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ok
                  ? '$balance credit${balance == 1 ? '' : 's'} available — submitting will use 1'
                  : 'No credits remaining. Purchase credits to continue.',
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  final Patient patient;
  const _PatientTile({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: Colors.purple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.patientName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (patient.patientId != null)
                  Text('ID: ${patient.patientId}',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
