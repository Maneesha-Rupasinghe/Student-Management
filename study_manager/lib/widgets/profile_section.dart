import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  _ProfileSectionState createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final _storage = const FlutterSecureStorage();
  String _userName = '';
  String _email = '';
  double _quizPercentage = 0.0;
  bool _showFullEmail = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load user profile')));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load quiz percentage')));
    }
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/profile.jpeg'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showFullEmail = !_showFullEmail;
                    });
                  },
                  child: Text(
                    _showFullEmail ? _email : _getMaskedEmail(_email),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Text(
                '${_quizPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.blue),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
          ],
        ),
      ],
    );
  }
}