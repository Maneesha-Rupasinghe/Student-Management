import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:study_manager/widgets/quiz/quiz_results_screen.dart';

class QuizAttemptScreen extends StatefulWidget {
  final String subject;
  final String level;

  const QuizAttemptScreen({
    super.key,
    required this.subject,
    required this.level,
  });

  @override
  _QuizAttemptScreenState createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  Map<int, String> userAnswers = {};
  bool isLoading = true;
  String? errorMessage;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchQuizData();
  }

  Future<void> fetchQuizData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Retrieve the access token from secure storage
      final String? token = await _storage.read(key: 'access_token');

      if (token == null) {
        // If the token is not available, show an error and return
        setState(() {
          errorMessage = 'No access token found. Please log in first.';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8000/api/questions/?subject=${widget.subject}&level=${widget.level}',
        ),
        headers: {
          'Authorization':
              'Bearer $token', // Include the token in the Authorization header
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          questions = List<Map<String, dynamic>>.from(data['questions']);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load quiz data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching quiz data: $e';
        isLoading = false;
      });
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void submitQuiz() async {
    int correctAnswers = 0;

    // Calculate correct answers
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i]['correct_answer']) {
        correctAnswers++;
      }
    }

    // Calculate the percentage
    final percentage = (correctAnswers / questions.length * 100)
        .toStringAsFixed(2);
    print("Correct Answers: $correctAnswers / ${questions.length}");
    print("Percentage: $percentage%");

    // Save the quiz results to the API
    await _saveQuizResults(percentage);

    // Navigate to the Quiz Result Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizResultScreen(
              correctAnswers: correctAnswers,
              totalQuestions: questions.length,
            ),
      ),
    );
  }

  Future<void> _saveQuizResults(String percentage) async {
    // Retrieve the access token from secure storage
    final String? token = await _storage.read(key: 'access_token');
    print("Retrieved token: $token");

    if (token == null) {
      // If no token is available, show an error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }

    // Define the body of the POST request
    final body = {
      'subject': widget.subject,
      'level': widget.level,
      'results':
          '$percentage%', // Send the percentage as a string with a percentage sign
    };

    print("Request body: $body"); // Debug the request body

    try {
      // Send the request to the backend
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/quiz/results/save/'),
        headers: {
          'Authorization':
              'Bearer $token', // Include the token in the Authorization header
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // Handle the response (e.g., show success message)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz results saved successfully!')),
        );
      } else {
        // Handle failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save quiz results: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving quiz results: $e')));
      print("Error saving quiz results: $e"); // Print error for debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.subject} - ${widget.level} Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.subject} - ${widget.level} Quiz')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchQuizData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('${widget.subject} - ${widget.level} Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              currentQuestion['question'],
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ...List.generate(currentQuestion['choices'].length, (index) {
              final choice = currentQuestion['choices'][index];
              final isSelected = userAnswers[currentQuestionIndex] == choice;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSelected ? Colors.blue.shade100 : Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey),
                  ),
                  onPressed: () {
                    setState(() {
                      userAnswers[currentQuestionIndex] = choice;
                    });
                  },
                  child: Text(choice),
                ),
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentQuestionIndex > 0 ? previousQuestion : null,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed:
                      currentQuestionIndex < questions.length - 1
                          ? nextQuestion
                          : userAnswers.length == questions.length
                          ? submitQuiz
                          : null,
                  child: Text(
                    currentQuestionIndex < questions.length - 1
                        ? 'Next'
                        : 'Submit',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
