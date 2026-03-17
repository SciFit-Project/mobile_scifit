import 'package:flutter/material.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';

class WorkoutDayCard extends StatelessWidget {
  final int idx;
  final String workoutTitle;
  final int totalExercise;

  const WorkoutDayCard({
    super.key,
    required this.idx,
    required this.workoutTitle,
    required this.totalExercise,
  });

  void editWorkout() {
    debugPrint("Edit workout ID: $idx ");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "DAY ${(idx + 1).toString()}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryLight,
                ),
              ),
              Text(
                workoutTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${totalExercise.toString()} exercises",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          IconButton(onPressed: editWorkout, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
    );
  }
}
