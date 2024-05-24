import 'package:flutter/material.dart';
import 'package:untitled2/widgets/database_helper.dart';
import 'login_screen.dart'; // Import the LoginScreen

class RegisterScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController retypePasswordController = TextEditingController(); // Add retype password controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
    leading: IconButton(
    icon: Icon(Icons.arrow_back),
      onPressed: () {
        // Navigate back to the login screen
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
    ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress, // Set keyboard type to email
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
            TextField(
              controller: retypePasswordController, // Use retype password controller
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Retype Password', // Label for retype password field
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text.trim();
                String email = emailController.text.trim();
                String password = passwordController.text;
                String retypePassword = retypePasswordController.text;

                // Regular expression to validate email format
                RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                // Check if all fields are filled and email format is correct
                if (name.isNotEmpty &&
                    email.isNotEmpty &&
                    password.isNotEmpty &&
                    retypePassword.isNotEmpty &&
                    emailRegExp.hasMatch(email)) {
                  // Check if password and retype password match
                  if (password == retypePassword) {
                    try {
                      final dbHelper = DatabaseHelper();
                      // Check if email already exists in the database
                      bool emailExists = await dbHelper.checkEmailExists(email);
                      if (emailExists) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Email already in use')),
                        );
                        // Clear the email field
                        emailController.clear();
                      } else {
                        // Register the user if email is not in use
                        await dbHelper.addUser(name, email, password);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Registration successful')),
                        );
                        // Delay navigation back to the login screen
                        await Future.delayed(Duration(seconds: 2));
                        // Navigate to the login screen and replace the current route
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      }
                    } catch (e) {
                      print('Error registering user: $e'); // Log error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to register user')),
                      );
                    }
                  } else {
                    // Clear password fields if passwords do not match
                    passwordController.clear();
                    retypePasswordController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Passwords do not match')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill valid email')),
                  );
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
