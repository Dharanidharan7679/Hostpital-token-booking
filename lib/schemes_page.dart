import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme.dart';

class SchemesPage extends StatelessWidget {
  const SchemesPage({super.key});

  final List<Map<String, String>> schemes = const [
    {
      "title": "Ayushman Bharat PM-JAY",
      "description": "World's largest health insurance scheme fully financed by the government, providing a cover of Rs. 5 lakhs per family per year for secondary and tertiary care hospitalization.",
      "url": "https://nha.gov.in/PM-JAY"
    },
    {
      "title": "CGHS (Central Government Health Scheme)",
      "description": "Provides comprehensive health care facilities for the Central Govt. employees and pensioners and their dependents.",
      "url": "https://cghs.nic.in/"
    },
    {
      "title": "State Specific Health Schemes",
      "description": "Various state governments offer specific health schemes covering major surgeries and medical treatments for BPL families.",
      "url": "https://www.india.gov.in/my-government/schemes"
    }
  ];

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Government Schemes'),
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
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        itemCount: schemes.length,
        itemBuilder: (context, index) {
          final scheme = schemes[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.policy_rounded, color: Color(0xFF2563EB), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          scheme["title"]!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    scheme["description"]!,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl(scheme["url"]!),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Learn More'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
