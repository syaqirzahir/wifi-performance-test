import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/widgets/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/screens/user_provider.dart';

class TestResultsPage extends StatefulWidget {
  @override
  _TestResultsPageState createState() => _TestResultsPageState();
}

class _TestResultsPageState extends State<TestResultsPage> {
  late Future<Map<String, List<Map<String, dynamic>>>> _testResultsFuture;
  String selectedTestType = 'TCP';

  @override
  void initState() {
    super.initState();
    _testResultsFuture = fetchTestResults();
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchTestResults() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final results = await DatabaseHelper().fetchTestResults();
    final Map<String, List<Map<String, dynamic>>> segregatedResults = {
      'TCP': [],
      'UDP': [],
    };

    for (var result in results) {
      if (result['user_id'] == userProvider.userId) {
        if (result['test_type'] == 'TCP') {
          segregatedResults['TCP']!.add(result);
        } else if (result['test_type'] == 'UDP') {
          segregatedResults['UDP']!.add(result);
        }
      }
    }

    return segregatedResults;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Results'),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _testResultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data!['TCP']!.isEmpty && snapshot.data!['UDP']!.isEmpty)) {
            return Center(child: Text('No test results found'));
          } else {
            final results = snapshot.data!;
            final tcpResults = results['TCP']!;
            final udpResults = results['UDP']!;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedTestType = 'TCP';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedTestType == 'TCP' ? Colors.teal : Colors.grey,
                      ),
                      child: Text('Stability Test Results'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedTestType = 'UDP';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedTestType == 'UDP' ? Colors.teal : Colors.grey,
                      ),
                      child: Text('UDP Test Results'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedTestType == 'TCP' ? tcpResults.length : udpResults.length,
                    itemBuilder: (context, index) {
                      final result = selectedTestType == 'TCP' ? tcpResults[index] : udpResults[index];
                      final timestampString = result['test_timestamp'].toString();

                      // Ensure the timestamp string is properly parsed to DateTime
                      DateTime? timestamp;
                      try {
                        timestamp = DateTime.parse(timestampString);
                      } catch (e) {
                        print('Error parsing timestamp: $e');
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text('Invalid date format for Test ID: ${result['id']}'),
                          ),
                        );
                      }

                      final formattedDate = DateFormat('yyyy-MM-dd').format(timestamp);
                      final formattedTime = DateFormat('HH:mm:ss').format(timestamp);

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            'Test ID: ${result['id']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Text('User ID: ${result['user_id']}'),
                              Text('Type: ${result['test_type']}'),
                              Text('Date: $formattedDate'),
                              Text('Time: $formattedTime'),
                              SizedBox(height: 4),
                              Divider(),
                              SizedBox(height: 4),
                              Text('Throughput: ${result['throughput']} Mbits/sec'),
                              Text('Transfer: ${result['transfer']} MBytes'),
                              if (result['test_type'] == 'UDP')
                                Text('Jitter: ${result['jitter']} ms'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
