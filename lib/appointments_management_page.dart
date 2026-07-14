import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dashboard_page.dart';

class AppointmentsManagementPage extends StatelessWidget {
  const AppointmentsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Appointments"),
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
      drawer: const AdminDrawer(currentPage: "appointments"),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No upcoming appointments.", style: TextStyle(color: Color(0xFF64748B), fontSize: 16)));
          }

          var appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            padding: const EdgeInsets.all(24),
            itemBuilder: (context, index) {
              var data = appointments[index].data() as Map<String, dynamic>;
              
              // Handle potential null or missing bookedDate safely
              DateTime date = DateTime.now();
              if (data['bookedDate'] != null && data['bookedDate'] is Timestamp) {
                date = (data['bookedDate'] as Timestamp).toDate();
              }
              String formattedDate = DateFormat('MMM dd, yyyy').format(date);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event, color: Color(0xFF2563EB), size: 28),
                  ),
                  title: Text(
                    "${data['name']} (Reg: ${data['regNo']})",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E3A8A)),
                  ),
                  subtitle: Text(
                    "Doctor: ${data['doctor'] ?? 'N/A'}\nDate: $formattedDate",
                    style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                    onPressed: () {
                      FirebaseFirestore.instance.collection('appointments').doc(appointments[index].id).delete();
                    },
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
