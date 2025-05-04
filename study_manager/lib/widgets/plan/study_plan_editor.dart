import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudyPlanEditor extends StatefulWidget {
  final int eventId;
  final String subject;
  final String startDate;
  final String examDate;
  final VoidCallback? onPlanSaved;

  const StudyPlanEditor({
    Key? key,
    required this.eventId,
    required this.subject,
    required this.startDate,
    required this.examDate,
    this.onPlanSaved,
  }) : super(key: key);

  @override
  _StudyPlanEditorState createState() => _StudyPlanEditorState();
}

class _StudyPlanEditorState extends State<StudyPlanEditor> {
  List<dynamic> studyPlan = [];
  bool isLoading = true;
  String errorMessage = '';
  String accessToken = '';
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchPlan();
  }

  Future<void> _loadTokenAndFetchPlan() async {
    final String? token = await _storage.read(key: 'access_token');
    setState(() {
      accessToken = token ?? '';
    });
    print('Access token: $accessToken');
    if (accessToken.isNotEmpty) {
      await _fetchStudyPlan();
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Authentication token not found. Please log in.';
      });
    }
  }

  Future<bool> _refreshToken() async {
    final String? refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null || refreshToken.isEmpty) {
      print('No refresh token available');
      return false;
    }
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:8000/api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );
      print(
        'Token refresh response: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          accessToken = data['access'];
        });
        await _storage.write(key: 'access_token', value: accessToken);
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  Future<void> _fetchStudyPlan() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.1.4:8000/api/study-plan-data/${widget.eventId}/',
        ),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      print(
        'Fetch study plan response: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        setState(() {
          studyPlan = jsonDecode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        if (await _refreshToken()) {
          await _fetchStudyPlan();
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'Authentication failed. Please log in again.';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load study plan: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      print('Fetch study plan error: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching study plan: $e';
      });
    }
  }

  Future<void> _saveStudyPlan() async {
    for (var day in studyPlan) {
      try {
        final studyDate = DateTime.parse(day['study_date']);
        final start = DateTime.parse(widget.startDate);
        final exam = DateTime.parse(widget.examDate);
        if (studyDate.isBefore(start) ||
            studyDate.isAfter(exam.subtract(const Duration(days: 1)))) {
          setState(() {
            isLoading = false;
            errorMessage =
                'Study dates must be between ${widget.startDate} and ${widget.examDate}';
          });
          return;
        }
        for (var session in day['sessions']) {
          final startTime = DateFormat('HH:mm').parse(session['start_time']);
          final endTime = DateFormat('HH:mm').parse(session['end_time']);
          if (endTime.isBefore(startTime) ||
              endTime.isAtSameMomentAs(startTime)) {
            setState(() {
              isLoading = false;
              errorMessage =
                  'End time must be after start time in session on ${day['study_date']}';
            });
            return;
          }
        }
      } catch (e) {
        setState(() {
          isLoading = false;
          errorMessage = 'Invalid date or time format: $e';
        });
        return;
      }
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await http.put(
        Uri.parse(
          'http://192.168.1.4:8000/api/study-plan/update/${widget.eventId}/',
        ),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'plan': studyPlan}),
      );
      print(
        'Save study plan response: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Study plan updated successfully!')),
        );
        setState(() {
          isLoading = false;
        });
        widget.onPlanSaved?.call();
        Navigator.pop(context);
      } else if (response.statusCode == 401) {
        if (await _refreshToken()) {
          await _saveStudyPlan();
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'Authentication failed. Please log in again.';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to save study plan: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      print('Save study plan error: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error saving study plan: $e';
      });
    }
  }

  void _updateSession(
    int dayIndex,
    int sessionIndex,
    String field,
    String value,
  ) {
    setState(() {
      studyPlan[dayIndex]['sessions'][sessionIndex][field] = value;
      try {
        final start = DateFormat(
          'HH:mm',
        ).parse(studyPlan[dayIndex]['sessions'][sessionIndex]['start_time']);
        final end = DateFormat(
          'HH:mm',
        ).parse(studyPlan[dayIndex]['sessions'][sessionIndex]['end_time']);
        final hours = end.difference(start).inMinutes / 60.0;
        studyPlan[dayIndex]['sessions'][sessionIndex]['hours_to_study'] =
            double.parse(hours.toStringAsFixed(2));
        studyPlan[dayIndex]['total_hours'] = studyPlan[dayIndex]['sessions']
            .fold(0.0, (sum, session) => sum + session['hours_to_study']);
      } catch (e) {
        print('Update session error: $e');
      }
    });
  }

  void _deleteSession(int dayIndex, int sessionIndex) {
    setState(() {
      studyPlan[dayIndex]['sessions'].removeAt(sessionIndex);
      studyPlan[dayIndex]['total_hours'] = studyPlan[dayIndex]['sessions'].fold(
        0.0,
        (sum, session) => sum + session['hours_to_study'],
      );
      if (studyPlan[dayIndex]['sessions'].isEmpty) {
        studyPlan.removeAt(dayIndex);
      }
    });
  }

  void _addSession(int dayIndex) {
    setState(() {
      studyPlan[dayIndex]['sessions'].add({
        'start_time': '08:00',
        'end_time': '09:00',
        'hours_to_study': 1.0,
      });
      studyPlan[dayIndex]['total_hours'] = studyPlan[dayIndex]['sessions'].fold(
        0.0,
        (sum, session) => sum + session['hours_to_study'],
      );
    });
  }

  void _deleteDay(int dayIndex) {
    setState(() {
      studyPlan.removeAt(dayIndex);
    });
  }

  void _addDay() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(widget.startDate),
      firstDate: DateTime.parse(widget.startDate),
      lastDate: DateTime.parse(
        widget.examDate,
      ).subtract(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        studyPlan.add({
          'study_date': DateFormat('yyyy-MM-dd').format(picked),
          'sessions': [
            {'start_time': '08:00', 'end_time': '09:00', 'hours_to_study': 1.0},
          ],
          'subject': widget.subject,
          'study_time': 'Morning',
          'total_hours': 1.0,
        });
        studyPlan.sort((a, b) => a['study_date'].compareTo(b['study_date']));
      });
    }
  }

  Widget _buildTimePicker(
    String label,
    String initialValue,
    Function(String) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(
            DateFormat('HH:mm').parse(initialValue),
          ),
        );
        if (picked != null) {
          final formattedTime =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          onChanged(formattedTime);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          child: Text(initialValue, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Study Plan - ${widget.subject}',
          style: const TextStyle(color: Colors.black),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB4EBE6), Color(0xFFB4EBE6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (!isLoading)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.black),
              onPressed: _saveStudyPlan,
            ),
        ],
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3674B5), Color(0xFF3674B5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        child: FloatingActionButton(
          onPressed: _addDay,
          backgroundColor: Colors.transparent,
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  )
                  : studyPlan.isEmpty
                  ? const Center(
                    child: Text(
                      'No study plan available.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                  : ListView.builder(
                    itemCount: studyPlan.length,
                    itemBuilder: (context, dayIndex) {
                      final day = studyPlan[dayIndex];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            'Date: ${day['study_date']} (${day['total_hours']} hours)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Subject: ${day['subject']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteDay(dayIndex),
                          ),
                          children:
                              day['sessions'].asMap().entries.map<Widget>((
                                  entry,
                                ) {
                                  final sessionIndex = entry.key;
                                  final session = entry.value;
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    elevation: 1,
                                    child: ListTile(
                                      title: Text(
                                        'Session ${sessionIndex + 1}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildTimePicker(
                                            'Start Time',
                                            session['start_time'],
                                            (value) => _updateSession(
                                              dayIndex,
                                              sessionIndex,
                                              'start_time',
                                              value,
                                            ),
                                          ),
                                          _buildTimePicker(
                                            'End Time',
                                            session['end_time'],
                                            (value) => _updateSession(
                                              dayIndex,
                                              sessionIndex,
                                              'end_time',
                                              value,
                                            ),
                                          ),
                                          Text(
                                            'Hours: ${session['hours_to_study']}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => _deleteSession(
                                              dayIndex,
                                              sessionIndex,
                                            ),
                                      ),
                                    ),
                                  );
                                }).toList()
                                ..add(
                                  ListTile(
                                    title: const Text(
                                      'Add Session',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    leading: const Icon(
                                      Icons.add,
                                      color: Color(0xFF3674B5),
                                    ),
                                    onTap: () => _addSession(dayIndex),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
