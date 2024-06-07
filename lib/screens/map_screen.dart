import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/screens/user_provider.dart';
import 'package:untitled2/widgets/database_helper.dart';

class WiFiTestForm extends StatefulWidget {
  @override
  _WiFiTestFormState createState() => _WiFiTestFormState();
}

class _WiFiTestFormState extends State<WiFiTestForm> {
  final _formKey = GlobalKey<FormState>();
  final _testResult = WifiTestResult(
    userId: 0, // This will be set later
    testName: '',
    testTimestamp: DateTime.now(),
    testType: 'TCP',
    buildingName: '',
    floor: '',
    apName: '',
    wifiSsid: '',
    throughput: 0.0,
    transfer: 0.0,
    jitter: 0.0,
  );

  Future<void> _submitTestResult() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _testResult.userId = userProvider.userId!;

      await DatabaseHelper().addWifiTestResult(_testResult);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test result saved successfully')),
      );

      // Clear the form after submission
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wi-Fi Test Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Test Name'),
                onSaved: (value) => _testResult.testName = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the test name';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Test Type'),
                value: _testResult.testType,
                onChanged: (String? newValue) {
                  setState(() {
                    _testResult.testType = newValue!;
                  });
                },
                items: <String>['TCP', 'UDP']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Building Name'),
                onSaved: (value) => _testResult.buildingName = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the building name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Floor'),
                onSaved: (value) => _testResult.floor = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the floor';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'AP Name'),
                onSaved: (value) => _testResult.apName = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the AP name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'WiFi SSID'),
                onSaved: (value) => _testResult.wifiSsid = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the WiFi SSID';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Throughput (Mbps)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _testResult.throughput = double.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the throughput';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Transfer (MBytes)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _testResult.transfer = double.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the transfer';
                  }
                  return null;
                },
              ),
              if (_testResult.testType == 'UDP')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Jitter (ms)'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _testResult.jitter = double.parse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the jitter';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitTestResult,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
