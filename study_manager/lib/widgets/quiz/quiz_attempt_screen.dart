import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:study_manager/widgets/quiz/quiz_results_screen.dart';
import 'package:study_manager/widgets/task/task_service.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

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
  final TaskService _taskService = TaskService();

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
      final String? token = await _storage.read(key: 'access_token');

      if (token == null) {
        setState(() {
          errorMessage = 'No access token found. Please log in first.';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          'http://192.168.1.4:8000/api/questions/?subject=${widget.subject}&level=${widget.level}',
        ),
        headers: {'Authorization': 'Bearer $token'},
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

    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i]['correct_answer']) {
        correctAnswers++;
      }
    }

    final percentage = (correctAnswers / questions.length * 100)
        .toStringAsFixed(2);
    print("Correct Answers: $correctAnswers / ${questions.length}");
    print("Percentage: $percentage%");

    await _saveQuizResults(percentage);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizResultScreen(
              correctAnswers: correctAnswers,
              totalQuestions: questions.length,
              quizLevel: widget.level.capitalize(),
              quizSubject: widget.subject, // Add the subject parameter
            ),
      ),
    );
  }

  Future<void> _saveQuizResults(String percentage) async {
    final String? token = await _storage.read(key: 'access_token');
    print("Retrieved token: $token");

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }

    final body = {
      'subject': widget.subject,
      'level': widget.level.capitalize(),
      'results': '$percentage%',
    };

    print("Quiz results request body: $body");

    try {
      final quizResponse = await http.post(
        Uri.parse('http://192.168.1.4:8000/api/quiz/results/save/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("Quiz results response status: ${quizResponse.statusCode}");
      print("Quiz results response body: ${quizResponse.body}");

      if (quizResponse.statusCode == 200 || quizResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz results saved successfully!')),
        );
        print("About to call updateStudyPlans for subject: ${widget.subject}");
        try {
          final studyPlanResult = await _taskService.updateStudyPlans(
            widget.subject,
          );
          print("Study plans update result: $studyPlanResult");
          if (studyPlanResult['success']) {
            final updatedPlans =
                studyPlanResult['data']['updated_plans'] as List;
            final errors = studyPlanResult['data']['errors'] as List;
            if (updatedPlans.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Updated ${updatedPlans.length} study plan(s) for ${widget.subject}',
                  ),
                ),
              );
            } else if (studyPlanResult['data'].containsKey('message')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(studyPlanResult['data']['message'])),
              );
            }
            if (errors.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Some study plans failed to update: ${errors.length} error(s)',
                  ),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to update study plans: ${studyPlanResult['error']}',
                ),
              ),
            );
          }
        } catch (e) {
          print("Error in updateStudyPlans: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating study plans: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save quiz results: ${quizResponse.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving quiz results: $e')));
      print("Error saving quiz results: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.subject} - ${widget.level} Quiz',
            style: const TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3674B5), Color(0xFF3674B5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.subject} - ${widget.level} Quiz',
            style: const TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3674B5), Color(0xFF3674B5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3674B5),
                    ),
                    onPressed: fetchQuizData,
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subject} - ${widget.level} Quiz',
          style: const TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3674B5), Color(0xFF3674B5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3674B5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Question ${currentQuestionIndex + 1}/${questions.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3674B5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  currentQuestion['question'],
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                ...List.generate(currentQuestion['choices'].length, (index) {
                  final choice = currentQuestion['choices'][index];
                  final isSelected =
                      userAnswers[currentQuestionIndex] == choice;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected
                                ? const Color(0xFF3674B5).withOpacity(0.1)
                                : Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFF3674B5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3674B5),
                      ),
                      onPressed:
                          currentQuestionIndex > 0 ? previousQuestion : null,
                      child: const Text(
                        'Previous',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3674B5),
                      ),
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
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
