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
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _selectedEvents = ValueNotifier([]);
    _fetchTasks();
  }

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
                date: localEventDate,
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
      ).showSnackBar(const SnackBar(content: Text('Failed to load tasks')));
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events.where((event) => isSameDay(event.date, day)).toList();
  }

  void _showTaskDetails(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.title,
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
                  'Subject: ${event.subject}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Task Type: ${event.taskType}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Due Date: ${event.date.toLocal()}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Status: ${event.status}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DateTime> _getMarkedDays() {
    return _events
        .map(
          (event) =>
              DateTime.utc(event.date.year, event.date.month, event.date.day),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xFFDAF5F3),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Tasks & Quizzes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C8D8A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF6C8D8A)),
                  onPressed: _fetchTasks,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar<Event>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _selectedEvents.value = _getEventsForDay(selectedDay);
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
                      color: Color(0XFF3674B5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0XFF3674B5),
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: const TextStyle(color: Colors.red),
                    markerDecoration: const BoxDecoration(
                      color: Color(0XFF3674B5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final hasTask = _events.any(
                        (event) => isSameDay(event.date, day),
                      );
                      return Container(
                        decoration: BoxDecoration(
                          color: hasTask ? Color(0XFF3674B5) : null,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Stack(
                            children: [
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: hasTask ? Colors.white : Colors.black,
                                ),
                              ),
                              if (hasTask)
                                const Positioned(
                                  right: 1,
                                  bottom: 1,
                                  child: Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: Color(0XFF3674B5),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedEvents.value.length,
              itemBuilder: (context, index) {
                final event = _selectedEvents.value[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      Icons.task,
                      color:
                          event.status == 'completed'
                              ? Colors.green
                              : Color(0XFF3674B5),
                    ),
                    title: Text(
                      event.title,
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(
                      'Due: ${event.date.toLocal()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () => _showTaskDetails(event),
                  ),
                );
              },
            ),
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
