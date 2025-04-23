import 'package:flutter/material.dart';
import 'package:study_manager/widgets/user/strength.dart';
import 'package:study_manager/widgets/user/study_preferences.dart';
import 'package:study_manager/widgets/user/weakness.dart' show WeaknessesWidget;

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // User profile data
  List<String> selectedStrengths = [];
  List<String> selectedWeaknesses = [];
  int hoursPerDay = 2;
  int daysPerWeek = 5;
  String preferredStudyTime = "Morning";

  // Function to submit profile changes
  void _submitProfile() {
    // You can save the profile data to backend or local storage here
    // For now, we will print it
    print("Profile Submitted:");
    print("Strengths: $selectedStrengths");
    print("Weaknesses: $selectedWeaknesses");
    print("Hours per Day: $hoursPerDay");
    print("Days per Week: $daysPerWeek");
    print("Preferred Study Time: $preferredStudyTime");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Strengths
            StrengthsWidget(
              selectedStrengths: selectedStrengths,
              onChanged: (selected) {
                setState(() {
                  selectedStrengths = selected;
                });
              },
            ),
            const SizedBox(height: 20),

            // Weaknesses
            WeaknessesWidget(
              selectedWeaknesses: selectedWeaknesses,
              onChanged: (selected) {
                setState(() {
                  selectedWeaknesses = selected;
                });
              },
            ),
            const SizedBox(height: 20),

            // Study Preferences
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

            // Submit Button
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
