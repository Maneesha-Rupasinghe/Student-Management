import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:study_manager/models/task_model.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final List<Task> _tasks = [];
  final _storage = FlutterSecureStorage();
  final String baseUrl = 'http://192.168.1.4:8000/api/task-event/save/';
  final String studyPlanUrl = 'http://192.168.1.4:8000/api/study-plan/';
  final String updateStudyPlansUrl =
      'http://192.168.1.4:8000/api/update-study-plans/';

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    _tasks.add(task);
  }

  Task createTask({
    required String taskName,
    required String subject,
    required DateTime examDate,
    required int priority,
    required DateTime studyStartDate,
    required String notes,
    required String taskType,
    required double estimatedHours,
    required List<String> skipDays,
  }) {
    return Task(
      taskName: taskName,
      subject: subject,
      examDate: examDate,
      priority: priority,
      studyStartDate: studyStartDate,
      notes: notes,
      taskType: taskType,
      estimatedHours: estimatedHours,
      skipDays: skipDays,
    );
  }

  Future<Map<String, dynamic>> saveTaskToBackend(Task task) async {
    try {
      final String? token = await _storage.read(key: 'access_token');

      if (token == null) {
        return {
          'success': false,
          'error': 'No access token found. Please log in first.',
        };
      }

      final Map<String, dynamic> body = {
        'task_name': task.taskName,
        'subject': task.subject,
        'task_type': task.taskType,
        'start_date': task.studyStartDate.toUtc().toIso8601String(),
        'event_date': task.examDate.toUtc().toIso8601String(),
        'estimated_study_hours': task.estimatedHours,
        'notes': task.notes,
        'priority': task.priority,
        'skip_days': task.skipDays,
      };

      print('Sending task data: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final taskEventId = responseData['task_event_id'];
        await _createStudyPlan(taskEventId, task);
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error':
              'Failed to save task: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error saving task: $e');
      return {'success': false, 'error': 'Error saving task: $e'};
    }
  }

  Future<void> _createStudyPlan(int taskEventId, Task task) async {
    try {
      final String? token = await _storage.read(key: 'access_token');

      if (token == null) {
        throw 'No access token found. Please log in first.';
      }

      final Map<String, dynamic> studyPlanBody = {
        'subject': task.subject,
        'study_start_date': task.studyStartDate.toUtc().toIso8601String(),
        'exam_date': task.examDate.toUtc().toIso8601String(),
        'estimated_study_hours': task.estimatedHours,
        'id': taskEventId,
      };

      print('Sending study plan data: ${jsonEncode(studyPlanBody)}');

      final response = await http.post(
        Uri.parse(studyPlanUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(studyPlanBody),
      );

      print('Study plan response status: ${response.statusCode}');
      print('Study plan response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('Study plan created successfully: $responseData');
      } else {
        print(
          'Failed to create study plan: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error creating study plan: $e');
    }
  }

  Future<Map<String, dynamic>> updateStudyPlans(String subject) async {
    try {
      final String? token = await _storage.read(key: 'access_token');

      if (token == null) {
        return {
          'success': false,
          'error': 'No access token found. Please log in first.',
        };
      }

      final Map<String, dynamic> body = {'subject': subject};

      print('Sending update study plans data: ${jsonEncode(body)}');

      final response = await http
          .post(
            Uri.parse(updateStudyPlansUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              return http.Response('Request timed out', 408);
            },
          );

      print('Update study plans response status: ${response.statusCode}');
      print('Update study plans response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 207) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error':
              'Failed to update study plans: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error updating study plans: $e');
      return {'success': false, 'error': 'Error updating study plans: $e'};
    }
  }
}
