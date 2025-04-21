import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarSection extends StatefulWidget {
  @override
  _CalendarSectionState createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  late final CalendarFormat _calendarFormat;
  late final DateTime _focusedDay;
  late final DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;

    // Define some sample events
    _selectedEvents = ValueNotifier([
      Event(title: 'Study for Exam', date: DateTime.utc(2023, 4, 25)),
      Event(title: 'Quiz on Flutter', date: DateTime.utc(2023, 4, 26)),
      Event(title: 'Task Deadline', date: DateTime.utc(2023, 4, 28)),
    ]);
  }

  // Event list based on selected day
  List<Event> _getEventsForDay(DateTime day) {
    return _selectedEvents.value.where((event) {
      return isSameDay(event.date, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Event>(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
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
        ),
        // Display events for the selected day
        Expanded(
          child: ListView(
            children:
                _getEventsForDay(_selectedDay).map((event) {
                  return ListTile(title: Text(event.title));
                }).toList(),
          ),
        ),
      ],
    );
  }
}

// Sample Event class
class Event {
  final String title;
  final DateTime date;

  Event({required this.title, required this.date});
}
