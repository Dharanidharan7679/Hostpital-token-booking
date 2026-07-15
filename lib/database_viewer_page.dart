import 'package:flutter/material.dart';
import 'database_helper.dart';

class DatabaseViewerPage extends StatefulWidget {
  const DatabaseViewerPage({super.key});

  @override
  State<DatabaseViewerPage> createState() => _DatabaseViewerPageState();
}

class _DatabaseViewerPageState extends State<DatabaseViewerPage> {
  // Hardcoded list of our 8 Firestore collections
  final List<String> _tables = [
    'users',
    'departments',
    'doctors',
    'tokens',
    'appointments',
    'patients',
    'patient_reports',
    'notifications'
  ];
  
  Map<String, int> _rowCounts = {};
  String? _selectedTable;
  List<Map<String, dynamic>> _tableData = [];
  bool _isLoadingCounts = true;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _loadTableCounts();
  }

  Future<void> _loadTableCounts() async {
    Map<String, int> counts = {};
    for (String table in _tables) {
      try {
        final db = await DatabaseHelper.instance.database;
        var snapshot = await db.query('SELECT COUNT(*) as count FROM $table');
        if (snapshot.isNotEmpty) {
          counts[table] = int.tryParse(snapshot.first['count'].toString()) ?? 0;
        } else {
          counts[table] = 0;
        }
      } catch (e) {
        counts[table] = 0;
      }
    }
    
    if (mounted) {
      setState(() {
        _rowCounts = counts;
        _isLoadingCounts = false;
      });
    }
  }

  Future<void> _loadTableData(String table) async {
    setState(() {
      _selectedTable = table;
      _isLoadingData = true;
    });

    try {
      final db = await DatabaseHelper.instance.database;
      var snapshot = await db.query('SELECT * FROM $table LIMIT 100'); // Limit to 100 for safety
      List<Map<String, dynamic>> data = [];
      for (var row in snapshot) {
        Map<String, dynamic> map = {};
        row.fields.forEach((k, v) => map[k] = v?.toString() ?? '');
        data.add(map);
      }

      if (mounted) {
        setState(() {
          _tableData = data;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _tableData = [];
          _isLoadingData = false;
        });
      }
    }
  }

  // Get all unique keys across all documents to form the table columns
  List<String> _getColumns() {
    if (_tableData.isEmpty) return [];
    Set<String> columns = {};
    for (var row in _tableData) {
      columns.addAll(row.keys);
    }
    // ensure document_id is first
    List<String> colList = columns.toList();
    if (colList.contains('document_id')) {
      colList.remove('document_id');
      colList.insert(0, 'document_id');
    }
    return colList;
  }

  @override
  Widget build(BuildContext context) {
    List<String> columns = _getColumns();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("MySQL Database Inspector"),
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
      body: Row(
        children: [
          // Left sidebar for collections
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Total Collections: ${_tables.length}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _isLoadingCounts
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _tables.length,
                          itemBuilder: (context, index) {
                            final table = _tables[index];
                            final isSelected = table == _selectedTable;
                            return ListTile(
                              leading: const Icon(Icons.table_chart, color: Color(0xFF3B82F6)),
                              title: Text(table, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
                                child: Text("${_rowCounts[table]}"),
                              ),
                              selected: isSelected,
                              selectedTileColor: const Color(0xFFEFF6FF),
                              onTap: () => _loadTableData(table),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
          // Right side for data view
          Expanded(
            child: _selectedTable == null
                ? const Center(child: Text("Select a collection to view its raw data.", style: TextStyle(fontSize: 16, color: Color(0xFF64748B))))
                : _isLoadingData
                    ? const Center(child: CircularProgressIndicator())
                    : _tableData.isEmpty
                        ? const Center(child: Text("Collection is empty.", style: TextStyle(fontSize: 16, color: Color(0xFF64748B))))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.resolveWith((states) => const Color(0xFFE2E8F0)),
                                  columns: columns.map((String key) {
                                    return DataColumn(label: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)));
                                  }).toList(),
                                  rows: _tableData.map((Map<String, dynamic> row) {
                                    return DataRow(
                                      cells: columns.map((String col) {
                                        var val = row[col];
                                        // Handle nested objects or timestamps gracefully
                                        String displayVal = val?.toString() ?? 'null';
                                        return DataCell(Text(displayVal));
                                      }).toList(),
                                    );
                                  }).toList(),
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
