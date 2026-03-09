import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class SleepDashboard extends StatefulWidget {
  final Map<int, double> weeklySleep;

  const SleepDashboard({super.key, required this.weeklySleep});

  @override
  State<SleepDashboard> createState() => _SleepDashboardState();
}

class _SleepDashboardState extends State<SleepDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getDayLabel(int daysAgo) {
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatHours(double hours) {
    if (hours <= 0) return '--';
    int h = hours.toInt();
    int m = ((hours - h) * 60).round();
    if (m == 60) {
      h += 1;
      m = 0;
    }
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  Color _barColor(double hours) {
    if (hours <= 0) return const Color(0xFFF0F7FF);
    if (hours >= 7 && hours <= 9) return const Color(0xFF34D399);
    if (hours >= 6) return const Color(0xFFFBBF24);
    if (hours > 9) return const Color(0xFF4285F4);
    return const Color(0xFFF87171);
  }

  @override
  Widget build(BuildContext context) {
    final sleep = widget.weeklySleep;
    double total = sleep.values.fold(0, (s, v) => s + v);
    double avg = total / 7;
    double todayHours = sleep[0] ?? 0.0;
    final double progress = (todayHours / 8).clamp(0.0, 1.0);
    final int percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row (mirror StepCard layout) ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.bedtime_rounded,
                          color: Color(0xFF4285F4),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'SLEEP',
                          style: GoogleFonts.spaceGrotesk(
                            color: const Color(0xFF4285F4),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatHours(todayHours),
                      style: GoogleFonts.spaceGrotesk(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                    Text(
                      'Goal: 8h  •  Avg ${avg.toStringAsFixed(1)}h / week',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      todayHours >= 7
                          ? 'Great sleep last night!'
                          : todayHours > 0
                          ? 'Below recommended 7–9h'
                          : 'No data yet',
                      style: GoogleFonts.spaceGrotesk(
                        color: todayHours >= 7
                            ? const Color(0xFF34D399)
                            : todayHours > 0
                            ? Colors.orange
                            : Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Circular progress (same size/style as StepCard)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 85,
                    height: 85,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (_, __) => CircularProgressIndicator(
                        value: progress * _animation.value,
                        strokeWidth: 9,
                        backgroundColor: const Color(0xFFF0F7FF),
                        color: _barColor(todayHours),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF4285F4),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.grey.withAlpha(12), height: 1),
          const SizedBox(height: 16),

          // ── Weekly bar chart ──
          SizedBox(
            height: 90,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (_, __) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  int daysAgo = 6 - index;
                  double hours = sleep[daysAgo] ?? 0.0;
                  return _buildBar(hours, _getDayLabel(daysAgo), daysAgo == 0);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double hours, String label, bool isToday) {
    const double maxHeight = 56.0;
    final double barHeight =
        (hours / 10).clamp(0.0, 1.0) * maxHeight * _animation.value;
    final Color color = _barColor(hours);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (hours > 0)
            Text(
              hours.toStringAsFixed(1),
              style: GoogleFonts.spaceGrotesk(
                color: isToday ? const Color(0xFF111827) : Colors.grey[400],
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            const SizedBox(height: 12),
          const SizedBox(height: 3),
          Container(
            width: isToday ? 22 : 16,
            height: math.max(barHeight, 5),
            decoration: BoxDecoration(
              color: isToday ? color : color.withAlpha(5),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: isToday ? const Color(0xFF4285F4) : Colors.grey[400],
              fontSize: 10,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
