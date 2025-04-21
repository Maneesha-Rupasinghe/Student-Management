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

    // Define some sample events with correct dates in 2025
    _selectedEvents = ValueNotifier([
      Event(
        title: 'Study for Exam',
        date: DateTime(2025, 4, 25),
      ), // Correct year (2025)
      Event(
        title: 'Quiz on Flutter',
        date: DateTime(2025, 4, 26),
      ), // Correct year (2025)
      Event(
        title: 'Task Deadline',
        date: DateTime(2025, 4, 28),
      ), // Correct year (2025)
    ]);
  }

  // Event list based on selected day
  List<Event> _getEventsForDay(DateTime day) {
    // Log selected day and events to check the comparison logic
    print("Selected Day: $day");

    return _selectedEvents.value.where((event) {
      print("Checking event: ${event.date}"); // Log event date
      return isSameDay(event.date, day); // Correct comparison
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Wrap the entire Column in a SingleChildScrollView
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Tasks & Quizzes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Container(
            color: Colors.grey[200], // Customize the calendar color
            child: TableCalendar<Event>(
              firstDay: DateTime.utc(2020, 1, 1), // Define the start date
              lastDay: DateTime.utc(2030, 12, 31), // Define the end date
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader:
                  _getEventsForDay, // Correctly loading events for each day
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
          ),
          SizedBox(height: 10),
          // Display events for the selected day
          ListView(
            shrinkWrap: true, // Ensures the ListView only takes required space
            physics:
                NeverScrollableScrollPhysics(), // Prevents double scrolling
            children:
                _getEventsForDay(_selectedDay).map((event) {
                  return ListTile(title: Text(event.title));
                }).toList(),
          ),
        ],
      ),
    );
  }
}

// Sample Event class
class Event {
  final String title;
  final DateTime date;

  Event({required this.title, required this.date});
}

// isSameDay function to compare dates without time
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
