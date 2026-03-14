import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';

class StepsBarChart extends StatelessWidget {
  final Map<int, Map<String, int>> data;
  final int goalSteps;

  const StepsBarChart({super.key, required this.data, this.goalSteps = 10000});

  int getDisplaySteps(int day) {
    final mobile = data[day]?['mobile'] ?? 0;
    final wearable = data[day]?['wearable'] ?? 0;

    return wearable > 0 ? wearable : mobile;
  }

  String getWeekday(int daysAgo) {
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    return DateFormat('E').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat.compact();

    int maxSteps = goalSteps;

    for (int i = 0; i < 7; i++) {
      int steps = getDisplaySteps(i);
      if (steps > maxSteps) maxSteps = steps;
    }

    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          /// GOAL LINE
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(height: 1, color: Colors.grey.withAlpha(80)),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final dayIndex = 6 - i;
              final steps = getDisplaySteps(dayIndex);
              final ratio = steps / maxSteps;

              final isToday = dayIndex == 0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  /// TODAY VALUE
                  if (isToday)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        nf.format(steps),
                        style: const TextStyle(
                          // color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  /// BAR
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 8,
                    height: 180 * ratio,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isToday? AppTheme.primaryLight : AppTheme.primaryLight.withAlpha(70),
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// WEEKDAY
                  Text(
                    getWeekday(dayIndex),
                    style: TextStyle(
                      color: isToday ? Colors.black : Colors.grey,
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
