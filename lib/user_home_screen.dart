import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'user_data.dart';
import 'package:permission_handler/permission_handler.dart';

class UserHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userLocation = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocoding to get the human-readable address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      // Construct the human-readable address
      String address =
          '${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

      setState(() {
        _userLocation = address;
      });
    } catch (e) {
      print('Error fetching location: $e');
      setState(() {
        _userLocation = 'Failed to fetch location';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: 250), // Set maximum width for the Drawer
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Make the blue box taller than the white box
                Container(
                  color: Colors.blue,
                  height: 200, // Adjust the height of the DrawerHeader
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Information',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Email: ${UserData.email}',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Location: $_userLocation',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Add ListView for other items in the Drawer
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    ListTile(
                      title: Text('Edit Profile'),
                      onTap: () {
                        Navigator.pushNamed(context, '/edit_profile');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to the Speed Test App!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
