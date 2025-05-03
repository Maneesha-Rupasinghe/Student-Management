import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:study_manager/services/notification_service.dart';
import 'package:study_manager/widgets/plan/study_plan_editor.dart';
import 'package:intl/intl.dart';

class UpcomingTasksList extends StatefulWidget {
  const UpcomingTasksList({Key? key}) : super(key: key);

  @override
  _UpcomingTasksListState createState() => _UpcomingTasksListState();
}

class _UpcomingTasksListState extends State<UpcomingTasksList> {
  List<dynamic> tasks = [];
  final _storage = const FlutterSecureStorage();
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to view tasks')),
      );
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.4:8000/api/tasks/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('Fetch tasks response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          tasks = json.decode(response.body);
          print('Tasks loaded: $tasks');
          // Commented out to avoid repeated reminders
          // _scheduleTaskNotifications();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load tasks: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Fetch tasks error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching tasks: $e')));
    }
  }

  // Future<void> _scheduleTaskNotifications() async {
  //   for (var task in tasks) {
  //     final taskId = task['id'] as int?;
  //     final taskName = task['task_name'] ?? 'Unnamed Task';
  //     final eventDate = task['event_date'] as String?;
  //     if (taskId == null || eventDate == null) continue;

  //     try {
  //       final dueDate = DateTime.parse(eventDate);
  //       final notificationTime = dueDate.subtract(const Duration(hours: 1));
  //       if (notificationTime.isAfter(DateTime.now())) {
  //         await _notificationService.scheduleNotification(
  //           taskId,
  //           'Task Reminder: $taskName',
  //           'Due on ${DateFormat('yyyy-MM-dd').format(dueDate)}',
  //           notificationTime,
  //         );
  //         print('Scheduled notification for task $taskId at $notificationTime');
  //       }
  //     } catch (e) {
  //       print('Error scheduling notification for task $taskId: $e');
  //     }
  //   }
  // }

  Future<void> _updateTaskStatus(int taskId, String newStatus) async {
    if (taskId <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid task ID')));
      return;
    }
    print('Updating task $taskId status to $newStatus');

    final String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to update task status')),
      );
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('http://192.168.1.4:8000/api/tasks/$taskId/status/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': newStatus}),
      );
      print(
        'Update task status response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        await _fetchTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task status updated successfully')),
        );
        final task = tasks.firstWhere(
          (t) => t['id'] == taskId,
          orElse: () => {},
        );
        final taskName = task['task_name'] ?? 'Unnamed Task';
        print(
          'Triggering notification for task $taskId: $taskName is now $newStatus',
        );
        await _notificationService.showNotification(
          taskId,
          'Task Status Updated',
          '$taskName is now $newStatus',
          saveToBackend: false, // Prevent duplicate save
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update task status: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      print('Update task status error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating task status: $e')));
    }
  }

  void _navigateToStudyPlanEditor(Map<String, dynamic> task) {
    final eventId = task['id'] as int?;
    final subject = task['subject'] as String?;
    final startDate = task['start_date'] as String?;
    final eventDate = task['event_date'] as String?;

    if (eventId == null ||
        subject == null ||
        startDate == null ||
        eventDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid task data')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => StudyPlanEditor(
              eventId: eventId,
              subject: subject,
              startDate: startDate.split('T')[0],
              examDate: eventDate.split('T')[0],
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Tasks',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        tasks.isEmpty
            ? const Center(child: Text('No upcoming tasks'))
            : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final taskId = task['id'] as int?;
                if (taskId == null) {
                  return const SizedBox.shrink();
                }
                final dueDate = DateTime.parse(task['event_date']);
                final status = task['status'] as String? ?? 'Pending';
                final overdue =
                    dueDate.isBefore(DateTime.now()) && status != 'Complete';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  color: overdue ? Colors.red.shade100 : null,
                  child: ListTile(
                    title: Text(task['task_name'] ?? 'Unnamed Task'),
                    subtitle: Text(
                      'Due date: ${dueDate.toLocal().toString().split(' ')[0]}',
                    ),
                    leading: const Icon(Icons.task),
                    trailing: PopupMenuButton<String>(
                      onSelected: (status) {
                        _updateTaskStatus(taskId, status);
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'Complete',
                              child: Text('Complete'),
                            ),
                            const PopupMenuItem(
                              value: 'Not Complete',
                              child: Text('Not Complete'),
                            ),
                            const PopupMenuItem(
                              value: 'Pending',
                              child: Text('Pending'),
                            ),
                            const PopupMenuItem(
                              value: 'Deleted',
                              child: Text('Delete'),
                            ),
                          ],
                    ),
                    onTap: () => _navigateToStudyPlanEditor(task),
                  ),
                );
              },
            ),
      ],
    );
  }
}
