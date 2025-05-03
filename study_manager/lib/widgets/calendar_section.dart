import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CalendarSection extends StatefulWidget {
  @override
  _CalendarSectionState createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  late final CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final _storage = FlutterSecureStorage();
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay =
        DateTime.now(); // Initialize _selectedDay with the current date
    _calendarFormat = CalendarFormat.month;
    _selectedEvents = ValueNotifier([]); // Initialize with empty list

    _fetchTasks(); // Fetch tasks from backend
  }

  // Fetch tasks from the backend and map them to the Event model
  Future<void> _fetchTasks() async {
    final String? token = await _storage.read(key: 'access_token');
    final response = await http.get(
      Uri.parse('http://192.168.1.4:8000/api/tasks/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> tasks = json.decode(response.body);
      setState(() {
        _events =
            tasks.map((task) {
              DateTime localEventDate =
                  DateTime.parse(task['event_date']).toLocal();
              return Event(
                title: task['task_name'],
                date: localEventDate, // Use the local time here
                taskId: task['id'],
                taskType: task['task_type'],
                subject: task['subject'],
                status: task['status'],
              );
            }).toList();
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load tasks')));
    }
  }

  // Event list based on selected day
  List<Event> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      return isSameDay(event.date, day);
    }).toList();
  }

  // Function to show task details when a task is selected

  void _showTaskDetails(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 50,
          ), // Adjust dialog padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16,
            ), // Customize the dialog border radius
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Subject: ${event.subject}'),
                  Text('Task Type: ${event.taskType}'),
                  Text('Due Date: ${event.date.toLocal()}'),
                  Text('Status: ${event.status}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Function to mark the days with tasks
  List<DateTime> _getMarkedDays() {
    return _events.map((event) {
      return DateTime.utc(event.date.year, event.date.month, event.date.day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Tasks & Quizzes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed:
                    _fetchTasks, // Trigger the fetch tasks method to refresh
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            color: Colors.grey[200],
            child: TableCalendar<Event>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay; // Set the selected day
                  _focusedDay = focusedDay; // Set the focused day
                });
                // Fetch events for the selected day
                _selectedEvents.value = _getEventsForDay(selectedDay);
                // If there are events for that day, show the details of the first event
                if (_selectedEvents.value.isNotEmpty) {
                  _showTaskDetails(_selectedEvents.value.first);
                }
              },
              eventLoader: _getEventsForDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: Colors.red),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final hasTask = _events.any(
                    (event) => isSameDay(event.date, day),
                  );
                  return Container(
                    decoration: BoxDecoration(
                      color: hasTask ? Colors.blue.shade200 : null,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: hasTask ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _selectedEvents.value.length,
            itemBuilder: (context, index) {
              final event = _selectedEvents.value[index];
              return ListTile(
                title: Text(event.title),
                subtitle: Text('Due date: ${event.date.toLocal()}'),
                leading: Icon(Icons.task),
                onTap: () {
                  _showTaskDetails(event); // Show task details when tapped
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// Event class with additional task details
class Event {
  final String title;
  final DateTime date;
  final int taskId;
  final String taskType;
  final String subject;
  final String status;

  Event({
    required this.title,
    required this.date,
    required this.taskId,
    required this.taskType,
    required this.subject,
    required this.status,
  });
}

// Helper function to compare dates
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
