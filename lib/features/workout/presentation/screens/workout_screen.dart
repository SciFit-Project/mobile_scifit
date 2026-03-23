import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/plans/data/plan_store.dart';
import 'package:mobile_scifit/features/plans/types/plans_type.dart';
import 'package:mobile_scifit/features/sessions/data/session_repository.dart';
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
  final SessionRepository _sessionRepository = SessionRepository();
  late final List<WorkoutExercise> _exercises;
  late final String _workoutTitle;
  late final String _planName;

  String? _sessionId;
  bool _isStartingSession = true;

  @override
  void initState() {
    super.initState();
    final day = findWorkoutDayById(widget.dayId);
    final plan = _findPlanForDay(widget.dayId);
    _workoutTitle = day?.name ?? 'Workout';
    _planName = plan?.name ?? 'Workout Plan';
    _exercises =
        day?.exercises
            .map(
              (exercise) => WorkoutExercise(
                id: exercise.exerciseId,
                name: exercise.name,
                sets: exercise.sets,
                reps: '${exercise.reps}',
                muscleGroup: exercise.muscleGroup.toLowerCase(),
              ),
            )
            .toList() ??
        [];
    _startSession();
  }

  MyPlans? _findPlanForDay(String dayId) {
    for (final plan in currentPlans) {
      if (plan.days.any((day) => day.id == dayId)) {
        return plan;
      }
    }
    return findActivePlan();
  }

  Future<void> _startSession() async {
    final sessionId = await _sessionRepository.startSession(
      workoutDayId: widget.dayId,
      planName: _planName,
      dayName: _workoutTitle,
    );
    if (!mounted) return;
    setState(() {
      _sessionId = sessionId;
      _isStartingSession = false;
    });
  }

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
          _workoutTitle,
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
              child: _isStartingSession
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
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
                          onTap: isDone || _sessionId == null
                              ? null
                              : () async {
                                  final didComplete = await context.push<bool>(
                                    '/workout-plan/${widget.dayId}/exercise/${exercise.id}?sessionId=$_sessionId&exerciseName=${Uri.encodeComponent(exercise.name)}',
                                  );

                                  if (didComplete == true) {
                                    _markDone(index);
                                  }
                                },
                        );
                      },
                    ),
            ),

            FinishWorkoutButton(
              enabled: _allDone && _sessionId != null,
              onPressed: () async {
                if (_sessionId == null) return;
                await _sessionRepository.finishSession(sessionId: _sessionId!);
                if (!context.mounted) return;
                context.pop();
              },
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
