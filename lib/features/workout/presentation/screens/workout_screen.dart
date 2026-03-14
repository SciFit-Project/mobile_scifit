import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/workout/presentation/widgets/workout_widgets/exercise_row.dart';
import 'package:mobile_scifit/features/workout/presentation/widgets/workout_widgets/finish_workout_button.dart';
import 'package:mobile_scifit/features/workout/presentation/widgets/workout_widgets/workout_progress.dart';
import 'package:mobile_scifit/features/workout/types/response_type.dart';

class WorkoutPlanScreen extends StatefulWidget {
  final String dayId;
  const WorkoutPlanScreen({super.key, required this.dayId});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  final List<WorkoutExercise> _exercises = [
    WorkoutExercise(
      id: '1',
      name: 'Bench Press',
      sets: 4,
      reps: '8-12',
      muscleGroup: "chest",
    ),
    WorkoutExercise(
      id: '2',
      name: 'Incline Dumbbell',
      sets: 3,
      reps: '10-12',
      muscleGroup: "chest",
    ),
    WorkoutExercise(
      id: '3',
      name: 'Cable Fly',
      sets: 3,
      reps: '12-15',
      muscleGroup: "chest",
    ),
    WorkoutExercise(
      id: '4',
      name: 'Tricep Pushdown',
      sets: 3,
      reps: '12-15',
      muscleGroup: "triceps",
    ),
  ];

  final String _sessionId = 'mock-session-id';

  void _markDone(int index) {
    setState(() {
      _exercises[index].done = true;
    });
  }

  bool get _allDone => _exercises.every((e) => e.done == true);

  int get _doneCount => _exercises.where((e) => e.done).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Push Day',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            WorkoutProgress(done: _doneCount, total: _exercises.length),

            const Gap(16),

            Expanded(
              child: ListView.separated(
                itemCount: _exercises.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  final isDone = exercise.done;

                  return ExerciseRow(
                    name: exercise.name,
                    sets: exercise.sets,
                    reps: exercise.reps,
                    isDone: isDone,
                    muscleGroup: exercise.muscleGroup,
                    onTap: isDone
                        ? null
                        : () async {
                            await context.push(
                              '/workout-plan/${widget.dayId}/exercise/${exercise.id}?sessionId=$_sessionId',
                            );

                            _markDone(index);
                          },
                  );
                },
              ),
            ),

            FinishWorkoutButton(
              enabled: _allDone,
              onPressed: () => context.pop(),
            ),
            const Gap(8),
            Text(
              "Complete all exercise to finish",
              style: TextStyle(color: Colors.black.withAlpha(90)),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}
