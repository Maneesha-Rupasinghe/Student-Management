import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class QuizResultScreen extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final String quizLevel;
  final String quizSubject;

  const QuizResultScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.quizLevel,
    required this.quizSubject,
  });

  @override
  _QuizResultScreenState createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> recommendedResources = [];
  bool isLoading = true;
  String advice = '';

  @override
  void initState() {
    super.initState();
    _fetchRecommendedResources();
  }

  Future<void> _fetchRecommendedResources() async {
    final String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      setState(() {
        isLoading = false;
        advice = 'Please log in to view recommended resources.';
      });
      return;
    }

    final percentage = widget.correctAnswers / widget.totalQuestions * 100;
    String recommendedLevel;
    if (widget.quizLevel == 'Beginner' && percentage < 75) {
      recommendedLevel = 'Beginner';
      advice =
          'Great effort! Keep practicing with beginner resources to build your foundation.';
    } else if ((widget.quizLevel == 'Intermediate' && percentage < 75) ||
        (widget.quizLevel == 'Beginner' && percentage >= 75)) {
      recommendedLevel = 'Intermediate';
      advice =
          'Well done! You’re ready to move to intermediate resources for deeper learning.';
    } else {
      recommendedLevel = 'Advanced';
      advice =
          'Excellent work! Explore advanced resources to challenge yourself further.';
    }

    try {
      final url = Uri.parse(
        'http://192.168.1.4:8000/api/users_resources/?study_level=$recommendedLevel&subject=${widget.quizSubject}',
      );
      print('Fetching recommended resources from: $url');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}, body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          recommendedResources = data.cast<Map<String, dynamic>>();
          isLoading = false;
          if (recommendedResources.isEmpty) {
            advice +=
                '\nNo recommended resources found for this subject and level.';
          }
        });
      } else {
        setState(() {
          isLoading = false;
          advice =
              'Failed to load recommended resources: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        advice = 'Error fetching resources: $e';
      });
    }
  }

  Future<void> _launchURL(String url) async {
    // Validate URL format
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url'; // Add https:// as a fallback
    }

    try {
      final Uri uri = Uri.parse(url);
      print('Attempting to launch URL: $url');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('URL launched successfully: $url');
      } else {
        print('Cannot launch URL: $url');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    } catch (e) {
      print('Error launching URL: $url, Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error launching $url: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.correctAnswers / widget.totalQuestions * 100)
        .toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz Results',
          style: TextStyle(color: Colors.white),
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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Quiz Completed!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Correct Answers: ${widget.correctAnswers}/${widget.totalQuestions}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Percentage: $percentage%',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Advice: $advice',
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Recommended Resources:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: recommendedResources.length,
                            itemBuilder: (context, index) {
                              final resource = recommendedResources[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(
                                    resource['resource'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Level: ${resource['study_level']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  onTap: () {
                                    _launchURL(resource['resource']);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3674B5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/home',
                                (route) => false,
                                arguments: 1,
                              );
                            },
                            child: const Text(
                              'Back to Menu',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
