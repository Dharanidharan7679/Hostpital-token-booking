import 'package:flutter/material.dart';
import 'doctor_list_page.dart';

class DepartmentDashboard extends StatelessWidget {
  final List<Map<String, dynamic>> departments = [
    {'name': 'Cardiology', 'icon': Icons.favorite, 'color': Colors.redAccent},
    {'name': 'Neurology', 'icon': Icons.psychology, 'color': Colors.purpleAccent},
    {'name': 'Pediatrics', 'icon': Icons.child_care, 'color': Colors.orangeAccent},
    {'name': 'Orthopedics', 'icon': Icons.accessibility_new, 'color': Colors.greenAccent},
    {'name': 'Dermatology', 'icon': Icons.healing, 'color': Colors.tealAccent},
    {'name': 'ENT', 'icon': Icons.hearing, 'color': Colors.blueAccent},
    {'name': 'Ophthalmology', 'icon': Icons.remove_red_eye, 'color': Colors.indigoAccent},
    {'name': 'Gynecology', 'icon': Icons.pregnant_woman, 'color': Colors.pinkAccent},
    {'name': 'Radiology', 'icon': Icons.radio, 'color': Colors.deepOrangeAccent},
    {'name': 'Oncology', 'icon': Icons.biotech, 'color': Colors.deepPurpleAccent},
  ];

  DepartmentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Select Department"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1E3A8A),
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: GridView.builder(
          itemCount: departments.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final dept = departments[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorListPage(department: dept['name']),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: dept['color'].withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            dept['color'].withValues(alpha: 0.7),
                            dept['color'],
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: dept['color'].withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Icon(dept['icon'], size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dept['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
