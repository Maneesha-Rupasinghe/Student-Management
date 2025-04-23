class QuizQuestion {
  final String question;
  final List<String> choices;
  final String correctAnswer;
  final String difficultyLevel;

  QuizQuestion({
    required this.question,
    required this.choices,
    required this.correctAnswer,
    required this.difficultyLevel,
  });
}
