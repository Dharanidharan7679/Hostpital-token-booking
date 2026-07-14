import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'department_dash.dart';
import 'theme.dart';

class HospitalMapPage extends StatefulWidget {
  const HospitalMapPage({super.key});

  @override
  State<HospitalMapPage> createState() => _HospitalMapPageState();
}

class _HospitalMapPageState extends State<HospitalMapPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  // Full list of 30 hospitals with mock coordinates
  final List<Map<String, dynamic>> _allHospitals = [
    {'name': 'City Health Care', 'location': const LatLng(13.0827, 80.2707), 'type': 'Private', 'availableBeds': 45},
    {'name': 'Green Valley Hospital', 'location': const LatLng(11.0168, 76.9558), 'type': 'Private', 'availableBeds': 30},
    {'name': 'Sunrise Medical Center', 'location': const LatLng(9.9252, 78.1198), 'type': 'Private', 'availableBeds': 50},
    {'name': 'Apollo Hospital, Chennai', 'location': const LatLng(13.0604, 80.2496), 'type': 'Private', 'availableBeds': 150},
    {'name': 'MIOT International, Chennai', 'location': const LatLng(13.0156, 80.1802), 'type': 'Private', 'availableBeds': 120},
    {'name': 'Fortis Malar Hospital, Chennai', 'location': const LatLng(13.0116, 80.2559), 'type': 'Private', 'availableBeds': 80},
    {'name': 'Sri Ramachandra Medical Centre', 'location': const LatLng(13.0400, 80.1415), 'type': 'Private', 'availableBeds': 200},
    {'name': 'Kauvery Hospital, Trichy', 'location': const LatLng(10.8050, 78.6856), 'type': 'Private', 'availableBeds': 90},
    {'name': 'Ganga Hospital, Coimbatore', 'location': const LatLng(11.0183, 76.9427), 'type': 'Private', 'availableBeds': 110},
    {'name': 'PSG Hospitals, Coimbatore', 'location': const LatLng(11.0238, 77.0142), 'type': 'Private', 'availableBeds': 180},
    {'name': 'KMCH, Coimbatore', 'location': const LatLng(11.0392, 77.0270), 'type': 'Private', 'availableBeds': 220},
    {'name': 'Velammal Medical College, Madurai', 'location': const LatLng(9.8824, 78.1437), 'type': 'Private', 'availableBeds': 150},
    {'name': 'Meenakshi Mission Hospital, Madurai', 'location': const LatLng(9.9392, 78.1583), 'type': 'Private', 'availableBeds': 175},
    {'name': 'Madurai Apollo Speciality Hospital', 'location': const LatLng(9.9272, 78.1434), 'type': 'Private', 'availableBeds': 140},
    {'name': 'Billroth Hospitals, Chennai', 'location': const LatLng(13.0734, 80.2227), 'type': 'Private', 'availableBeds': 95},
    {'name': 'Sankara Nethralaya, Chennai', 'location': const LatLng(13.0645, 80.2425), 'type': 'Private', 'availableBeds': 60},
    {'name': 'Gleneagles Global Health City', 'location': const LatLng(12.8988, 80.2104), 'type': 'Private', 'availableBeds': 130},
    {'name': 'Rajiv Gandhi Government General Hospital', 'location': const LatLng(13.0815, 80.2764), 'type': 'Government Panel', 'availableBeds': 500},
    {'name': 'Government Rajaji Hospital, Madurai', 'location': const LatLng(9.9324, 78.1345), 'type': 'Government Panel', 'availableBeds': 400},
    {'name': 'CMC Vellore', 'location': const LatLng(12.9262, 79.1321), 'type': 'Private', 'availableBeds': 600},
    {'name': 'Government Medical College Hospital, Ooty', 'location': const LatLng(11.4118, 76.6953), 'type': 'Government Panel', 'availableBeds': 120},
    {'name': 'Salem Government Hospital', 'location': const LatLng(11.6643, 78.1460), 'type': 'Government Panel', 'availableBeds': 250},
    {'name': 'Government Stanley Medical College', 'location': const LatLng(13.1098, 80.2858), 'type': 'Government Panel', 'availableBeds': 350},
    {'name': 'Government Kilpauk Medical College', 'location': const LatLng(13.0782, 80.2435), 'type': 'Government Panel', 'availableBeds': 300},
    {'name': 'Erode Government Hospital', 'location': const LatLng(11.3444, 77.7126), 'type': 'Government Panel', 'availableBeds': 180},
    {'name': 'Dharmapuri Government Hospital', 'location': const LatLng(12.1287, 78.1582), 'type': 'Government Panel', 'availableBeds': 150},
    {'name': 'Villupuram Medical College Hospital', 'location': const LatLng(12.0006, 79.4891), 'type': 'Government Panel', 'availableBeds': 220},
    {'name': 'Tirunelveli Government Medical College', 'location': const LatLng(8.7139, 77.7567), 'type': 'Government Panel', 'availableBeds': 280},
    {'name': 'Thoothukudi Medical College Hospital', 'location': const LatLng(8.7997, 78.1352), 'type': 'Government Panel', 'availableBeds': 210},
    {'name': 'Kanyakumari Government Medical College', 'location': const LatLng(8.2144, 77.4116), 'type': 'Government Panel', 'availableBeds': 190},
  ];

  List<Map<String, dynamic>> _filteredHospitals = [];

  @override
  void initState() {
    super.initState();
    _filteredHospitals = _allHospitals;
    _searchController.addListener(_filterHospitals);
  }

  void _filterHospitals() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredHospitals = _allHospitals;
      } else {
        _filteredHospitals = _allHospitals.where((hospital) {
          final name = hospital['name'].toString().toLowerCase();
          return name.contains(query);
        }).toList();
      }
    });

    if (_filteredHospitals.isNotEmpty) {
      // Move map to the first result
      _mapController.move(_filteredHospitals.first['location'], 12.0);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showHospitalDetails(Map<String, dynamic> hospital) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hospital["name"],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  hospital["type"] == 'Government Panel' ? Icons.verified : Icons.business,
                  color: hospital["type"] == 'Government Panel' ? const Color(0xFF10B981) : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Type: ${hospital["type"]}",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.bed, color: Color(0xFF3B82F6), size: 20),
                const SizedBox(width: 8),
                Text(
                  "Available Beds: ${hospital["availableBeds"]}",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DepartmentDashboard(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Select & Book Appointment',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Find Hospitals'),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 4,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1E3A8A),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(13.0827, 80.2707), // Default to Chennai
              initialZoom: 7.0, // Zoomed out to show Tamil Nadu generally
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: _filteredHospitals.map((hospital) {
                  return Marker(
                    point: hospital["location"],
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => _showHospitalDetails(hospital),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFFEF4444),
                        size: 40.0,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          // Floating Search Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a hospital...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF3B82F6)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
