import 'package:flutter/material.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';

class DeviceListScreen extends StatefulWidget {
  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final List<Host> _hosts = [];
  double? _progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected Devices'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _scanForDevices();
              },
              child: Text('Scan for Devices'),
            ),
            SizedBox(height: 20),
            if (_hosts.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _hosts.length,
                  itemBuilder: (context, index) {
                    final host = _hosts[index];
                    return ListTile(
                      title: Text('IP: ${host.internetAddress.address}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MAC Address: ${_getMacAddress(host)}'),
                          Text('Device Name: ${_getHostName(host)}'),
                          Text('Ping Time: ${host.pingTime?.toString() ?? 'N/A'}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (_progress != null)
              LinearProgressIndicator(
                value: _progress,
              ),
          ],
        ),
      ),
    );
  }

  String _getMacAddress(Host host) {
    // Add logic here to retrieve MAC address
    return 'Unknown';
  }

  String _getHostName(Host host) {
    // Add logic here to retrieve host name
    return 'Unknown';
  }

  Future<void> _scanForDevices() async {
    setState(() {
      _hosts.clear();
      _progress = 0.0;
    });

    final scanner = LanScanner(debugLogging: true);
    final wifiIp = await NetworkInfo().getWifiIP();
    final subnet = ipToCSubnet(wifiIp ?? '');
    final stream = scanner.icmpScan(
      subnet,
      scanThreads: 20,
      progressCallback: (newProgress) {
        setState(() {
          _progress = newProgress;
        });
      },
    );

    stream.listen((host) {
      setState(() {
        _hosts.add(host);
      });
    });
  }
}
