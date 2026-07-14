import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedReportType = 'General Checkup';
  bool _isSubmitting = false;

  final List<String> _reportTypes = [
    'General Checkup',
    'Surgery Report',
    'Lab Results',
    'Emergency Incident',
    'Discharge Summary'
  ];

  Future<void> _submitReport() async {
    final regNo = _regNoController.text.trim();
    final notes = _notesController.text.trim();

    if (regNo.isEmpty || notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('patient_reports').add({
        'regNo': regNo,
        'reportType': _selectedReportType,
        'notes': notes,
        'createdAt': Timestamp.now(),
      });

      // Add a notification for the patient
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'New Medical Report',
        'message': 'A new $_selectedReportType has been added to your profile (Reg No: $regNo).',
        'patientRegNo': regNo,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient report added successfully!', style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF10B981)),
      );

      // Clear the form
      _regNoController.clear();
      _notesController.clear();
      setState(() => _selectedReportType = 'General Checkup');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding report: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Add Patient Report"),
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
      drawer: const AdminDrawer(currentPage: "reports"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.note_add_rounded, color: Color(0xFF2563EB), size: 32),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "New Medical Report",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text("Patient Registration Number", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _regNoController,
                    decoration: InputDecoration(
                      hintText: "Enter Reg No (e.g. REG12345)",
                      prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF3B82F6)),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Report Type", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedReportType,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF3B82F6)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    items: _reportTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedReportType = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text("Diagnosis & Notes", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Type detailed medical report here...",
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitReport,
                      icon: _isSubmitting 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save_rounded),
                      label: Text(_isSubmitting ? "Saving..." : "Save Patient Report"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
