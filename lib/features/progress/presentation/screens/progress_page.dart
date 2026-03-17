// ignore_for_file: prefer_const_constructors

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/home/data/home_service.dart';
import 'package:mobile_scifit/features/progress/data/mock_progress_data.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final HomeService _homeService = HomeService();

  int _avgSteps = 8420;
  double _avgSleep = 7.2;
  bool _loadingHealth = true;

  @override
  void initState() {
    super.initState();
    _loadHealthSnapshot();
  }

  Future<void> _loadHealthSnapshot() async {
    try {
      final weeklySteps = await _homeService.getWeeklySteps();
      final weeklySleep = await _homeService.getWeeklySleep();

      final stepsTotal = weeklySteps.values.fold<int>(
        0,
        (sum, day) => sum + (day['mobile'] ?? 0) + (day['wearable'] ?? 0),
      );
      final sleepTotal = weeklySleep.values.fold<double>(
        0,
        (sum, value) => sum + value,
      );

      if (!mounted) return;
      setState(() {
        _avgSteps = (stepsTotal / 7).round();
        _avgSleep = sleepTotal / 7;
        _loadingHealth = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingHealth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weeklyVolume = getWeeklyVolumePoints();
    final topLifts = getTopLifts();
    final workoutDays = getWorkoutCalendarDays();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHealthSnapshot,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dashboard for volume, consistency, recovery, and PRs',
                  style: TextStyle(color: Colors.black.withAlpha(150)),
                ),
                const SizedBox(height: 20),
                _ChartCard(
                  title: 'Weekly Volume',
                  subtitle: 'Total kg lifted per week over the last 8 weeks',
                  trailing: '${weeklyVolume.last.volume.round().toString()} kg',
                  child: Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: _SimpleLineChart(
                          points: weeklyVolume
                              .map((point) => point.volume)
                              .toList(),
                          lineColor: AppTheme.primaryLight,
                          fillColor: AppTheme.primaryLight.withAlpha(18),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: weeklyVolume.map((point) {
                          return Text(
                            DateFormat('MM/dd').format(point.weekStart),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ChartCard(
                  title: 'Workout Frequency',
                  subtitle: 'Last 4 weeks of training consistency',
                  child: _WorkoutHeatmap(activeDays: workoutDays),
                ),
                const SizedBox(height: 16),
                _ChartCard(
                  title: 'Body Weight Trend',
                  subtitle: 'Last 30 days',
                  trailing:
                      '${mockBodyWeightTrend.last.weight.toStringAsFixed(1)} kg',
                  child: SizedBox(
                    height: 180,
                    child: _SimpleLineChart(
                      points: mockBodyWeightTrend
                          .map((point) => point.weight)
                          .toList(),
                      lineColor: const Color(0xFF16A34A),
                      fillColor: const Color(0xFF16A34A).withAlpha(20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _ChartCard(
                  title: 'Top Lifts',
                  subtitle: 'Latest personal records',
                  child: Column(
                    children: topLifts.map((lift) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TopLiftTile(record: lift),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                _ChartCard(
                  title: 'Health Snapshot',
                  subtitle: 'This week',
                  child: _loadingHealth
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 28),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _HealthSnapshotTile(
                                label: 'Steps Avg',
                                value: NumberFormat.compact().format(_avgSteps),
                                helper: 'per day',
                                icon: Icons.directions_walk,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _HealthSnapshotTile(
                                label: 'Sleep Avg',
                                value: '${_avgSleep.toStringAsFixed(1)} h',
                                helper: 'per night',
                                icon: Icons.bedtime_outlined,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                _ChartCard(
                  title: 'Shortcuts',
                  subtitle: 'Dive deeper into your training data',
                  child: Row(
                    children: [
                      Expanded(
                        child: _ShortcutTile(
                          label: 'View History',
                          icon: Icons.history,
                          onTap: () => context.push('/history'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ShortcutTile(
                          label: 'Exercise Stats',
                          icon: Icons.insights_outlined,
                          onTap: () =>
                              context.push('/progress/exercise/ex-bench'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryLight,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _SimpleLineChart extends StatelessWidget {
  final List<double> points;
  final Color lineColor;
  final Color fillColor;

  const _SimpleLineChart({
    required this.points,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(
        points: points,
        lineColor: lineColor,
        fillColor: fillColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _WorkoutHeatmap extends StatelessWidget {
  final List<DateTime> activeDays;

  const _WorkoutHeatmap({required this.activeDays});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final cells = List.generate(28, (index) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 27 - index));
      final count = activeDays
          .where(
            (day) =>
                day.year == date.year &&
                day.month == date.month &&
                day.day == date.day,
          )
          .length;
      return (date, count);
    });

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 26,
          ),
          itemBuilder: (context, index) {
            final cell = cells[index];
            final intensity = math.min(cell.$2, 3);
            final colors = [
              const Color(0xFFE2E8F0),
              AppTheme.primaryLight.withAlpha(50),
              AppTheme.primaryLight.withAlpha(120),
              AppTheme.primaryLight,
            ];

            return Tooltip(
              message:
                  '${DateFormat('EEE, dd MMM').format(cell.$1)}${cell.$2 > 0 ? ' • ${cell.$2} workout' : ' • Rest'}',
              child: Container(
                decoration: BoxDecoration(
                  color: colors[intensity],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Mon', style: TextStyle(color: Color(0xFF64748B))),
            Text('Tue', style: TextStyle(color: Color(0xFF64748B))),
            Text('Wed', style: TextStyle(color: Color(0xFF64748B))),
            Text('Thu', style: TextStyle(color: Color(0xFF64748B))),
            Text('Fri', style: TextStyle(color: Color(0xFF64748B))),
            Text('Sat', style: TextStyle(color: Color(0xFF64748B))),
            Text('Sun', style: TextStyle(color: Color(0xFF64748B))),
          ],
        ),
      ],
    );
  }
}

class _TopLiftTile extends StatelessWidget {
  final PersonalRecord record;

  const _TopLiftTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/progress/exercise/${record.exerciseId}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.workspace_premium_outlined,
                color: AppTheme.primaryLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${record.weight.toStringAsFixed(record.weight.truncateToDouble() == record.weight ? 0 : 1)} kg × ${record.reps}',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Text(
              DateFormat('dd MMM').format(record.date),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthSnapshotTile extends StatelessWidget {
  final String label;
  final String value;
  final String helper;
  final IconData icon;

  const _HealthSnapshotTile({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryLight),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(helper, style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ShortcutTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withAlpha(12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryLight),
            const SizedBox(height: 18),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;
  final Color fillColor;

  const _LineChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final minValue = points.reduce(math.min);
    final maxValue = points.reduce(math.max);
    final range = (maxValue - minValue).abs() < 0.001
        ? 1.0
        : maxValue - minValue;

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x =
          (size.width / (points.length - 1 == 0 ? 1 : points.length - 1)) * i;
      final normalized = (points[i] - minValue) / range;
      final y = size.height - (normalized * (size.height - 16)) - 8;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    for (var i = 0; i < points.length; i++) {
      final x =
          (size.width / (points.length - 1 == 0 ? 1 : points.length - 1)) * i;
      final normalized = (points[i] - minValue) / range;
      final y = size.height - (normalized * (size.height - 16)) - 8;
      canvas.drawCircle(Offset(x, y), 4.5, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}
