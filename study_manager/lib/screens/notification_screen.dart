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
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3674B5), Color(0xFF3674B5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notifications.isEmpty
                  ? const Center(
                    child: Text(
                      'No notifications found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color:
                            notification['is_read']
                                ? Colors.grey[200]
                                : const Color(0xFF3674B5).withOpacity(0.1),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            notification['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  notification['is_read']
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                              color:
                                  notification['is_read']
                                      ? Colors.black87
                                      : const Color(0xFF3674B5),
                            ),
                          ),
                          subtitle: Text(
                            notification['body'],
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Text(
                            notification['timestamp'].substring(0, 16),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () {
                            _toggleReadStatus(
                              notification['id'],
                              notification['is_read'],
                            );
                          },
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
