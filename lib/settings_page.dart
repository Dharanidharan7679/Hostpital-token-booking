import 'package:flutter/material.dart';
import 'dashboard_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1E3A8A),
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      drawer: const AdminDrawer(currentPage: "settings"),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          _buildSettingsGroup(
            "Account Security",
            [
              _buildSettingsItem(Icons.lock_rounded, "Change Password", const Color(0xFFF59E0B)),
              _buildSettingsItem(Icons.security_rounded, "Two-Factor Auth", const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsGroup(
            "System Preferences",
            [
              _buildSettingsItem(Icons.notifications_rounded, "Notifications", const Color(0xFF3B82F6)),
              _buildSettingsItem(Icons.language_rounded, "Language", const Color(0xFF8B5CF6)),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsGroup(
            "About",
            [
              _buildSettingsItem(Icons.info_rounded, "About App", const Color(0xFF94A3B8)),
              _buildSettingsItem(Icons.help_rounded, "Help & Support", const Color(0xFF64748B)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text("Log Out"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.2),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, Color color) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1E3A8A))),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
      onTap: () {},
    );
  }
}
