import 'package:flutter/services.dart';

class Iperf3Service {
  static const MethodChannel _channel = MethodChannel('iperf3');

  static Future<String> runIperf3() async {
    try {
      final String result = await _channel.invokeMethod('runIperf3');
      return result;
    } on PlatformException catch (e) {
      return "Failed to run iperf3: '${e.message}'.";
    }
  }
}
