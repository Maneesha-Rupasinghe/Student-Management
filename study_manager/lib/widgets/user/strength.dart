import 'package:flutter/material.dart';

class StrengthsWidget extends StatelessWidget {
  final List<String> selectedStrengths;
  final ValueChanged<List<String>> onChanged;

  StrengthsWidget({
    super.key,
    required this.selectedStrengths,
    required this.onChanged,
  });

  final List<String> strengths = [
    "Can work more than 3 hours continuously",
    "Good at organizing tasks and time",
    "Quick learner",
    "Can stay focused for extended periods",
    "Good at retaining information through reading",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Your Strengths",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3674B5),
          ),
        ),
        const SizedBox(height: 10),
        ...strengths.map((strength) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color:
                selectedStrengths.contains(strength)
                    ? const Color(0xFF3674B5).withOpacity(0.1)
                    : Colors.white,
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(strength, style: const TextStyle(fontSize: 16)),
              value: selectedStrengths.contains(strength),
              onChanged: (bool? value) {
                if (value == true) {
                  onChanged([...selectedStrengths, strength]);
                } else {
                  onChanged(selectedStrengths..remove(strength));
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
