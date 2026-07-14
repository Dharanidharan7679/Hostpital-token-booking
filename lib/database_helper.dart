import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hospital.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. users
    await db.execute('''
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  role TEXT NOT NULL,
  createdAt TEXT NOT NULL
)
''');

    // 2. departments
    await db.execute('''
CREATE TABLE departments (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  createdAt TEXT NOT NULL
)
''');

    // 3. doctors
    await db.execute('''
CREATE TABLE doctors (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  department TEXT NOT NULL,
  degree TEXT NOT NULL,
  experience TEXT NOT NULL,
  createdAt TEXT NOT NULL
)
''');

    // 4. tokens
    await db.execute('''
CREATE TABLE tokens (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  age TEXT NOT NULL,
  regNo TEXT NOT NULL,
  mobile TEXT NOT NULL,
  bookedDate TEXT NOT NULL,
  status TEXT NOT NULL
)
''');

    // 5. appointments
    await db.execute('''
CREATE TABLE appointments (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  age TEXT NOT NULL,
  regNo TEXT NOT NULL,
  mobile TEXT NOT NULL,
  bookedDate TEXT NOT NULL,
  doctor TEXT NOT NULL
)
''');

    // 6. patients
    await db.execute('''
CREATE TABLE patients (
  regNo TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  mobile TEXT NOT NULL,
  age TEXT NOT NULL,
  bloodGroup TEXT,
  allergies TEXT,
  pastSurgeries TEXT
)
''');

    // 7. patient_reports
    await db.execute('''
CREATE TABLE patient_reports (
  id TEXT PRIMARY KEY,
  regNo TEXT NOT NULL,
  reportType TEXT NOT NULL,
  notes TEXT NOT NULL,
  createdAt TEXT NOT NULL
)
''');

    // 8. notifications
    await db.execute('''
CREATE TABLE notifications (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  createdAt TEXT NOT NULL
)
''');
  }

  Future<List<String>> getAllTableNames() async {
    final db = await instance.database;
    final result = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
    return result.map((e) => e['name'] as String).toList();
  }

  Future<int> getTableRowCount(String tableName) async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    final db = await instance.database;
    return await db.query(tableName);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
