import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddQuizQuestionScreen extends StatefulWidget {
  final String subject;
  final String level;

  const AddQuizQuestionScreen({
    super.key,
    required this.subject,
    required this.level,
  });

  @override
  _AddQuizQuestionScreenState createState() => _AddQuizQuestionScreenState();
}

class _AddQuizQuestionScreenState extends State<AddQuizQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _choice1Controller = TextEditingController();
  final TextEditingController _choice2Controller = TextEditingController();
  final TextEditingController _choice3Controller = TextEditingController();
  final TextEditingController _choice4Controller = TextEditingController();
  String? _correctAnswer;
  final _storage = FlutterSecureStorage();

  Future<void> _submitQuestion() async {
    if (_formKey.currentState!.validate()) {
      final questionData = {
        'subject': widget.subject,
        'difficulty_level': widget.level,
        'question': _questionController.text,
        'choice_1': _choice1Controller.text,
        'choice_2': _choice2Controller.text,
        'choice_3': _choice3Controller.text,
        'choice_4': _choice4Controller.text,
        'correct_answer': _correctAnswer,
      };

      final String? token = await _storage.read(key: 'access_token');

      final response = await http.post(
        Uri.parse('http://192.168.1.4:8000/api/questions/add/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode([questionData]),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question added successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add question: ${response.body}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Quiz Question',
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        labelText: 'Question',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF3674B5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter a question';
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _choice1Controller,
                      decoration: InputDecoration(
                        labelText: 'Choice 1',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF3674B5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter Choice 1';
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _choice2Controller,
                      decoration: InputDecoration(
                        labelText: 'Choice 2',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF3674B5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter Choice 2';
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _choice3Controller,
                      decoration: InputDecoration(
                        labelText: 'Choice 3',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF3674B5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter Choice 3';
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _choice4Controller,
                      decoration: InputDecoration(
                        labelText: 'Choice 4',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF3674B5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter Choice 4';
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Correct Answer',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF3674B5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: _correctAnswer,
                      onChanged: (String? newValue) {
                        setState(() {
                          _correctAnswer = newValue;
                        });
                      },
                      items:
                          [
                                _choice1Controller.text,
                                _choice2Controller.text,
                                _choice3Controller.text,
                                _choice4Controller.text,
                              ]
                              .where((choice) => choice.isNotEmpty)
                              .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              })
                              .toList(),
                      validator:
                          (value) =>
                              value == null
                                  ? 'Please select a correct answer'
                                  : null,
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
                        onPressed: _submitQuestion,
                        child: const Text(
                          'Submit Question',
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
      ),
    );
  }
}
