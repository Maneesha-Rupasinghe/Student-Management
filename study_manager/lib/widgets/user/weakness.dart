import 'package:flutter/material.dart';

class WeaknessesWidget extends StatelessWidget {
  final List<String> selectedWeaknesses;
  final ValueChanged<List<String>> onChanged;

  WeaknessesWidget({
    super.key,
    required this.selectedWeaknesses,
    required this.onChanged,
  });

  final List<String> weaknesses = [
    "I am a little bit lazy",
    "Very poor memory",
    "Easily distracted",
    "Have trouble focusing for long periods",
    "Tend to procrastinate often",
    "Find it hard to start studying without motivation",
    "Struggle with organizing tasks",
    "Have difficulty managing stress",
    "Struggle with retaining information",
    "Tend to overthink tasks and waste time",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Your Weaknesses",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...weaknesses.map((weakness) {
          return CheckboxListTile(
            title: Text(weakness),
            value: selectedWeaknesses.contains(weakness),
            onChanged: (bool? value) {
              if (value == true) {
                onChanged([...selectedWeaknesses, weakness]);
              } else {
                onChanged(selectedWeaknesses..remove(weakness));
              }
            },
          );
        }).toList(),
      ],
    );
  }
}
