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
      _userLocation =
      '${placemarks.first.locality}, ${placemarks.first.country}';
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
            color: Colors.black, // Set the app bar title color
          ),
        ),
        backgroundColor: Colors.greenAccent, // Set the app bar background color
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: 250),
            // Set maximum width for the Drawer
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blue box with user information
                LayoutBuilder(
                  builder: (context, constraints) {
                    return PreferredSize(
                      preferredSize: Size.fromHeight(
                          constraints.maxHeight), // Set dynamic preferred size
                      child: Container(
                        color: Colors.green,
                        width:
                        MediaQuery.of(context).size.width, // Match the width of the drawer
                        padding: EdgeInsets.fromLTRB(
                            16, 30, 16, 20), // Add top padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User Information',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18),
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
                    );
                  },
                ),

                // Edit Profile item
                Container(
                  decoration: BoxDecoration(
                    border:
                    Border.all(color: Colors.black), // Add border decoration
                  ),
                  child: ListTile(
                    title: Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight:
                        FontWeight.bold, // Set font weight to bold
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/edit_profile');
                    },
                  ),
                ),
                // Network Performance Test History section
                FutureBuilder<List<NetworkTestEntry>>(
                  future: dbHelper.getTestHistory(), // Fetch test history from the database
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Display loading indicator while fetching data
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Handle error
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // Display test history entries
                      return Column(
                        children: [
                          // Section header
                          ListTile(
                            title: Text(
                              'Network Performance Test History',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // List of test history entries
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final testEntry = snapshot.data![index];
                              return ListTile(
                                title: Text(
                                  'Test ${index + 1}: ${testEntry.date}',
                                  style: TextStyle(color: Colors.black),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Duration: ${testEntry.duration}', style: TextStyle(color: Colors.grey)),
                                    Text('Throughput: ${testEntry.throughput}', style: TextStyle(color: Colors.grey)),
                                    Text('Packet Loss: ${testEntry.packetLoss}', style: TextStyle(color: Colors.grey)),
                                    Text('Jitter: ${testEntry.jitter}', style: TextStyle(color: Colors.grey)),
                                    Text('Latency: ${testEntry.latency}', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                onTap: () {
                                  // Handle onTap event
                                },
                              );
                            },
                          ),

                        ],
                      );
                    }
                  },
                ),
                // Log out item
                Container(
                  decoration: BoxDecoration(
                    border:
                    Border.all(color: Colors.black), // Add border decoration
                  ),
                  child: ListTile(
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
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          // Button to conduct network performance test
          Container(
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: ListTile(
              title: Text(
                'Conduct Network Performance Test',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NetworkPerformanceTestScreen(),
                  ),
                );
              },
            ),
          ),
          // Button to navigate to the Wi-Fi list screen
          Container(
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: ListTile(
              title: Text(
                'View Wi-Fi Networks',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WifiListScreen(),
                  ),
                );
              },
            ),
          ),
          // Button to navigate to the Map screen
          Container(
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: ListTile(
              title: Text(
                'Map',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(), // Replace MapScreen with your map screen widget
                  ),
                );
              },
            ),
          ),
          // Button to navigate to the Device List screen
          Container(
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: ListTile(
              title: Text(
                'List of Devices Connected',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceListScreen(), // Replace DeviceListScreen with your device list screen widget
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _logOut(BuildContext context) async {
    // Record logout process in the logs database
    await dbHelper.addLog(
      'User Logout',
      'User ${UserData.email} logged out from the app',
    );

    // Navigate to the login screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false, // Remove all existing routes from the navigator
    );
  }
}
