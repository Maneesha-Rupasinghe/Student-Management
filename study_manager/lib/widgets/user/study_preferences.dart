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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3674B5),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      "Hours per Day: ",
                      style: TextStyle(fontSize: 16),
                    ),
                    Expanded(
                      child: Slider(
                        value: hoursPerDay.toDouble(),
                        min: 1,
                        max: 12,
                        divisions: 11,
                        label: '$hoursPerDay hours',
                        activeColor: const Color(0xFF3674B5),
                        inactiveColor: Colors.grey[300],
                        thumbColor: const Color(0xFF3674B5),
                        onChanged: (value) {
                          onHoursPerDayChanged(value.toInt());
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Days per Week: ",
                      style: TextStyle(fontSize: 16),
                    ),
                    Expanded(
                      child: Slider(
                        value: daysPerWeek.toDouble(),
                        min: 1,
                        max: 7,
                        divisions: 6,
                        label: '$daysPerWeek days',
                        activeColor: const Color(0xFF3674B5),
                        inactiveColor: Colors.grey[300],
                        thumbColor: const Color(0xFF3674B5),
                        onChanged: (value) {
                          onDaysPerWeekChanged(value.toInt());
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Preferred Study Time:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        ...["Morning", "Day", "Night", "Any time"].map((time) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              title: Text(time, style: const TextStyle(fontSize: 16)),
              leading: Radio<String>(
                value: time,
                groupValue: preferredStudyTime,
                activeColor: const Color(0xFF3674B5),
                onChanged: (String? value) {
                  if (value != null) {
                    onPreferredStudyTimeChanged(value);
                  }
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
