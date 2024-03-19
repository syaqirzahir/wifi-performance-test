import 'package:flutter/material.dart';

class UserData {
  static String email = ''; // Define email property
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
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
                ],
              ),
            ),
            ListTile(
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/edit_profile');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to the Speed Test App, ${UserData.email}!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
