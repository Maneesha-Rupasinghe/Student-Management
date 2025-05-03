import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CompletedTasksList extends StatefulWidget {
  @override
  _CompletedTasksListState createState() => _CompletedTasksListState();
}

class _CompletedTasksListState extends State<CompletedTasksList> {
  List<dynamic> completedTasks = [];
  final _storage = FlutterSecureStorage();

  // Fetch completed tasks from backend
  Future<void> _fetchCompletedTasks() async {
    final String? token = await _storage.read(key: 'access_token');

    print("Fetching completed tasks..."); // Debugging print

    final response = await http.get(
      Uri.parse('http://192.168.1.4:8000/api/tasks/completed/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("Response status: ${response.statusCode}"); // Debugging print
    print("Response body: ${response.body}"); // Debugging print

    if (response.statusCode == 200) {
      setState(() {
        completedTasks = json.decode(response.body); // Save response data
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load completed tasks')));
      print("Error loading tasks: ${response.statusCode}"); // Debugging print
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCompletedTasks(); // Fetch completed tasks when the screen loads
  }

  // Method to show additional details for the selected task
  void _showTaskDetails(BuildContext context, dynamic task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task['task_name']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Subject: ${task['subject']}'),
              Text('Start Date: ${task['start_date']}'),
              Text('Event Date: ${task['event_date']}'),
              Text('Estimated Study Hours: ${task['estimated_study_hours']}'),
              Text('Notes: ${task['notes']}'),
              Text('Priority: ${task['priority']}'),
              Text('Status: ${task['status']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Completed Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: completedTasks.length,
          itemBuilder: (context, index) {
            final task = completedTasks[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text(task['task_name']),
                subtitle: Text('Due date: ${task['event_date']}'),
                leading: Icon(Icons.task),
                trailing: Icon(Icons.arrow_forward),
                onTap:
                    () => _showTaskDetails(
                      context,
                      task,
                    ), // Show task details on tap
              ),
            );
          },
        ),
      ),
    );
  }
}
