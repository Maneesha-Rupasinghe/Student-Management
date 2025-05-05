import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AllTasksList extends StatefulWidget {
  const AllTasksList({super.key});

  @override
  _AllTasksListState createState() => _AllTasksListState();
}

class _AllTasksListState extends State<AllTasksList> {
  List<dynamic> allTasks = [];
  final _storage = const FlutterSecureStorage();
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAllTasks();
  }

  Future<void> _fetchAllTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final String? token = await _storage.read(key: 'access_token');
      if (token == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Please log in to view tasks.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.4:8000/api/all_tasks/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          allTasks = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load tasks: ${response.statusCode}';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load tasks')));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching tasks: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching tasks: $e')));
    }
  }

  Future<void> _updateTaskStatus(int taskId, String newStatus) async {
    try {
      final String? token = await _storage.read(key: 'access_token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to update task status.')),
        );
        return;
      }

      // Map frontend status to backend-compatible status if needed
      String backendStatus =
          newStatus == 'Not Complete' ? 'Pending' : newStatus;

      final response = await http.patch(
        Uri.parse('http://192.168.1.4:8000/api/tasks/$taskId/status/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': backendStatus}),
      );

      print(
        'Update task status response: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        await _fetchAllTasks(); // Refresh the task list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task status updated to $newStatus')),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating task status: $e')));
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
                        color: Color(0xFF3674B5),
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
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Text(
                  'Start Date: ${task['start_date']}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Text(
                  'Event Date: ${task['event_date']}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Text(
                  'Estimated Study Hours: ${task['estimated_study_hours']}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Text(
                  'Notes: ${task['notes'] ?? 'No notes'}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Text(
                  'Priority: ${task['priority']}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Text(
                  'Status: ${task['status']}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0XFFB4EBE6), Color(0XFFB4EBE6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3674B5),
                      ),
                      onPressed: _fetchAllTasks,
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
              : allTasks.isEmpty
              ? const Center(child: Text('No tasks available'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: allTasks.length,
                  itemBuilder: (context, index) {
                    final task = allTasks[index];
                    final taskId = task['id'] as int?;
                    if (taskId == null) return const SizedBox.shrink();
                    final dueDate = DateTime.parse(task['event_date']);
                    final isCompleted = task['status'] == 'Completed';
                    final overdue =
                        dueDate.isBefore(DateTime.now()) && !isCompleted;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        side:
                            overdue
                                ? const BorderSide(color: Colors.red, width: 2)
                                : BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color: isCompleted ? Colors.green[50] : Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          task['task_name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3674B5),
                          ),
                        ),
                        subtitle: Text(
                          'Due: ${dueDate.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            color: overdue ? Colors.red : Colors.grey,
                          ),
                        ),
                        leading: Icon(
                          isCompleted ? Icons.check_circle : Icons.pending,
                          color: isCompleted ? Colors.green : Color(0xFF3674B5),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Color(0xFF3674B5),
                          ),
                          onSelected: (String status) {
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
                                    leading: Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
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
                                    leading: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    title: Text('Delete'),
                                  ),
                                ),
                              ],
                        ),
                        onTap: () => _showTaskDetails(context, task),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
