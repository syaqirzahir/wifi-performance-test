import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart'; // Import for MethodChannel
import 'guest_home_screen.dart';
import 'login_screen.dart';
import 'user_home_screen.dart';
import 'register_screen.dart';
import 'edit_profile_screen.dart'; // Import the EditProfileScreen
import 'welcome.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'user_provider.dart'; // Import UserProvider

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static const platform = MethodChannel('iperf3'); // Define the MethodChannel

  @override
  Widget build(BuildContext context) {
    // Initialize location and storage services when the app starts
    initPermissions(context);

    // Call the method to copy the correct ABI for iperf3
    _copyIperf3Binary();

    return MaterialApp(
      title: 'Speed Test App',
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/login': (context) => LoginScreen(),
        '/guest_home': (context) => GuestHomeScreen(),
        '/user_home': (context) => UserHomeScreen(),
        '/register_screen': (context) => RegisterScreen(),
        '/edit_profile': (context) => EditProfileScreen(),
        // Add the route for EditProfileScreen
      },
      theme: ThemeData(
        primaryColor: Colors.yellow, // Define primary color here
        scaffoldBackgroundColor: Color(0xFFFFF9C4), // Dark Grayish Black
        // Define scaffold background color here
        appBarTheme: AppBarTheme(
          color: Colors.yellow, // Define AppBar color here
          iconTheme: IconThemeData(color: Colors.black), // AppBar icons color
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.yellow, // Define button color here
          textTheme: ButtonTextTheme.primary, // Button text color theme
        ),
      ),
    );
  }

  Future<void> initPermissions(BuildContext context) async {
    // Request locationWhenInUse permission
    var locationStatus = await Permission.locationWhenInUse.status;
    if (!locationStatus.isGranted) {
      var status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        // Request storage permission if locationWhenInUse permission is granted
        await _requestStoragePermission();
      }
    } else {
      // locationWhenInUse permission was previously granted
      // Request storage permission
      await _requestStoragePermission();
    }
  }

  Future<void> _requestStoragePermission() async {
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        // Handle when storage permission is denied
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
      // storage permission was previously granted
      // Do something
    }
  }

  Future<void> _copyIperf3Binary() async {
    try {
      await platform.invokeMethod('copyIperf3Binary');
    } on PlatformException catch (e) {
      print("Failed to copy iperf3 binary: '${e.message}'.");
    }
  }
}
