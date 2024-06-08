import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/widgets/database_helper.dart';
import 'package:untitled2/screens/user_provider.dart';

class TestResultsPage extends StatefulWidget {
  @override
  _TestResultsPageState createState() => _TestResultsPageState();
}

class _TestResultsPageState extends State<TestResultsPage> {
  late Future<List<Map<String, dynamic>>> _wifiTestResultsFuture;
  late int userId;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userId = userProvider.userId!;
    setState(() {
      _wifiTestResultsFuture = _fetchWifiTestResultsByUserId(userId);
    });
  }

  Future<List<Map<String, dynamic>>> _fetchWifiTestResultsByUserId(int userId) async {
    return await DatabaseHelper().fetchWifiTestResultsByUserId(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WiFi Test Results'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _wifiTestResultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No test results found'));
          } else {
            final results = snapshot.data!;
            final groupedResults = groupTestResultsByProjectId(results);

            return ListView.builder(
              itemCount: groupedResults.length,
              itemBuilder: (context, index) {
                final projectId = groupedResults.keys.toList()[index];
                final testResultsForProject = groupedResults[projectId]!;

                return GestureDetector(
                  onTap: () {
                    // Navigate to a detailed view of the selected project
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailsPage(
                          projectId: projectId,
                          testResults: testResultsForProject,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        'Project ID: $projectId',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${testResultsForProject.length} test(s)'),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Map<int?, List<Map<String, dynamic>>> groupTestResultsByProjectId(List<Map<String, dynamic>> results) {
    final groupedResults = <int?, List<Map<String, dynamic>>>{};

    for (final result in results) {
      final projectId = result['project_id'];

      if (!groupedResults.containsKey(projectId)) {
        groupedResults[projectId] = [];
      }

      groupedResults[projectId]?.add(result);
    }

    return groupedResults;
  }
}

class ProjectDetailsPage extends StatelessWidget {
  final int? projectId;
  final List<Map<String, dynamic>> testResults;

  const ProjectDetailsPage({
    required this.projectId,
    required this.testResults,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details'),
      ),
      body: ListView.builder(
        itemCount: testResults.length,
        itemBuilder: (context, index) {
          final result = testResults[index];
          final timestampString = result['test_timestamp'].toString();

          DateTime? timestamp;
          try {
            timestamp = DateTime.parse(timestampString);
          } catch (e) {
            print('Error parsing timestamp: $e');
          }

          final formattedDate = timestamp != null ? DateFormat('yyyy-MM-dd').format(timestamp!) : 'Invalid Date';
          final formattedTime = timestamp != null ? DateFormat('HH:mm:ss').format(timestamp!) : 'Invalid Time';

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
                  Text('User ID: ${result['user_id']}'),
                  Text('Test Name: ${result['test_name']}'),
                  Text('Test Type: ${result['test_type']}'),
                  Text('Building Name: ${result['building_name']}'),
                  Text('Floor: ${result['floor']}'),
                  Text('AP Name: ${result['ap_name']}'),
                  Text('WiFi SSID: ${result['wifi_ssid']}'),
                  Text('Throughput: ${result['throughput']} Mbits/sec'),
                  Text('Transfer: ${result['transfer']} MBytes'),
                  if (result['test_type'] == 'UDP') Text('Jitter: ${result['jitter']} ms'),
                  Text('Date: $formattedDate'),
                  Text('Time: $formattedTime'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
 