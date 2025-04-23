import 'package:flutter/material.dart';
import 'package:study_manager/widgets/user/strength.dart';
import 'package:study_manager/widgets/user/study_preferences.dart';
import 'package:study_manager/widgets/user/weakness.dart';


class GeneralSection extends StatefulWidget {
  const GeneralSection({super.key});

  @override
  _GeneralSectionState createState() => _GeneralSectionState();
}

class _GeneralSectionState extends State<GeneralSection> {
  List<String> selectedStrengths = [];
  List<String> selectedWeaknesses = [];
  int hoursPerDay = 2;
  int daysPerWeek = 5;
  String preferredStudyTime = "Morning";

  // Function to submit profile changes
  void _submitProfile() {
    print("Profile Submitted:");
    print("Strengths: $selectedStrengths");
    print("Weaknesses: $selectedWeaknesses");
    print("Hours per Day: $hoursPerDay");
    print("Days per Week: $daysPerWeek");
    print("Preferred Study Time: $preferredStudyTime");

    // Here you can send the data to the backend or store it locally
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // General Section Header
        const Text(
          "General",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Strengths Widget
        StrengthsWidget(
          selectedStrengths: selectedStrengths,
          onChanged: (selected) {
            setState(() {
              selectedStrengths = selected;
            });
          },
        ),
        const SizedBox(height: 20),

        // Weaknesses Widget
        WeaknessesWidget(
          selectedWeaknesses: selectedWeaknesses,
          onChanged: (selected) {
            setState(() {
              selectedWeaknesses = selected;
            });
          },
        ),
        const SizedBox(height: 20),

        // Study Preferences Widget
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
    );
  }
}
