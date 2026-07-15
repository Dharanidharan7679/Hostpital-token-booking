import 'package:flutter/material.dart';
import 'database_helper.dart';
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
                  final db = await DatabaseHelper.instance.database;
                  final String id = DateTime.now().millisecondsSinceEpoch.toString();
                  final String createdAt = DateTime.now().toIso8601String();

                  // Add to doctors collection
                  await db.query(
                    'INSERT INTO doctors (id, name, department, degree, experience, createdAt) VALUES (?, ?, ?, ?, ?, ?)',
                    [id, name, dept, degree, experience, createdAt]
                  );

                  // Add to departments collection if it doesn't exist
                  final deptResults = await db.query('SELECT id FROM departments WHERE name = ?', [dept]);
                  if (deptResults.isEmpty) {
                    final String deptId = DateTime.now().millisecondsSinceEpoch.toString();
                    await db.query(
                      'INSERT INTO departments (id, name, createdAt) VALUES (?, ?, ?)',
                      [deptId, dept, createdAt]
                    );
                  }

                  setState(() {}); // Refresh list
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.database.then((db) async {
          final results = await db.query('SELECT * FROM doctors ORDER BY createdAt DESC');
          List<Map<String, dynamic>> docs = [];
          for (var row in results) {
            Map<String, dynamic> doc = {};
            row.fields.forEach((k, v) => doc[k] = v?.toString() ?? '');
            docs.add(doc);
          }
          return docs;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No doctors found.", style: TextStyle(color: Color(0xFF64748B), fontSize: 16)));
          }

          var doctors = snapshot.data!;

          return ListView.builder(
            itemCount: doctors.length,
            padding: const EdgeInsets.all(24),
            itemBuilder: (context, index) {
              var data = doctors[index];
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
                    onPressed: () async {
                      final db = await DatabaseHelper.instance.database;
                      await db.query('DELETE FROM doctors WHERE id = ?', [data['id']]);
                      setState(() {});
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
