import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:study_manager/widgets/task/task_service.dart';

class TaskListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tasks = TaskService().tasks;

    return WillPopScope(
      onWillPop: () async {
        // Navigate back to HomeScreen with Events tab
        Navigator.pushReplacementNamed(context, '/home');
        return false; // Prevent default pop
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tasks'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ),
        body:
            tasks.isEmpty
                ? Center(child: Text('No tasks added yet'))
                : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.subject,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 8),
                            Text('Type: ${task.taskType}'),
                            Text('Priority: ${task.priority}'),
                            Text(
                              'Exam Date: ${DateFormat('yyyy-MM-dd').format(task.examDate)}',
                            ),
                            Text(
                              'Start Date: ${DateFormat('yyyy-MM-dd').format(task.studyStartDate)}',
                            ),
                            Text('Hours: ${task.estimatedHours}'),
                            if (task.notes.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text('Notes: ${task.notes}'),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/add-task'),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
