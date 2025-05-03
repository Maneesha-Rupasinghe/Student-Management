import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> notifications = [];
  final _storage = const FlutterSecureStorage();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      isLoading = true;
    });
    final String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      print('Error: No access token found');
      setState(() {
        isLoading = false;
      });
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.4:8000/api/notifications/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(
        'Fetch notifications response: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        setState(() {
          notifications = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print('Failed to fetch notifications: ${response.reasonPhrase}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleReadStatus(int notificationId, bool currentStatus) async {
    final String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      print('Error: No access token found');
      return;
    }
    try {
      final response = await http.patch(
        Uri.parse(
          'http://192.168.1.4:8000/api/notifications/$notificationId/read/',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('Toggle read response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          final index = notifications.indexWhere(
            (n) => n['id'] == notificationId,
          );
          if (index != -1) {
            notifications[index] = jsonDecode(response.body);
          }
        });
      } else {
        print('Failed to toggle read status: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error toggling read status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? const Center(child: Text('No notifications found'))
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return ListTile(
                    title: Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight:
                            notification['is_read']
                                ? FontWeight.normal
                                : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(notification['body']),
                    trailing: Text(
                      notification['timestamp'].substring(0, 16),
                      style: const TextStyle(fontSize: 12),
                    ),
                    tileColor:
                        notification['is_read']
                            ? Colors.grey[200]
                            : Colors.white,
                    onTap: () {
                      _toggleReadStatus(
                        notification['id'],
                        notification['is_read'],
                      );
                    },
                  );
                },
              ),
    );
  }
}
