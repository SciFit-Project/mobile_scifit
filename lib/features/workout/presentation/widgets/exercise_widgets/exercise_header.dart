import 'package:flutter/material.dart';

class ExerciseHeader extends StatelessWidget {
  const ExerciseHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            'SET',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            'KG',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            'REPS',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ),
        SizedBox(width: 40),
      ],
    );
  }
}
