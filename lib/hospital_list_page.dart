import 'package:flutter/material.dart';
import 'patient_form_page.dart';
import 'hospital_map_page.dart';
import 'schemes_page.dart';
import 'theme.dart';

class HospitalListPage extends StatelessWidget {
  const HospitalListPage({super.key});

  final List<Map<String, dynamic>> hospitals = const [
    {'name': 'City Health Care'},
    {'name': 'Green Valley Hospital'},
    {'name': 'Sunrise Medical Center'},
    {'name': 'Apollo Hospital, Chennai'},
    {'name': 'MIOT International, Chennai'},
    {'name': 'Fortis Malar Hospital, Chennai'},
    {'name': 'Sri Ramachandra Medical Centre, Chennai'},
    {'name': 'Kauvery Hospital, Trichy'},
    {'name': 'Ganga Hospital, Coimbatore'},
    {'name': 'PSG Hospitals, Coimbatore'},
    {'name': 'KMCH, Coimbatore'},
    {'name': 'Velammal Medical College, Madurai'},
    {'name': 'Meenakshi Mission Hospital, Madurai'},
    {'name': 'Madurai Apollo Speciality Hospital'},
    {'name': 'Billroth Hospitals, Chennai'},
    {'name': 'Sankara Nethralaya, Chennai'},
    {'name': 'Gleneagles Global Health City, Chennai'},
    {'name': 'Rajiv Gandhi Government General Hospital, Chennai'},
    {'name': 'Government Rajaji Hospital, Madurai'},
    {'name': 'CMC Vellore'},
    {'name': 'Government Medical College Hospital, Ooty'},
    {'name': 'Salem Government Mohan Kumaramangalam Hospital'},
    {'name': 'Government Stanley Medical College Hospital'},
    {'name': 'Government Kilpauk Medical College Hospital'},
    {'name': 'Erode Government Hospital'},
    {'name': 'Dharmapuri Government Hospital'},
    {'name': 'Villupuram Medical College Hospital'},
    {'name': 'Tirunelveli Government Medical College Hospital'},
    {'name': 'Thoothukudi Medical College Hospital'},
    {'name': 'Kanyakumari Government Medical College Hospital'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Nearby Hospitals",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
              ),
              child: Text(
                'Patient Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Government Hospitals Map'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HospitalMapPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy),
              title: const Text('Government Schemes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SchemesPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: hospitals.length,
          itemBuilder: (context, index) {
            final hospital = hospitals[index];
            return Card(
              color: Colors.white,
              elevation: 5,
              shadowColor: Colors.black26,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.local_hospital,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                title: Text(
                  hospital['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientFormPage(
                        hospitalName: hospital['name'],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
