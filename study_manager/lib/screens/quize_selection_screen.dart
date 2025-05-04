import 'package:flutter/material.dart';
import 'add_quiz_question_screen.dart';

class AddQuizSelectionScreen extends StatefulWidget {
  const AddQuizSelectionScreen({super.key});

  @override
  _AddQuizSelectionScreenState createState() => _AddQuizSelectionScreenState();
}

class _AddQuizSelectionScreenState extends State<AddQuizSelectionScreen> {
  final List<String> subjects = ['OOP', 'DSA', 'SE'];
  final List<String> levels = ['Beginner', 'Intermediate', 'Advanced'];
  String? selectedSubject;
  String? selectedLevel;

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz Selection',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Select Subject:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Subject',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF3674B5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: selectedSubject,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSubject = newValue;
                      });
                    },
                    items:
                        subjects.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Level:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Level',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF3674B5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: selectedLevel,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLevel = newValue;
                      });
                    },
                    items:
                        levels.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        if (selectedSubject != null && selectedLevel != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AddQuizQuestionScreen(
                                    subject: selectedSubject!,
                                    level: selectedLevel!,
                                  ),
                            ),
                          );
                        } else {
                          _showSnackBar(
                            'Please select subject and level',
                            isError: true,
                          );
                        }
                      },
                      child: const Text(
                        'Proceed to Add Questions',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
