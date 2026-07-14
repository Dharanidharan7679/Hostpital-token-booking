import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_page.dart';
import 'theme.dart';

class PatientManagementPage extends StatefulWidget {
  const PatientManagementPage({super.key});

  @override
  State<PatientManagementPage> createState() => _PatientManagementPageState();
}

class _PatientManagementPageState extends State<PatientManagementPage> {
  Future<void> _editPatientDetails(Map<String, dynamic> tokenData) async {
    final regNo = tokenData['regNo'];
    final name = tokenData['name'];
    final mobile = tokenData['mobile'];
    final age = tokenData['age'];

    // Try to fetch existing patient profile from 'patients' collection
    var patientDoc = await FirebaseFirestore.instance.collection('patients').doc(regNo).get();
    Map<String, dynamic> patientData = patientDoc.exists ? patientDoc.data()! : {};

    final bloodGroupController = TextEditingController(text: patientData['bloodGroup'] ?? '');
    final surgeriesController = TextEditingController(text: patientData['pastSurgeries'] ?? '');
    final allergiesController = TextEditingController(text: patientData['allergies'] ?? '');

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Text("Edit EMR: $name", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(bloodGroupController, "Blood Group", Icons.bloodtype_rounded),
              const SizedBox(height: 16),
              _buildDialogTextField(surgeriesController, "Past Surgeries", Icons.medical_services_rounded),
              const SizedBox(height: 16),
              _buildDialogTextField(allergiesController, "Allergies", Icons.warning_rounded),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 24, bottom: 24),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('patients').doc(regNo).set({
                'name': name,
                'regNo': regNo,
                'mobile': mobile,
                'age': age,
                'bloodGroup': bloodGroupController.text.trim(),
                'pastSurgeries': surgeriesController.text.trim(),
                'allergies': allergiesController.text.trim(),
                'lastUpdated': Timestamp.now(),
              }, SetOptions(merge: true));
              
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Patient record updated securely."), backgroundColor: Color(0xFF10B981)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("Save Record", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Patient Management"),
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
      drawer: const AdminDrawer(currentPage: "patients"),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tokens').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No patients found.", style: TextStyle(color: Color(0xFF64748B), fontSize: 16)));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 28),
                  ),
                  title: Text(data['name'] ?? 'Unknown Patient', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E3A8A))),
                  subtitle: Text("Reg No: ${data['regNo']} | Mobile: ${data['mobile']}", style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB)),
                      onPressed: () => _editPatientDetails(data),
                    ),
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
