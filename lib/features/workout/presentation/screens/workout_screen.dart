import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkoutPlanScreen extends StatefulWidget {
  final String dayId;
  const WorkoutPlanScreen({super.key, required this.dayId});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  // Mock exercises — ทีหลังดึงจาก API
  final List<Map<String, dynamic>> _exercises = [
    {
      'id': '1',
      'name': 'Bench Press',
      'sets': 4,
      'reps': '8-12',
      'done': false,
    },
    {
      'id': '2',
      'name': 'Incline Dumbbell',
      'sets': 3,
      'reps': '10-12',
      'done': false,
    },
    {'id': '3', 'name': 'Cable Fly', 'sets': 3, 'reps': '12-15', 'done': false},
    {
      'id': '4',
      'name': 'Tricep Pushdown',
      'sets': 3,
      'reps': '12-15',
      'done': false,
    },
  ];

  final String _sessionId =
      'mock-session-id'; // ทีหลังสร้างจาก API POST /sessions

  void _markDone(int index) {
    setState(() => _exercises[index]['done'] = true);
  }

  bool get _allDone => _exercises.every((e) => e['done'] == true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
        title: const Text('Push Day'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_exercises.where((e) => e['done']).length} / ${_exercises.length} exercises',
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value:
                        _exercises.where((e) => e['done']).length /
                        _exercises.length,
                    backgroundColor: const Color(0xFF2C2C2C),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Exercise List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _exercises.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                final isDone = exercise['done'] as bool;

                return _ExerciseRow(
                  name: exercise['name'],
                  sets: exercise['sets'],
                  reps: exercise['reps'],
                  isDone: isDone,
                  onTap: isDone
                      ? null
                      : () async {
                          await context.push(
                            '/workout-plan/${widget.dayId}/exercise/${exercise['id']}?sessionId=$_sessionId',
                          );
                          _markDone(index);
                        },
                );
              },
            ),
          ),

          // Finish Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: _allDone ? () => context.pop() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                disabledBackgroundColor: const Color(0xFF2C2C2C),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _allDone ? 'Finish Workout' : 'Complete all exercises first',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final String name;
  final int sets;
  final String reps;
  final bool isDone;
  final VoidCallback? onTap;

  const _ExerciseRow({
    required this.name,
    required this.sets,
    required this.reps,
    required this.isDone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFF0D2818) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone ? const Color(0xFF10B981) : const Color(0xFF2C2C2C),
          ),
        ),
        child: Row(
          children: [
            // Done Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(0xFF10B981)
                    : const Color(0xFF2C2C2C),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check : Icons.fitness_center,
                color: isDone ? Colors.white : const Color(0xFF6B7280),
                size: 18,
              ),
            ),
            const SizedBox(width: 14),

            // Name + Sets/Reps
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDone ? const Color(0xFF10B981) : Colors.white,
                    ),
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

            if (!isDone)
              const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }
}
