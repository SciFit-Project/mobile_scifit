import 'package:flutter/material.dart';

class SetRow extends StatefulWidget {
  final int setNumber;
  final bool isDone;
  final void Function(double weight, int reps) onDone;

  const SetRow({
    super.key,
    required this.setNumber,
    required this.isDone,
    required this.onDone,
  });

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
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

    if (weight > 0 && reps > 0) {
      widget.onDone(weight, reps);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.setNumber}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: TextField(
              controller: _weightCtrl,
              keyboardType: TextInputType.number,
              enabled: !widget.isDone,
              style: const TextStyle(
                color: Colors.black,
                backgroundColor: Colors.white,
              ),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              controller: _repsCtrl,
              keyboardType: TextInputType.number,
              enabled: !widget.isDone,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'reps',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          ),
          const SizedBox(width: 12),

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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
