import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UpcomingTasksList extends StatefulWidget {
  @override
  _UpcomingTasksListState createState() => _UpcomingTasksListState();
}

class _UpcomingTasksListState extends State<UpcomingTasksList> {
  List<dynamic> tasks = [];
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final String? token = await _storage.read(key: 'access_token');
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/tasks/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        tasks = json.decode(response.body);
        print(tasks); // Debug: Check the response structure
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tasks')),
      );
    }
  }

  Future<void> _updateTaskStatus(int taskId, String newStatus) async {
    if (taskId == null || taskId is! int) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid task ID')),
      );
      return;
    }

    final String? token = await _storage.read(key: 'access_token');
    final response = await http.patch(
      Uri.parse('http://10.0.2.2:8000/api/tasks/$taskId/status/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      _fetchTasks(); // Refresh task list after status update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task status updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task status')),
      );
    }
  }

  Future<void> _fetchStudyPlan(int taskId) async {
    final String? token = await _storage.read(key: 'access_token');
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/study-plan-data/$taskId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final studyPlan = json.decode(response.body);
        _showStudyPlanDialog(studyPlan);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load study plan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching study plan: $e')),
      );
    }
  }

  void _showStudyPlanDialog(List<dynamic> studyPlan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Study Plan Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: studyPlan.length,
            itemBuilder: (context, index) {
              final day = studyPlan[index];
              final studyDate = DateTime.parse(day['study_date']);
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${studyDate.toLocal().toString().split(' ')[0]} (${studyDate.weekday == 1 ? 'Monday' : studyDate.weekday == 2 ? 'Tuesday' : studyDate.weekday == 3 ? 'Wednesday' : studyDate.weekday == 4 ? 'Thursday' : studyDate.weekday == 5 ? 'Friday' : studyDate.weekday == 6 ? 'Saturday' : 'Sunday'})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Subject: ${day['subject']}', style: TextStyle(fontSize: 16)),
                      Text('Study Time: ${day['study_time']}', style: TextStyle(fontSize: 16)),
                      Text('Total Hours: ${day['total_hours']}', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text(
                        'Sessions:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      ...day['sessions'].map<Widget>((session) => Padding(
                            padding: EdgeInsets.only(left: 16, top: 4),
                            child: Text(
                              '• ${session['start_time']} - ${session['end_time']} (${session['hours_to_study']} hours)',
                              style: TextStyle(fontSize: 14),
                            ),
                          )).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Tasks',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            if (task['id'] == null) {
              return SizedBox.shrink();
            }
            final dueDate = DateTime.parse(task['event_date']);
            final status = task['status'];

            // Display overdue tasks in red
            final overdue =
                dueDate.isBefore(DateTime.now()) && status != 'Complete';

            return Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              color: overdue ? Colors.red.shade100 : null,
              child: ListTile(
                title: Text(task['task_name']),
                subtitle: Text('Due date: ${dueDate.toLocal()}'),
                leading: Icon(Icons.task),
                trailing: PopupMenuButton<String>(
                  onSelected: (status) {
                    _updateTaskStatus(task['id'], status);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'Complete', child: Text('Complete')),
                    PopupMenuItem(value: 'Not Complete', child: Text('Not Complete')),
                    PopupMenuItem(value: 'Pending', child: Text('Pending')),
                    PopupMenuItem(value: 'Deleted', child: Text('Delete')),
                  ],
                ),
                onTap: () => _fetchStudyPlan(task['id']),
              ),
            );
          },
        ),
      ],
    );
  }
}