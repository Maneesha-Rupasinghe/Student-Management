import 'package:flutter/material.dart';
import 'package:study_manager/screens/quize_selection_screen.dart';
import 'package:study_manager/widgets/quiz/quiz_selection_screen.dart';


class QuizMenuScreen extends StatelessWidget {
  const QuizMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizSelectionScreen(),
                  ),
                );
              },
              child: const Text('Attempt a Quiz'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to QuizSelectionScreen to add a new quiz
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddQuizSelectionScreen(),
                  ),
                );
              },
              child: const Text('Add New Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
