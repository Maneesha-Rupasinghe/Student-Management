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

  void _submitProfile() {
    print("Profile Submitted:");
    print("Strengths: $selectedStrengths");
    print("Weaknesses: $selectedWeaknesses");
    print("Hours per Day: $hoursPerDay");
    print("Days per Week: $daysPerWeek");
    print("Preferred Study Time: $preferredStudyTime");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3674B5), Color(0xFF3674B5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "General",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
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
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3674B5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 4,
                  ),
                  onPressed: _submitProfile,
                  child: const Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}