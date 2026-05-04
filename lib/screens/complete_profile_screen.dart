import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_router.dart';
import '../services/profile_service.dart';

/// Shown after Google Sign-In (or any auth method) when the user's
/// doctor_profiles/{uid} document is missing or incomplete.
/// The user cannot proceed to the app until all fields are filled.
class CompleteProfileScreen extends StatefulWidget {
  /// Pre-filled values extracted from the Google account (may be empty).
  final String prefillName;
  final String prefillEmail;

  const CompleteProfileScreen({
    super.key,
    this.prefillName  = '',
    this.prefillEmail = '',
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  final _phoneCtrl        = TextEditingController();
  final _hospitalCtrl     = TextEditingController();
  final _licenseCtrl      = TextEditingController();
  final _cityCtrl         = TextEditingController();
  final _stateCtrl        = TextEditingController();

  String _accountType = 'doctor';
  bool   _isSaving    = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.prefillName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _hospitalCtrl.dispose();
    _licenseCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) throw Exception('Not signed in');

      final profile = DoctorProfile(
        fullName:      _nameCtrl.text.trim(),
        phone:         _phoneCtrl.text.trim(),
        hospital:      _hospitalCtrl.text.trim(),
        accountType:   _accountType,
        licenseNumber: _licenseCtrl.text.trim(),
        city:          _cityCtrl.text.trim(),
        state:         _stateCtrl.text.trim(),
      );

      await ProfileService.instance.saveProfile(uid, profile);

      if (!mounted) return;
      AppRouter.navigateToHome(
        context,
        userEmail: widget.prefillEmail.isNotEmpty
            ? widget.prefillEmail
            : (Supabase.instance.client.auth.currentUser?.email ?? ''),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false, // no back button — profile is mandatory
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Please fill in the details below to continue.\nAll fields are required.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  _field(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: _required('Full name'),
                  ),
                  const SizedBox(height: 16),

                  _field(
                    controller: _phoneCtrl,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Phone number is required';
                      if (!RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(v.trim())) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Account type selector
                  DropdownButtonFormField<String>(
                    value: _accountType,
                    decoration: _inputDecoration('Account Type', Icons.badge),
                    items: const [
                      DropdownMenuItem(value: 'doctor',            child: Text('Doctor / Physician')),
                      DropdownMenuItem(value: 'diagnostic_center', child: Text('Diagnostic Center')),
                    ],
                    onChanged: (v) => setState(() => _accountType = v!),
                    validator: _required('Account type'),
                  ),
                  const SizedBox(height: 16),

                  _field(
                    controller: _hospitalCtrl,
                    label: _accountType == 'diagnostic_center'
                        ? 'Diagnostic Center Name'
                        : 'Hospital / Clinic Name',
                    icon: Icons.local_hospital,
                    validator: _required('Hospital / clinic name'),
                  ),
                  const SizedBox(height: 16),

                  _field(
                    controller: _licenseCtrl,
                    label: 'Medical Registration / License Number',
                    icon: Icons.verified,
                    validator: _required('License number'),
                  ),
                  const SizedBox(height: 16),

                  _field(
                    controller: _cityCtrl,
                    label: 'City',
                    icon: Icons.location_city,
                    validator: _required('City'),
                  ),
                  const SizedBox(height: 16),

                  _field(
                    controller: _stateCtrl,
                    label: 'State',
                    icon: Icons.map,
                    validator: _required('State'),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save & Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade50,
      );

  String? Function(String?) _required(String fieldName) =>
      (v) => (v == null || v.trim().isEmpty) ? '$fieldName is required' : null;
}
