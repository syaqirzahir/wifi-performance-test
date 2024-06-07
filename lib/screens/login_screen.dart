import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/widgets/database_helper.dart';
import 'package:untitled2/screens/user_data.dart';
import 'package:untitled2/screens/user_provider.dart';
import 'package:dbcrypt/dbcrypt.dart'; // Import dbcrypt package

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Image.asset(
                'assets/university_logo.png',
                height: 150,
              ),
              SizedBox(height: 20),
              Text(
                'WiFi Performance Test App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.lightBlueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.lightBlueAccent),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.lightBlueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.lightBlueAccent),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  print('Login button pressed');
                  String email = emailController.text;
                  String password = passwordController.text;

                  String? hashedPassword = await dbHelper.getPassword(email);

                  bool isAuthenticated = false;
                  if (hashedPassword != null) {
                    DBCrypt bcrypt = DBCrypt();
                    isAuthenticated = bcrypt.checkpw(password, hashedPassword);
                  }

                  if (isAuthenticated) {
                    String? userName = await dbHelper.getUserName(email);
                    int? userId = await dbHelper.getUserId(email);

                    if (userName != null && userId != null) {
                      UserData.updateName(userName);
                      UserData.updateEmail(email);

                      Provider.of<UserProvider>(context, listen: false).setUserId(userId);
                    }

                    await addLoginLog('User Login', 'User $email logged in to the app');

                    Navigator.pushReplacementNamed(context, '/user_home');
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Authentication Failed'),
                        content: Text('Invalid email or password. Please try again.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text('Login', style: TextStyle(fontSize: 18)),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: Colors.lightBlueAccent,
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  addLoginLog('Guest Login', 'Guest user logged in to the app');
                  UserData.updateName('Guest');
                  UserData.updateEmail('guest@example.com');

                  Navigator.pushReplacementNamed(context, '/user_home');
                },
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(color: Colors.lightBlueAccent, fontSize: 16),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register_screen');
                },
                child: Text(
                  'Sign Up Now',
                  style: TextStyle(color: Colors.lightBlueAccent, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addLoginLog(String eventType, String eventDescription) async {
    await dbHelper.addLog(eventType, eventDescription);
  }
}
