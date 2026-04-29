import 'package:flutter/material.dart';
import 'widgets/centralized_footer.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onProfile;
  final VoidCallback? onPatientDatabase;

  const CustomDrawer({
    super.key,
    this.onLogout,
    this.onProfile,
    this.onPatientDatabase,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Center(
                    child: Image.asset('assets/images/logo.png', height: 40),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  title: 'Home',
                  isSelected: true,
                ),
                _buildDrawerItem(
                  icon: Icons.folder_outlined,
                  title: 'Patient Database',
                  // backgroundColor: Color(0xFFF5E6FF),
                  // textColor: Color(0xFF8B44F7),
                  onTap: onPatientDatabase,
                ),
                _buildDrawerItem(
                  icon: Icons.medical_information_outlined,
                  title: 'Reports',
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: onProfile,
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Customer support',
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            showDivider: true,
            onTap: onLogout,
          ),
          SizedBox(height: 16),
          const CentralizedFooter(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    bool isSelected = false,
    Color? backgroundColor,
    Color? textColor,
    bool showDivider = false,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        if (showDivider) Divider(),
        Container(
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                (isSelected ? Color(0xFFF5E6FF) : Colors.transparent),
            borderRadius: BorderRadius.circular(4),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 1,
          ), // Even tighter vertical spacing
          child: ListTile(
            leading: Icon(
              icon,
              color:
                  textColor ??
                  (isSelected
                      ? Color(0xFF8B44F7)
                      : Colors.grey[400]), // Lighter grey
              size: 20,
            ),
            title: Text(
              title,
              style: TextStyle(
                color:
                    textColor ??
                    (isSelected ? Color(0xFF8B44F7) : Colors.grey[600]),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            dense: true,
            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
            horizontalTitleGap: 24, // Increased from 8 to 24 for more spacing
            minLeadingWidth: 20,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}
