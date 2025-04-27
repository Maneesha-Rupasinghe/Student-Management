import 'package:flutter/material.dart';
import 'add_quiz_question_screen.dart'; // Import AddQuizQuestionScreen

class AddQuizSelectionScreen extends StatefulWidget {
  const AddQuizSelectionScreen({super.key});

  @override
  _AddQuizSelectionScreenState createState() => _AddQuizSelectionScreenState();
}

class _AddQuizSelectionScreenState extends State<AddQuizSelectionScreen> {
  final List<String> subjects = ['OOP', 'DSA', 'SE'];  // List of subjects
  final List<String> levels = ['Beginner', 'Intermediate', 'Advanced'];  // List of levels
  String? selectedSubject;
  String? selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Selection')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              hint: const Text('Select Subject'),
              value: selectedSubject,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSubject = newValue;
                });
              },
              items: subjects.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              hint: const Text('Select Level'),
              value: selectedLevel,
              onChanged: (String? newValue) {
                setState(() {
                  selectedLevel = newValue;
                });
              },
              items: levels.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedSubject != null && selectedLevel != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddQuizQuestionScreen(
                        subject: selectedSubject!,
                        level: selectedLevel!,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select subject and level')),
                  );
                }
              },
              child: const Text('Proceed to Add Questions'),
            ),
          ],
        ),
      ),
    );
  }
}
