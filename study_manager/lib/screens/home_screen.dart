import 'package:flutter/material.dart';
import 'package:study_manager/models/bottom_bar_item_model.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar_controller.dart';
import 'package:study_manager/widgets/calendar_section.dart';
import 'package:study_manager/widgets/profile_section.dart';
// import 'package:study_manager/widgets/quiz_percentage_circle.dart';
import 'package:study_manager/widgets/upcoming_tasks_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Create the NotchBottomBarController
  final NotchBottomBarController _controller = NotchBottomBarController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Personalized Study Planner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              // Profile Section
              ProfileSection(),
              SizedBox(height: 20),

              // Quiz Percentage Circle
              // QuizPercentageCircle(),
              // SizedBox(height: 20),

              // Calendar Section
              CalendarSection(),
              SizedBox(height: 20),

              // Upcoming Tasks List
              UpcomingTasksList(),
            ],
          ),
        ),
      ),

      // Add the AnimatedNotchBottomBar here
      // bottomNavigationBar: AnimatedNotchBottomBar(
      //   notchBottomBarController: _controller, // Pass the controller
      //   bottomBarItems: [
      //     BottomBarItem(
      //       inActiveItem: Icon(Icons.home),
      //       activeItem: Icon(Icons.home, color: Colors.blue),
      //       itemLabel: 'Home',
      //     ),
      //     BottomBarItem(
      //       inActiveItem: Icon(Icons.quiz_rounded),
      //       activeItem: Icon(Icons.quiz_rounded, color: Colors.blue),
      //       itemLabel: 'Quiz',
      //     ),
      //     BottomBarItem(
      //       inActiveItem: Icon(Icons.notifications),
      //       activeItem: Icon(Icons.notifications, color: Colors.blue),
      //       itemLabel: 'Notifications',
      //     ),
      //     BottomBarItem(
      //       inActiveItem: Icon(Icons.settings),
      //       activeItem: Icon(Icons.settings, color: Colors.blue),
      //       itemLabel: 'Settings',
      //     ),
      //   ],
      //   onTap: (index) {
      //     // Handle onTap event (optional)
      //     print("Tapped item index: $index");
      //   },
      //   kIconSize: 24.0,
      //   kBottomRadius: 28.0,
      //   showShadow: true,
      //   showLabel: true,
      //   notchColor: Colors.white,
      //   durationInMilliSeconds: 300,
      // ),
    );
  }
}
