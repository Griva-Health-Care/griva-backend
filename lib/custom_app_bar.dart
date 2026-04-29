import 'package:flutter/material.dart';
// import 'home_page.dart';
import 'screens/user_profile_screen.dart';
// import 'main.dart';
import 'login_page.dart';
import 'services/network_service.dart';
import 'services/auth_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Key? infoIconKey;
  final String? userEmail; // Optional user email for profile navigation
  final List<Widget>? extraActions;
  final Widget? title; // Optional custom title

  const CustomAppBar({super.key, this.infoIconKey, this.userEmail, this.extraActions, this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleSpacing: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: Colors.purple),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: title ?? Container(
        padding: EdgeInsets.all(4),
        // decoration: BoxDecoration(
        //   border: Border.all(color: Color(0xFF8B44F7), width: 1.5),
        //   borderRadius: BorderRadius.circular(8),
        // ),
        child: Image.asset(
          'assets/images/griva_bg.png',
          height: 36,
        ),
      ),
      actions: [
        IconButton(
          key: infoIconKey,
          icon: Icon(Icons.precision_manufacturing, color: Color(0xFF8B44F7)),
          onPressed: () {
            bool showDeviceSetup = false;
            showDialog(
              context: context,
              barrierColor: Colors.black.withOpacity(0.4),
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 420),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return showDeviceSetup
                          ? Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF3EDFC),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        padding: EdgeInsets.all(16),
                                        child: Icon(Icons.usb_rounded, color: Color(0xFF8B44F7), size: 32),
                                      ),
                                      SizedBox(height: 24),
                                      Text(
                                        'Device Setup',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Please complete the following steps to prepare your Colposcope device for connection.',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 24),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Color(0xFFE0E0E0)),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.power_settings_new, color: Color(0xFF8B44F7)),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Power On Device', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                                  Text('Press the power button on your Colposcope device', style: TextStyle(fontSize: 13, color: Colors.black54)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Color(0xFFE0E0E0)),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.wifi, color: Color(0xFF8B44F7)),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Enable Hotspot', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                                  Text('Ensure the blue light is visible on the device', style: TextStyle(fontSize: 13, color: Colors.black54)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 18),
                                      Text(
                                        'Once both steps are complete, tap the button below to open network settings and connect to your device',
                                        style: TextStyle(fontSize: 13, color: Colors.black54),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await NetworkService.openSpecificNetworkSettings(NetworkType.wifi);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF8B44F7),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text('Open Network Settings'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.close, color: Colors.black45),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF3EDFC),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(16),
                                    child: Icon(Icons.usb_rounded, color: Color(0xFF8B44F7), size: 32),
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    'Connect to Colposcope?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'You need to connect to Griva Colposcope to begin the examination. Would you like to do it now?',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 32),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: Colors.grey.shade300),
                                            foregroundColor: Colors.black87,
                                            padding: EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text('Do it Later'),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              showDeviceSetup = true;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF8B44F7),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text('Connect Now'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
        _buildPopupMenu(context),
        _buildProfileMenu(context),
        ...extraActions ?? [],
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.settings, color: Color(0xFF8B44F7)),
      offset: Offset(0, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      shadowColor: Color(0xFF8B44F7),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'wifi',
          child: _buildPopupMenuItem(Icons.wifi, 'Wifi'),
        ),
        PopupMenuItem<String>(
          value: 'microphone',
          child: _buildPopupMenuItem(Icons.mic, 'Microphone'),
        ),
        PopupMenuItem<String>(
          value: 'bluetooth',
          child: _buildPopupMenuItem(Icons.bluetooth, 'Bluetooth'),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: _buildPopupMenuItem(Icons.logout, 'Logout'),
        ),
      ],
      onSelected: (String value) => _handleMenuSelection(context, value),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.person_outline, color: Color(0xFF8B44F7)),
      offset: Offset(0, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      shadowColor: Color(0xFF8B44F7),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: _buildPopupMenuItem(Icons.person_outline, 'Profile'),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: _buildPopupMenuItem(Icons.settings_outlined, 'Settings'),
        ),
        PopupMenuItem<String>(
          value: 'support',
          child: _buildPopupMenuItem(Icons.help_outline, 'Customer support'),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: _buildPopupMenuItem(Icons.logout, 'Logout'),
        ),
      ],
      onSelected: (String value) => _handleMenuSelection(context, value),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'wifi':
        NetworkService.openSpecificNetworkSettings(NetworkType.wifi);
        break;
      case 'microphone':
        _showFeatureDialog(context, 'Microphone Settings', 'Microphone functionality coming soon');
        break;
      case 'bluetooth':
        _showFeatureDialog(context, 'Bluetooth Settings', 'Bluetooth functionality coming soon');
        break;
      case 'logout':
        _handleLogout(context);
        break;
      case 'profile':
        _handleProfile(context);
        break;
      case 'settings':
        _showFeatureDialog(context, 'Settings', 'Settings functionality coming soon');
        break;
      case 'support':
        _showFeatureDialog(context, 'Customer Support', 'Customer support functionality coming soon');
        break;
    }
  }

  void _showFeatureDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to login page and clear navigation stack
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => GrivaLoginPage(authService: AuthService())),
                (route) => false,
              );
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _handleProfile(BuildContext context) {
    if (userEmail != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(userEmail: userEmail!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information not available')),
      );
    }
  }

  Widget _buildPopupMenuItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}