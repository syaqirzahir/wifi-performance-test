import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              onPressed: () {
                // Perform login logic here
                String email = emailController.text;
                String password = passwordController.text;

                bool isRegisteredUser = true; // Replace with your actual login logic

                // Navigate to the appropriate home screen based on user status
                Navigator.pushReplacementNamed(
                  context,
                  isRegisteredUser ? '/user_home' : '/guest_home',
                );
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate to the home screen directly
                Navigator.pushReplacementNamed(
                  context,
                  '/guest_home',
                );
              },
              child: Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
