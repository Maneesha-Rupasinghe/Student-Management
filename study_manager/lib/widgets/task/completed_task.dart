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

  Future<void> _fetchCompletedTasks() async {
    final String? token = await _storage.read(key: 'access_token');
    print("Fetching completed tasks...");

    final response = await http.get(
      Uri.parse('http://192.168.1.4:8000/api/tasks/completed/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        completedTasks = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load completed tasks')),
      );
      print("Error loading tasks: ${response.statusCode}");
    }
  }

  void _showTaskDetails(BuildContext context, dynamic task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task['task_name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Subject: ${task['subject']}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Start Date: ${task['start_date']}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Event Date: ${task['event_date']}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Estimated Study Hours: ${task['estimated_study_hours']}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Notes: ${task['notes']}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Priority: ${task['priority']}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Status: ${task['status']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCompletedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Tasks'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: completedTasks.length,
          itemBuilder: (context, index) {
            final task = completedTasks[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: Colors.green[50],
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(
                  task['task_name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Due: ${task['event_date']}'),
                leading: const Icon(Icons.check_circle, color: Colors.green),
                trailing: const Icon(Icons.arrow_forward, color: Colors.blue),
                onTap: () => _showTaskDetails(context, task),
              ),
            );
          },
        ),
      ),
    );
  }
}
