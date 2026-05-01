import 'package:flutter/material.dart';
import 'package:griva_pi/custom_app_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'new_patient_form.dart';
import 'custom_drawer.dart';
import 'exam_screen.dart';
import 'screens/patient_list_screen.dart';
import 'services/patient_service.dart';
import 'services/user_service.dart';
import 'screens/patient_details_screen.dart';
import 'screens/user_profile_screen.dart';
import 'login_page.dart';
import 'services/network_service.dart';
import 'widgets/centralized_footer.dart';
import 'services/auth_service.dart';
import 'services/griva_api_service.dart';

class HomePage extends StatefulWidget {
  final String? userEmail;

  const HomePage({super.key, this.userEmail});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Add state variable for active tab
  bool _showUpcoming = true;
  List<Patient> _patients = [];
  bool _isLoading = true;
  String _userName = 'Doctor';
  final UserService _userService = UserService();
  final GlobalKey _infoIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _loadUserData();
    GrivaApiService.instance.warmUp();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Request location permission BEFORE showing the popup so the system
      // dialog does not interfere with the overlay used by showMenu.
      await Permission.locationWhenInUse.request();
      if (mounted) _showNotConnectedPopup();
    });
  }

  Future<void> _fetchPatients() async {
    final patients = await PatientService().getAllPatients();
    setState(() {
      _patients = patients;
      _isLoading = false;
    });
  }

  Future<void> _loadUserData() async {
    if (widget.userEmail != null) {
      try {
        final user = await _userService.getUserByEmail(widget.userEmail!);
        if (user != null) {
          print(
            'Loaded user: ${user.fullName} with role: ${user.role}',
          ); // Debug log
          setState(() {
            // Format the name based on role
            if (user.role == 'admin') {
              _userName = user.fullName;
            } else {
              // For doctors, add Dr. prefix if not already present
              _userName =
                  user.fullName.startsWith('Dr.')
                      ? user.fullName
                      : 'Dr. ${user.fullName}';
            }
          });
        } else {
          print('User not found for email: ${widget.userEmail}');
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    } else {
      print('No user email provided to HomePage');
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login page and clear the navigation stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GrivaLoginPage(authService: AuthService()),
                  ),
                  (route) => false,
                );
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showProfile() {
    if (widget.userEmail != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(userEmail: widget.userEmail!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information not available')),
      );
    }
  }

  void _showPatientDatabase() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PatientListScreen()),
    );
  }

  void _showNotConnectedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[400]),
                    SizedBox(width: 8),
                    Text(
                      'Not Connected',
                      style: TextStyle(
                        color: Colors.red[400],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'You need to connect to Griva Colposcope to begin the examination.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Do it Later'),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await NetworkService.openSpecificNetworkSettings(
                          NetworkType.wifi,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B44F7),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Connect Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotConnectedPopup() async {
    final status = await NetworkService.checkColposcopeConnection();
    final isConnected = status == ColposcopeConnectionStatus.connected;

    if (!mounted) return;
    final RenderBox? renderBox =
        _infoIconKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
      final size = renderBox.size;

      final Color statusColor =
          isConnected ? Colors.green[600]! : Colors.red[400]!;
      final IconData statusIcon =
          isConnected ? Icons.check_circle_outline : Icons.error_outline;
      final String statusTitle =
          isConnected ? 'Colposcope Connected' : 'Not Connected';
      final String statusMessage =
          isConnected
              ? 'Griva Colposcope is connected and ready for examination.'
              : 'You need to connect to Griva Colposcope to begin the examination.';

      await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
          position.dx,
          position.dy + size.height,
          position.dx + size.width,
          position.dy,
        ),
        items: [
          PopupMenuItem(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      statusTitle,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  statusMessage,
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isConnected ? 'OK' : 'Do it Later',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    if (!isConnected) ...[
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await NetworkService.openSpecificNetworkSettings(
                            NetworkType.wifi,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8B44F7),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Connect Now',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
        elevation: 8,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        onLogout: _logout,
        onProfile: _showProfile,
        onPatientDatabase: _showPatientDatabase,
      ),
      appBar: CustomAppBar(
        infoIconKey: _infoIconKey,
        userEmail: widget.userEmail,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 24),
            Center(
              child: Text(
                "Hello $_userName!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewPatientForm(),
                        ),
                      ).then((_) => _fetchPatients());
                    },
                    child: _buildActionCard(
                      icon: Icons.person_outline,
                      title: 'New Patient',
                      subtitle: 'Register a new patient',
                      color: Color(0xFFE6F0FF),
                      iconColor: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PiCameraScreen(),
                        ),
                      );
                    },
                    child: _buildActionCard(
                      icon: Icons.assignment_outlined,
                      title: 'Start Exam',
                      subtitle: 'Begin patient consultation',
                      color: Color(0xFFE6FFE6),
                      iconColor: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientListScreen(),
                        ),
                      );
                    },
                    child: _buildActionCard(
                      icon: Icons.folder_outlined,
                      title: 'Patient Database',
                      subtitle: ' ',
                      color: Color(0xFFF5E6FF),
                      iconColor: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _showUpcoming = true),
                        child: _buildTab(
                          "Upcoming Appointments",
                          _showUpcoming,
                          _patients.length.toString(),
                        ),
                      ),
                      SizedBox(width: 24),
                      GestureDetector(
                        onTap: () => setState(() => _showUpcoming = false),
                        child: _buildTab(
                          "Pending Diagnosis",
                          !_showUpcoming,
                          '9',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = 320.0;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 180,
                          child: Stack(
                            children: [
                              _isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : _patients.isEmpty
                                  ? Center(
                                    child: Text('No upcoming appointments'),
                                  )
                                  : SizedBox(
                                    height: 180,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _patients.length,
                                      separatorBuilder:
                                          (_, __) => SizedBox(width: 16),
                                      itemBuilder: (context, index) {
                                        return _buildPatientCard(
                                          _patients[index],
                                          cardWidth,
                                        );
                                      },
                                    ),
                                  ),
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0),
                                        Colors.white,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xFF8B44F7),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Add centralized footer
            const CentralizedFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: iconColor),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isActive, String count) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? Color(0xFF8B44F7) : Colors.transparent,
            width: 2.0,
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? Color(0xFF8B44F7) : Colors.grey,
            ),
          ),
          SizedBox(width: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? Color(0xFF8B44F7) : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Patient patient, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            patient.patientName,
            style: TextStyle(
              fontSize: width * 0.06,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            patient.patientId ?? '',
            style: TextStyle(fontSize: width * 0.05, color: Colors.grey[600]),
          ),
          Text(
            patient.dateOfBirth != null
                ? 'Age: ${DateTime.now().year - patient.dateOfBirth!.year}'
                : '',
            style: TextStyle(fontSize: width * 0.05, color: Colors.grey[600]),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PatientDetailsScreen(patient: patient),
                      ),
                    );
                    if (updated == true) {
                      _fetchPatients();
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[700],
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Details'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B44F7),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Start Exam'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
