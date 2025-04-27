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
  String? _correctAnswer; // Correct answer text
  final _storage = FlutterSecureStorage();

  // Function to submit the question
  Future<void> _submitQuestion() async {
    if (_formKey.currentState!.validate()) {
      // Prepare the question data
      final questionData = {
        'subject': widget.subject,
        'difficulty_level': widget.level,
        'question': _questionController.text,
        'choice_1': _choice1Controller.text,
        'choice_2': _choice2Controller.text,
        'choice_3': _choice3Controller.text,
        'choice_4': _choice4Controller.text,
        'correct_answer': _correctAnswer, // Save the correct answer text
      };

      final String? token = await _storage.read(key: 'access_token');

      // Send the question data to the backend
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/questions/add/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode([questionData]), // Sending as a list
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question added successfully')),
        );
        Navigator.pop(context); // Return to the previous screen
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
      appBar: AppBar(title: const Text('Add Quiz Question')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _choice1Controller,
                decoration: const InputDecoration(labelText: 'Choice 1'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Choice 1';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _choice2Controller,
                decoration: const InputDecoration(labelText: 'Choice 2'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Choice 2';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _choice3Controller,
                decoration: const InputDecoration(labelText: 'Choice 3'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Choice 3';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _choice4Controller,
                decoration: const InputDecoration(labelText: 'Choice 4'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Choice 4';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Dropdown to select the correct answer text
              DropdownButton<String>(
                hint: const Text('Select Correct Answer'),
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
                        .where(
                          (choice) => choice.isNotEmpty,
                        ) // Filter out empty choices
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        })
                        .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitQuestion,
                child: const Text('Submit Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
