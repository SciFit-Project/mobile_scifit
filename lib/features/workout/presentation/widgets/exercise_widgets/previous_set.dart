import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/workout/types/response_type.dart';

class PreviousSet extends StatelessWidget {
  final List<LastSessionHistory> previousSet;

  const PreviousSet({super.key, required this.previousSet});

  @override
  Widget build(BuildContext context) {
    if (previousSet.isEmpty) return const SizedBox();

    final lastSession = previousSet.first;
    final maxWeight = lastSession.sessionHistory
        .map((s) => s.weight)
        .reduce(max);
    String formatWeight(double weight) {
      if (weight == weight.roundToDouble()) {
        return weight.toInt().toString();
      }
      return weight.toString();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withAlpha(60),
            borderRadius: BorderRadius.circular(16),
            border: const Border(
              left: BorderSide(color: AppTheme.primaryLight, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_rounded, size: 20),
                  const SizedBox(width: 6),
                  const Text(
                    "Last Session",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    lastSession.lastDate,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// SET NUMBERS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lastSession.sessionHistory.map((set) {
                  return Expanded(
                    child: Text(
                      "Set ${set.set}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 6),

              /// WEIGHT × REPS
              Row(
                children: lastSession.sessionHistory.map((set) {
                  return Expanded(
                    child: Text(
                      "${formatWeight(set.weight)}kg × ${set.reps}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
              Divider(color: Colors.black.withAlpha(50)),
              Text("Max: $maxWeight kg", textAlign: TextAlign.left),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
