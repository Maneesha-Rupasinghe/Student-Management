import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:study_manager/widgets/user/strength.dart';
import 'package:study_manager/widgets/user/study_preferences.dart';
import 'package:study_manager/widgets/user/weakness.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar_controller.dart';

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

  final _storage = const FlutterSecureStorage();

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _submitProfile() async {
    final String? token = await _storage.read(key: 'access_token');

    if (token == null) {
      _showSnackBar('Please log in first', isError: true);
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
        Uri.parse('http://192.168.1.4:8000/api/user/preferences/'),
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
        _showSnackBar(responseData['message'], isError: false);
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar('Failed to save preferences: ${errorData['error'] ?? response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error saving preferences: $e', isError: true);
      print("Error saving preferences: $e");
    }
  }

  void _fetchUserPreferences() async {
    final String? token = await _storage.read(key: 'access_token');

    if (token == null) {
      _showSnackBar('Please log in first', isError: true);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.4:8000/api/user/preferences/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("Fetch preferences response status: ${response.statusCode}");
      print("Fetch preferences response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          selectedStrengths = List<String>.from(responseData['strengths'] ?? []);
          selectedWeaknesses = List<String>.from(responseData['weaknesses'] ?? []);
          hoursPerDay = (responseData['hours_per_day'] ?? 2).toInt();
          daysPerWeek = (responseData['days_per_week'] ?? 5) is int
              ? responseData['days_per_week']
              : (responseData['days_per_week'] ?? 5).toInt();
          preferredStudyTime = responseData['preferred_study_time'] ?? 'Morning';
        });
      } else {
        _showSnackBar('Failed to fetch preferences: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error fetching preferences: $e', isError: true);
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
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Reset the bottom navigation bar index to Home (index 0)
            final _controller = NotchBottomBarController(index: 0);
            _controller.jumpTo(0);
            Navigator.popUntil(context, ModalRoute.withName('/home'));
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Select Your Strengths',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            StrengthsWidget(
              selectedStrengths: selectedStrengths,
              onChanged: (selected) {
                setState(() {
                  selectedStrengths = selected;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Select Your Weaknesses',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitProfile,
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}