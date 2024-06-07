import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'user_data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'network_performance_test_screen.dart';
import 'package:untitled2/widgets/database_helper.dart';
import 'wifi_list_screen.dart';
import 'package:untitled2/widgets/Network_Test_Entry.dart';
import 'map_screen.dart';
import 'device_list_screen.dart';

class UserHomeScreen extends StatefulWidget {
  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String _userLocation = 'Fetching location...';
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initLocationStream();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocationStream() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _positionStreamSubscription =
          Geolocator.getPositionStream().listen((position) {
            _fetchUserLocation(position);
          });
    } else {
      // Handle when location permission is denied
    }
  }

  Future<void> _fetchUserLocation(Position position) async {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    setState(() {
      _userLocation = '${placemarks.first.locality}, ${placemarks.first.country}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(userLocation: _userLocation);
  }
}

class HomeScreen extends StatelessWidget {
  final String userLocation;
  final DatabaseHelper dbHelper = DatabaseHelper();

  HomeScreen({required this.userLocation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.teal,
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(16, 40, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Information',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Email: ${UserData.email}',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Location: $userLocation',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.edit, color: Colors.teal),
                  title: Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/edit_profile');
                  },
                ),
                Divider(color: Colors.teal),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: dbHelper.fetchTestResults(), // Assuming this fetches test entries from the database
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final List<Map<String, dynamic>> testResults = snapshot.data!;
                      final lastTwoTests = testResults.length >= 2 ? testResults.sublist(testResults.length - 2) : testResults;

                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              'Network Performance Test History',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: lastTwoTests.length,
                            itemBuilder: (context, index) {
                              final testResult = lastTwoTests[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                child: ListTile(
                                  title: Text(
                                    'Test ${testResults.length - 1 - index}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Test Type: ${testResult['test_type'] ?? 'N/A'}',
                                          style: TextStyle(color: Colors.grey)),
                                      Text('Timestamp: ${testResult['test_timestamp'] ?? 'N/A'}',
                                          style: TextStyle(color: Colors.grey)),
                                      if (testResult['transfer'] != null)
                                        Text('Transfer: ${testResult['transfer']} MBytes',
                                            style: TextStyle(color: Colors.grey)),
                                      if (testResult['jitter'] != null)
                                        Text('Jitter: ${testResult['jitter']} ms',
                                            style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                  onTap: () {
                                    // Handle onTap event
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
                Divider(color: Colors.teal),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.teal),
                  title: Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    _logOut(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[100],
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true, // Added to make GridView take the minimum height needed
                physics: NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                children: <Widget>[
                  _buildHomeScreenButton(
                    context,
                    'Wi-Fi Performance Test',
                    Icons.speed,
                    Colors.blue,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Iperf3TestScreen(),
                      ),
                    ),
                  ),
                  _buildHomeScreenButton(
                    context,
                    'View Wi-Fi Networks',
                    Icons.wifi,
                    Colors.orange,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TestResultsPage(),
                      ),
                    ),
                  ),
                  _buildHomeScreenButton(
                    context,
                    'Indoor Wi-Fi Optimization',
                    Icons.map,
                    Colors.green,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WiFiTestForm(),
                      ),
                    ),
                  ),
                  _buildHomeScreenButton(
                    context,
                    'List of Devices Connected',
                    Icons.devices,
                    Colors.red,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceListScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildInstructionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeScreenButton(
      BuildContext context,
      String title,
      IconData icon,
      Color iconColor,
      VoidCallback onTap,
      ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 50),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Use This App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '1. Wi-Fi Performance Test: Run a zdfhbserhaerhaerhaehaerhaethjksbgbwaejkgbuiawbegiujbawuigbuiawebguibawuigbuia'
                  'wbguibawuigbuiawbguijbawuijrgbiujawebrgiubawiuejrgbiuawbgiubaewijgbijkerbgtest to check the speed and quality of your Wi-Fi.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text(
              '2. View Wi-Fi Networks: See available Wi-Fi networks and their details. zdfhbserhaerhaerhaehaerhaethjksbgbwaejkgbuiawbegiujbawuigbuiawebguibawuigbuia'
                  'wbguibawuigbuiawbguijbawuijrgbiujawebrgiubawiuejrgbiuawbgiubaewijgbijkerbgtest',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text(
              '3. Indoor Wi-Fi Optimization: View a map of your Wi-Fi coverage to optimize your setup.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text(
              '4. List of Devices Connected: View all devices currently connected to your Wi-Fi.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _logOut(BuildContext context) async {
    await dbHelper.addLog(
      'User Logout',
      'User ${UserData.email} logged out from the app',
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }
}
