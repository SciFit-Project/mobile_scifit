import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/plans/data/plans_repository.dart';
import 'package:mobile_scifit/features/plans/presentation/screens/add_exercises_screen.dart';
import 'package:mobile_scifit/features/plans/presentation/widgets/create/add_day.dart';
import 'package:mobile_scifit/features/plans/presentation/widgets/create/plan_details.dart';
import 'package:mobile_scifit/features/plans/presentation/widgets/create/workout_day_card.dart';
import 'package:mobile_scifit/features/plans/types/plans_type.dart';

class CreatePlan extends StatefulWidget {
  const CreatePlan({super.key});

  @override
  State<CreatePlan> createState() => _CreatePlanState();
}

class _CreatePlanState extends State<CreatePlan> {
  final PlansRepository _plansRepository = PlansRepository();
  final _planName = TextEditingController();
  final _planDescription = TextEditingController();
  final List<WorkoutDay> _days = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _planName.dispose();
    _planDescription.dispose();
    super.dispose();
  }

  void addDay() {
    setState(() {
      _days.add(
        WorkoutDay(
          id: 'draft-day-${DateTime.now().microsecondsSinceEpoch}',
          dayNumber: _days.length + 1,
          name: 'Workout Day ${_days.length + 1}',
          exercises: const [],
        ),
      );
    });
  }

  Future<void> _editDay(int index) async {
    final current = _days[index];
    final nameController = TextEditingController(text: current.name);
    var draftExercises = current.exercises
        .map(
          (exercise) => PlanExercise(
            exerciseId: exercise.exerciseId,
            name: exercise.name,
            muscleGroup: exercise.muscleGroup,
            sets: exercise.sets,
            reps: exercise.reps,
            order: exercise.order,
          ),
        )
        .toList();

    final saved = await showModalBottomSheet<_DayDraftResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> addExercise() async {
              final exercise = await Navigator.of(context).push<Exercise>(
                MaterialPageRoute(
                  builder: (_) => AddExercisesScreen(
                    planId: 'draft-plan',
                    dayId: current.id,
                  ),
                ),
              );

              if (exercise == null) return;

              final exists = draftExercises.any(
                (item) => item.exerciseId == exercise.id,
              );
              if (exists) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${exercise.name} already added')),
                );
                return;
              }

              setModalState(() {
                draftExercises = [
                  ...draftExercises,
                  PlanExercise(
                    exerciseId: exercise.id,
                    name: exercise.name,
                    muscleGroup: _formatMuscleGroup(exercise.muscleGroup),
                    sets: 3,
                    reps: 10,
                    order: draftExercises.length,
                  ),
                ];
              });
            }

            void removeExercise(int exerciseIndex) {
              setModalState(() {
                draftExercises = [
                  for (final entry in draftExercises.asMap().entries)
                    if (entry.key != exerciseIndex)
                      PlanExercise(
                        exerciseId: entry.value.exerciseId,
                        name: entry.value.name,
                        muscleGroup: entry.value.muscleGroup,
                        sets: entry.value.sets,
                        reps: entry.value.reps,
                        order: entry.key > exerciseIndex
                            ? entry.key - 1
                            : entry.key,
                      ),
                ];
              });
            }

            return SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(40),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Edit Workout Day',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Workout Day Name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Exercises (${draftExercises.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: addExercise,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Exercise'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (draftExercises.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Add at least one exercise to this day before saving the plan.',
                          ),
                        )
                      else
                        ...draftExercises.asMap().entries.map((entry) {
                          final exerciseIndex = entry.key;
                          final exercise = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${exercise.muscleGroup} • ${exercise.sets} sets • ${exercise.reps} reps',
                                          style: TextStyle(
                                            color: Colors.black.withAlpha(140),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        removeExercise(exerciseIndex),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            final trimmedName = nameController.text.trim();
                            if (trimmedName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a workout day name'),
                                ),
                              );
                              return;
                            }

                            Navigator.of(context).pop(
                              _DayDraftResult(
                                name: trimmedName,
                                exercises: draftExercises,
                              ),
                            );
                          },
                          child: const Text('Save Day'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || saved == null) return;

    setState(() {
      _days[index] = WorkoutDay(
        id: current.id,
        dayNumber: current.dayNumber,
        name: saved.name,
        exercises: saved.exercises.asMap().entries.map((entry) {
          final exercise = entry.value;
          return PlanExercise(
            exerciseId: exercise.exerciseId,
            name: exercise.name,
            muscleGroup: exercise.muscleGroup,
            sets: exercise.sets,
            reps: exercise.reps,
            order: entry.key,
          );
        }).toList(),
      );
    });
  }

  Future<void> submit() async {
    final name = _planName.text.trim();
    final description = _planDescription.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a plan name')),
      );
      return;
    }

    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one workout day')),
      );
      return;
    }

    final emptyDay = _days.where((day) => day.exercises.isEmpty).firstOrNull;
    if (emptyDay != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${emptyDay.name} still has no exercises'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final createdPlan = await _plansRepository.createPlan(
        name: name,
        description: description,
        days: _days,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${createdPlan.name} created')),
      );
      context.go('/plans/${createdPlan.id}');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to create plan right now')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatMuscleGroup(MuscleGroup group) {
    const labels = {
      MuscleGroup.chest: 'Chest',
      MuscleGroup.back: 'Back',
      MuscleGroup.shoulders: 'Shoulders',
      MuscleGroup.biceps: 'Biceps',
      MuscleGroup.triceps: 'Triceps',
      MuscleGroup.quads: 'Quads',
      MuscleGroup.hamstrings: 'Hamstrings',
      MuscleGroup.calves: 'Calves',
      MuscleGroup.glutes: 'Glutes',
      MuscleGroup.core: 'Core',
      MuscleGroup.legs: 'Legs',
      MuscleGroup.arms: 'Arms',
    };
    return labels[group] ?? group.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        title: const Text(
          "Create Plans",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PlanDetails(
                      planName: _planName,
                      planDescription: _planDescription,
                    ),
                    const SizedBox(height: 16),
                    AddDay(onTap: addDay),
                    ..._days.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: WorkoutDayCard(
                          idx: index,
                          workoutTitle: day.name,
                          totalExercise: day.exercises.length,
                          onEdit: () => _editDay(index),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : submit,
            child: Text(_isSubmitting ? "Saving..." : "Submit"),
          ),
        ),
      ),
    );
  }
}

class _DayDraftResult {
  final String name;
  final List<PlanExercise> exercises;

  const _DayDraftResult({
    required this.name,
    required this.exercises,
  });
}
