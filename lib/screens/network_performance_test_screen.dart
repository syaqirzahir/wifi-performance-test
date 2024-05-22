import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Iperf3TestScreen extends StatefulWidget {
  @override
  _Iperf3TestScreenState createState() => _Iperf3TestScreenState();
}

class _Iperf3TestScreenState extends State<Iperf3TestScreen> {
  static const platform = MethodChannel('iperf3');
  String _output = 'Output will be shown here';

  Future<void> _runIperf3() async {
    try {
      final output = await platform.invokeMethod('executeIperf3');
      setState(() {
        _output = output;
      });
    } on PlatformException catch (e) {
      setState(() {
        _output = "Failed to execute iperf3: '${e.message}'.";
      });
    }
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
              onPressed: _runIperf3,
              child: Text('Run Iperf3'),
            ),
            SizedBox(height: 20),
            Text(_output),
          ],
        ),
      ),
    );
  }
}
