import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  final List<Map<String, dynamic>> _sets = [];
  double _rpe = 7;

  void _addSet() {
    setState(() {
      _sets.add({'weight': 0.0, 'reps': 0, 'done': false});
    });
  }

  void _updateSet(int index, double weight, int reps) {
    setState(() {
      _sets[index] = {'weight': weight, 'reps': reps, 'done': true};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
        title: const Text('Bench Press'),
      ),
      body: Column(
        children: [
          // Sets List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Header
                const Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        'SET',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'KG',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'REPS',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 12),

                // Set Rows
                ..._sets.asMap().entries.map((entry) {
                  final i = entry.key;
                  final set = entry.value;
                  return _SetRow(
                    setNumber: i + 1,
                    isDone: set['done'],
                    onDone: (weight, reps) => _updateSet(i, weight, reps),
                  );
                }),

                const SizedBox(height: 12),

                // Add Set
                GestureDetector(
                  onTap: _addSet,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2C2C2C),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Color(0xFF6C63FF), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Add Set',
                          style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // RPE Slider
                Text(
                  'RPE: ${_rpe.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF6C63FF),
                    inactiveTrackColor: const Color(0xFF2C2C2C),
                    thumbColor: const Color(0xFF6C63FF),
                    overlayColor: const Color(0x296C63FF),
                  ),
                  child: Slider(
                    value: _rpe,
                    min: 1,
                    max: 10,
                    divisions: 18,
                    onChanged: (v) => setState(() => _rpe = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Easy',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    ),
                    Text(
                      'Max Effort',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Complete Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: _sets.isNotEmpty && _sets.any((s) => s['done'])
                  ? () => context.pop()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                disabledBackgroundColor: const Color(0xFF2C2C2C),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Complete Exercise',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final int setNumber;
  final bool isDone;
  final void Function(double weight, int reps) onDone;

  const _SetRow({
    required this.setNumber,
    required this.isDone,
    required this.onDone,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  final _weightCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    final reps = int.tryParse(_repsCtrl.text) ?? 0;
    if (weight > 0 && reps > 0) widget.onDone(weight, reps);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Set Number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isDone
                  ? const Color(0xFF10B981)
                  : const Color(0xFF2C2C2C),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.setNumber}',
                style: TextStyle(
                  color: widget.isDone ? Colors.white : const Color(0xFF9E9E9E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Weight Input
          Expanded(
            child: TextField(
              controller: _weightCtrl,
              keyboardType: TextInputType.number,
              enabled: !widget.isDone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'kg',
                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Reps Input
          Expanded(
            child: TextField(
              controller: _repsCtrl,
              keyboardType: TextInputType.number,
              enabled: !widget.isDone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'reps',
                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Done Button
          GestureDetector(
            onTap: widget.isDone ? null : _submit,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.isDone
                    ? const Color(0xFF10B981)
                    : const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.isDone ? Icons.check : Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
