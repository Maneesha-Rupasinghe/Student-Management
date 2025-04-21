import 'package:flutter/material.dart';

class QuizPercentageCircle extends StatelessWidget {
  const QuizPercentageCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue[100],
        ),
        child: Center(
          child: Text(
            '85%', // Replace with quiz correct percentage
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
