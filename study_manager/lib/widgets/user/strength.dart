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
    "Have good memory",
    "Quick learner",
    "Can stay focused for extended periods",
    "Have a strong analytical mindset",
    "Good at organizing tasks and time",
    "Able to stay motivated without external push",
    "Skilled at breaking down complex tasks",
    "Good at retaining information through reading",
    "Can prioritize tasks efficiently",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Your Strengths",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...strengths.map((strength) {
          return CheckboxListTile(
            title: Text(strength),
            value: selectedStrengths.contains(strength),
            onChanged: (bool? value) {
              if (value == true) {
                onChanged([...selectedStrengths, strength]);
              } else {
                onChanged(selectedStrengths..remove(strength));
              }
            },
          );
        }).toList(),
      ],
    );
  }
}
