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
  List<dynamic> studyPlans = [];
  final _storage = const FlutterSecureStorage();
  final _notificationService = NotificationService();
  DateTime? lastScheduledSessionTime;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
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
          _fetchStudyPlansAndScheduleReminders();
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

  Future<void> _fetchStudyPlansAndScheduleReminders() async {
    final String? token = await _storage.read(key: 'access_token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.4:8000/api/study-plans/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(
        'Fetch study plans response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        setState(() {
          studyPlans = json.decode(response.body);
        });
        await _scheduleStudyReminders();
      }
    } catch (e) {
      print('Fetch study plans error: $e');
    }
  }

  Future<void> _scheduleStudyReminders() async {
    DateTime? nextSessionTime;
    String? nextSubject;
    String? nextStartTimeStr;

    final now = DateTime.now();
    final oneHourFromNow = now.add(const Duration(hours: 1));

    for (var plan in studyPlans) {
      final planData = plan['plan'];
      for (var day in planData) {
        final studyDate = DateTime.parse(day['study_date']);
        for (var session in day['sessions']) {
          final startTimeStr = session['start_time'];
          final startDateTime = DateTime(
            studyDate.year,
            studyDate.month,
            studyDate.day,
            int.parse(startTimeStr.split(':')[0]),
            int.parse(startTimeStr.split(':')[1]),
          );
          if (startDateTime.isAfter(now) &&
              (nextSessionTime == null ||
                  startDateTime.isBefore(nextSessionTime))) {
            nextSessionTime = startDateTime;
            nextSubject = day['subject'];
            nextStartTimeStr = startTimeStr;
          }
        }
      }
    }

    if (nextSessionTime != null && nextSessionTime.isBefore(oneHourFromNow)) {
      if (lastScheduledSessionTime == null ||
          !nextSessionTime.isAtSameMomentAs(lastScheduledSessionTime!)) {
        final reminderTime = nextSessionTime.subtract(const Duration(hours: 1));
        if (reminderTime.isAfter(now)) {
          await _notificationService.cancelAllNotifications();
          await _notificationService.scheduleNotification(
            studyPlans.isNotEmpty ? studyPlans[0]['event_id'] : 0,
            'Study Reminder',
            'Time to study $nextSubject at $nextStartTimeStr',
            reminderTime,
          );
          print('Scheduled study reminder for $nextSubject at $reminderTime');
          lastScheduledSessionTime = nextSessionTime;
        } else {
          await _notificationService.cancelAllNotifications();
          await _notificationService.showNotification(
            studyPlans.isNotEmpty ? studyPlans[0]['event_id'] : 0,
            'Study Reminder',
            'Time to study $nextSubject at $nextStartTimeStr',
          );
          print('Showing immediate study reminder for $nextSubject');
          lastScheduledSessionTime = nextSessionTime;
        }
      } else {
        print('Reminder for this session already scheduled');
      }
    } else {
      print('No upcoming study session within the next hour');
      lastScheduledSessionTime = null;
    }
  }

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
        await fetchTasks();
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
          saveToBackend: false,
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
              onPlanSaved: fetchTasks,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFDAF5F3),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            'Upcoming Tasks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C8D8A),
            ),
          ),
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
                  shape: RoundedRectangleBorder(
                    side:
                        overdue
                            ? BorderSide(color: Colors.red, width: 2)
                            : BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      task['task_name'] ?? 'Unnamed Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Due: ${dueDate.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(
                        color: overdue ? Colors.red : Colors.grey,
                      ),
                    ),
                    leading: Icon(
                      Icons.task,
                      color: overdue ? Colors.red : Color(0XFF3674B5),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Color(0XFF3674B5),
                      ),
                      onSelected: (status) {
                        _updateTaskStatus(taskId, status);
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'Complete',
                              child: ListTile(
                                leading: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                title: Text('Complete'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'Not Complete',
                              child: ListTile(
                                leading: Icon(Icons.cancel, color: Colors.red),
                                title: Text('Not Complete'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'Pending',
                              child: ListTile(
                                leading: Icon(
                                  Icons.schedule,
                                  color: Colors.orange,
                                ),
                                title: Text('Pending'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'Deleted',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Delete'),
                              ),
                            ),
                          ],
                    ),
                    onTap: () {
                      _navigateToStudyPlanEditor(task);
                    },
                  ),
                );
              },
            ),
      ],
    );
  }
}
