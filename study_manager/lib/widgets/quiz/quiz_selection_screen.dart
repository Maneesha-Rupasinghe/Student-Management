import 'package:flutter/material.dart';
import 'quiz_attempt_screen.dart';

class QuizSelectionScreen extends StatefulWidget {
  const QuizSelectionScreen({super.key});

  @override
  _QuizSelectionScreenState createState() => _QuizSelectionScreenState();
}

class _QuizSelectionScreenState extends State<QuizSelectionScreen> {
  String? selectedSubject;
  String? selectedLevel;
  final List<String> subjects = ['OOP', 'Database', 'Networking', 'Algorithms'];
  final List<String> levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Subject:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: selectedSubject,
              hint: const Text('Choose a subject'),
              isExpanded: true,
              items: subjects.map((String subject) {
                return DropdownMenuItem<String>(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSubject = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Select Level:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: levels.map((level) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLevel = level;
                      });
                    },
                    child: Card(
                      color: selectedLevel == level
                          ? Colors.blue.shade100
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(child: Text(level)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: (selectedSubject != null && selectedLevel != null)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizAttemptScreen(
                              subject: selectedSubject!,
                              level: selectedLevel!,
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text('Start Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}