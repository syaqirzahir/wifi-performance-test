import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'guest_home_screen.dart';
import 'login_screen.dart';
import 'user_home_screen.dart';
import 'register_screen.dart';
import 'edit_profile_screen.dart'; // Import the EditProfileScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize location services when the app starts
    initLocationServices(context);

    return MaterialApp(
      title: 'Speed Test App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/guest_home': (context) => GuestHomeScreen(),
        '/user_home': (context) => UserHomeScreen(),
        '/register_screen': (context) => RegisterScreen(),
        '/edit_profile': (context) => EditProfileScreen(), // Add the route for EditProfileScreen
      },
      theme: ThemeData(
        primaryColor: Colors.redAccent, // Define primary color here
      ),
    );
  }

  Future<void> initLocationServices(BuildContext context) async {
    // Request locationWhenInUse permission
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      var status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        // Check for locationAlways permission
        var alwaysStatus = await Permission.locationAlways.status;
        if (!alwaysStatus.isGranted) {
          var alwaysStatus = await Permission.locationAlways.request();
          if (alwaysStatus.isGranted) {
            // Do something
          } else {
            // Handle when locationAlways permission is denied
          }
        } else {
          // locationAlways permission was previously granted
          // Do something
        }
      } else {
        // Handle when locationWhenInUse permission is denied
      }

      // Check if permission is permanently denied
      if (status.isPermanentlyDenied) {
        // Open app settings
        bool result = await openAppSettings();
        if (!result) {
          // Unable to open app settings
        }
      }
    } else {
      // locationWhenInUse permission was previously granted
      // Check if locationAlways permission is needed
      var alwaysStatus = await Permission.locationAlways.status;
      if (!alwaysStatus.isGranted) {
        var alwaysStatus = await Permission.locationAlways.request();
        if (alwaysStatus.isGranted) {
          // Do something
        } else {
          // Handle when locationAlways permission is denied
        }
      } else {
        // locationAlways permission was previously granted
        // Do something
      }
    }
  }
}
