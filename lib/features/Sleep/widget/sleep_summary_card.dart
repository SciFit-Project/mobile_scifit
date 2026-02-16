import 'package:flutter/material.dart';

class SleepSummaryCard extends StatelessWidget {
  final Map<String, dynamic> weekData;

  const SleepSummaryCard({super.key, required this.weekData});

  @override
  Widget build(BuildContext context) {
    List<double> sleepHours = [];
    List<String> dayLabels = [];

    for (int i = 6; i >= 0; i--) {
      var data = weekData['day_$i'];
      if (data != null) {
        double minutes = data['totalSleep'] ?? 0;
        sleepHours.add(minutes / 60);
      } else {
        sleepHours.add(0);
      }

      DateTime date = DateTime.now().subtract(Duration(days: i));
      dayLabels.add(_getShortDay(date.weekday));
    }

    // avg
    double avgSleep = 0;
    int validDays = 0;

    weekData.forEach((key, value) {
      if (value != null) {
        avgSleep += (value['totalSleep'] ?? 0);
        validDays++;
      }
    });

    avgSleep = validDays > 0 ? avgSleep / validDays / 60 : 0; // to hours

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[400]!, Colors.purple[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.nights_stay, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Last 7 Days',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Avg ${avgSleep.toStringAsFixed(1)}h',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // กราฟแท่ง
              SizedBox(
                height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    return _buildBar(
                      sleepHours[index],
                      dayLabels[index],
                      index == 6, // วันล่าสุด (Today)
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              // Legend - แสดงช่วงเวลานอน
              _buildLegend(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar(double hours, String label, bool isToday) {
    double maxHeight = 140;
    double barHeight = (hours / 10) * maxHeight;

    // color quality
    Color barColor;
    if (hours >= 7 && hours <= 9) {
      barColor = Colors.green[300]!; // normal
    } else if (hours >= 6 && hours < 7) {
      barColor = Colors.yellow[300]!; // less
    } else if (hours > 9) {
      barColor = Colors.blue[300]!; // high
    } else if (hours > 0) {
      barColor = Colors.red[300]!; // less
    } else {
      barColor = Colors.grey[400]!; // Non data
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (hours > 0)
              Text(
                hours.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 4),

            // แท่งกราฟ
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: hours > 0 ? barHeight : 20,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                boxShadow: isToday
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),

            const SizedBox(height: 8),

            // Label วัน
            Text(
              label,
              style: TextStyle(
                color: isToday ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(Colors.green[300]!, '7-9h Ideal'),
          _buildLegendItem(Colors.yellow[300]!, '6-7h Good'),
          _buildLegendItem(Colors.red[300]!, '<6h Poor'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
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
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }

  String _getShortDay(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
