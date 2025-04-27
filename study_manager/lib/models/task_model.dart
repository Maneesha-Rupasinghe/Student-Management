class Task {
  final String taskName;
  final String subject;
  final DateTime examDate;
  final int priority; // 1 to 5
  final DateTime studyStartDate;
  final String notes;
  final String taskType; // Exam, Assignment, Project
  final double estimatedHours;
  final List<String> skipDays;

  Task(
    {
    required this.taskName,
    required this.subject,
    required this.examDate,
    required this.priority,
    required this.studyStartDate,
    required this.notes,
    required this.taskType,
    required this.estimatedHours,
    required this.skipDays,
  });
}
