import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_page.dart';

class DoctorManagementPage extends StatefulWidget {
  const DoctorManagementPage({super.key});

  @override
  State<DoctorManagementPage> createState() => _DoctorManagementPageState();
}

class _DoctorManagementPageState extends State<DoctorManagementPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController deptController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();

  void _showAddDoctorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Doctor"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Doctor Name (e.g. Dr. John Doe)"),
                ),
                TextField(
                  controller: deptController,
                  decoration: const InputDecoration(labelText: "Department (e.g. Cardiology)"),
                ),
                TextField(
                  controller: degreeController,
                  decoration: const InputDecoration(labelText: "Degree (e.g. MBBS, MD)"),
                ),
                TextField(
                  controller: experienceController,
                  decoration: const InputDecoration(labelText: "Experience (e.g. 10 years)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final dept = deptController.text.trim();
                final degree = degreeController.text.trim();
                final experience = experienceController.text.trim();

                if (name.isNotEmpty && dept.isNotEmpty) {
                  // Add to doctors collection
                  await FirebaseFirestore.instance.collection('doctors').add({
                    'name': name,
                    'department': dept,
                    'degree': degree,
                    'experience': experience,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  // Add to departments collection if it doesn't exist
                  final deptRef = FirebaseFirestore.instance.collection('departments').doc(dept);
                  final deptDoc = await deptRef.get();
                  if (!deptDoc.exists) {
                    await deptRef.set({'name': dept, 'createdAt': FieldValue.serverTimestamp()});
                  }

                  Navigator.pop(context);
                  nameController.clear();
                  deptController.clear();
                  degreeController.clear();
                  experienceController.clear();
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Doctor Management"),
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
      drawer: const AdminDrawer(currentPage: "doctors"),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No doctors found.", style: TextStyle(color: Color(0xFF64748B), fontSize: 16)));
          }

          var doctors = snapshot.data!.docs;

          return ListView.builder(
            itemCount: doctors.length,
            padding: const EdgeInsets.all(24),
            itemBuilder: (context, index) {
              var data = doctors[index].data() as Map<String, dynamic>;
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
                    child: const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 28),
                  ),
                  title: Text(
                    data['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E3A8A)),
                  ),
                  subtitle: Text(
                    "${data['department'] ?? 'No Dept'} • ${data['experience'] ?? '0 years'}",
                    style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      FirebaseFirestore.instance.collection('doctors').doc(doctors[index].id).delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        onPressed: () => _showAddDoctorDialog(context),
      ),
    );
  }
}
