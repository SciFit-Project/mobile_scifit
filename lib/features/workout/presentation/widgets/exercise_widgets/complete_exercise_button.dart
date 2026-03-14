import 'package:flutter/material.dart';

class CompleteExerciseButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const CompleteExerciseButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        disabledBackgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: Colors.black,
      ),
      child: Text(
        'Complete Exercise',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: enabled ? Colors.black: Colors.black26,
        ),
      ),
    );
  }
}
