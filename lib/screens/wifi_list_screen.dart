import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
class WifiListScreen extends StatefulWidget {
  @override
  _WifiListScreenState createState() => _WifiListScreenState();
}

class _WifiListScreenState extends State<WifiListScreen> {
  late List<WiFiAccessPoint> _wifiList = [];
  late Stream<List<WiFiAccessPoint>> _scannedResultsStream;

  @override
  void initState() {
    super.initState();
    _scannedResultsStream = WiFiScan.instance.onScannedResultsAvailable;
    _startWifiScan();
  }

  Future<void> _startWifiScan() async {
    try {
      bool success = await WiFiScan.instance.startScan();
      if (!success) {
        print('Failed to start Wi-Fi scan');
      }
    } catch (e) {
      print('Error starting Wi-Fi scan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wi-Fi List'),
      ),
      body: StreamBuilder<List<WiFiAccessPoint>>(
        stream: _scannedResultsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            _wifiList = snapshot.data!;
            return ListView.builder(
              itemCount: _wifiList.length,
              itemBuilder: (context, index) {
                WiFiAccessPoint network = _wifiList[index];
                return ListTile(
                  title: Text(network.ssid),
                  subtitle: Text('Signal Strength: ${network.level} dBm'),
                );
              },
            );
          } else {
            return Center(child: Text('No Wi-Fi networks found'));
          }
        },
      ),
    );
  }
}