import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:study_manager/widgets/user/strength.dart';
import 'package:study_manager/widgets/user/study_preferences.dart';
import 'package:study_manager/widgets/user/weakness.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  List<String> selectedStrengths = [];
  List<String> selectedWeaknesses = [];
  int hoursPerDay = 2;
  int daysPerWeek = 5;
  String preferredStudyTime = "Morning";

  final _storage = FlutterSecureStorage();

  void _submitProfile() async {
    final String? token = await _storage.read(key: 'access_token');

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }

    final Map<String, dynamic> body = {
      'strengths': selectedStrengths,
      'weaknesses': selectedWeaknesses,
      'hours_per_day': hoursPerDay,
      'days_per_week': daysPerWeek,
      'preferred_study_time': preferredStudyTime,
    };

    print("Submitting preferences: $body");

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/user/preferences/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("Preferences response status: ${response.statusCode}");
      print("Preferences response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(responseData['message'])));
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save preferences: ${errorData['error'] ?? response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving preferences: $e')));
      print("Error saving preferences: $e");
    }
  }

  void _fetchUserPreferences() async {
    final String? token = await _storage.read(key: 'access_token');

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/user/preferences/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("Fetch preferences response status: ${response.statusCode}");
      print("Fetch preferences response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          selectedStrengths = List<String>.from(
            responseData['strengths'] ?? [],
          );
          selectedWeaknesses = List<String>.from(
            responseData['weaknesses'] ?? [],
          );
          // Handle hours_per_day: convert to int, since it's a FloatField in the backend
          hoursPerDay = (responseData['hours_per_day'] ?? 2).toInt();
          // Handle days_per_week: ensure it's an int, even if backend returns a double
          daysPerWeek =
              (responseData['days_per_week'] ?? 5) is int
                  ? responseData['days_per_week']
                  : (responseData['days_per_week'] ?? 5).toInt();
          preferredStudyTime =
              responseData['preferred_study_time'] ?? 'Morning';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to fetch preferences: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching preferences: $e')));
      print("Error fetching preferences: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            StrengthsWidget(
              selectedStrengths: selectedStrengths,
              onChanged: (selected) {
                setState(() {
                  selectedStrengths = selected;
                });
              },
            ),
            const SizedBox(height: 20),
            WeaknessesWidget(
              selectedWeaknesses: selectedWeaknesses,
              onChanged: (selected) {
                setState(() {
                  selectedWeaknesses = selected;
                });
              },
            ),
            const SizedBox(height: 20),
            StudyPreferencesWidget(
              hoursPerDay: hoursPerDay,
              daysPerWeek: daysPerWeek,
              preferredStudyTime: preferredStudyTime,
              onHoursPerDayChanged: (value) {
                setState(() {
                  hoursPerDay = value;
                });
              },
              onDaysPerWeekChanged: (value) {
                setState(() {
                  daysPerWeek = value;
                });
              },
              onPreferredStudyTimeChanged: (value) {
                setState(() {
                  preferredStudyTime = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitProfile,
              child: const Text("Submit"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
