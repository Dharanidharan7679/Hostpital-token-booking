import 'package:flutter/material.dart';
import 'department_dash.dart';
import 'new_patient_form_screen.dart'; 

class PatientFormPage extends StatelessWidget {
  final String hospitalName;

  const PatientFormPage({super.key, required this.hospitalName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 160, 140, 198),
      ),
      backgroundColor: const Color.fromARGB(255, 233, 233, 237),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    "Selected Hospital: $hospitalName",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 58, 36, 120),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                _buildDashboardBox(
                  context,
                  title: 'New Patient Form',
                  icon: Icons.person_add,
                  color: const Color.fromARGB(255, 53, 27, 216),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewPatientFormScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                _buildDashboardBox(
                  context,
                  title: 'Book Appointment',
                  icon: Icons.calendar_today,
                  color: const Color.fromARGB(255, 126, 75, 189),
                  onTap: () {
                    // Navigate to DepartmentDashboard
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DepartmentDashboard(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardBox(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 50),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
