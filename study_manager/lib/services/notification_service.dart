import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _storage = const FlutterSecureStorage();
  static const MethodChannel _channel = MethodChannel(
    'com.example.app/badges',
  ); // For Samsung badge updates

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification tapped with payload: ${response.payload}');
        await _markNotificationAsRead(
          response.id ?? 0,
        ); // Mark as read when tapped
      },
    );

    final androidPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showNotification(
    int id,
    String title,
    String body, {
    bool saveToBackend = true,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'task_channel',
          'Task Notifications',
          channelDescription: 'Notifications for task reminders and updates',
          importance: Importance.max,
          priority: Priority.high,
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: 'notification_screen',
    );
    await _saveNotification(id, title, body); // Save to local storage
    if (saveToBackend) {
      await _saveNotificationToBackend(title, body);
    }
    await _updateBadgeCount(); // Update badge count
  }

  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'task_channel',
          'Task Notifications',
          channelDescription: 'Notifications for task reminders and updates',
          importance: Importance.max,
          priority: Priority.high,
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'notification_screen',
    );
    await _saveNotification(id, title, body); // Save to local storage
    await _updateBadgeCount(); // Update badge count
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    await _markNotificationAsRead(id); // Mark as read when canceled
    await _updateBadgeCount(); // Update badge count
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    await _clearAllNotifications(); // Clear all from local storage
    await _updateBadgeCount(); // Update badge count
  }

  // Save notification to local storage
  Future<void> _saveNotification(int id, String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];
    final notificationData = jsonEncode({
      'id': id,
      'title': title,
      'body': body,
      'isRead': false,
    });
    notifications.add(notificationData);
    await prefs.setStringList('notifications', notifications);
    print('Saved notification: $notificationData');
  }

  // Mark a notification as read
  Future<void> _markNotificationAsRead(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];
    final updatedNotifications =
        notifications.map((notification) {
          final data = jsonDecode(notification);
          if (data['id'] == id) {
            data['isRead'] = true;
          }
          return jsonEncode(data);
        }).toList();
    await prefs.setStringList('notifications', updatedNotifications);
    print('Marked notification $id as read');
  }

  // Clear all notifications from local storage
  Future<void> _clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
    print('Cleared all notifications from local storage');
  }

  // Get unread notification count (made public)
  Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];
    int unreadCount = notifications.fold(0, (count, notification) {
      final data = jsonDecode(notification);
      return data['isRead'] == false ? count + 1 : count;
    });
    return unreadCount;
  }

  // Update badge count on app icon (Samsung-specific)
  Future<void> _updateBadgeCount() async {
    try {
      final unreadCount = await getUnreadCount();
      print('Updating badge count to $unreadCount');
      await _channel.invokeMethod('updateBadgeCount', {
        'count': unreadCount,
        'packageName':
            'com.example.student_help', // Replace with your app's package name
      });
    } catch (e) {
      print('Error updating badge count: $e');
    }
  }

  Future<void> _saveNotificationToBackend(String title, String body) async {
    final String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      print(
        'Error: No access token found, cannot save notification to backend',
      );
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:8000/api/notifications/save/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'title': title, 'body': body}),
      );
      print(
        'Save notification response: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode != 201) {
        print('Failed to save notification: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error saving notification to backend: $e');
    }
  }
}