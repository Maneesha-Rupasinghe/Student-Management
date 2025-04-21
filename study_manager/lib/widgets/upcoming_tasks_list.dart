import 'package:flutter/material.dart';

class UpcomingTasksList extends StatelessWidget {
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
          itemCount: 5, // Replace with the number of tasks
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text('Task $index'), // Replace with task name
                subtitle: Text('Due date: 2023-04-25'), // Replace with due date
                leading: Icon(Icons.task),
                trailing: Icon(Icons.arrow_forward),
              ),
            );
          },
        ),
      ],
    );
  }
}
