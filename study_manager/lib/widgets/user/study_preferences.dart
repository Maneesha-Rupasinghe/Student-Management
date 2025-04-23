import 'package:flutter/material.dart';

class StudyPreferencesWidget extends StatelessWidget {
  final int hoursPerDay;
  final int daysPerWeek;
  final String preferredStudyTime;
  final ValueChanged<int> onHoursPerDayChanged;
  final ValueChanged<int> onDaysPerWeekChanged;
  final ValueChanged<String> onPreferredStudyTimeChanged;

  const StudyPreferencesWidget({
    super.key,
    required this.hoursPerDay,
    required this.daysPerWeek,
    required this.preferredStudyTime,
    required this.onHoursPerDayChanged,
    required this.onDaysPerWeekChanged,
    required this.onPreferredStudyTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Study Preferences",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Hours per Day
        Row(
          children: [
            const Text("Hours per Day: "),
            Expanded(
              child: Slider(
                value: hoursPerDay.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                label: '$hoursPerDay hours',
                onChanged: (value) {
                  onHoursPerDayChanged(value.toInt());
                },
              ),
            ),
          ],
        ),

        // Days per Week
        Row(
          children: [
            const Text("Days per Week: "),
            Expanded(
              child: Slider(
                value: daysPerWeek.toDouble(),
                min: 1,
                max: 7,
                divisions: 6,
                label: '$daysPerWeek days',
                onChanged: (value) {
                  onDaysPerWeekChanged(value.toInt());
                },
              ),
            ),
          ],
        ),

        // Preferred Study Time
        const Text("Preferred Study Time:"),
        ListTile(
          title: const Text("Morning"),
          leading: Radio<String>(
            value: "Morning",
            groupValue: preferredStudyTime,
            onChanged: (String? value) {
              if (value != null) {
                onPreferredStudyTimeChanged(value);
              }
            },
          ),
        ),
        ListTile(
          title: const Text("Day"),
          leading: Radio<String>(
            value: "Day",
            groupValue: preferredStudyTime,
            onChanged: (String? value) {
              if (value != null) {
                onPreferredStudyTimeChanged(value);
              }
            },
          ),
        ),
        ListTile(
          title: const Text("Night"),
          leading: Radio<String>(
            value: "Night",
            groupValue: preferredStudyTime,
            onChanged: (String? value) {
              if (value != null) {
                onPreferredStudyTimeChanged(value);
              }
            },
          ),
        ),
        ListTile(
          title: const Text("Any time"),
          leading: Radio<String>(
            value: "Any time",
            groupValue: preferredStudyTime,
            onChanged: (String? value) {
              if (value != null) {
                onPreferredStudyTimeChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}
