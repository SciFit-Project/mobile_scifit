import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/workout/presentation/widgets/exercise_widgets/add_set_button.dart';
import 'package:mobile_scifit/features/workout/presentation/widgets/exercise_widgets/complete_exercise_button.dart';
import 'package:mobile_scifit/features/workout/presentation/widgets/exercise_widgets/rpe_slider.dart';
import 'package:mobile_scifit/features/workout/presentation/widgets/exercise_widgets/set_row.dart';
import 'package:mobile_scifit/features/workout/types/response_type.dart';

import '../widgets/exercise_widgets/exercise_header.dart';
import '../widgets/exercise_widgets/previous_set.dart';

class ExerciseLogScreen extends StatefulWidget {
  final String exerciseId;
  final String sessionId;

  const ExerciseLogScreen({
    super.key,
    required this.exerciseId,
    required this.sessionId,
  });

  @override
  State<ExerciseLogScreen> createState() => _ExerciseLogScreenState();
}

class _ExerciseLogScreenState extends State<ExerciseLogScreen> {
  final List<WorkoutSet> _sets = [];
  double _rpe = 7;

  final List<LastSessionHistory> previousSet = [
    LastSessionHistory(
      lastDate: "Dec 10",
      sessionHistory: [
        ListSessionHistory(set: 1, weight: 60, reps: 12),
        ListSessionHistory(set: 2, weight: 60, reps: 12),
        ListSessionHistory(set: 3, weight: 62.5, reps: 12),
      ],
    ),
  ];

  void _addSet() {
    setState(() {
      _sets.add(WorkoutSet(weight: 0, reps: 0));
    });
  }

  void _updateSet(int index, double weight, int reps) {
    setState(() {
      _sets[index].weight = weight;
      _sets[index].reps = reps;
      _sets[index].done = true;
    });
  }

  bool get _canComplete {
    return _sets.isNotEmpty && _sets.any((s) => s.done);
  }

  void _completeExercise() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Bench Press'),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                PreviousSet(previousSet: previousSet),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const ExerciseHeader(),
                      ..._sets.asMap().entries.map((entry) {
                        final index = entry.key;
                        final set = entry.value;

                        return SetRow(
                          setNumber: index + 1,
                          isDone: set.done,
                          onDone: (weight, reps) {
                            _updateSet(index, weight, reps);
                          },
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                AddSetButton(onTap: _addSet),

                const SizedBox(height: 32),

                RpeSlider(
                  value: _rpe,
                  onChanged: (v) {
                    setState(() {
                      _rpe = v;
                    });
                  },
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: CompleteExerciseButton(
              enabled: _canComplete,
              onPressed: _completeExercise,
            ),
          ),
        ],
      ),
    );
  }
}
