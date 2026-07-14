import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'token_booking_page.dart';

class DoctorListPage extends StatelessWidget {
  final String department;

  const DoctorListPage({super.key, required this.department});

  List<Map<String, dynamic>> _getDummyDoctors(String dept) {
    return [
      {
        'name': 'Dr. Sarah Jenkins',
        'degree': 'MBBS, MD ($dept)',
        'experience': '12 years',
        'department': dept,
      },
      {
        'name': 'Dr. Michael Chen',
        'degree': 'MBBS, MS, Fellowship in $dept',
        'experience': '8 years',
        'department': dept,
      },
      {
        'name': 'Dr. Emily Parker',
        'degree': 'MBBS, MD, Board Certified',
        'experience': '15 years',
        'department': dept,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text("$department Specialists"),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .where('department', isEqualTo: department)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          }

          List<Map<String, dynamic>> doctorsList = [];
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            doctorsList = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          } else {
            // Fallback to dummy data so the app always looks professional
            doctorsList = _getDummyDoctors(department);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: doctorsList.length,
            itemBuilder: (context, index) {
              final doc = doctorsList[index];
              final name = doc['name'] ?? 'Unknown Doctor';
              final degree = doc['degree'] ?? 'MBBS';
              final experience = doc['experience'] ?? '0 years';

              final Map<String, String> doctorMapForBooking = {
                'name': name.toString(),
                'department': department,
                'degree': degree.toString(),
                'experience': experience.toString(),
              };

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5)),
                              ],
                            ),
                            child: const Icon(Icons.person_rounded, size: 40, color: Colors.white),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  degree,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.work_history_rounded, size: 14, color: Color(0xFF2563EB)),
                                      const SizedBox(width: 6),
                                      Text(experience, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TokenBookingPage(doctor: doctorMapForBooking),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 8,
                            shadowColor: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
                          ),
                          child: const Text("Book Appointment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
