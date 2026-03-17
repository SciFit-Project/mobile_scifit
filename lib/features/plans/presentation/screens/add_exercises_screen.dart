import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scifit/features/plans/data/mock_plan.dart';
import 'package:mobile_scifit/features/plans/types/plans_type.dart';

class AddExercisesScreen extends StatefulWidget {
  final String planId;
  final String dayId;

  const AddExercisesScreen({
    super.key,
    required this.planId,
    required this.dayId,
  });

  @override
  State<AddExercisesScreen> createState() => _AddExercisesScreenState();
}

class _AddExercisesScreenState extends State<AddExercisesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  String _search = '';
  MuscleGroup? _selectedGroup;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Exercise> get _filteredExercises {
    return mockExercises.where((exercise) {
      final matchName = exercise.name.toLowerCase().contains(
        _search.toLowerCase(),
      );

      final matchGroup =
          _selectedGroup == null || exercise.muscleGroup == _selectedGroup;

      return matchName && matchGroup;
    }).toList();
  }

  Map<MuscleGroup, List<Exercise>> get _groupedExercises {
    final Map<MuscleGroup, List<Exercise>> grouped = {};

    for (final exercise in _filteredExercises) {
      grouped.putIfAbsent(exercise.muscleGroup, () => []);
      grouped[exercise.muscleGroup]!.add(exercise);
    }

    return grouped;
  }

  String _groupLabel(MuscleGroup? group) {
    if (group == null) return 'All';

    switch (group) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.legs:
      case MuscleGroup.quads:
      case MuscleGroup.hamstrings:
      case MuscleGroup.calves:
      case MuscleGroup.glutes:
        return 'Legs';
      case MuscleGroup.arms:
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
        return 'Arms';
      case MuscleGroup.core:
        return 'Core';
    }
  }

  String _equipmentLabel(Equipment? equipment) {
    switch (equipment) {
      case Equipment.barbell:
        return 'Barbell';
      case Equipment.dumbbell:
        return 'Dumbbell';
      case Equipment.cable:
        return 'Cable';
      case Equipment.machine:
        return 'Machine';
      case Equipment.bodyweight:
        return 'Bodyweight';
      case Equipment.band:
        return 'Band';
      case null:
        return 'Unknown';
    }
  }

  IconData _equipmentIcon(Equipment? equipment) {
    switch (equipment) {
      case Equipment.barbell:
        return Icons.fitness_center;
      case Equipment.dumbbell:
        return Icons.sports_gymnastics;
      case Equipment.cable:
        return Icons.cable;
      case Equipment.machine:
        return Icons.precision_manufacturing;
      case Equipment.bodyweight:
        return Icons.accessibility_new;
      case Equipment.band:
        return Icons.linear_scale;
      case null:
        return Icons.error;
    }
  }

  Color _equipmentIconBg(Equipment? equipment) {
    switch (equipment) {
      case Equipment.barbell:
        return const Color(0xFFEAF1FF);
      case Equipment.dumbbell:
        return const Color(0xFFF3ECFF);
      case Equipment.cable:
        return const Color(0xFFFFF1E8);
      case Equipment.machine:
        return const Color(0xFFEFF7F1);
      case Equipment.bodyweight:
        return const Color(0xFFE9F8F0);
      case Equipment.band:
        return const Color(0xFFFFF4CC);
      case null:
        return const Color(0xFFFFF4CC);
    }
  }

  Color _equipmentIconColor(Equipment? equipment) {
    switch (equipment) {
      case Equipment.barbell:
        return const Color(0xFF2F66F3);
      case Equipment.dumbbell:
        return const Color(0xFF8B5CF6);
      case Equipment.cable:
        return const Color(0xFFF97316);
      case Equipment.machine:
        return const Color(0xFF16A34A);
      case Equipment.bodyweight:
        return const Color(0xFF059669);
      case Equipment.band:
        return const Color(0xFFCA8A04);
      case null:
        return const Color(0xFFCA8A04);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedExercises;
    final orderedGroups = [
      MuscleGroup.chest,
      MuscleGroup.back,
      MuscleGroup.shoulders,
      MuscleGroup.legs,
      MuscleGroup.arms,
      MuscleGroup.core,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Add Exercise',
          style: TextStyle(
            color: Color(0xFF1D2433),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: _SearchBar(
                controller: _searchCtrl,
                onChanged: (value) {
                  setState(() {
                    _search = value;
                  });
                },
              ),
            ),

            SizedBox(
              height: 42,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _selectedGroup == null,
                    onTap: () {
                      setState(() {
                        _selectedGroup = null;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ...[
                    MuscleGroup.chest,
                    MuscleGroup.back,
                    MuscleGroup.shoulders,
                    MuscleGroup.legs,
                    MuscleGroup.arms,
                    MuscleGroup.core,
                  ].map((group) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _FilterChip(
                        label: _groupLabel(group),
                        selected: _selectedGroup == group,
                        onTap: () {
                          setState(() {
                            _selectedGroup = group;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: grouped.isEmpty
                  ? const Center(
                      child: Text(
                        'No exercises found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      children: orderedGroups
                          .where((group) => grouped[group]?.isNotEmpty ?? false)
                          .map((group) {
                            final exercises = grouped[group]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  '${_groupLabel(group).toUpperCase()} (${exercises.length})',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF64748B),
                                    letterSpacing: 0.7,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ...exercises.map(
                                  (exercise) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _ExerciseCard(
                                      exercise: exercise,
                                      equipmentLabel: _equipmentLabel(
                                        exercise.equipment,
                                      ),
                                      equipmentIcon: _equipmentIcon(
                                        exercise.equipment,
                                      ),
                                      iconBg: _equipmentIconBg(
                                        exercise.equipment,
                                      ),
                                      iconColor: _equipmentIconColor(
                                        exercise.equipment,
                                      ),
                                      onAdd: () {
                                        context.pop(exercise);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                              ],
                            );
                          })
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
          prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 28),
          suffixIcon: Icon(Icons.mic_none, color: Color(0xFF94A3B8)),
          hintText: 'Search exercises...',
          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF2F66F3) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF475569),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final String equipmentLabel;
  final IconData equipmentIcon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onAdd;

  const _ExerciseCard({
    required this.exercise,
    required this.equipmentLabel,
    required this.equipmentIcon,
    required this.iconBg,
    required this.iconColor,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = (exercise.secondaryMuscles ?? []).isEmpty
        ? '-'
        : (exercise.secondaryMuscles ?? []).join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(equipmentIcon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Primary: ${exercise.muscleGroup.name[0].toUpperCase()}${exercise.muscleGroup.name.substring(1)} · Secondary: $secondary',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    equipmentLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 46,
            height: 46,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F66F3),
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.add, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}
