import 'package:flutter/material.dart';
import 'package:study_manager/widgets/task/date_picker_field.dart';
import 'package:study_manager/widgets/task/priority_selector.dart';
import 'package:study_manager/widgets/task/task_service.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar_controller.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key});

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
  List<String> _skipDays = [];
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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_skipDays.length >= 7) {
        _showSnackBar(
          'Please leave at least one day available for studying.',
          isError: true,
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
        skipDays: _skipDays,
      );

      final result = await TaskService().saveTaskToBackend(task);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        TaskService().addTask(task);
        _showSnackBar('Task saved successfully!', isError: false);
        Navigator.pushNamed(context, '/task-list');
      } else {
        _showSnackBar(result['error'] ?? 'Failed to save task.', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Task Name'),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Subject'),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Task Type'),
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
              const SizedBox(height: 16),
              DatePickerField(
                label: 'Exam/Target Date',
                selectedDate: _examDate,
                onDateSelected: (date) {
                  setState(() {
                    _examDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              DatePickerField(
                label: 'Study Start Date',
                selectedDate: _studyStartDate,
                onDateSelected: (date) {
                  setState(() {
                    _studyStartDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              PrioritySelector(
                selectedPriority: _priority,
                onPriorityChanged: (priority) {
                  setState(() {
                    _priority = priority;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Estimated Study Hours',
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
              const SizedBox(height: 16),
              Text(
                'Skip Days',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 4,
                onSaved: (value) {
                  _notes = value ?? '';
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Add Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
