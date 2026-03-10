import 'package:flutter/material.dart';

class HeartrateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;

  const HeartrateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE8FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF4A90E2), size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A90E2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "100", //Num
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F36),
                ),
              ),
              SizedBox(width: 4),
              Text(
                "bpm",
                style: TextStyle(fontSize: 14, color: Color(0xFF8A94A6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
