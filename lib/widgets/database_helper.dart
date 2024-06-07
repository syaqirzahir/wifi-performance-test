import 'package:mysql1/mysql1.dart';
import 'package:dbcrypt/dbcrypt.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static MySqlConnection? _connection;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  Future<MySqlConnection> get connection async {
    if (_connection != null) return _connection!;
    _connection = await _connectToDatabase();
    return _connection!;
  }

  Future<MySqlConnection> _connectToDatabase() async {
    final settings = ConnectionSettings(
      host: '192.168.0.110', // Replace with your MariaDB host
      port: 3306, // Default MySQL port
      user: 'syaqirzahir', // Replace with your MariaDB user
      password: 'along619', // Replace with your MariaDB password
      db: 'data', // Replace with your MariaDB database name
    );

    return await MySqlConnection.connect(settings);
  }

  Future<String?> getPassword(String email) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT password FROM users WHERE email = ?',
      [email],
    );
    if (results.isNotEmpty) {
      return results.first['password'] as String?;
    }
    return null; // Return null if user with the specified email is not found
  }

  Future<bool> authenticateUser(String email, String password) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT password FROM users WHERE email = ?',
      [email],
    );
    if (results.isNotEmpty) {
      // Retrieve hashed password from the database
      String hashedPasswordFromDb = results.first['password'] as String;

      // Verify the password using DBCrypt
      return DBCrypt().checkpw(password, hashedPasswordFromDb);
    }
    return false; // Return false if user with the specified email is not found
  }

  Future<int?> getUserId(String email) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT id FROM users WHERE email = ?',
      [email],
    );
    if (results.isNotEmpty) {
      return results.first['id'] as int?;
    }
    return null; // Return null if user with the specified email is not found
  }

  Future<String?> getUserName(String email) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT name FROM users WHERE email = ?',
      [email],
    );
    if (results.isNotEmpty) {
      return results.first['name'];
    }
    return null; // Return null if user with the specified email is not found
  }

  Future<void> addUser(String name, String email, String password) async {
    final conn = await connection;

    // Generate a salt for hashing the password
    String salt = DBCrypt().gensalt();

    // Hash the password using DBCrypt
    String hashedPassword = DBCrypt().hashpw(password, salt);

    // Insert the user data into the database
    await conn.query('''
    INSERT INTO users (name, email, password, salt)
    VALUES (?, ?, ?, ?)
    ''', [name, email, hashedPassword, salt]);
  }

  Future<bool> updateUserName(String newName, String email) async {
    final conn = await connection;
    try {
      await conn.query(
        'UPDATE users SET name = ? WHERE email = ?',
        [newName, email],
      );
      return true; // Return true if the update operation was successful
    } catch (e) {
      print('Error updating user name: $e');
      return false; // Return false if the update operation failed
    }
  }

  Future<bool> checkEmailExists(String email) async {
    final conn = await connection;
    var result = await conn.query(
      'SELECT * FROM users WHERE email = ?',
      [email],
    );
    return result.isNotEmpty;
  }

  Future<void> addLog(String eventType, String eventDescription) async {
    final conn = await connection;
    await conn.query('''
      INSERT INTO logs (event_type, event_description, created_at)
      VALUES (?, ?, NOW())
    ''', [eventType, eventDescription]);
  }

  Future<void> insertTestResult({
    required int userId,
    required String testType,
    required double throughput,
    required double transfer,
    double? jitter,
  }) async {
    final conn = await connection;
    await conn.query('''
    INSERT INTO test_results (user_id, test_type, throughput, transfer, jitter)
    VALUES (?, ?, ?, ?, ?)
    ''', [userId, testType, throughput, transfer, jitter]);
  }

  Future<List<Map<String, dynamic>>> fetchTestResults() async {
    final conn = await connection;
    final results = await conn.query('SELECT * FROM test_results');
    return results.map((result) => result.fields).toList();
  }

  Future<void> addWifiTestResult(WifiTestResult result) async {
    final conn = await connection;
    await conn.query('''
      INSERT INTO wifi_test_results (
        user_id, test_name, test_timestamp, test_type, building_name, floor, ap_name, wifi_ssid, throughput, transfer, jitter
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      result.userId, result.testName, result.testTimestamp.toIso8601String(), result.testType,
      result.buildingName, result.floor, result.apName, result.wifiSsid, result.throughput,
      result.transfer, result.jitter
    ]);
  }

  Future<List<Map<String, dynamic>>> fetchWifiTestResults() async {
    final conn = await connection;
    final results = await conn.query('SELECT * FROM wifi_test_results');
    return results.map((result) => result.fields).toList();
  }

  getTestHistory() {}
}

class WifiTestResult {
  int userId;
  String testName;
  DateTime testTimestamp;
  String testType;
  String buildingName;
  String floor;
  String apName;
  String wifiSsid;
  double throughput;
  double transfer;
  double jitter;

  WifiTestResult({
    required this.userId,
    required this.testName,
    required this.testTimestamp,
    required this.testType,
    required this.buildingName,
    required this.floor,
    required this.apName,
    required this.wifiSsid,
    required this.throughput,
    required this.transfer,
    required this.jitter,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'test_name': testName,
      'test_timestamp': testTimestamp.toIso8601String(),
      'test_type': testType,
      'building_name': buildingName,
      'floor': floor,
      'ap_name': apName,
      'wifi_ssid': wifiSsid,
      'throughput': throughput,
      'transfer': transfer,
      'jitter': jitter,
    };
  }
}
