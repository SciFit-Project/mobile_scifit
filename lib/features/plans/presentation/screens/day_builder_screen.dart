import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/plans/data/plan_store.dart';
import 'package:mobile_scifit/features/plans/data/plans_repository.dart';
import 'package:mobile_scifit/features/plans/types/plans_type.dart';

class DayBuilderScreen extends StatefulWidget {
  final String id;
  final String dayId;
  const DayBuilderScreen({super.key, required this.id, required this.dayId});

  @override
  State<DayBuilderScreen> createState() => _DayBuilderScreenState();
}

class _DayBuilderScreenState extends State<DayBuilderScreen> {
  final PlansRepository _plansRepository = PlansRepository();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  late List<PlanExercise> _draftExercises;
  late String _savedDayName;
  late List<PlanExercise> _savedExercises;
  final List<_PendingRemovalExercise> _pendingRemovalExercises = [];
  final Set<PlanExercise> _newExercises = {};

  @override
  void initState() {
    super.initState();
    _loadDraftFromSource();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  MyPlans get _plan => findPlanById(widget.id)!;

  WorkoutDay get _sourceDay =>
      _plan.days.firstWhere((d) => d.id == widget.dayId);

  bool get _hasPendingChanges {
    return _nameController.text.trim() != _savedDayName ||
        _pendingRemovalExercises.isNotEmpty ||
        !_sameExerciseList(_draftExercises, _savedExercises);
  }

  void _loadDraftFromSource() {
    final day = _sourceDay;
    _savedDayName = day.name;
    _savedExercises = day.exercises.map(_cloneExercise).toList();
    _draftExercises = day.exercises.map(_cloneExercise).toList();
    _pendingRemovalExercises.clear();
    _newExercises.clear();
    _nameController.text = day.name;
  }

  PlanExercise _cloneExercise(PlanExercise exercise) {
    return PlanExercise(
      order: exercise.order,
      exerciseId: exercise.exerciseId,
      name: exercise.name,
      muscleGroup: exercise.muscleGroup,
      sets: exercise.sets,
      reps: exercise.reps,
    );
  }

  bool _sameExerciseList(List<PlanExercise> a, List<PlanExercise> b) {
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      final current = a[i];
      final saved = b[i];

      if (current.exerciseId != saved.exerciseId ||
          current.name != saved.name ||
          current.muscleGroup != saved.muscleGroup ||
          current.sets != saved.sets ||
          current.reps != saved.reps) {
        return false;
      }
    }

    return true;
  }

  String _formatMuscleGroup(MuscleGroup group) {
    const compoundGroups = {
      MuscleGroup.legs: 'Legs',
      MuscleGroup.arms: 'Arms',
      MuscleGroup.core: 'Core',
      MuscleGroup.back: 'Back',
      MuscleGroup.chest: 'Chest',
    };

    final mapped = compoundGroups[group];
    if (mapped != null) return mapped;

    final name = group.name;
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }

  Future<void> _browseExercises() async {
    final exercise = await context.push<Exercise>(
      '/plans/${widget.id}/days/${widget.dayId}/edit/exercises/browse',
    );

    if (!mounted || exercise == null) return;

    final pendingIndex = _pendingRemovalExercises.indexWhere(
      (item) => item.exercise.exerciseId == exercise.id,
    );

    if (pendingIndex >= 0) {
      setState(() {
        final pending = _pendingRemovalExercises.removeAt(pendingIndex);
        final insertIndex = pending.previousIndex.clamp(
          0,
          _draftExercises.length,
        );
        _draftExercises.insert(insertIndex, pending.exercise);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${exercise.name} restored to this day')),
      );
      return;
    }

    final alreadyExists = _draftExercises.any(
      (item) => item.exerciseId == exercise.id,
    );
    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${exercise.name} is already in this day')),
      );
      return;
    }

    setState(() {
      final newExercise = PlanExercise(
        order: _draftExercises.length + 1,
        exerciseId: exercise.id,
        name: exercise.name,
        muscleGroup: _formatMuscleGroup(exercise.muscleGroup),
        sets: 3,
        reps: 10,
      );

      _draftExercises.add(newExercise);
      _newExercises.add(newExercise);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${exercise.name} added to draft')));
  }

  void _queueExerciseRemoval(PlanExercise exercise, int index) {
    setState(() {
      _draftExercises.remove(exercise);

      if (_newExercises.remove(exercise)) {
        return;
      }

      _pendingRemovalExercises.insert(
        0,
        _PendingRemovalExercise(exercise: exercise, previousIndex: index),
      );
    });
  }

  void _restorePendingExercise(_PendingRemovalExercise pendingExercise) {
    setState(() {
      _pendingRemovalExercises.remove(pendingExercise);
      final insertIndex = pendingExercise.previousIndex.clamp(
        0,
        _draftExercises.length,
      );
      _draftExercises.insert(insertIndex, pendingExercise.exercise);
    });
  }

  void _saveDay() {
    final dayName = _nameController.text.trim();
    if (dayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout name cannot be empty')),
      );
      _nameFocusNode.requestFocus();
      return;
    }

    final updatedExercises = _draftExercises.asMap().entries.map((entry) {
      final exercise = entry.value;
      return PlanExercise(
        order: entry.key + 1,
        exerciseId: exercise.exerciseId,
        name: exercise.name,
        muscleGroup: exercise.muscleGroup,
        sets: exercise.sets,
        reps: exercise.reps,
      );
    }).toList();

    _plansRepository
        .saveDay(
          planId: widget.id,
          dayId: widget.dayId,
          dayName: dayName,
          exercises: updatedExercises,
        )
        .then((_) {
          if (!mounted) return;
          setState(_loadDraftFromSource);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Day saved successfully')),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _nameController.text.trim().isEmpty
              ? 'Edit Day'
              : _nameController.text.trim(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _renameCard(),
            const SizedBox(height: 12),
            if (_hasPendingChanges) _draftNoticeCard(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercises (${_draftExercises.length})',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _browseExercises,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_draftExercises.isEmpty)
              _emptyExerciseState()
            else
              ..._draftExercises.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _exerciseDayPlanned(entry.key, entry.value),
                ),
              ),
            if (_pendingRemovalExercises.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Pending removal (${_pendingRemovalExercises.length})',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'These exercises will be removed only after you tap Save Day.',
                style: TextStyle(
                  color: Colors.black.withAlpha(140),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ..._pendingRemovalExercises.map(
                (pendingExercise) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _pendingRemovalCard(pendingExercise),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_hasPendingChanges)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _pendingRemovalExercises.isEmpty
                      ? 'You have unsaved changes'
                      : '${_pendingRemovalExercises.length} exercise(s) waiting to be removed',
                  style: TextStyle(
                    color: Colors.black.withAlpha(160),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _hasPendingChanges ? _saveDay : null,
                child: const Text('Save Day'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exerciseDayPlanned(int index, PlanExercise exercise) {
    final isNew = _newExercises.contains(exercise);

    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${exercise.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Badge(
                          label: Text(exercise.muscleGroup),
                          backgroundColor: AppTheme.primaryLight,
                        ),
                        if (isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'New',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isNew ? 'Discard exercise' : 'Move to pending removal',
                onPressed: () => _queueExerciseRemoval(exercise, index),
                icon: Icon(
                  isNew ? Icons.remove_circle_outline : Icons.delete_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sets'),
                      SizedBox(
                        width: 140,
                        child: _setValue(
                          value: exercise.sets,
                          onIncrement: () {
                            setState(() {
                              exercise.sets++;
                            });
                          },
                          onDecrement: () {
                            setState(() {
                              if (exercise.sets > 0) {
                                exercise.sets--;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reps'),
                      SizedBox(
                        width: 140,
                        child: _setValue(
                          value: exercise.reps,
                          onIncrement: () {
                            setState(() {
                              exercise.reps++;
                            });
                          },
                          onDecrement: () {
                            setState(() {
                              if (exercise.reps > 0) {
                                exercise.reps--;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pendingRemovalCard(_PendingRemovalExercise pendingExercise) {
    final exercise = pendingExercise.exercise;

    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withAlpha(40)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${exercise.muscleGroup} • ${exercise.sets} sets • ${exercise.reps} reps',
                  style: TextStyle(color: Colors.black.withAlpha(150)),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _restorePendingExercise(pendingExercise),
            icon: const Icon(Icons.undo),
            label: const Text('Undo'),
          ),
        ],
      ),
    );
  }

  Widget _setValue({
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 32,
            width: 32,
            child: IconButton(
              onPressed: onDecrement,
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.remove, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 32,
            width: 32,
            child: IconButton(
              onPressed: onIncrement,
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renameCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WORKOUT NAME',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black.withAlpha(80),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Enter day name',
              suffixIcon: const Icon(Icons.edit),
              filled: true,
              fillColor: AppTheme.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _draftNoticeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withAlpha(50),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_note, color: AppTheme.primaryLight),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Changes stay in draft until you tap Save Day.',
              style: TextStyle(
                color: Colors.black.withAlpha(170),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyExerciseState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 40,
            color: Colors.black.withAlpha(90),
          ),
          const SizedBox(height: 12),
          const Text(
            'No exercises in this day yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap Add New to build this workout. Nothing will be saved until you confirm.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black.withAlpha(140)),
          ),
        ],
      ),
    );
  }
}

class _PendingRemovalExercise {
  final PlanExercise exercise;
  final int previousIndex;

  const _PendingRemovalExercise({
    required this.exercise,
    required this.previousIndex,
  });
}
