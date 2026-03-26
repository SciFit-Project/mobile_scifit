// ignore_for_file: prefer_const_constructors

class LoggedSet {
  final int reps;
  final double weight;
  final double rpe;

  const LoggedSet({
    required this.reps,
    required this.weight,
    required this.rpe,
  });
}

class SessionExerciseLog {
  final String exerciseId;
  final String exerciseName;
  final bool newPr;
  final List<LoggedSet> sets;

  const SessionExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.newPr,
    required this.sets,
  });

  double get volume =>
      sets.fold(0, (sum, set) => sum + (set.weight * set.reps));

  double get maxWeight =>
      sets.fold(0, (max, set) => set.weight > max ? set.weight : max);

  int get maxReps =>
      sets.fold(0, (max, set) => set.reps > max ? set.reps : max);

  double get estimatedOneRm {
    double best = 0;
    for (final set in sets) {
      final estimate = set.weight * (1 + (set.reps / 30));
      if (estimate > best) best = estimate;
    }
    return best;
  }

  double get avgRpe => sets.isEmpty
      ? 0
      : sets.fold(0.0, (sum, set) => sum + set.rpe) / sets.length;
}

class WorkoutSessionLog {
  final String id;
  final String planName;
  final String dayName;
  final DateTime date;
  final int durationMin;
  final double avgRpe;
  final int calories;
  final List<SessionExerciseLog> exercises;
  final double? totalVolumeOverride;

  const WorkoutSessionLog({
    required this.id,
    required this.planName,
    required this.dayName,
    required this.date,
    required this.durationMin,
    required this.avgRpe,
    required this.calories,
    required this.exercises,
    this.totalVolumeOverride,
  });

  double get totalVolume =>
      totalVolumeOverride ??
      exercises.fold(0.0, (sum, exercise) => sum + exercise.volume);
}

class BodyWeightPoint {
  final DateTime date;
  final double weight;

  const BodyWeightPoint({required this.date, required this.weight});
}

class WeeklyVolumePoint {
  final DateTime weekStart;
  final double volume;

  const WeeklyVolumePoint({required this.weekStart, required this.volume});
}

class PersonalRecord {
  final String exerciseId;
  final String name;
  final double weight;
  final int reps;
  final DateTime date;

  const PersonalRecord({
    required this.exerciseId,
    required this.name,
    required this.weight,
    required this.reps,
    required this.date,
  });
}

final List<WorkoutSessionLog> mockWorkoutSessions = [
  WorkoutSessionLog(
    id: 'session-001',
    planName: 'PPL Program',
    dayName: 'Push Day A',
    date: DateTime(2026, 3, 15),
    durationMin: 67,
    avgRpe: 8.2,
    calories: 518,
    exercises: [
      SessionExerciseLog(
        exerciseId: 'ex-bench',
        exerciseName: 'Bench Press',
        newPr: true,
        sets: const [
          LoggedSet(reps: 5, weight: 95, rpe: 8.5),
          LoggedSet(reps: 5, weight: 95, rpe: 8.5),
          LoggedSet(reps: 4, weight: 97.5, rpe: 9),
        ],
      ),
      SessionExerciseLog(
        exerciseId: 'ex-ohp',
        exerciseName: 'Overhead Press',
        newPr: false,
        sets: const [
          LoggedSet(reps: 8, weight: 45, rpe: 8),
          LoggedSet(reps: 8, weight: 45, rpe: 8),
          LoggedSet(reps: 7, weight: 47.5, rpe: 8.5),
        ],
      ),
      SessionExerciseLog(
        exerciseId: 'ex-incline',
        exerciseName: 'Incline DB Press',
        newPr: false,
        sets: const [
          LoggedSet(reps: 10, weight: 30, rpe: 8),
          LoggedSet(reps: 10, weight: 30, rpe: 8),
          LoggedSet(reps: 9, weight: 32.5, rpe: 8.5),
        ],
      ),
    ],
  ),
  WorkoutSessionLog(
    id: 'session-002',
    planName: 'PPL Program',
    dayName: 'Pull Day A',
    date: DateTime(2026, 3, 13),
    durationMin: 72,
    avgRpe: 7.8,
    calories: 552,
    exercises: [
      SessionExerciseLog(
        exerciseId: 'ex-deadlift',
        exerciseName: 'Deadlift',
        newPr: false,
        sets: const [
          LoggedSet(reps: 5, weight: 150, rpe: 8),
          LoggedSet(reps: 5, weight: 150, rpe: 8),
          LoggedSet(reps: 4, weight: 160, rpe: 8.5),
        ],
      ),
      SessionExerciseLog(
        exerciseId: 'ex-row',
        exerciseName: 'Barbell Row',
        newPr: false,
        sets: const [
          LoggedSet(reps: 8, weight: 75, rpe: 7.5),
          LoggedSet(reps: 8, weight: 75, rpe: 8),
          LoggedSet(reps: 8, weight: 77.5, rpe: 8.5),
        ],
      ),
      SessionExerciseLog(
        exerciseId: 'ex-curl',
        exerciseName: 'Barbell Curl',
        newPr: false,
        sets: const [
          LoggedSet(reps: 10, weight: 32.5, rpe: 8),
          LoggedSet(reps: 10, weight: 32.5, rpe: 8),
          LoggedSet(reps: 9, weight: 35, rpe: 8.5),
        ],
      ),
    ],
  ),
  WorkoutSessionLog(
    id: 'session-003',
    planName: 'PPL Program',
    dayName: 'Leg Day A',
    date: DateTime(2026, 3, 11),
    durationMin: 75,
    avgRpe: 8.4,
    calories: 610,
    exercises: [
      SessionExerciseLog(
        exerciseId: 'ex-squat',
        exerciseName: 'Back Squat',
        newPr: true,
        sets: const [
          LoggedSet(reps: 5, weight: 135, rpe: 8.5),
          LoggedSet(reps: 5, weight: 135, rpe: 8.5),
          LoggedSet(reps: 4, weight: 140, rpe: 9),
        ],
      ),
      SessionExerciseLog(
        exerciseId: 'ex-rdl',
        exerciseName: 'Romanian Deadlift',
        newPr: false,
        sets: const [
          LoggedSet(reps: 8, weight: 95, rpe: 8),
          LoggedSet(reps: 8, weight: 95, rpe: 8),
          LoggedSet(reps: 8, weight: 100, rpe: 8.5),
        ],
      ),
      SessionExerciseLog(
        exerciseId: 'ex-press',
        exerciseName: 'Leg Press',
        newPr: false,
        sets: const [
          LoggedSet(reps: 12, weight: 180, rpe: 8),
          LoggedSet(reps: 12, weight: 180, rpe: 8),
          LoggedSet(reps: 10, weight: 200, rpe: 9),
        ],
      ),
    ],
  ),
  WorkoutSessionLog(
    id: 'session-004',
    planName: 'PPL Program',
    dayName: 'Push Day A',
    date: DateTime(2026, 3, 8),
    durationMin: 64,
    avgRpe: 7.9,
    calories: 500,
    exercises: [
      SessionExerciseLog(
        exerciseId: 'ex-bench',
        exerciseName: 'Bench Press',
        newPr: false,
        sets: const [
          LoggedSet(reps: 5, weight: 92.5, rpe: 8),
          LoggedSet(reps: 5, weight: 92.5, rpe: 8),
          LoggedSet(reps: 5, weight: 95, rpe: 8.5),
        ],
      ),
      SessionExerciseLog(
        exerciseId: 'ex-ohp',
        exerciseName: 'Overhead Press',
        newPr: false,
        sets: const [
          LoggedSet(reps: 8, weight: 42.5, rpe: 7.5),
          LoggedSet(reps: 8, weight: 45, rpe: 8),
          LoggedSet(reps: 8, weight: 45, rpe: 8),
        ],
      ),
      SessionExerciseLog(
        exerciseId: 'ex-incline',
        exerciseName: 'Incline DB Press',
        newPr: false,
        sets: const [
          LoggedSet(reps: 10, weight: 27.5, rpe: 7.5),
          LoggedSet(reps: 10, weight: 30, rpe: 8),
          LoggedSet(reps: 10, weight: 30, rpe: 8),
        ],
      ),
    ],
  ),
  WorkoutSessionLog(
    id: 'session-005',
    planName: 'Upper Lower Split',
    dayName: 'Upper A',
    date: DateTime(2026, 3, 4),
    durationMin: 69,
    avgRpe: 7.7,
    calories: 530,
    exercises: [
      SessionExerciseLog(
        exerciseId: 'ex-bench',
        exerciseName: 'Bench Press',
        newPr: false,
        sets: const [
          LoggedSet(reps: 6, weight: 90, rpe: 7.5),
          LoggedSet(reps: 6, weight: 90, rpe: 7.5),
          LoggedSet(reps: 5, weight: 92.5, rpe: 8),
        ],
      ),
      SessionExerciseLog(
        exerciseId: 'ex-deadlift',
        exerciseName: 'Deadlift',
        newPr: false,
        sets: const [
          LoggedSet(reps: 4, weight: 145, rpe: 8),
          LoggedSet(reps: 4, weight: 145, rpe: 8),
          LoggedSet(reps: 4, weight: 150, rpe: 8.5),
        ],
      ),
    ],
  ),
  WorkoutSessionLog(
    id: 'session-006',
    planName: 'Upper Lower Split',
    dayName: 'Lower A',
    date: DateTime(2026, 2, 28),
    durationMin: 71,
    avgRpe: 8.1,
    calories: 590,
    exercises: [
      SessionExerciseLog(
        exerciseId: 'ex-squat',
        exerciseName: 'Back Squat',
        newPr: false,
        sets: const [
          LoggedSet(reps: 5, weight: 130, rpe: 8),
          LoggedSet(reps: 5, weight: 130, rpe: 8),
          LoggedSet(reps: 5, weight: 132.5, rpe: 8.5),
        ],
      ),
      SessionExerciseLog(
        exerciseId: 'ex-rdl',
        exerciseName: 'Romanian Deadlift',
        newPr: false,
        sets: const [
          LoggedSet(reps: 8, weight: 90, rpe: 7.5),
          LoggedSet(reps: 8, weight: 92.5, rpe: 8),
          LoggedSet(reps: 8, weight: 95, rpe: 8),
        ],
      ),
    ],
  ),
  WorkoutSessionLog(
    id: 'session-007',
    planName: 'PPL Program',
    dayName: 'Push Day A',
    date: DateTime(2026, 2, 22),
    durationMin: 63,
    avgRpe: 7.6,
    calories: 492,
    exercises: [
      SessionExerciseLog(
        exerciseId: 'ex-bench',
        exerciseName: 'Bench Press',
        newPr: false,
        sets: const [
          LoggedSet(reps: 6, weight: 87.5, rpe: 7.5),
          LoggedSet(reps: 6, weight: 87.5, rpe: 7.5),
          LoggedSet(reps: 5, weight: 90, rpe: 8),
        ],
      ),
      SessionExerciseLog(
        exerciseId: 'ex-ohp',
        exerciseName: 'Overhead Press',
        newPr: false,
        sets: const [
          LoggedSet(reps: 8, weight: 40, rpe: 7.5),
          LoggedSet(reps: 8, weight: 42.5, rpe: 8),
          LoggedSet(reps: 8, weight: 42.5, rpe: 8),
        ],
      ),
    ],
  ),
  WorkoutSessionLog(
    id: 'session-008',
    planName: 'PPL Program',
    dayName: 'Leg Day A',
    date: DateTime(2026, 2, 18),
    durationMin: 73,
    avgRpe: 8.0,
    calories: 602,
    exercises: [
      SessionExerciseLog(
        exerciseId: 'ex-squat',
        exerciseName: 'Back Squat',
        newPr: false,
        sets: const [
          LoggedSet(reps: 5, weight: 127.5, rpe: 8),
          LoggedSet(reps: 5, weight: 127.5, rpe: 8),
          LoggedSet(reps: 5, weight: 130, rpe: 8.5),
        ],
      ),
      SessionExerciseLog(
        exerciseId: 'ex-press',
        exerciseName: 'Leg Press',
        newPr: false,
        sets: const [
          LoggedSet(reps: 12, weight: 170, rpe: 8),
          LoggedSet(reps: 12, weight: 170, rpe: 8),
          LoggedSet(reps: 10, weight: 180, rpe: 8.5),
        ],
      ),
    ],
  ),
  WorkoutSessionLog(
    id: 'session-009',
    planName: 'PPL Program',
    dayName: 'Pull Day A',
    date: DateTime(2026, 2, 14),
    durationMin: 70,
    avgRpe: 7.7,
    calories: 540,
    exercises: [
      SessionExerciseLog(
        exerciseId: 'ex-deadlift',
        exerciseName: 'Deadlift',
        newPr: true,
        sets: const [
          LoggedSet(reps: 5, weight: 145, rpe: 8),
          LoggedSet(reps: 4, weight: 150, rpe: 8.5),
          LoggedSet(reps: 3, weight: 165, rpe: 9),
        ],
      ),
      SessionExerciseLog(
        exerciseId: 'ex-row',
        exerciseName: 'Barbell Row',
        newPr: false,
        sets: const [
          LoggedSet(reps: 8, weight: 72.5, rpe: 7.5),
          LoggedSet(reps: 8, weight: 75, rpe: 8),
          LoggedSet(reps: 8, weight: 75, rpe: 8),
        ],
      ),
    ],
  ),
];

final List<BodyWeightPoint> mockBodyWeightTrend = List.generate(30, (index) {
  final date = DateTime(2026, 2, 15).add(Duration(days: index));
  final weights = [
    73.8,
    73.7,
    73.7,
    73.6,
    73.5,
    73.5,
    73.4,
    73.3,
    73.3,
    73.2,
    73.1,
    73.1,
    73.0,
    73.0,
    72.9,
    72.9,
    72.8,
    72.8,
    72.7,
    72.7,
    72.6,
    72.6,
    72.5,
    72.5,
    72.5,
    72.4,
    72.4,
    72.3,
    72.3,
    72.2,
  ];
  return BodyWeightPoint(date: date, weight: weights[index]);
});

List<WeeklyVolumePoint> getWeeklyVolumePoints() {
  final sessions = [...mockWorkoutSessions]
    ..sort((a, b) => a.date.compareTo(b.date));
  final Map<DateTime, double> weeklyTotals = {};

  for (final session in sessions) {
    final weekday = session.date.weekday;
    final weekStart = DateTime(
      session.date.year,
      session.date.month,
      session.date.day - (weekday - 1),
    );
    weeklyTotals.update(
      weekStart,
      (value) => value + session.totalVolume,
      ifAbsent: () => session.totalVolume,
    );
  }

  final points =
      weeklyTotals.entries
          .map(
            (entry) =>
                WeeklyVolumePoint(weekStart: entry.key, volume: entry.value),
          )
          .toList()
        ..sort((a, b) => a.weekStart.compareTo(b.weekStart));

  if (points.length <= 8) return points;
  return points.sublist(points.length - 8);
}

List<WorkoutSessionLog> getSessionsForExercise(String exerciseId) {
  return mockWorkoutSessions
      .where(
        (session) => session.exercises.any(
          (exercise) => exercise.exerciseId == exerciseId,
        ),
      )
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}

SessionExerciseLog? getExerciseLogForSession(
  WorkoutSessionLog session,
  String exerciseId,
) {
  for (final exercise in session.exercises) {
    if (exercise.exerciseId == exerciseId) return exercise;
  }
  return null;
}

WorkoutSessionLog? getSessionById(String sessionId) {
  for (final session in mockWorkoutSessions) {
    if (session.id == sessionId) return session;
  }
  return null;
}

WorkoutSessionLog? getPreviousSession(String sessionId) {
  final sessions = [...mockWorkoutSessions]
    ..sort((a, b) => b.date.compareTo(a.date));
  final index = sessions.indexWhere((session) => session.id == sessionId);
  if (index == -1 || index == sessions.length - 1) return null;
  return sessions[index + 1];
}

List<PersonalRecord> getTopLifts() {
  final targets = ['ex-bench', 'ex-squat', 'ex-deadlift'];
  final List<PersonalRecord> records = [];

  for (final exerciseId in targets) {
    PersonalRecord? bestRecord;
    for (final session in mockWorkoutSessions) {
      final exercise = getExerciseLogForSession(session, exerciseId);
      if (exercise == null) continue;

      final maxSet = exercise.sets.reduce(
        (best, current) => current.weight > best.weight ? current : best,
      );

      if (bestRecord == null || maxSet.weight > bestRecord.weight) {
        bestRecord = PersonalRecord(
          exerciseId: exerciseId,
          name: exercise.exerciseName,
          weight: maxSet.weight,
          reps: maxSet.reps,
          date: session.date,
        );
      }
    }

    if (bestRecord != null) records.add(bestRecord);
  }

  return records;
}

List<DateTime> getWorkoutCalendarDays({int weeks = 4}) {
  final cutoff = DateTime.now().subtract(Duration(days: weeks * 7));
  return mockWorkoutSessions
      .where((session) => session.date.isAfter(cutoff))
      .map(
        (session) =>
            DateTime(session.date.year, session.date.month, session.date.day),
      )
      .toList();
}
