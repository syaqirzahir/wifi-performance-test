import 'package:flutter/material.dart';
import 'user_data.dart';
import 'package:untitled2/widgets/database_helper.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = UserData.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text;

                // Update user data in UserData class
                UserData.updateUserData(newName, UserData.email, UserData.password);

                // Update name in the database
                bool success = await DatabaseHelper().updateUserName(newName, UserData.email);

                if (success) {
                  showNotification('Profile updated successfully');
                } else {
                  showNotification('Failed to update profile');
                }

                // Delay the navigation pop by 1 second to ensure the notification is shown
                await Future.delayed(Duration(seconds: 1));
                Navigator.pop(context);
              },

              child: Text('Save'),
            ),

          ],
        ),
      ),
    );
  }

  void showNotification(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
