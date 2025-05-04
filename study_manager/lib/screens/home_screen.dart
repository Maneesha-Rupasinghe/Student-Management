import 'package:flutter/material.dart';
import 'package:study_manager/widgets/calendar_section.dart';
import 'package:study_manager/widgets/profile_section.dart';
import 'package:study_manager/widgets/upcoming_tasks_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudySync'),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const ProfileSection(),
              const SizedBox(height: 20),
              CalendarSection(),
              const SizedBox(height: 20),
              const UpcomingTasksList(),
            ],
          ),
        ),
      ),
    );
  }
}
