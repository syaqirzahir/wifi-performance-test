import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MyLocationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Request location permission
            var status = await Permission.location.request();
            if (status.isGranted) {
              // Location permission granted, proceed with location-related tasks
            } else {
              // Location permission denied, handle accordingly
            }
          },
          child: Text('Request Location Permission'),
        ),
      ),
    );
  }
}
