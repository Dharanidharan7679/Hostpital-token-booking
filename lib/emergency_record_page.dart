import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';

class EmergencyRecordPage extends StatefulWidget {
  const EmergencyRecordPage({super.key});

  @override
  State<EmergencyRecordPage> createState() => _EmergencyRecordPageState();
}

class _EmergencyRecordPageState extends State<EmergencyRecordPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _patientData;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _searchPatient() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _patientData = null;
    });

    try {
      // Search by register number or phone number
      final snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('regNo', isEqualTo: query)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _patientData = snapshot.docs.first.data();
        });
      } else {
        // Fallback: search by phone number
        final phoneSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .where('mobile', isEqualTo: query)
            .limit(1)
            .get();

        if (phoneSnapshot.docs.isNotEmpty) {
          setState(() {
            _patientData = phoneSnapshot.docs.first.data();
          });
        } else {
          setState(() {
            _errorMessage = "No patient found with this ID or Phone Number.";
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching record: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Emergency EMR'),
        backgroundColor: const Color(0xFFEF4444), // Intense Red for Emergency
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Enter Patient Reg No or Mobile",
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFEF4444)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFFEF4444)),
                    onPressed: _searchPatient,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onSubmitted: (_) => _searchPatient(),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator(color: Color(0xFFEF4444))
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold))),
                  ],
                ),
              )
            else if (_patientData != null)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFCA5A5), width: 2), // Red border for emergency focus
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.emergency_rounded, size: 40, color: Color(0xFFEF4444)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _patientData!['name'] ?? 'Unknown',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Reg No: ${_patientData!['regNo'] ?? 'N/A'}",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(thickness: 1, color: Color(0xFFE2E8F0)),
                      ),
                      _buildInfoRow(Icons.cake_rounded, "Age", "${_patientData!['age'] ?? 'N/A'}"),
                      _buildInfoRow(Icons.phone_rounded, "Mobile", "${_patientData!['mobile'] ?? 'N/A'}"),
                      _buildInfoRow(Icons.bloodtype_rounded, "Blood Group", "${_patientData!['bloodGroup'] ?? 'N/A'}"),
                      _buildInfoRow(Icons.medical_services_rounded, "Past Surgeries", "${_patientData!['pastSurgeries'] ?? 'None'}"),
                      _buildInfoRow(Icons.warning_rounded, "Allergies", "${_patientData!['allergies'] ?? 'None'}"),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF64748B), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
