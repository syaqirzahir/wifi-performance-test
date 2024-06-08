import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'package:untitled2/widgets/database_helper.dart';
import 'iperf3_test_screen.dart';

class WiFiTestForm extends StatefulWidget {
  final int projectId;

  WiFiTestForm({required this.projectId});

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
    projectId: 0, // Add this line
  );

  void _navigateToIperfTestScreen() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.userId != null) {
        _testResult.userId = userProvider.userId!;
        _testResult.projectId = widget.projectId; // Add this line
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Iperf3TestScreen(testResult: _testResult),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID is not set. Please log in again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wi-Fi Test Form'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    'Enter Wi-Fi Test Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    label: 'Test Name',
                    onSaved: (value) => _testResult.testName = value!,
                    validator: (value) => value!.isEmpty ? 'Please enter the test name' : null,
                  ),
                  _buildDropdownField(
                    label: 'Test Type',
                    value: _testResult.testType,
                    items: ['TCP', 'UDP'],
                    onChanged: (value) => setState(() {
                      _testResult.testType = value!;
                    }),
                  ),
                  _buildTextField(
                    label: 'Building Name',
                    onSaved: (value) => _testResult.buildingName = value!,
                    validator: (value) => value!.isEmpty ? 'Please enter the building name' : null,
                  ),
                  _buildTextField(
                    label: 'Floor',
                    onSaved: (value) => _testResult.floor = value!,
                    validator: (value) => value!.isEmpty ? 'Please enter the floor' : null,
                  ),
                  _buildTextField(
                    label: 'AP Name',
                    onSaved: (value) => _testResult.apName = value!,
                    validator: (value) => value!.isEmpty ? 'Please enter the AP name' : null,
                  ),
                  _buildTextField(
                    label: 'WiFi SSID',
                    onSaved: (value) => _testResult.wifiSsid = value!,
                    validator: (value) => value!.isEmpty ? 'Please enter the WiFi SSID' : null,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _navigateToIperfTestScreen,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        backgroundColor: Colors.lightBlueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        keyboardType: keyboardType,
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        value: value,
        onChanged: onChanged,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }
}
