import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'guest_home_screen.dart';
import 'user_home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Test App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/guest_home': (context) => GuestHomeScreen(),
        '/user_home': (context) => UserHomeScreen(),
      },
    );
  }
}