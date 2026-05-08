import 'package:flutter/material.dart';
import 'widgets/centralized_footer.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onPatientDatabase;
  final VoidCallback? onLibrary;
  final VoidCallback? onSettings;

  const CustomDrawer({
    super.key,
    this.onLogout,
    this.onPatientDatabase,
    this.onLibrary,
    this.onSettings,
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
                  onTap: onPatientDatabase,
                ),
                _buildDrawerItem(
                  icon: Icons.medical_information_outlined,
                  title: 'Reports',
                ),
                _buildDrawerItem(
                  icon: Icons.menu_book_outlined,
                  title: 'Library',
                  onTap: onLibrary,
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: onSettings,
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
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          child: ListTile(
            leading: Icon(
              icon,
              color:
                  textColor ??
                  (isSelected ? Color(0xFF8B44F7) : Colors.grey[400]),
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
            horizontalTitleGap: 24,
            minLeadingWidth: 20,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}
