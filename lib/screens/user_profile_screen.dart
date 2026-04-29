import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfileScreen extends StatefulWidget {
  final String userEmail;

  const UserProfileScreen({super.key, required this.userEmail});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _userService = UserService();
  User? _user;
  bool _isLoading = true;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _userService.getUserByEmail(widget.userEmail);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      // Upload the image and update the user profile
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null || _user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${_user!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(_selectedImage!);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user profile with the image URL
      final updatedUser = _user!.copyWith(profileImage: downloadUrl);
      await _userService.updateUser(updatedUser.id!, updatedUser);
      await _loadUserProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile image: $e')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF8B44F7),
        elevation: 1,
        iconTheme: IconThemeData(color: Color(0xFF8B44F7)),
      ),
      backgroundColor: Colors.white,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _user == null
              ? const Center(child: Text('User not found'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Modern Profile Header Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Color(0xFF8B44F7), width: 1.5),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 28,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Color(0xFFF3EDFC),
                                backgroundImage:
                                    _selectedImage != null
                                        ? FileImage(_selectedImage!)
                                        : (_user?.profileImage != null &&
                                            _user!.profileImage!.isNotEmpty)
                                        ? NetworkImage(_user!.profileImage!)
                                        : null,
                                child:
                                    (_selectedImage == null &&
                                            (_user?.profileImage == null ||
                                                _user!.profileImage!.isEmpty))
                                        ? Icon(
                                          Icons.person,
                                          size: 48,
                                          color: Color(0xFF8B44F7),
                                        )
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              _user!.fullName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _user!.role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF8B44F7),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Profile Information
                    _buildInfoSection('Personal Information', [
                      _buildInfoRow('Full Name', _user!.fullName),
                      _buildInfoRow('Email', _user!.email),
                      if (_user!.phoneNumber != null)
                        _buildInfoRow('Phone', _user!.phoneNumber!),
                    ]),

                    const SizedBox(height: 18),

                    _buildInfoSection('Medical Information', [
                      _buildInfoRow('Medical License', _user!.medicalLicense),
                      _buildInfoRow('Hospital/Clinic', _user!.hospital),
                      if (_user!.specialization != null)
                        _buildInfoRow('Specialization', _user!.specialization!),
                      if (_user!.department != null)
                        _buildInfoRow('Department', _user!.department!),
                    ]),

                    const SizedBox(height: 18),

                    _buildInfoSection('Account Information', [
                      _buildInfoRow(
                        'Status',
                        _user!.isActive ? 'Active' : 'Inactive',
                      ),
                      _buildInfoRow('Role', _user!.role),
                      if (_user!.createdAt != null)
                        _buildInfoRow(
                          'Member Since',
                          '${_user!.createdAt!.day}/${_user!.createdAt!.month}/${_user!.createdAt!.year}',
                        ),
                      if (_user!.lastLogin != null)
                        _buildInfoRow(
                          'Last Login',
                          '${_user!.lastLogin!.day}/${_user!.lastLogin!.month}/${_user!.lastLogin!.year}',
                        ),
                    ]),

                    const SizedBox(height: 28),

                    // Action Button
                    ElevatedButton.icon(
                      onPressed: () {
                        _showEditProfileModal();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B44F7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B44F7),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A8B44F7),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF8B44F7),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 13.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileModal() {
    final nameController = TextEditingController(text: _user?.fullName ?? '');
    final phoneController = TextEditingController(
      text: _user?.phoneNumber ?? '',
    );
    final licenseController = TextEditingController(
      text: _user?.medicalLicense ?? '',
    );
    final hospitalController = TextEditingController(
      text: _user?.hospital ?? '',
    );
    final specializationController = TextEditingController(
      text: _user?.specialization ?? '',
    );
    final departmentController = TextEditingController(
      text: _user?.department ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF8B44F7),
                    ),
                  ),
                ),
                SizedBox(height: 18),
                _buildEditField('Full Name', nameController),
                SizedBox(height: 12),
                _buildEditField(
                  'Phone',
                  phoneController,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 12),
                _buildEditField('Medical License', licenseController),
                SizedBox(height: 12),
                _buildEditField('Hospital/Clinic', hospitalController),
                SizedBox(height: 12),
                _buildEditField('Specialization', specializationController),
                SizedBox(height: 12),
                _buildEditField('Department', departmentController),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final currentContext =
                          context; // Store context before async
                      // Validate
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(currentContext).showSnackBar(
                          SnackBar(content: Text('Full Name cannot be empty')),
                        );
                        return;
                      }
                      Navigator.of(currentContext).pop();
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        final updatedUser = _user!.copyWith(
                          fullName: nameController.text.trim(),
                          phoneNumber: phoneController.text.trim(),
                          medicalLicense: licenseController.text.trim(),
                          hospital: hospitalController.text.trim(),
                          specialization: specializationController.text.trim(),
                          department: departmentController.text.trim(),
                        );
                        await _userService.updateUser(
                          updatedUser.id!,
                          updatedUser,
                        );
                        await _loadUserProfile();
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(currentContext).showSnackBar(
                            SnackBar(
                              content: Text('Profile updated successfully!'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(currentContext).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update profile: $e'),
                            ),
                          );
                        }
                      }
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8B44F7),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child: Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B44F7),
            fontSize: 13,
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFF7F7FA),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF8B44F7), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF8B44F7), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
