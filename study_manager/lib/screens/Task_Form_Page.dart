import 'package:flutter/material.dart';
import 'package:study_manager/widgets/task/date_picker_field.dart';
import 'package:study_manager/widgets/task/priority_selector.dart';
import 'package:study_manager/widgets/task/task_service.dart';

class TaskFormPage extends StatefulWidget {
  @override
  _TaskFormPageState createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _subject = '';
  DateTime? _examDate;
  int _priority = 1;
  DateTime? _studyStartDate;
  String _notes = '';
  String _taskType = 'Exam';
  double _estimatedHours = 1.0;
  String _taskName = '';
  List<String> _skipDays = []; // New field for skip days
  bool _isLoading = false;

  final _subjects = ['OOP', 'DSA', 'SE'];
  final _taskTypes = ['Exam', 'Assignment', 'Project', 'Revision'];
  final _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validate skip days
      if (_skipDays.length >= 7) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please leave at least one day available for studying.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final task = TaskService().createTask(
        subject: _subject,
        examDate: _examDate!,
        priority: _priority,
        studyStartDate: _studyStartDate!,
        notes: _notes,
        taskType: _taskType,
        estimatedHours: _estimatedHours,
        taskName: _taskName,
        skipDays: _skipDays, // Pass skip days to TaskService
      );

      // Save task to backend
      final result = await TaskService().saveTaskToBackend(task);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Add task locally for UI
        TaskService().addTask(task);
        

        // Show success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Task saved successfully!')));

        // Navigate to TaskListPage
        Navigator.pushNamed(context, '/task-list');
      } else {
        // Show specific error message from backend
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to save task.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Task')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Name
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _taskName = value ?? '';
                },
              ),
              SizedBox(height: 16),

              // Subject Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                value: _subjects.contains(_subject) ? _subject : null,
                items:
                    _subjects
                        .map(
                          (subject) => DropdownMenuItem(
                            value: subject,
                            child: Text(subject),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _subject = value!;
                  });
                },
                validator:
                    (value) => value == null ? 'Please select a subject' : null,
              ),
              SizedBox(height: 16),

              // Task Type Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Task Type',
                  border: OutlineInputBorder(),
                ),
                value: _taskType,
                items:
                    _taskTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _taskType = value!;
                  });
                },
              ),
              SizedBox(height: 16),

              // Exam Date
              DatePickerField(
                label: 'Exam/Target Date',
                selectedDate: _examDate,
                onDateSelected: (date) {
                  setState(() {
                    _examDate = date;
                  });
                },
              ),
              SizedBox(height: 16),

              // Study Start Date
              DatePickerField(
                label: 'Study Start Date',
                selectedDate: _studyStartDate,
                onDateSelected: (date) {
                  setState(() {
                    _studyStartDate = date;
                  });
                },
              ),
              SizedBox(height: 16),

              // Priority Selector
              PrioritySelector(
                selectedPriority: _priority,
                onPriorityChanged: (priority) {
                  setState(() {
                    _priority = priority;
                  });
                },
              ),
              SizedBox(height: 16),

              // Estimated Hours
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Estimated Study Hours',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: '1.0',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter estimated hours';
                  }
                  final hours = double.tryParse(value);
                  if (hours == null || hours <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _estimatedHours = double.parse(value!);
                },
              ),
              SizedBox(height: 16),

              // Skip Days Selector
              Text(
                'Skip Days',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children:
                    _daysOfWeek.map((day) {
                      return ChoiceChip(
                        label: Text(day),
                        selected: _skipDays.contains(day),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _skipDays.add(day);
                            } else {
                              _skipDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
              SizedBox(height: 16),

              // Notes
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                onSaved: (value) {
                  _notes = value ?? '';
                },
              ),
              SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
