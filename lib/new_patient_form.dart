import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_app_bar.dart';
import 'custom_drawer.dart';
import "exam_screen.dart";
import 'services/patient_service.dart';
import 'widgets/centralized_footer.dart';

class NewPatientForm extends StatefulWidget {
  final Patient? patient;
  const NewPatientForm({super.key, this.patient});

  @override
  State<NewPatientForm> createState() => _NewPatientFormState();
}

class _NewPatientFormState extends State<NewPatientForm> {
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _dateOfVisitController = TextEditingController();
  final TextEditingController _lastMenstrualDateController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _referredByController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _referralReasonController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _patientSummaryController = TextEditingController();
  final TextEditingController _hcgLevelController = TextEditingController();

  // Add state variables for smoking and blood group
  String? _smokingValue;
  String? _selectedBloodGroup = 'Dropdown'; // Default value
  String? _menopauseValue;
  String? _sexuallyActiveValue;
  String? _pregnantValue;
  String? _selectedContraception = 'Dropdown';
  String? _selectedHIVStatus = 'Dropdown';
  String? _selectedHPVVaccination = 'Dropdown';

  // Add counters for pregnancy history
  int _liveBirths = 0;
  int _stillBirths = 0;
  int _abortions = 0;
  int _cesareans = 0;
  int _miscarriages = 0;

  // New state variables for Colposcopy Specific Details
  String? _hpvTestValue;
  String? _hpvResultValue;
  final TextEditingController _hpvDateController = TextEditingController();
  String? _hcgTestValue;
  final TextEditingController _hcgDateController = TextEditingController();

  final _patientService = PatientService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    if (p != null) {
      _nameController.text = p.patientName;
      _patientIdController.text = p.patientId ?? '';
      if (p.dateOfBirth != null) {
        _dateOfBirthController.text = DateFormat('MM/dd/yyyy').format(p.dateOfBirth!);
      }
      if (p.dateOfVisit != null) {
        _dateOfVisitController.text = DateFormat('MM/dd/yyyy').format(p.dateOfVisit!);
      }
      _mobileController.text = p.mobileNo;
      _emailController.text = p.email ?? '';
      _addressController.text = p.address ?? '';
      _doctorNameController.text = p.doctorName ?? '';
      _referredByController.text = p.referredBy ?? '';
      _smokingValue = p.smoking;
      _selectedBloodGroup = p.bloodGroup ?? _selectedBloodGroup;
      _medicationController.text = p.medication ?? '';
      _allergiesController.text = p.allergies ?? '';
      _menopauseValue = p.menopause;
      if (p.lastMenstrualDate != null) {
        _lastMenstrualDateController.text = DateFormat('MM/dd/yyyy').format(p.lastMenstrualDate!);
      }
      _sexuallyActiveValue = p.sexuallyActive;
      _selectedContraception = p.contraception ?? _selectedContraception;
      _selectedHIVStatus = p.hivStatus ?? _selectedHIVStatus;
      _pregnantValue = p.pregnant;
      _liveBirths = p.liveBirths ?? 0;
      _stillBirths = p.stillBirths ?? 0;
      _abortions = p.abortions ?? 0;
      _cesareans = p.cesareans ?? 0;
      _miscarriages = p.miscarriages ?? 0;
      _selectedHPVVaccination = p.hpvVaccination ?? _selectedHPVVaccination;
      _referralReasonController.text = p.referralReason ?? '';
      _symptomsController.text = p.symptoms ?? '';
      _hpvTestValue = p.hpvTest;
      _hpvResultValue = p.hpvResult;
      if (p.hpvDate != null) {
        _hpvDateController.text = DateFormat('MM/dd/yyyy').format(p.hpvDate!);
      }
      _hcgTestValue = p.hcgTest;
      if (p.hcgDate != null) {
        _hcgDateController.text = DateFormat('MM/dd/yyyy').format(p.hcgDate!);
      }
      _hcgLevelController.text = p.hcgLevel?.toString() ?? '';
      _patientSummaryController.text = p.patientSummary ?? '';
    }
  }

  @override
  void dispose() {
    _dateOfBirthController.dispose();
    _dateOfVisitController.dispose();
    _lastMenstrualDateController.dispose();
    _nameController.dispose();
    _patientIdController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _doctorNameController.dispose();
    _referredByController.dispose();
    _medicationController.dispose();
    _allergiesController.dispose();
    _referralReasonController.dispose();
    _symptomsController.dispose();
    _patientSummaryController.dispose();
    _hcgLevelController.dispose();
    _hpvDateController.dispose();
    _hcgDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> _savePatient({required bool goToExam}) async {
    setState(() { _isSaving = true; });
    try {
      final patient = Patient(
        id: widget.patient?.id,
        uuid: widget.patient?.uuid ?? '',
        doctorId: widget.patient?.doctorId ?? '',
        patientName: _nameController.text,
        patientId: _patientIdController.text,
        dateOfBirth: _dateOfBirthController.text.isNotEmpty ? DateFormat('MM/dd/yyyy').parse(_dateOfBirthController.text) : null,
        dateOfVisit: _dateOfVisitController.text.isNotEmpty ? DateFormat('MM/dd/yyyy').parse(_dateOfVisitController.text) : null,
        mobileNo: _mobileController.text,
        email: _emailController.text,
        address: _addressController.text,
        doctorName: _doctorNameController.text,
        referredBy: _referredByController.text,
        smoking: _smokingValue,
        bloodGroup: _selectedBloodGroup == 'Dropdown' ? null : _selectedBloodGroup,
        medication: _medicationController.text,
        allergies: _allergiesController.text,
        menopause: _menopauseValue,
        lastMenstrualDate: _lastMenstrualDateController.text.isNotEmpty ? DateFormat('MM/dd/yyyy').parse(_lastMenstrualDateController.text) : null,
        sexuallyActive: _sexuallyActiveValue,
        contraception: _selectedContraception == 'Dropdown' ? null : _selectedContraception,
        hivStatus: _selectedHIVStatus == 'Dropdown' ? null : _selectedHIVStatus,
        pregnant: _pregnantValue,
        liveBirths: _liveBirths,
        stillBirths: _stillBirths,
        abortions: _abortions,
        cesareans: _cesareans,
        miscarriages: _miscarriages,
        hpvVaccination: _selectedHPVVaccination == 'Dropdown' ? null : _selectedHPVVaccination,
        referralReason: _referralReasonController.text,
        symptoms: _symptomsController.text,
        hpvTest: _hpvTestValue,
        hpvResult: _hpvResultValue,
        hpvDate: _hpvDateController.text.isNotEmpty ? DateFormat('MM/dd/yyyy').parse(_hpvDateController.text) : null,
        hcgTest: _hcgTestValue,
        hcgDate: _hcgDateController.text.isNotEmpty ? DateFormat('MM/dd/yyyy').parse(_hcgDateController.text) : null,
        hcgLevel: _hcgLevelController.text.isNotEmpty ? double.tryParse(_hcgLevelController.text) : null,
        patientSummary: _patientSummaryController.text,
      );
      Patient savedPatient;
      if (patient.id != null) {
        savedPatient = await _patientService.updatePatient(patient);
      } else {
        savedPatient = await _patientService.createPatient(patient);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient saved successfully!')),
        );
        if (goToExam) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PiCameraScreen(initialPatient: savedPatient)),
          );
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving patient: $e')),
        );
      }
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.patient != null;
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: CustomAppBar(),
      backgroundColor: const Color.fromARGB(255,255,254,254),
      body: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time and Date display
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Color.fromARGB(255,169,84,234),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Text(
                              isEditing ? 'Edit Patient' : 'New Patient Form',
                              style: TextStyle(
                                color: Color.fromARGB(255,169,84,234),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('hh:mm a').format(DateTime.now()),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'MMMM dd, yyyy',
                              ).format(DateTime.now()),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Form Card
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255,249,248,248),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    const Center(
                      child: Text(
                        'General Information',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Row 1: Patient Name and ID
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Patient Name*',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Patient ID',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _patientIdController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Row 2: Date of Birth and Visit
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date of Birth',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _dateOfBirthController,
                                readOnly: true,
                                onTap:
                                    () => _selectDate(
                                      context,
                                      _dateOfBirthController,
                                    ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date of Visit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _dateOfVisitController,
                                readOnly: true,
                                onTap:
                                    () => _selectDate(
                                      context,
                                      _dateOfVisitController,
                                    ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Row 3: Mobile No and Email
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mobile No.*',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Row 4: Address
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Row 5: Doctor's Name and Referred By
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Doctor\'s Name',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _doctorNameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Referred By',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _referredByController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Space for additional elements
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // New General Medical History Section in a Card
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255,249,248,248),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'General Medical History',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text('Smoking: '),
                        Radio<String>(
                          value: 'Yes',
                          groupValue: _smokingValue,
                          onChanged: (value) {
                            setState(() {
                              _smokingValue = value;
                            });
                          },
                        ),
                        const Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: _smokingValue,
                          onChanged: (value) {
                            setState(() {
                              _smokingValue = value;
                            });
                          },
                        ),
                        const Text('No'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Blood Group'),
                              DropdownButton<String>(
                                value: _selectedBloodGroup,
                                items:
                                    <String>[
                                      'Dropdown',
                                      'A+',
                                      'A-',
                                      'B+',
                                      'B-',
                                      'O+',
                                      'O-',
                                      'AB+',
                                      'AB-',
                                    ].map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedBloodGroup = newValue;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Medication'),
                              TextFormField(
                                controller: _medicationController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.all(8.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Any Allergies'),
                    TextFormField(
                      controller: _allergiesController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(8.0),
                      ),
                    ),
                  ],
                ),
              ),
              // New Reproductive & Obstetric History Section in a Card
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255,249,248,248),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Reproductive & Obstetric History',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Menopause: '),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'Yes',
                                        groupValue: _menopauseValue,
                                        onChanged: (value) {
                                          setState(() {
                                            _menopauseValue = value;
                                          });
                                        },
                                      ),
                                      const Text('Yes'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: 'No',
                                        groupValue: _menopauseValue,
                                        onChanged: (value) {
                                          setState(() {
                                            _menopauseValue = value;
                                          });
                                        },
                                      ),
                                      const Text('No'),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Last Menstrual Date (If not menopausal)',
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _lastMenstrualDateController,
                                readOnly: true,
                                onTap:
                                    () => _selectDate(
                                      context,
                                      _lastMenstrualDateController,
                                    ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.all(8.0),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // New fields from the image
                    const SizedBox(height: 16),

                    // Sexually Active row
                    Row(
                      children: [
                        const Text('Sexually Active?'),
                        Radio<String>(
                          value: 'Yes',
                          groupValue: _sexuallyActiveValue,
                          onChanged: (value) {
                            setState(() {
                              _sexuallyActiveValue = value;
                            });
                          },
                        ),
                        const Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: _sexuallyActiveValue,
                          onChanged: (value) {
                            setState(() {
                              _sexuallyActiveValue = value;
                            });
                          },
                        ),
                        const Text('No'),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Contraceptions and HIV Status row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Contraceptions Used'),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedContraception,
                                items:
                                    <String>[
                                      'Dropdown',
                                      'None',
                                      'Condoms',
                                      'Pills',
                                      'IUD',
                                      'Implant',
                                      'Injection',
                                      'Sterilization',
                                      'Other',
                                    ].map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedContraception = newValue;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('HIV Status'),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedHIVStatus,
                                items:
                                    <String>[
                                      'Dropdown',
                                      'Positive',
                                      'Negative',
                                      'Unknown',
                                    ].map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedHIVStatus = newValue;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // B. Pregnancy and Birth History section
                    const Text(
                      'B. Pregnancy and Birth History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Pregnant row
                    Row(
                      children: [
                        const Text('Pregnant?'),
                        Radio<String>(
                          value: 'Yes',
                          groupValue: _pregnantValue,
                          onChanged: (value) {
                            setState(() {
                              _pregnantValue = value;
                            });
                          },
                        ),
                        const Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: _pregnantValue,
                          onChanged: (value) {
                            setState(() {
                              _pregnantValue = value;
                            });
                          },
                        ),
                        const Text('No'),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Counter rows
                    Row(
                      children: [
                        Expanded(
                          child: _buildCounter('Live Births', _liveBirths, (
                            value,
                          ) {
                            setState(() {
                              _liveBirths = value;
                            });
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCounter('Still Births', _stillBirths, (
                            value,
                          ) {
                            setState(() {
                              _stillBirths = value;
                            });
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCounter('Abortions', _abortions, (
                            value,
                          ) {
                            setState(() {
                              _abortions = value;
                            });
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildCounter('Cesareans', _cesareans, (
                            value,
                          ) {
                            setState(() {
                              _cesareans = value;
                            });
                          }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCounter('Miscarriages', _miscarriages, (
                            value,
                          ) {
                            setState(() {
                              _miscarriages = value;
                            });
                          }),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ), // Empty space for alignment
                      ],
                    ),

                    const SizedBox(height: 16),

                    // C. Immunization History section
                    const Text(
                      'C. Immunization History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('HPV Vaccination Type'),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedHPVVaccination,
                          items:
                              <String>[
                                'Dropdown',
                                'None',
                                'Gardasil',
                                'Cervarix',
                                'Gardasil 9',
                                'Unknown',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedHPVVaccination = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer
              const SizedBox(height: 20),

              // New Colposcopy Specific Details Section
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255,249,248,248),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Colposcopy Specific Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Referral Reason
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Referral reason'),
                              TextFormField(
                                controller: _referralReasonController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.all(8.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Symptoms'),
                              TextFormField(
                                controller: _symptomsController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.all(8.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // HPV Test
                    Row(
                      children: [
                        const Text('HPV Test'),
                        SizedBox(width: 10),
                        Radio<String>(
                          value: 'Yes',
                          groupValue: _hpvTestValue,
                          onChanged: (value) {
                            setState(() {
                              _hpvTestValue = value;
                            });
                          },
                        ),
                        const Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: _hpvTestValue,
                          onChanged: (value) {
                            setState(() {
                              _hpvTestValue = value;
                            });
                          },
                        ),
                        const Text('No'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Result'),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Positive',
                          groupValue: _hpvResultValue,
                          onChanged: (value) {
                            setState(() {
                              _hpvResultValue = value;
                            });
                          },
                        ),
                        const Text('Positive'),
                        Radio<String>(
                          value: 'Negative',
                          groupValue: _hpvResultValue,
                          onChanged: (value) {
                            setState(() {
                              _hpvResultValue = value;
                            });
                          },
                        ),
                        const Text('Negative'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Date'),
                    TextFormField(
                      readOnly: true,
                      onTap: () => _selectDate(context, _hpvDateController),
                      controller: _hpvDateController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(8.0),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // HCG Test
                    const Text('HCG Test'),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Yes',
                          groupValue: _hcgTestValue,
                          onChanged: (value) {
                            setState(() {
                              _hcgTestValue = value;
                            });
                          },
                        ),
                        const Text('Yes'),
                        Radio<String>(
                          value: 'No',
                          groupValue: _hcgTestValue,
                          onChanged: (value) {
                            setState(() {
                              _hcgTestValue = value;
                            });
                          },
                        ),
                        const Text('No'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Date'),
                    TextFormField(
                      readOnly: true,
                      onTap: () => _selectDate(context, _hcgDateController),
                      controller: _hcgDateController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(8.0),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('HCG Level (in mIU/ml)'),
                    TextFormField(
                      controller: _hcgLevelController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(8.0),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Patient Summary & Notes
                    const Text('Patient Summary & Notes'),
                    TextFormField(
                      controller: _patientSummaryController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(8.0),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isSaving ? null : () => _savePatient(goToExam: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255,169,84,234),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(isEditing ? 'Update' : 'Save and Edit'),
                  ),
                  ElevatedButton(
                    onPressed: _isSaving ? null : () => _savePatient(goToExam: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255,169,84,234),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(isEditing ? 'Update and Start Exam' : 'Save and Start Exam'),
                  ),
                ],
              ),

              // Footer
              const SizedBox(height: 20),
              const CentralizedFooter(),
            ],
          ),
        ),
      ),
    ),
    ),
  ),
),
    );
  }

  // Helper method to build consistent counter widgets
  Widget _buildCounter(String label, int value, Function(int) onChanged) {
    return Row(
      children: [
        Text(label),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 32,
                child: Text(value.toString(), textAlign: TextAlign.center),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => onChanged(value + 1),
                style: IconButton.styleFrom(
                  backgroundColor: Color.fromARGB(255,169,84,234),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// To use this screen, just call:
// Navigator.push(
//   context,
//   MaterialPageRoute(builder: (context) => const NewPatientForm()),
// );
