import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/profile/data/mock_profile.dart';
import 'package:mobile_scifit/features/progress/data/body_weight_repository.dart';
import 'package:mobile_scifit/features/progress/data/body_weight_store.dart';
import 'package:mobile_scifit/features/progress/data/mock_progress_data.dart';
import 'package:mobile_scifit/features/sessions/data/session_repository.dart';
import 'package:mobile_scifit/features/sessions/data/session_store.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final SessionRepository _sessionRepository = SessionRepository();
  final BodyWeightRepository _bodyWeightRepository = BodyWeightRepository();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await _sessionRepository.fetchHistory();
    try {
      await _bodyWeightRepository.fetchLogs();
    } catch (_) {
      seedBodyWeightIfEmpty(mockProfileStore.value.weightKg);
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  int _workoutsThisWeek(List<WorkoutSessionLog> sessions) {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    return sessions.where((session) => !session.date.isBefore(weekStart)).length;
  }

  int _workoutsThisMonth(List<WorkoutSessionLog> sessions) {
    final now = DateTime.now();
    return sessions
        .where(
          (session) =>
              session.date.year == now.year && session.date.month == now.month,
        )
        .length;
  }

  int _currentStreak(List<WorkoutSessionLog> sessions) {
    if (sessions.isEmpty) return 0;

    final uniqueDays = <DateTime>{};
    for (final session in sessions) {
      uniqueDays.add(DateTime(session.date.year, session.date.month, session.date.day));
    }

    final sortedDays = uniqueDays.toList()..sort((a, b) => b.compareTo(a));
    var streak = 1;

    for (var i = 0; i < sortedDays.length - 1; i++) {
      final current = sortedDays[i];
      final next = sortedDays[i + 1];
      if (current.difference(next).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  List<WeeklyVolumePoint> _weeklyVolume(List<WorkoutSessionLog> sessions) {
    final now = DateTime.now();
    final currentWeekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final buckets = <DateTime, double>{};
    for (var i = 7; i >= 0; i--) {
      final weekStart = currentWeekStart.subtract(Duration(days: i * 7));
      buckets[weekStart] = 0;
    }

    for (final session in sessions) {
      final day = DateTime(session.date.year, session.date.month, session.date.day);
      final weekStart = day.subtract(Duration(days: day.weekday - 1));
      if (buckets.containsKey(weekStart)) {
        buckets[weekStart] = (buckets[weekStart] ?? 0) + session.totalVolume;
      }
    }

    return buckets.entries
        .map((entry) => WeeklyVolumePoint(weekStart: entry.key, volume: entry.value))
        .toList()
      ..sort((a, b) => a.weekStart.compareTo(b.weekStart));
  }

  double _weekOverWeekDelta(List<WeeklyVolumePoint> points) {
    if (points.length < 2) return 0;
    final previous = points[points.length - 2].volume;
    final current = points.last.volume;
    return current - previous;
  }

  List<WorkoutSessionLog> _recentSessions(List<WorkoutSessionLog> sessions) {
    final sorted = [...sessions]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  List<_ExerciseProgressSummary> _exerciseSummaries(
    List<WorkoutSessionLog> sessions,
  ) {
    final grouped = <String, List<_ExerciseLogWithDate>>{};

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        grouped.putIfAbsent(exercise.exerciseId, () => []);
        grouped[exercise.exerciseId]!.add(
          _ExerciseLogWithDate(date: session.date, log: exercise),
        );
      }
    }

    final summaries = grouped.entries.map((entry) {
      final logs = [...entry.value]..sort((a, b) => a.date.compareTo(b.date));
      final latest = logs.last;
      final bestOneRm = logs
          .map((item) => item.log.estimatedOneRm)
          .reduce(math.max);

      double? previousOneRm;
      if (logs.length > 1) {
        previousOneRm = logs[logs.length - 2].log.estimatedOneRm;
      }

      return _ExerciseProgressSummary(
        exerciseId: entry.key,
        name: latest.log.exerciseName,
        lastDate: latest.date,
        bestOneRm: bestOneRm,
        lastOneRm: latest.log.estimatedOneRm,
        previousOneRm: previousOneRm,
      );
    }).toList();

    summaries.sort((a, b) => b.lastDate.compareTo(a.lastDate));
    return summaries.take(3).toList();
  }

  Future<void> _showWeightLogDialog() async {
    final weightController = TextEditingController();
    var selectedDate = DateTime.now();

    final result = await showDialog<_WeightLogInput>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Log Body Weight'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked == null) return;
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final weight = double.tryParse(weightController.text.trim());
                    if (weight == null || weight <= 0) return;
                    Navigator.of(dialogContext).pop(
                      _WeightLogInput(date: selectedDate, weightKg: weight),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    await _bodyWeightRepository.saveLog(
      date: result.date,
      weightKg: result.weightKg,
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: ValueListenableBuilder<List<WorkoutSessionLog>>(
            valueListenable: sessionHistoryStore,
            builder: (context, sessions, _) {
              final weeklyVolume = _weeklyVolume(sessions);
              final recentSessions = _recentSessions(sessions);
              final weekDelta = _weekOverWeekDelta(weeklyVolume);
              final exerciseSummaries = _exerciseSummaries(sessions);

              return SingleChildScrollView(
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
                      'See consistency, volume, and recent workouts at a glance',
                      style: TextStyle(color: Colors.black.withAlpha(150)),
                    ),
                    const SizedBox(height: 20),
                    _ChartCard(
                      title: 'Workout Consistency',
                      subtitle: 'Your training rhythm this week and this month',
                      child: _isLoading && sessions.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 28),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _ConsistencyMetricTile(
                                      label: 'This Week',
                                      value: _workoutsThisWeek(sessions).toString(),
                                      helper: 'sessions',
                                      icon: Icons.calendar_view_week,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _ConsistencyMetricTile(
                                      label: 'This Month',
                                      value: _workoutsThisMonth(sessions).toString(),
                                      helper: 'sessions',
                                      icon: Icons.date_range,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _ConsistencyMetricTile(
                                      label: 'Streak',
                                      value: _currentStreak(sessions).toString(),
                                      helper: 'days',
                                      icon: Icons.local_fire_department_outlined,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    _ChartCard(
                      title: 'Training Volume',
                      subtitle: 'Weekly total kg lifted over the last 8 weeks',
                      trailing:
                          '${weeklyVolume.isEmpty ? 0 : weeklyVolume.last.volume.round()} kg',
                      child: weeklyVolume.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 28),
                              child: Center(child: Text('No volume data yet')),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weekDelta == 0
                                      ? 'No change from last week'
                                      : weekDelta > 0
                                          ? '+${weekDelta.round()} kg vs last week'
                                          : '${weekDelta.round()} kg vs last week',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: weekDelta >= 0
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB91C1C),
                                  ),
                                ),
                                const SizedBox(height: 16),
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
                      title: 'Recent Sessions',
                      subtitle: 'Your latest completed workouts',
                      child: recentSessions.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 28),
                              child: Center(child: Text('No workouts logged yet')),
                            )
                          : Column(
                              children: recentSessions.map((session) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _RecentSessionTile(session: session),
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 16),
                    _ChartCard(
                      title: 'More Progress',
                      subtitle: 'Strength trends and body weight updates',
                      child: Column(
                        children: [
                          _SectionLabelRow(
                            title: 'Exercise Progress',
                            actionLabel:
                                exerciseSummaries.isNotEmpty ? 'View details' : null,
                            onTap: exerciseSummaries.isNotEmpty
                                ? () => context.push(
                                      '/progress/exercise/${exerciseSummaries.first.exerciseId}',
                                    )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          if (exerciseSummaries.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Text('No exercise progress yet'),
                            )
                          else
                            ...exerciseSummaries.map((summary) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ExerciseProgressTile(summary: summary),
                              );
                            }),
                          const SizedBox(height: 8),
                          _SectionLabelRow(
                            title: 'Body Weight Trend',
                            actionLabel: 'Add Weight',
                            onTap: _showWeightLogDialog,
                          ),
                          const SizedBox(height: 12),
                          ValueListenableBuilder<List<BodyWeightPoint>>(
                            valueListenable: bodyWeightStore,
                            builder: (context, points, _) {
                              final visiblePoints = points.length <= 14
                                  ? points
                                  : points.sublist(points.length - 14);
                              final latest = latestBodyWeightPoint();
                              final first = points.isEmpty ? null : points.first;
                              final delta =
                                  latest == null || first == null
                                  ? 0.0
                                  : latest.weight - first.weight;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        latest == null
                                            ? '--'
                                            : '${latest.weight.toStringAsFixed(1)} kg',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        points.length < 2
                                            ? 'Latest entry'
                                            : delta == 0
                                                ? 'No change'
                                                : delta > 0
                                                    ? '+${delta.toStringAsFixed(1)} kg'
                                                    : '${delta.toStringAsFixed(1)} kg',
                                        style: TextStyle(
                                          color: delta <= 0
                                              ? const Color(0xFF15803D)
                                              : const Color(0xFFB91C1C),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    latest == null
                                        ? 'No body weight logs yet'
                                        : 'Updated ${DateFormat('dd MMM yyyy').format(latest.date)}',
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 180,
                                    child: _SimpleLineChart(
                                      points: visiblePoints.isEmpty
                                          ? [0]
                                          : visiblePoints
                                                .map((point) => point.weight)
                                                .toList(),
                                      lineColor: const Color(0xFF16A34A),
                                      fillColor: const Color(0xFF16A34A).withAlpha(20),
                                    ),
                                  ),
                                  if (visiblePoints.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat(
                                            'dd MMM',
                                          ).format(visiblePoints.first.date),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          DateFormat(
                                            'dd MMM',
                                          ).format(visiblePoints.last.date),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  const _SectionLabelRow(
                                    title: 'Recent Logs',
                                  ),
                                  const SizedBox(height: 8),
                                  if (points.isEmpty)
                                    const Text(
                                      'No body weight logs yet',
                                      style: TextStyle(color: Color(0xFF64748B)),
                                    )
                                  else
                                    ...points.reversed.take(5).map((point) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: _BodyWeightLogTile(
                                          point: point,
                                          onEdit: () => _showWeightLogDialogWithInitial(point),
                                          onDelete: () async {
                                            await _bodyWeightRepository.deleteLog(
                                              point.date,
                                            );
                                            if (!mounted) return;
                                            setState(() {});
                                          },
                                        ),
                                      );
                                    }),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showWeightLogDialogWithInitial(BodyWeightPoint point) async {
    final weightController = TextEditingController(
      text: point.weight.toStringAsFixed(1),
    );
    var selectedDate = point.date;

    final result = await showDialog<_WeightLogInput>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Body Weight'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked == null) return;
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final weight = double.tryParse(weightController.text.trim());
                    if (weight == null || weight <= 0) return;
                    Navigator.of(dialogContext).pop(
                      _WeightLogInput(date: selectedDate, weightKg: weight),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    if (!_sameDate(result.date, point.date)) {
      await _bodyWeightRepository.deleteLog(point.date);
    }
    await _bodyWeightRepository.saveLog(
      date: result.date,
      weightKg: result.weightKg,
    );
    if (!mounted) return;
    setState(() {});
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

class _ConsistencyMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String helper;
  final IconData icon;

  const _ConsistencyMetricTile({
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
          Column(
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                helper,
                style: const TextStyle(color: Color(0xFF64748B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentSessionTile extends StatelessWidget {
  final WorkoutSessionLog session;

  const _RecentSessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/history/${session.id}'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.dayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd MMM').format(session.date),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              session.planName,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(label: '${session.durationMin} min'),
                _MetricChip(label: '${session.totalVolume.round()} kg'),
                _MetricChip(label: 'RPE ${session.avgRpe.toStringAsFixed(1)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;

  const _MetricChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _SectionLabelRow extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _SectionLabelRow({
    required this.title,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        if (actionLabel != null && onTap != null)
          TextButton(onPressed: onTap, child: Text(actionLabel!)),
      ],
    );
  }
}

class _ExerciseProgressTile extends StatelessWidget {
  final _ExerciseProgressSummary summary;

  const _ExerciseProgressTile({required this.summary});

  @override
  Widget build(BuildContext context) {
    final delta = summary.previousOneRm == null
        ? null
        : summary.lastOneRm - summary.previousOneRm!;

    return InkWell(
      onTap: () => context.push('/progress/exercise/${summary.exerciseId}'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Best 1RM ${summary.bestOneRm.round()} kg',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  delta == null
                      ? 'New'
                      : delta == 0
                          ? 'Flat'
                          : delta > 0
                              ? '+${delta.toStringAsFixed(1)}'
                              : delta.toStringAsFixed(1),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: delta == null || delta >= 0
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM').format(summary.lastDate),
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyWeightLogTile extends StatelessWidget {
  final BodyWeightPoint point;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BodyWeightLogTile({
    required this.point,
    required this.onEdit,
    required this.onDelete,
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${point.weight.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(point.date),
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _ExerciseLogWithDate {
  final DateTime date;
  final SessionExerciseLog log;

  const _ExerciseLogWithDate({
    required this.date,
    required this.log,
  });
}

class _ExerciseProgressSummary {
  final String exerciseId;
  final String name;
  final DateTime lastDate;
  final double bestOneRm;
  final double lastOneRm;
  final double? previousOneRm;

  const _ExerciseProgressSummary({
    required this.exerciseId,
    required this.name,
    required this.lastDate,
    required this.bestOneRm,
    required this.lastOneRm,
    required this.previousOneRm,
  });
}

class _WeightLogInput {
  final DateTime date;
  final double weightKg;

  const _WeightLogInput({
    required this.date,
    required this.weightKg,
  });
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
    final range = (maxValue - minValue).abs() < 0.001 ? 1.0 : maxValue - minValue;

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = (size.width / (points.length - 1 == 0 ? 1 : points.length - 1)) * i;
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

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = lineColor;
    for (var i = 0; i < points.length; i++) {
      final x = (size.width / (points.length - 1 == 0 ? 1 : points.length - 1)) * i;
      final normalized = (points[i] - minValue) / range;
      final y = size.height - (normalized * (size.height - 16)) - 8;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}
