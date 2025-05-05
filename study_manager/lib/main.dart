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
import 'package:study_manager/screens/user_progress_scren.dart';
import 'package:study_manager/services/notification_service.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar_controller.dart';
import 'package:study_manager/widgets/task/task_list_page.dart';
import 'package:study_manager/widgets/user/all_task_list.dart';
import 'screens/home_screen.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/forgot_password_page.dart';
import 'utils/fcm_utils.dart';
import 'screens/user_profile_screen.dart';
import 'screens/user_account_screen.dart';

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
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
      'Received a message in the foreground: ${message.notification?.title}',
    );
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
    const TaskFormPage(),
    const UserProgressScreen(),
    const SettingsPage(),
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
        primaryColor: const Color(0xFFB4EBE6),
        scaffoldBackgroundColor: const Color(0xFFFFFDF6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB4EBE6),
          foregroundColor: Color(0xFF080B0B),
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3674B5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF3674B5)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color.fromRGBO(180, 235, 230, 0.2),
          labelStyle: TextStyle(color: Color(0xFF080B0B)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF080B0B)),
          bodyMedium: TextStyle(color: Color(0xFF080B0B)),
          headlineSmall: TextStyle(
            color: Color(0xFF080B0B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgotPassword': (context) => ForgotPasswordPage(),
        '/add-task': (context) => const TaskFormPage(),
        '/task-list': (context) => TaskListPage(),
        '/notifications': (context) => const NotificationScreen(),
        '/user-profile': (context) => const UserProfileScreen(),
        '/user-account': (context) => const UserAccountScreen(),
        '/user-tasks':(context)=>const AllTasksList(),
        '/home':
            (context) => WillPopScope(
              onWillPop: () async => false,
              child: SafeArea(
                child: Scaffold(
                  body: _screens[_controller.index],
                  bottomNavigationBar: AnimatedNotchBottomBar(
                    notchBottomBarController: _controller,
                    bottomBarItems: [
                      BottomBarItem(
                        inActiveItem: Image.asset('assets/home.png', scale: 20),
                        activeItem: Image.asset('assets/home.png', scale: 20),
                        itemLabel: 'Home',
                      ),
                      BottomBarItem(
                        inActiveItem: Image.asset('assets/quiz.png', scale: 20),
                        activeItem: Image.asset('assets/quiz.png', scale: 20),
                        itemLabel: 'Quiz',
                      ),
                      BottomBarItem(
                        inActiveItem: Image.asset(
                          'assets/event.png',
                          scale: 20,
                        ),
                        activeItem: Image.asset('assets/event.png', scale: 20),
                        itemLabel: 'Event',
                      ),
                      BottomBarItem(
                        inActiveItem: Image.asset(
                          'assets/progress.png',
                          scale: 20,
                        ),
                        activeItem: Image.asset(
                          'assets/progress.png',
                          scale: 20,
                        ),
                        itemLabel: 'Progress',
                      ),
                      BottomBarItem(
                        inActiveItem: Image.asset(
                          'assets/settings.png',
                          scale: 20,
                        ),
                        activeItem: Image.asset(
                          'assets/settings.png',
                          scale: 20,
                        ),
                        itemLabel: 'Settings',
                      ),
                    ],
                    onTap: _onItemTapped,
                    kIconSize: 28.0,
                    kBottomRadius: 16.0,
                    showShadow: true,
                    showLabel: true,
                    itemLabelStyle: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF080B0B),
                      fontWeight: FontWeight.w500,
                    ),
                    notchColor: const Color(0xFFB4EBE6),
                    color: const Color(0xFFB4EBE6),
                    bottomBarWidth: MediaQuery.of(context).size.width,
                    durationInMilliSeconds: 200,
                  ),
                ),
              ),
            ),
      },
    );
  }
}
