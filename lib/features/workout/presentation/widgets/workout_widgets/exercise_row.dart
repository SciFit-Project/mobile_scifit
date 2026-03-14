import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';

class ExerciseRow extends StatelessWidget {
  final String name;
  final int sets;
  final String reps;
  final bool isDone;
  final String muscleGroup;
  final VoidCallback? onTap;

  const ExerciseRow({
    super.key,
    required this.name,
    required this.sets,
    required this.reps,
    required this.isDone,
    this.onTap,
    required this.muscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withAlpha(50)),
        ),

        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDone
                    ? AppTheme.primaryLight
                    : const Color(0xFF2C2C2C).withAlpha(60),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(10),
                      Badge(
                        label: Text(muscleGroup),
                        backgroundColor: AppTheme.primaryLight,
                        padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '$sets sets × $reps reps',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
