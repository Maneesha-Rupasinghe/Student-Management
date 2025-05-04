import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:study_manager/services/notification_service.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  _ProfileSectionState createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final _storage = const FlutterSecureStorage();
  final _notificationService = NotificationService();
  String _userName = '';
  String _email = '';
  double _quizPercentage = 0.0;
  bool _showFullEmail = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUnreadCount();
  }

  Future<void> _fetchUserData() async {
    final String? token = await _storage.read(key: 'access_token');

    final userProfileResponse = await http.get(
      Uri.parse('http://192.168.1.4:8000/api/user/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (userProfileResponse.statusCode == 200) {
      final userProfile = json.decode(userProfileResponse.body);
      setState(() {
        _userName = userProfile['username'];
        _email = userProfile['email'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user profile')),
      );
    }

    final quizPercentageResponse = await http.get(
      Uri.parse('http://192.168.1.4:8000/api/user/quiz-percentage/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (quizPercentageResponse.statusCode == 200) {
      final quizPercentageData = json.decode(quizPercentageResponse.body);
      setState(() {
        _quizPercentage = quizPercentageData['overall_percentage'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load quiz percentage')),
      );
    }
  }

  Future<void> _fetchUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    setState(() {
      _unreadCount = count;
    });
  }

  String _getMaskedEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '****';
    final name = parts[0];
    final domain = parts[1];

    final visible = name.length > 3 ? name.substring(0, 3) : name;
    return '$visible***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue[100],
                backgroundImage:
                    _userName.isNotEmpty
                        ? const AssetImage('assets/profile.jpeg')
                        : null,
                foregroundColor: Colors.white,
                child:
                    _userName.isEmpty
                        ? const Icon(Icons.person, color: Color(0XFF3674B5))
                        : null,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName.isEmpty ? 'Loading...' : _userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showFullEmail = !_showFullEmail;
                        });
                      },
                      child: Text(
                        _email.isEmpty
                            ? 'Loading...'
                            : (_showFullEmail
                                ? _email
                                : _getMaskedEmail(_email)),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0XFF3674B5), Color(0XFF3674B5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    '${_quizPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: Color(0XFF3674B5),
                        size: 32,
                      ),
                      onPressed: () async {
                        Navigator.pushNamed(context, '/notifications');
                        await _fetchUnreadCount();
                      },
                    ),
                    if (_unreadCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          // child: Text(
                          //   // _unreadCount > 9 ? '9+' : '$_unreadCount',
                          //   // style: const TextStyle(
                          //   //   color: Colors.white,
                          //   //   fontSize: 10,
                          //   //   fontWeight: FontWeight.bold,
                          //   // ),
                          //   // textAlign: TextAlign.center,
                          // ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
