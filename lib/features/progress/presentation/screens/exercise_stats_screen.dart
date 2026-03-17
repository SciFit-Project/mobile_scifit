import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/progress/data/mock_progress_data.dart';

class ExerciseStatsScreen extends StatelessWidget {
  final String exerciseId;

  const ExerciseStatsScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    final sessions = getSessionsForExercise(exerciseId);
    if (sessions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No stats found for this exercise')),
      );
    }

    final logs = sessions
        .map((session) => getExerciseLogForSession(session, exerciseId)!)
        .toList();
    final exerciseName = logs.first.exerciseName;

    final maxWeight = logs.map((log) => log.maxWeight).reduce(math.max);
    final maxReps = logs.map((log) => log.maxReps).reduce(math.max);
    final bestOneRm = logs.map((log) => log.estimatedOneRm).reduce(math.max);

    return Scaffold(
      appBar: AppBar(title: Text(exerciseName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _SectionCard(
            title: 'PR Summary',
            child: Row(
              children: [
                Expanded(
                  child: _SummaryBox(
                    label: 'Max Weight',
                    value: '${maxWeight.round()} kg',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryBox(label: 'Max Reps', value: '$maxReps reps'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryBox(
                    label: 'Est. 1RM',
                    value: '${bestOneRm.round()} kg',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Estimated 1RM Trend',
            child: SizedBox(
              height: 180,
              child: _MiniLineChart(
                points: logs.map((log) => log.estimatedOneRm).toList(),
                color: AppTheme.primaryLight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Max Weight per Session',
            child: SizedBox(
              height: 180,
              child: _BarChart(
                values: logs.map((log) => log.maxWeight).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Volume per Session',
            child: SizedBox(
              height: 180,
              child: _MiniLineChart(
                points: logs.map((log) => log.volume).toList(),
                color: const Color(0xFF16A34A),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Last 5 Sessions',
            child: Column(
              children: sessions.reversed.take(5).map((session) {
                final log = getExerciseLogForSession(session, exerciseId)!;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(DateFormat('dd MMM yyyy').format(session.date)),
                  subtitle: Text(
                    'Volume ${log.volume.round()} kg • 1RM ${log.estimatedOneRm.round()} kg',
                  ),
                  trailing: Text(
                    '${log.maxWeight.round()} kg',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _MiniLineChart extends StatelessWidget {
  final List<double> points;
  final Color color;

  const _MiniLineChart({required this.points, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MiniLineChartPainter(points: points, color: color),
      child: const SizedBox.expand(),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<double> values;

  const _BarChart({required this.values});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarChartPainter(values: values),
      child: const SizedBox.expand(),
    );
  }
}

class _MiniLineChartPainter extends CustomPainter {
  final List<double> points;
  final Color color;

  const _MiniLineChartPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final minValue = points.reduce(math.min);
    final maxValue = points.reduce(math.max);
    final range = (maxValue - minValue).abs() < 0.001
        ? 1.0
        : maxValue - minValue;

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x =
          (size.width / (points.length - 1 == 0 ? 1 : points.length - 1)) * i;
      final y =
          size.height -
          (((points[i] - minValue) / range) * (size.height - 16)) -
          8;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniLineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;

  const _BarChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxValue = values.reduce(math.max);
    final barWidth = size.width / (values.length * 1.8);
    final gap = barWidth * 0.8;

    for (var i = 0; i < values.length; i++) {
      final height = (values[i] / maxValue) * (size.height - 16);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * (barWidth + gap),
          size.height - height,
          barWidth,
          height,
        ),
        const Radius.circular(8),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = AppTheme.primaryLight.withAlpha(150),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
