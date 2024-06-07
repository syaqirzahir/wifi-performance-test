import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/screens/user_provider.dart';
import 'package:untitled2/widgets/database_helper.dart';

class Iperf3TestScreen extends StatefulWidget {
  @override
  _Iperf3TestScreenState createState() => _Iperf3TestScreenState();
}

class _Iperf3TestScreenState extends State<Iperf3TestScreen> {
  static const platform = MethodChannel('iperf3');
  String _output = 'Output will be shown here';
  String _result = '';
  bool _isTCPRunning = false;
  bool _isUDPRunning = false;
  bool _showDetails = false;
  double _testResult = 0.0; // Placeholder for the test result

  Future<void> _runIperf3TCP() async {
    setState(() {
      _isTCPRunning = true;
      _output = 'Running TCP test...';
      _result = '';
      _showDetails = false;
    });
    try {
      final output = await platform.invokeMethod('executeIperf3TCP');
      double throughput = _extractThroughput(output);
      double transfer = _extractBandwidth(output);

      setState(() {
        _output = output;
        _result = _extractTCPResults(output);
        _isTCPRunning = false;
        _testResult = throughput;
      });

      await _saveTestResultToDatabase(
        testType: 'TCP',
        throughput: throughput,
        transfer: transfer,
      );
    } on PlatformException catch (e) {
      setState(() {
        _output = "Failed to execute iperf3 TCP: '${e.message}'.";
        _result = '';
        _isTCPRunning = false;
        _testResult = 0.0;
      });
    }
  }

  Future<void> _runIperf3UDP() async {
    setState(() {
      _isUDPRunning = true;
      _output = 'Running UDP test...';
      _result = '';
      _showDetails = false;
    });
    try {
      final output = await platform.invokeMethod('executeIperf3UDP');
      double throughput = _extractThroughput(output);
      double transfer = _extractBandwidth(output);
      double jitter = _extractLatency(output);

      // Convert transfer to MBytes if necessary
      RegExp transferRegex = RegExp(r'\[\s*\d+\].* (\d+\.?\d*) (M|K)Bytes');
      Match? transferMatch = transferRegex.allMatches(output).lastOrNull;
      if (transferMatch != null && transferMatch.group(2) == 'K') {
        transfer = double.parse(transferMatch.group(1)!) / 1024; // Convert KBytes to MBytes for storage
      }

      setState(() {
        _output = output;
        _result = _extractUDPResults(output);
        _isUDPRunning = false;
        _testResult = throughput;
      });

      await _saveTestResultToDatabase(
        testType: 'UDP',
        throughput: throughput,
        transfer: transfer,
        jitter: jitter,
      );
    } on PlatformException catch (e) {
      setState(() {
        _output = "Failed to execute iperf3 UDP: '${e.message}'.";
        _result = '';
        _isUDPRunning = false;
        _testResult = 0.0;
      });
    }
  }

  String _extractTCPResults(String output) {
    RegExp transferRegex = RegExp(r'\[\s*\d+\].* (\d+\.\d+) (M|K)Bytes');
    RegExp bitrateRegex = RegExp(r'\[\s*\d+\].* (\d+\.\d+) Mbits/sec');

    Match? transferMatch = transferRegex.allMatches(output).lastOrNull;
    Match? bitrateMatch = bitrateRegex.allMatches(output).lastOrNull;

    double transfer = transferMatch != null ? double.parse(transferMatch.group(1)!) : 0.0;
    String transferUnit = transferMatch?.group(2) ?? '';
    double bitrate = bitrateMatch != null ? double.parse(bitrateMatch.group(1)!) : 0.0;

    return 'Bandwidth: $transfer ${transferUnit}Bytes\nThroughput: $bitrate Mbits/sec';
  }

  String _extractUDPResults(String output) {
    RegExp transferRegex = RegExp(r'\[\s*\d+\].* (\d+\.?\d*) (M|K)Bytes');
    RegExp bitrateRegex = RegExp(r'\[\s*\d+\].* (\d+\.\d+) Mbits/sec');
    RegExp jitterRegex = RegExp(r'\[\s*\d+\].* (\d+\.?\d*) ms');

    Match? transferMatch = transferRegex.allMatches(output).lastOrNull;
    Match? bitrateMatch = bitrateRegex.allMatches(output).lastOrNull;
    Match? jitterMatch = jitterRegex.allMatches(output).lastOrNull;

    double transfer = transferMatch != null ? double.parse(transferMatch.group(1)!) : 0.0;
    String transferUnit = transferMatch?.group(2) ?? '';
    if (transferUnit == 'K') {
      transfer /= 1024; // Convert KBytes to MBytes for storage
    }

    double bitrate = bitrateMatch != null ? double.parse(bitrateMatch.group(1)!) : 0.0;
    double jitter = jitterMatch != null ? double.parse(jitterMatch.group(1)!) : 0.0;

    return 'Bandwidth: ${transferMatch?.group(1) ?? '0.0'} KBytes\nThroughput: $bitrate Mbits/sec\nLatency: $jitter ms';
  }

  double _extractResultValue(String output) {
    RegExp bitrateRegex = RegExp(r'\[\s*\d+\].* (\d+\.\d+) Mbits/sec');
    Match? bitrateMatch = bitrateRegex.allMatches(output).lastOrNull;
    return bitrateMatch != null ? double.parse(bitrateMatch.group(1)!) : 0.0;
  }

  double _extractBandwidth(String output) {
    RegExp transferRegex = RegExp(r'\[\s*\d+\].* (\d+\.\d+) (M|K)Bytes');
    Match? transferMatch = transferRegex.allMatches(output).lastOrNull;
    if (transferMatch != null) {
      double value = double.parse(transferMatch.group(1)!);
      String unit = transferMatch.group(2)!;
      if (unit == 'K') {
        value /= 1024; // Convert KBytes to MBytes
      }
      return value;
    }
    return 0.0;
  }

  double _extractThroughput(String output) {
    RegExp bitrateRegex = RegExp(r'\[\s*\d+\].* (\d+\.\d+) (M|K)bits/sec');
    Match? bitrateMatch = bitrateRegex.allMatches(output).lastOrNull;
    if (bitrateMatch != null) {
      double value = double.parse(bitrateMatch.group(1)!);
      String unit = bitrateMatch.group(2)!;
      if (unit == 'K') {
        value /= 1024; // Convert Kbits/sec to Mbits/sec
      }
      return value;
    }
    return 0.0;
  }

  double _extractLatency(String output) {
    RegExp jitterRegex = RegExp(r'\[\s*\d+\].* (\d+\.?\d*) ms');
    Match? jitterMatch = jitterRegex.allMatches(output).lastOrNull;
    return jitterMatch != null ? double.parse(jitterMatch.group(1)!) : 0.0;
  }

  Future<void> _saveTestResultToDatabase({
    required String testType,
    required double throughput,
    required double transfer,
    double? jitter,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    int userId = userProvider.userId!; // Get the user ID from the provider

    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.insertTestResult(
      userId: userId,
      testType: testType,
      throughput: throughput,
      transfer: transfer,
      jitter: jitter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Speed Test'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 20),
                  CircularPercentIndicator(
                    radius: 120.0,
                    lineWidth: 16.0,
                    percent: _testResult / 100,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_testResult.toStringAsFixed(2)} MB/s',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text('', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    progressColor: Colors.blue,
                    backgroundColor: Colors.grey[300]!,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Container(
                      width: 170, // Make the button narrower
                      child: ElevatedButton(
                        onPressed: _isTCPRunning ? null : _runIperf3TCP,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Adjusted padding for better fit
                          textStyle: TextStyle(fontSize: 18),
                          backgroundColor: Colors.lightBlueAccent.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isTCPRunning
                            ? CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : Text(
                          'Run Stability Test',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 170, // Make the button narrower
                      child: ElevatedButton(
                        onPressed: _isUDPRunning ? null : _runIperf3UDP,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Adjusted padding for better fit
                          textStyle: TextStyle(fontSize: 18),
                          backgroundColor: Colors.lightBlueAccent.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isUDPRunning
                            ? CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : Text(
                          'Run Speed Test',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  if (_result.isNotEmpty)
                    Card(
                      color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Test Result:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            SizedBox(height: 10),
                            Text(
                              _result,
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showDetails = !_showDetails;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: TextStyle(fontSize: 18),
                        backgroundColor: Colors.lightBlueAccent.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(_showDetails
                          ? 'Hide Detailed Test Result'
                          : 'Show Detailed Test Result',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_showDetails)
                    Card(
                      color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'iPerf3 Output:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                _output,
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
