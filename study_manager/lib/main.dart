import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:study_manager/models/bottom_bar_item_model.dart';
import 'package:study_manager/screens/Task_Form_Page.dart';
import 'package:study_manager/screens/Welcome_screen.dart';
import 'package:study_manager/screens/notification_screen.dart';
import 'package:study_manager/screens/quiz_menu_screen.dart';
import 'package:study_manager/screens/settings_screen.dart';
import 'package:study_manager/services/notification_service.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar_controller.dart';
import 'package:study_manager/widgets/task/task_list_page.dart';

import 'screens/home_screen.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/forgot_password_page.dart';
import 'utils/fcm_utils.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final notificationService = NotificationService();
  await notificationService.init();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  String? token = await messaging.getToken();
  print("Device Token: $token");
  if (token != null) {
    setFcmToken(token);
  }

  messaging.onTokenRefresh.listen((newToken) async {
    print("New Device Token: $newToken");
    setFcmToken(newToken);
    if (fcmToken != null) {
      await sendTokenToBackend(newToken);
    } else {
      print('User not logged in. Token refresh will be sent after login.');
    }
  });

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message in the foreground: ${message.notification?.title}');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: 'notification_screen',
      );
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  RemoteMessage? initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }

  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.notification?.title}");
}

void _handleMessage(RemoteMessage message) {
  navigatorKey.currentState?.pushNamed('/notifications');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _controller = NotchBottomBarController(index: 0);

  final List<Widget> _screens = [
    const HomeScreen(),
    const QuizMenuScreen(),
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
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Personalized Study Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) =>  WelcomePage(),
        '/login': (context) =>  LoginPage(),
        '/register': (context) =>  RegisterPage(),
        '/forgotPassword': (context) =>  ForgotPasswordPage(),
        '/add-task': (context) =>  TaskFormPage(),
        '/task-list': (context) =>  TaskListPage(),
        '/notifications': (context) => const NotificationScreen(),
        '/home': (context) => WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: SafeArea(
                child: Scaffold(
                  body: _screens[_controller.index],
                  bottomNavigationBar: AnimatedNotchBottomBar(
                    notchBottomBarController: _controller,
                    bottomBarItems: [
                      const BottomBarItem(
                        inActiveItem: Icon(Icons.home),
                        activeItem: Icon(Icons.home, color: Colors.blue),
                        itemLabel: 'Home',
                      ),
                      const BottomBarItem(
                        inActiveItem: Icon(Icons.quiz_rounded),
                        activeItem: Icon(
                          Icons.quiz_rounded,
                          color: Colors.blue,
                        ),
                        itemLabel: 'Quiz',
                      ),
                      const BottomBarItem(
                        inActiveItem: Icon(Icons.add_box_rounded),
                        activeItem: Icon(
                          Icons.add_box_rounded,
                          color: Colors.blue,
                        ),
                        itemLabel: 'Events',
                      ),
                      const BottomBarItem(
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