import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/widgets/database_helper.dart';
import 'user_provider.dart';
import 'indoor_wifi_test.dart';
import '../widgets/project.dart'; // Import the Project class

class CreateProjectScreen extends StatefulWidget {
  @override
  _CreateProjectScreenState createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  String _projectName = '';

  void _createProject() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final dbHelper = DatabaseHelper();

      final newProject = Project(
        projectId: 0, // Auto-incremented by the database
        projectName: _projectName,
        userId: userProvider.userId!,
      );

      await dbHelper.addProject(newProject);

      // Fetch the newly created project's ID
      List<Project> projects = await dbHelper.fetchProjects(userProvider.userId!);
      int projectId = projects.last.projectId; // Assuming the new project is the last one

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WiFiTestForm(projectId: projectId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Project'),
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
              child: Column(
                children: [
                  Text(
                    'Enter Project Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Project Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onSaved: (value) => _projectName = value!,
                    validator: (value) => value!.isEmpty ? 'Please enter a project name' : null,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _createProject,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        backgroundColor: Colors.lightBlueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Create Project',
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
}
