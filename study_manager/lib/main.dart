import 'package:flutter/material.dart';
import 'package:study_manager/models/bottom_bar_item_model.dart';
import 'package:study_manager/screens/Task_Form_Page.dart';
import 'package:study_manager/screens/Welcome_screen.dart';
import 'package:study_manager/screens/notification_screen.dart';
import 'package:study_manager/screens/quiz_menu_screen.dart';
import 'package:study_manager/screens/settings_screen.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar_controller.dart';
import 'package:study_manager/widgets/task/task_list_page.dart';
import 'screens/home_screen.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/forgot_password_page.dart';

void main() async {

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _controller = NotchBottomBarController(index: 0);

  final List<Widget> _screens = [
    HomeScreen(),
    QuizMenuScreen(),
    TaskFormPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _controller.jumpTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personalized Study Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // Start with WelcomePage
      routes: {
        '/': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgotPassword': (context) => ForgotPasswordPage(),
        '/add-task': (context) => TaskFormPage(),
        '/task-list': (context) => TaskListPage(),
        '/home':
            (context) => WillPopScope(
              onWillPop: () async {
                // Prevent popping back to WelcomePage
                return false; // Disable back button to exit app
              },
              child: SafeArea(
                child: Scaffold(
                  body: _screens[_controller.index],
                  bottomNavigationBar: AnimatedNotchBottomBar(
                    notchBottomBarController: _controller,
                    bottomBarItems: [
                      BottomBarItem(
                        inActiveItem: Icon(Icons.home),
                        activeItem: Icon(Icons.home, color: Colors.blue),
                        itemLabel: 'Home',
                      ),
                      BottomBarItem(
                        inActiveItem: Icon(Icons.quiz_rounded),
                        activeItem: Icon(
                          Icons.quiz_rounded,
                          color: Colors.blue,
                        ),
                        itemLabel: 'Quiz',
                      ),
                      BottomBarItem(
                        inActiveItem: Icon(Icons.add_box_rounded),
                        activeItem: Icon(
                          Icons.add_box_rounded,
                          color: Colors.blue,
                        ),
                        itemLabel: 'Events',
                      ),
                      BottomBarItem(
                        inActiveItem: Icon(Icons.settings),
                        activeItem: Icon(Icons.settings, color: Colors.blue),
                        itemLabel: 'Settings',
                      ),
                    ],
                    onTap: _onItemTapped,
                    kIconSize: 24.0,
                    kBottomRadius: 28.0,
                    showShadow: true,
                    showLabel: true,
                    notchColor: Colors.white,
                    durationInMilliSeconds: 300,
                  ),
                ),
              ),
            ),
      },
    );
  }
}
