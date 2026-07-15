import 'package:flutter/material.dart';
import 'doctor_management_page.dart';
import 'queue_management_page.dart';
import 'patient_management_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';
import 'emergency_record_page.dart';
import 'users_management_page.dart';
import 'database_viewer_page.dart';
import 'appointments_management_page.dart';
import 'database_helper.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1E3A8A),
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded),
            onPressed: () {
              _showNotificationsDialog(context);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const AdminDrawer(currentPage: "dashboard"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 600;
          return GridView.count(
            crossAxisCount: isWide ? 3 : 1,
            padding: const EdgeInsets.all(24),
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: isWide ? 1.5 : 2.5,
            children: [
              _infoCard(Icons.people_alt_rounded, "Total Patients", "120", const Color(0xFF3B82F6)),
              _infoCard(Icons.queue_rounded, "Active Queues", "15", const Color(0xFF10B981)),
              _infoCard(Icons.medical_services_rounded, "Doctors", "8", const Color(0xFFF59E0B)),
            ],
          );
        },
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Notifications", style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper.instance.database.then((db) async {
                final results = await db.query('SELECT * FROM notifications ORDER BY createdAt DESC');
                List<Map<String, dynamic>> notifs = [];
                for (var row in results) {
                  Map<String, dynamic> notif = {};
                  row.fields.forEach((k, v) => notif[k] = v?.toString() ?? '');
                  notifs.add(notif);
                }
                return notifs;
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No notifications yet.", style: TextStyle(color: Color(0xFF64748B))));
                }
                
                var notifications = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    var data = notifications[index];
                    return ListTile(
                      leading: const Icon(Icons.info_outline, color: Color(0xFF3B82F6)),
                      title: Text(data['title'] ?? 'Alert', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(data['message'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            )
          ],
        );
      },
    );
  }

  Widget _infoCard(IconData icon, String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.7), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDrawer extends StatelessWidget {
  final String currentPage;
  const AdminDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E3A8A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF172554)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Admin Panel",
                  style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _drawerItem(context, Icons.dashboard_rounded, "Dashboard", const DashboardPage(), "dashboard"),
          _drawerItem(context, Icons.storage_rounded, "SQL Inspector", const DatabaseViewerPage(), "inspector"),
          _drawerItem(context, Icons.people_alt_rounded, "Users", const UsersManagementPage(), "users"),
          _drawerItem(context, Icons.event_available_rounded, "Appointments", const AppointmentsManagementPage(), "appointments"),
          _drawerItem(context, Icons.medical_services_rounded, "Doctors", const DoctorManagementPage(), "doctors"),
          _drawerItem(context, Icons.queue_rounded, "Queue", const QueueManagementPage(), "queue"),
          _drawerItem(context, Icons.people_alt_rounded, "Patients", const PatientManagementPage(), "patients"),
          _drawerItem(context, Icons.emergency_rounded, "Emergency Records", const EmergencyRecordPage(), "emergency"),
          _drawerItem(context, Icons.note_add_rounded, "Add Patient Report", const ReportsPage(), "reports"), // Updated title
          _drawerItem(context, Icons.settings_rounded, "Settings", const SettingsPage(), "settings"),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext ctx, IconData icon, String title, Widget page, String name) {
    final bool isSelected = currentPage == name;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: isSelected ? const Color(0xFF3B82F6) : Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.white.withValues(alpha: 0.1),
        onTap: () {
          Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }
}
