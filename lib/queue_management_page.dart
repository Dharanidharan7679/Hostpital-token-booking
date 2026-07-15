import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dashboard_page.dart';

class QueueManagementPage extends StatefulWidget {
  const QueueManagementPage({super.key});

  @override
  State<QueueManagementPage> createState() => _QueueManagementPageState();
}

class _QueueManagementPageState extends State<QueueManagementPage> {

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Today's Queue"),
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
      drawer: const AdminDrawer(currentPage: "queue"),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.database.then((db) async {
          final results = await db.query(
            'SELECT * FROM tokens WHERE bookedDate >= ? AND bookedDate < ? ORDER BY tokenNumber ASC',
            [startOfDay.toIso8601String(), endOfDay.toIso8601String()]
          );
          List<Map<String, dynamic>> items = [];
          for (var row in results) {
            Map<String, dynamic> item = {};
            row.fields.forEach((k, v) => item[k] = v?.toString() ?? '');
            items.add(item);
          }
          return items;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tokens booked for today.", style: TextStyle(color: Color(0xFF64748B), fontSize: 16)));
          }

          var tokens = snapshot.data!;

          return ListView.builder(
            itemCount: tokens.length,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            itemBuilder: (context, index) {
              var data = tokens[index];
              String status = data['status'] != null && data['status'].toString().isNotEmpty ? data['status'] : "Waiting";

              Color statusColor;
              Color bgColor;
              if (status == "Waiting") {
                statusColor = const Color(0xFFF59E0B);
                bgColor = const Color(0xFFFEF3C7);
              } else if (status == "In Progress") {
                statusColor = const Color(0xFF3B82F6);
                bgColor = const Color(0xFFDBEAFE);
              } else {
                statusColor = const Color(0xFF10B981);
                bgColor = const Color(0xFFD1FAE5);
              }

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
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${data['tokenNumber'] ?? '-'}", 
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  title: Text(
                    data['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E3A8A)),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                    onSelected: (newStatus) async {
                      final db = await DatabaseHelper.instance.database;
                      await db.query('UPDATE tokens SET status = ? WHERE id = ?', [newStatus, data['id']]);
                      setState(() {});
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: "Waiting", child: Text("Waiting")),
                      const PopupMenuItem(value: "In Progress", child: Text("In Progress")),
                      const PopupMenuItem(value: "Completed", child: Text("Completed")),
                    ],
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
