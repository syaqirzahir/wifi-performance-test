import 'dart:async';
import 'package:flutter/material.dart';
import 'package:untitled2/widgets//iperf3_client.dart'; // Import the Iperf3Client class

class NetworkPerformanceTestScreen extends StatefulWidget {
  @override
  _NetworkPerformanceTestScreenState createState() =>
      _NetworkPerformanceTestScreenState();
}

class _NetworkPerformanceTestScreenState
    extends State<NetworkPerformanceTestScreen> {
  String testResult = '';
  String iperfVersion = '';

  @override
  void initState() {
    super.initState();
    // Fetch and display iperf version when the screen is initialized
    fetchIperfVersion();
  }

  Future<void> fetchIperfVersion() async {
    try {
      String version = await IperfVersionChecker.getVersion();
      setState(() {
        iperfVersion = version;
      });
    } catch (e) {
      setState(() {
        iperfVersion = 'Error: $e';
      });
    }
  }

  Future<void> performNetworkTest() async {
    try {
      Map<String, dynamic> result = await Iperf3Client.runIperf3Test();
      if (result != null && result.containsKey('bandwidth')) {
        // Format the test result
        double bandwidth = result['bandwidth'];
        String formattedResult =
            'Interval           Transfer     Bitrate\n   0.00-0.00  sec   ${bandwidth.toStringAsFixed(2)} MBytes  ${bandwidth.toStringAsFixed(2)} bits/sec';
        setState(() {
          testResult = formattedResult;
        });
      } else {
        setState(() {
          testResult = 'Test failed!';
        });
      }
    } catch (e) {
      setState(() {
        testResult = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Performance Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: performNetworkTest,
              child: Text('Start Test'),
            ),
            SizedBox(height: 20),
            Text(
              testResult,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
