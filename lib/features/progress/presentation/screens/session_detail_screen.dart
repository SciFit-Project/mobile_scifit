import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scifit/features/progress/data/mock_progress_data.dart';

class SessionDetailScreen extends StatefulWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  bool _comparePrevious = false;

  @override
  Widget build(BuildContext context) {
    final session = getSessionById(widget.sessionId);
    if (session == null) {
      return const Scaffold(body: Center(child: Text('Session not found')));
    }

    final previousSession = getPreviousSession(widget.sessionId);

    return Scaffold(
      appBar: AppBar(title: const Text('Session Detail')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _OverviewCard(session: session),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Compare vs previous session',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              previousSession == null
                  ? 'No previous session available'
                  : 'Compare against ${DateFormat('dd MMM').format(previousSession.date)}',
            ),
            value: _comparePrevious,
            onChanged: previousSession == null
                ? null
                : (value) {
                    setState(() {
                      _comparePrevious = value;
                    });
                  },
          ),
          const SizedBox(height: 12),
          ...session.exercises.map((exercise) {
            final previousExercise = previousSession == null
                ? null
                : getExerciseLogForSession(
                    previousSession,
                    exercise.exerciseId,
                  );
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,
                collapsedBackgroundColor: Colors.white,
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.exerciseName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (exercise.newPr)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'NEW PR',
                          style: TextStyle(
                            color: Color(0xFF15803D),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  '${exercise.volume.round()} kg total volume • Avg RPE ${exercise.avgRpe.toStringAsFixed(1)}',
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  ...exercise.sets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final set = entry.value;
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Set ${index + 1}'),
                      subtitle: Text(
                        '${set.reps} reps • RPE ${set.rpe.toStringAsFixed(1)}',
                      ),
                      trailing: Text(
                        '${set.weight.toStringAsFixed(set.weight.truncateToDouble() == set.weight ? 0 : 1)} kg',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    );
                  }),
                  if (_comparePrevious && previousExercise != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Previous volume: ${previousExercise.volume.round()} kg • Delta: ${(exercise.volume - previousExercise.volume).round()} kg',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final WorkoutSessionLog session;

  const _OverviewCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Date', DateFormat('dd MMM yyyy').format(session.date)),
      ('Duration', '${session.durationMin} min'),
      ('Plan', session.planName),
      ('Volume', '${session.totalVolume.round()} kg'),
      ('Avg RPE', session.avgRpe.toStringAsFixed(1)),
      ('Calories', '${session.calories} kcal'),
    ];

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
            session.dayName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.$2,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
