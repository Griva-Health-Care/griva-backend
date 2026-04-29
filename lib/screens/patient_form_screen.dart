import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/patient_service.dart';

class PatientFormScreen extends StatefulWidget {
  final Patient? patient;

  const PatientFormScreen({super.key, this.patient});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientService = PatientService();
  bool _isLoading = false;

  // Form fields
  final _nameController = TextEditingController();
  final _patientIdController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _referredByController = TextEditingController();
  DateTime? _dateOfBirth;
  DateTime? _dateOfVisit;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _nameController.text = widget.patient!.patientName;
      _patientIdController.text = widget.patient!.patientId ?? '';
      _mobileController.text = widget.patient!.mobileNo;
      _emailController.text = widget.patient!.email ?? '';
      _addressController.text = widget.patient!.address ?? '';
      _doctorNameController.text = widget.patient!.doctorName ?? '';
      _referredByController.text = widget.patient!.referredBy ?? '';
      _dateOfBirth = widget.patient!.dateOfBirth;
      _dateOfVisit = widget.patient!.dateOfVisit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _patientIdController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _doctorNameController.dispose();
    _referredByController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate ? _dateOfBirth ?? DateTime.now() : _dateOfVisit ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _dateOfBirth = picked;
        } else {
          _dateOfVisit = picked;
        }
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final patient = Patient(
        id: widget.patient?.id,
        uuid: widget.patient?.uuid ?? '',
        doctorId: widget.patient?.doctorId ?? '',
        patientName: _nameController.text,
        patientId: _patientIdController.text.isEmpty ? null : _patientIdController.text,
        mobileNo: _mobileController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        doctorName: _doctorNameController.text.isEmpty ? null : _doctorNameController.text,
        referredBy: _referredByController.text.isEmpty ? null : _referredByController.text,
        dateOfBirth: _dateOfBirth,
        dateOfVisit: _dateOfVisit,
      );

      if (widget.patient == null) {
        await _patientService.createPatient(patient);
      } else {
        await _patientService.updatePatient(patient);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving patient: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? 'Add Patient' : 'Edit Patient'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Patient Name *'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter patient name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _patientIdController,
                      decoration: const InputDecoration(labelText: 'Patient ID'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mobileController,
                      decoration: const InputDecoration(labelText: 'Mobile Number *'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _doctorNameController,
                      decoration: const InputDecoration(labelText: 'Doctor Name'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _referredByController,
                      decoration: const InputDecoration(labelText: 'Referred By'),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Date of Birth'),
                      subtitle: Text(_dateOfBirth == null
                          ? 'Not set'
                          : DateFormat('yyyy-MM-dd').format(_dateOfBirth!)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Date of Visit'),
                      subtitle: Text(_dateOfVisit == null
                          ? 'Not set'
                          : DateFormat('yyyy-MM-dd').format(_dateOfVisit!)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _savePatient,
                      child: Text(widget.patient == null ? 'Add Patient' : 'Update Patient'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 