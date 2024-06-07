import 'package:flutter/material.dart';
import 'package:untitled2/widgets/database_helper.dart';
import 'package:untitled2/screens/user_data.dart';
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
        title: Text(''),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/university_logo.png',
                      height: 150,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Wifi Performance Test App',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  print('Login button pressed'); // Add this print statement
                  String email = emailController.text;
                  String password = passwordController.text;

                  // Retrieve hashed password from the database based on the provided email
                  String? hashedPassword = await dbHelper.getPassword(email);

                  // Verify the password using DBCrypt
                  bool isAuthenticated = false;
                  if (hashedPassword != null) {
                    DBCrypt bcrypt = DBCrypt();
                    isAuthenticated = bcrypt.checkpw(password, hashedPassword);
                  }

                  if (isAuthenticated) {
                    String? userName = await dbHelper.getUserName(email);

                    if (userName != null) {
                      UserData.updateName(userName);
                      UserData.updateEmail(email);
                    }
                    // Add login log
                    await addLoginLog(
                      'User Login',
                      'User $email logged in to the app',
                    );
                    Navigator.pushReplacementNamed(
                      context,
                      '/user_home',
                    );
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
                child: Text('Login'),
              ),

              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Add login log for guest user
                  addLoginLog(
                    'Guest Login',
                    'Guest user logged in to the app',
                  );
                  // Continue as Guest action
                  // For example, log in a guest account or create a guest session
                  UserData.updateName('Guest'); // Update guest name
                  UserData.updateEmail('guest@example.com'); // Update guest email

                  Navigator.pushReplacementNamed(
                    context,
                    '/user_home',
                  );
                },
                child: Text('Continue as Guest'),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/register_screen',
                  );
                },
                child: Text('Sign Up Now'),
              ),
            ],
          ),
        ),
      ),

    );

    }

  Future<void> addLoginLog(String eventType, String eventDescription) async {
    // Record login process in the logs database
    await dbHelper.addLog(
      eventType,
      eventDescription,
    );
  }

}
