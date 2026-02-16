import 'package:flutter/material.dart';

class SleepCard extends StatelessWidget {
  final Map<String, dynamic>? sleepData;
  final int dayIndex;

  const SleepCard({super.key, required this.sleepData, required this.dayIndex});

  @override
  Widget build(BuildContext context) {
    DateTime targetDate = DateTime.now().subtract(Duration(days: dayIndex));

    if (sleepData == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.bed_outlined, size: 40, color: Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDateLabel(targetDate, dayIndex),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFullDate(targetDate),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'No sleep data',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    double totalSleep = sleepData!['totalSleep'] ?? 0;
    double light = sleepData!['light'] ?? 0;
    double deep = sleepData!['deep'] ?? 0;
    double rem = sleepData!['rem'] ?? 0;
    double awake = sleepData!['awake'] ?? 0;
    DateTime? start = sleepData!['start'];
    DateTime? end = sleepData!['end'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDateLabel(targetDate, dayIndex),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFullDate(targetDate),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    if (start != null && end != null)
                      Text(
                        '${_formatTime(start)} - ${_formatTime(end)}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getSleepQualityColor(totalSleep).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDuration(totalSleep),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getSleepQualityColor(totalSleep),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sleep Stages Progress Bar
            _buildSleepStagesBar(light, deep, rem, awake, totalSleep),

            const SizedBox(height: 20),

            // Sleep Stages Details
            Row(
              children: [
                Expanded(
                  child: _buildSleepStage(
                    'Light',
                    light,
                    totalSleep,
                    Colors.blue[300]!,
                  ),
                ),
                Expanded(
                  child: _buildSleepStage(
                    'Deep',
                    deep,
                    totalSleep,
                    Colors.indigo[600]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSleepStage(
                    'REM',
                    rem,
                    totalSleep,
                    Colors.purple[400]!,
                  ),
                ),
                Expanded(
                  child: _buildSleepStage(
                    'Awake',
                    awake,
                    totalSleep,
                    Colors.orange[400]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepStagesBar(
    double light,
    double deep,
    double rem,
    double awake,
    double total,
  ) {
    if (total == 0) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sleep Stages',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              if (light > 0)
                Expanded(
                  flex: light.round(),
                  child: Container(height: 12, color: Colors.blue[300]),
                ),
              if (deep > 0)
                Expanded(
                  flex: deep.round(),
                  child: Container(height: 12, color: Colors.indigo[600]),
                ),
              if (rem > 0)
                Expanded(
                  flex: rem.round(),
                  child: Container(height: 12, color: Colors.purple[400]),
                ),
              if (awake > 0)
                Expanded(
                  flex: awake.round(),
                  child: Container(height: 12, color: Colors.orange[400]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSleepStage(
    String label,
    double minutes,
    double total,
    Color color,
  ) {
    int percentage = total > 0 ? ((minutes / total) * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${_formatDuration(minutes)} ($percentage%)',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // แสดงวันแบบสั้น (Today, Yesterday, หรือวัน)
  String _getDateLabel(DateTime date, int dayIndex) {
    if (dayIndex == 0) return 'Today';
    if (dayIndex == 1) return 'Yesterday';

    // แสดงชื่อวัน
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  // แสดงวันที่แบบเต็ม
  String _getFullDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDuration(double totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = (totalMinutes % 60).round();

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _getSleepQualityColor(double minutes) {
    double hours = minutes / 60;
    if (hours >= 7 && hours <= 9) return Colors.green;
    if (hours >= 6 && hours < 7) return Colors.orange;
    return Colors.red;
  }
}
