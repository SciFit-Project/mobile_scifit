import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';

class WorkoutCard extends StatelessWidget {
  final String workoutTitle;
  final int totalExercise;
  final int timeDuration;
  final bool isCompleted;
  final VoidCallback? onNextDay;
  final VoidCallback? onReset;
  final VoidCallback onStartWorkout;
  const WorkoutCard({
    super.key,
    required this.workoutTitle,
    required this.totalExercise,
    required this.timeDuration,
    this.isCompleted = false,
    this.onNextDay,
    this.onReset,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S WORKOUT",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Gap(10),
          Text(
            workoutTitle,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Gap(10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 13, color: Colors.white),
              const Gap(5),
              Text(
                "$totalExercise exercises",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const Gap(5),

              const Icon(Icons.circle, size: 5, color: Colors.white),

              const Gap(5),

              const Icon(Icons.timer_sharp, size: 13, color: Colors.white),
              const Gap(5),

              Text(
                "~$timeDuration min",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Gap(16),

          ElevatedButton(
            onPressed: isCompleted ? null : onStartWorkout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(10),
              minimumSize: const Size(double.infinity, 52),
              disabledBackgroundColor: Colors.white.withAlpha(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withAlpha(50), width: 2.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isCompleted ? 'Done' : 'Start Workout',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  isCompleted ? Icons.check_circle_outline : Icons.arrow_forward_outlined,
                ),
              ],
            ),
          ),
          const Gap(10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNextDay,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                    side: BorderSide(color: Colors.white.withAlpha(80)),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.skip_next),
                  label: const Text(
                    'Next Day',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReset,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                    side: BorderSide(color: Colors.white.withAlpha(80)),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text(
                    'Reset',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
