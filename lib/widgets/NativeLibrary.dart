import 'package:flutter/services.dart';

class NativeLibrary {
  static const platform = MethodChannel('com.example.untitled2');

  static Future<void> runIperf() async {
    try {
      await platform.invokeMethod('runIperf');
    } on PlatformException catch (e) {
      print("Failed to run iperf: '${e.message}'.");
    }
  }
}
