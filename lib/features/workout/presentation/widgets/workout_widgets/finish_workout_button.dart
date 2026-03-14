import 'package:flutter/material.dart';

class FinishWorkoutButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const FinishWorkoutButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,

      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6C63FF),
        disabledBackgroundColor: Colors.grey.withAlpha(50),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      child: const Text(
        'Finish Workout',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
