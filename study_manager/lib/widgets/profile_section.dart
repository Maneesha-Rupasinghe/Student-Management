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
  final _storage = FlutterSecureStorage();
  String _userName = '';
  String _email = '';
  double _quizPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Function to fetch user profile data and quiz percentage
  Future<void> _fetchUserData() async {
    final String? token = await _storage.read(key: 'access_token');

    // Fetch user profile (name and email)
    final userProfileResponse = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/user/profile/'),
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
      // Handle error if user profile data fetch fails
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load user profile')));
    }

    // Fetch user quiz percentage
    final quizPercentageResponse = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/user/quiz-percentage/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (quizPercentageResponse.statusCode == 200) {
      final quizPercentageData = json.decode(quizPercentageResponse.body);
      print(quizPercentageData);
      setState(() {
        _quizPercentage = quizPercentageData['overall_percentage'];
      });
    } else {
      // Handle error if quiz percentage fetch fails
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load quiz percentage')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(
                'assets/profile.jpeg',
              ), // Replace with user's profile image
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName, // Display user's name
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _email, // Display user's email
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        // Add a row for quiz percentage and notification icon
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Text(
                '${_quizPercentage.toStringAsFixed(0)}%', // Display quiz percentage
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10),
            // Notification icon to the right of quiz percentage
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.blue),
              onPressed: () {
                // Handle notification icon press
                print('Notification icon pressed');
              },
            ),
          ],
        ),
      ],
    );
  }
}
