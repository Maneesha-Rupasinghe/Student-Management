import 'package:flutter/material.dart';
import 'package:study_manager/screens/quize_selection_screen.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar_controller.dart';
import 'package:study_manager/widgets/quiz/quiz_selection_screen.dart';

class QuizMenuScreen extends StatelessWidget {
  const QuizMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Menu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Reset the bottom navigation bar index to Home (index 0)
            final _controller = NotchBottomBarController(index: 0);
            _controller.jumpTo(0);
            Navigator.popUntil(context, ModalRoute.withName('/home'));
          },
        ),
      ),
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
