import 'package:flutter/material.dart';

class RpeSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const RpeSlider({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RPE: ${value.toStringAsFixed(1)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        // const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF6C63FF),
            inactiveTrackColor: const Color(0xFF2C2C2C),
            thumbColor: const Color(0xFF6C63FF),
            overlayColor: const Color(0x296C63FF),
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 10,
            divisions: 18,
            onChanged: onChanged,
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Easy', style: TextStyle(color: Color(0xFF6B7280))),
            Text('Max Effort', style: TextStyle(color: Color(0xFF6B7280))),
          ],
        ),
      ],
    );
  }
}
