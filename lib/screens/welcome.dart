import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Center(
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
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
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
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register_screen');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text('Sign Up', style: TextStyle(fontSize: 18)),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: Colors.lightBlueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
