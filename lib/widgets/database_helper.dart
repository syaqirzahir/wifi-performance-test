import 'package:mysql1/mysql1.dart';
import 'package:untitled2/screens/user_data.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:untitled2/widgets/Network_Test_Entry.dart';

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
      user: 'syaqirzahir', // Remove the @localhost suffix
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
    String salt = new DBCrypt().gensalt();

    // Hash the password using DBCrypt
    String hashedPassword = new DBCrypt().hashpw(password, salt);

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

  Future<List<NetworkTestEntry>> getTestHistory() async {
    // Implement logic to fetch test history from the database
    // For demonstration purposes, let's return a hardcoded list of test entries
    return [
      NetworkTestEntry(
        date: '2024-03-27',
        duration: '30 Seconds',
        throughput: '50 Mbps',
        packetLoss: '1%',
        jitter: '5 ms',
        latency: '20 ms',
      ),
      NetworkTestEntry(
        date: '2024-03-28',
        duration: '60 Seconds',
        throughput: '45 Mbps',
        packetLoss: '2%',
        jitter: '6 ms',
        latency: '25 ms',
      ),
    ];
  }

}


