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
    "Easily distracted",
    "Tend to procrastinate often",
    "Find it hard to start studying without motivation",
    "Struggle with organizing tasks",
    "Have difficulty managing stress",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Your Weaknesses",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3674B5),
          ),
        ),
        const SizedBox(height: 10),
        ...weaknesses.map((weakness) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color:
                selectedWeaknesses.contains(weakness)
                    ? const Color(0xFF3674B5).withOpacity(0.1)
                    : Colors.white,
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(weakness, style: const TextStyle(fontSize: 16)),
              value: selectedWeaknesses.contains(weakness),
              onChanged: (bool? value) {
                if (value == true) {
                  onChanged([...selectedWeaknesses, weakness]);
                } else {
                  onChanged(selectedWeaknesses..remove(weakness));
                }
              },
              activeColor: const Color(0xFF3674B5),
              checkColor: Colors.white,
            ),
          );
        }).toList(),
      ],
    );
  }
}
