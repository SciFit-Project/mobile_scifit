import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scifit/features/progress/data/mock_progress_data.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  String _selectedPlan = 'All Plans';
  int _rangeDays = 90;

  List<WorkoutSessionLog> get _filteredSessions {
    final cutoff = DateTime.now().subtract(Duration(days: _rangeDays));
    return mockWorkoutSessions.where((session) {
      final matchesPlan =
          _selectedPlan == 'All Plans' || session.planName == _selectedPlan;
      final matchesDate = session.date.isAfter(cutoff);
      return matchesPlan && matchesDate;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, List<WorkoutSessionLog>> get _groupedByWeek {
    final Map<String, List<WorkoutSessionLog>> grouped = {};
    for (final session in _filteredSessions) {
      final weekStart = session.date.subtract(
        Duration(days: session.date.weekday - 1),
      );
      final label =
          '${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM').format(weekStart.add(const Duration(days: 6)))}';
      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(session);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final planNames = {
      'All Plans',
      ...mockWorkoutSessions.map((session) => session.planName),
    }.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedPlan,
                  decoration: const InputDecoration(labelText: 'Plan'),
                  items: planNames
                      .map(
                        (plan) =>
                            DropdownMenuItem(value: plan, child: Text(plan)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedPlan = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _rangeDays,
                  decoration: const InputDecoration(labelText: 'Date Range'),
                  items: const [
                    DropdownMenuItem(value: 7, child: Text('Last 7d')),
                    DropdownMenuItem(value: 30, child: Text('Last 30d')),
                    DropdownMenuItem(value: 90, child: Text('Last 90d')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _rangeDays = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._groupedByWeek.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ...entry.value.map((session) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SessionHistoryCard(session: session),
                  );
                }),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SessionHistoryCard extends StatelessWidget {
  final WorkoutSessionLog session;

  const _SessionHistoryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/history/${session.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.planName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.dayName,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(session.date),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
