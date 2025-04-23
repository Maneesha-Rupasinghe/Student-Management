import 'package:flutter/material.dart';
import 'package:study_manager/models/bottom_bar_item_model.dart';
import 'package:study_manager/screens/User_profile_screen.dart';
import 'package:study_manager/screens/Welcome_screen.dart';
import 'package:study_manager/screens/notification_screen.dart';
import 'package:study_manager/screens/quiz_menu_screen.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar_controller.dart';
import 'screens/home_screen.dart';

import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/forgot_password_page.dart';

void main() {
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
    NotificationsScreen(),
    UserProfileScreen(),
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
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgotPassword': (context) => ForgotPasswordPage(),
        '/home':
            (context) => SafeArea(
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
                      activeItem: Icon(Icons.quiz_rounded, color: Colors.blue),
                      itemLabel: 'Quiz',
                    ),
                    BottomBarItem(
                      inActiveItem: Icon(Icons.notifications),
                      activeItem: Icon(Icons.notifications, color: Colors.blue),
                      itemLabel: 'Notifications',
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
      },
    );
  }
}
