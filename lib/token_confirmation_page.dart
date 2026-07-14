import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'schemes_page.dart';

class TokenConfirmationPage extends StatelessWidget {
  final String name;
  final String age;
  final String regNo;
  final String mobile;
  final DateTime bookedDate;
  final int tokenNumber;

  const TokenConfirmationPage({
    super.key,
    required this.name,
    required this.age,
    required this.regNo,
    required this.mobile,
    required this.bookedDate,
    required this.tokenNumber,
  });

  void _viewStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        // Here you can fetch actual token status from Firestore
        // For now, using static demo data
        final upcomingTokens = [tokenNumber + 1, tokenNumber + 2];
        final servingToken = tokenNumber;

        return AlertDialog(
          title: const Text("Token Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Now Serving Token No: $servingToken",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 12),
              if (upcomingTokens.isNotEmpty)
                Column(
                  children: [
                    const Text("Upcoming Patients:"),
                    for (var t in upcomingTokens)
                      Text("Token No: $t - Please Wait",
                          style: const TextStyle(color: Colors.orange)),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"))
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
        title: const Text("Booking Confirmed"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1E3A8A),
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 80),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Appointment Secured!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Your token has been successfully generated.",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Patient Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow("Patient Name", name),
                      const Divider(height: 24),
                      _buildDetailRow("Registration No", regNo),
                      const Divider(height: 24),
                      _buildDetailRow("Date", DateFormat('dd MMM yyyy').format(bookedDate)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Token Display
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "TOKEN NUMBER",
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$tokenNumber",
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // QR Code
                Container(
                  padding: const EdgeInsets.all(12),
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
                  child: QrImageView(
                    data: "Name:$name, RegNo:$regNo, Date:${DateFormat('dd-MM-yyyy').format(bookedDate)}, Token:$tokenNumber",
                    version: QrVersions.auto,
                    size: 140.0,
                    gapless: false,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                
                Text(
                  "Estimated Waiting Time: ${tokenNumber * 5} minutes",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _viewStatus(context),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text("View Live Status"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SchemesPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.policy_outlined),
                    label: const Text("View Surgery Schemes"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 15, color: Color(0xFF334155), fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
