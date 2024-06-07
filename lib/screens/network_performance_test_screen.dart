import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Iperf3TestScreen extends StatefulWidget {
  @override
  _Iperf3TestScreenState createState() => _Iperf3TestScreenState();
}

class _Iperf3TestScreenState extends State<Iperf3TestScreen> {
  static const platform = MethodChannel('iperf3');
  String _output = 'Output will be shown here';

  Future<void> _runIperf3TCP() async {
    try {
      final output = await platform.invokeMethod('executeIperf3TCP');
      setState(() {
        _output = _extractResults(output);
      });
    } on PlatformException catch (e) {
      setState(() {
        _output = "Failed to execute iperf3 TCP: '${e.message}'.";
      });
    }
  }

  Future<void> _runIperf3UDP() async {
    try {
      final output = await platform.invokeMethod('executeIperf3UDP');
      setState(() {
        _output = _extractResults(output);
      });
    } on PlatformException catch (e) {
      setState(() {
        _output = "Failed to execute iperf3 UDP: '${e.message}'.";
      });
    }
  }

  String _extractResults(String output) {
    RegExp throughputRegex = RegExp(r'\d+\.\d+ (MBytes|GBytes|KBytes)');
    Match? throughputMatch = throughputRegex.firstMatch(output);

    RegExp latencyRegex = RegExp(r'jitter (\d+\.\d+) ms');
    Match? latencyMatch = latencyRegex.firstMatch(output);

    String throughput = throughputMatch?.group(0) ?? 'No throughput result';
    String latency = latencyMatch?.group(1) ?? 'No latency result';

    return "Throughput: $throughput\nLatency: $latency ms";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iperf3 Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _runIperf3TCP,
              child: Text('Run TCP Test'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _runIperf3UDP,
              child: Text('Run UDP Test'),
            ),
            SizedBox(height: 20),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 20),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  _output,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}