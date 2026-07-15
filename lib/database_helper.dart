import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  MySqlConnection? _connection;

  DatabaseHelper._init();

  Future<MySqlConnection> get database async {
    if (_connection != null) {
      // Check if connection is still alive, if not reconnect (basic check, in a real app a connection pool is better)
      return _connection!;
    }
    _connection = await _initDB();
    return _connection!;
  }

  Future<MySqlConnection> _initDB() async {
    final settings = ConnectionSettings(
      host: 'localhost', // Use 10.0.2.2 if running on Android emulator connecting to host machine
      port: 3306,
      user: 'root', // Assuming root as not specified
      password: 'Dharani@123',
      db: 'hospital_db',
    );

    try {
      final conn = await MySqlConnection.connect(settings);
      await _createTablesIfNotExist(conn);
      return conn;
    } catch (e) {
      print('Database connection failed: $e');
      rethrow;
    }
  }

  Future _createTablesIfNotExist(MySqlConnection db) async {
    // 1. users
    await db.query('''
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(255) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL,
        password VARCHAR(255) NOT NULL,
        role VARCHAR(50) NOT NULL,
        createdAt VARCHAR(255) NOT NULL
      )
    ''');

    // 2. departments
    await db.query('''
      CREATE TABLE IF NOT EXISTS departments (
        id VARCHAR(255) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        createdAt VARCHAR(255) NOT NULL
      )
    ''');

    // 3. doctors
    await db.query('''
      CREATE TABLE IF NOT EXISTS doctors (
        id VARCHAR(255) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        department VARCHAR(255) NOT NULL,
        degree VARCHAR(255) NOT NULL,
        experience VARCHAR(255) NOT NULL,
        createdAt VARCHAR(255) NOT NULL
      )
    ''');

    // 4. tokens
    await db.query('''
      CREATE TABLE IF NOT EXISTS tokens (
        id VARCHAR(255) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        age VARCHAR(50) NOT NULL,
        regNo VARCHAR(255) NOT NULL,
        mobile VARCHAR(50) NOT NULL,
        bookedDate VARCHAR(255) NOT NULL,
        status VARCHAR(50),
        doctor VARCHAR(255),
        tokenNumber INT,
        type VARCHAR(50),
        createdAt VARCHAR(255)
      )
    ''');

    // 5. appointments
    await db.query('''
      CREATE TABLE IF NOT EXISTS appointments (
        id VARCHAR(255) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        age VARCHAR(50) NOT NULL,
        regNo VARCHAR(255) NOT NULL,
        mobile VARCHAR(50) NOT NULL,
        bookedDate VARCHAR(255) NOT NULL,
        doctor VARCHAR(255),
        tokenNumber INT,
        type VARCHAR(50),
        createdAt VARCHAR(255)
      )
    ''');

    // 6. patients
    await db.query('''
      CREATE TABLE IF NOT EXISTS patients (
        regNo VARCHAR(255) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        mobile VARCHAR(50) NOT NULL,
        age VARCHAR(50) NOT NULL,
        bloodGroup VARCHAR(50),
        allergies TEXT,
        pastSurgeries TEXT
      )
    ''');

    // 7. patient_reports
    await db.query('''
      CREATE TABLE IF NOT EXISTS patient_reports (
        id VARCHAR(255) PRIMARY KEY,
        regNo VARCHAR(255) NOT NULL,
        reportType VARCHAR(255) NOT NULL,
        notes TEXT NOT NULL,
        createdAt VARCHAR(255) NOT NULL
      )
    ''');

    // 8. notifications
    await db.query('''
      CREATE TABLE IF NOT EXISTS notifications (
        id VARCHAR(255) PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        createdAt VARCHAR(255) NOT NULL
      )
    ''');
  }

  Future<List<String>> getAllTableNames() async {
    final db = await instance.database;
    final results = await db.query("SHOW TABLES");
    List<String> tableNames = [];
    for (var row in results) {
      tableNames.add(row[0].toString());
    }
    return tableNames;
  }

  Future<int> getTableRowCount(String tableName) async {
    final db = await instance.database;
    final results = await db.query('SELECT COUNT(*) FROM $tableName');
    for (var row in results) {
      return int.tryParse(row[0].toString()) ?? 0;
    }
    return 0;
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    final db = await instance.database;
    final results = await db.query('SELECT * FROM $tableName');
    
    List<Map<String, dynamic>> data = [];
    for (var row in results) {
      Map<String, dynamic> rowMap = {};
      row.fields.forEach((key, value) {
        // Convert Blob to String if necessary, else just pass value
        if (value is Blob) {
           rowMap[key] = value.toString();
        } else {
           rowMap[key] = value;
        }
      });
      data.add(rowMap);
    }
    return data;
  }

  Future close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
