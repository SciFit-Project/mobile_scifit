import 'dart:math';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scifit/core/network/dio_client.dart';
import 'package:mobile_scifit/features/progress/data/mock_progress_data.dart';
import 'package:mobile_scifit/features/sessions/data/session_store.dart';
import 'package:mobile_scifit/features/workout/types/response_type.dart';

class ActiveWorkoutSession {
  final String id;
  final String workoutDayId;
  final String planName;
  final String dayName;
  final DateTime startedAt;
  final Map<String, String> exerciseNames;
  final Map<String, List<LoggedSet>> exerciseSets;

  ActiveWorkoutSession({
    required this.id,
    required this.workoutDayId,
    required this.planName,
    required this.dayName,
    required this.startedAt,
    required this.exerciseNames,
    required this.exerciseSets,
  });
}

class SessionRepository {
  SessionRepository({Dio? dio}) : _dio = dio ?? DioClient().instance;

  final Dio _dio;
  static final Map<String, ActiveWorkoutSession> _activeSessions = {};

  Future<String> startSession({
    required String workoutDayId,
    required String planName,
    required String dayName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/sessions',
        data: {
          'workoutDayId': workoutDayId,
          'description': dayName,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final sessionId = data['id'] as String;
      _activeSessions[sessionId] = ActiveWorkoutSession(
        id: sessionId,
        workoutDayId: workoutDayId,
        planName: planName,
        dayName: dayName,
        startedAt:
            DateTime.tryParse((data['startedAt'] ?? data['started_at'] ?? '').toString()) ??
            DateTime.now(),
        exerciseNames: {},
        exerciseSets: {},
      );
      return sessionId;
    } catch (_) {
      final sessionId = 'local-session-${DateTime.now().microsecondsSinceEpoch}';
      _activeSessions[sessionId] = ActiveWorkoutSession(
        id: sessionId,
        workoutDayId: workoutDayId,
        planName: planName,
        dayName: dayName,
        startedAt: DateTime.now(),
        exerciseNames: {},
        exerciseSets: {},
      );
      return sessionId;
    }
  }

  Future<void> logExerciseSets({
    required String sessionId,
    required String exerciseId,
    required String exerciseName,
    required List<LoggedSet> sets,
  }) async {
    final session = _activeSessions[sessionId];
    if (session == null) return;

    session.exerciseNames[exerciseId] = exerciseName;
    session.exerciseSets[exerciseId] = sets;

    for (final entry in sets.asMap().entries) {
      final index = entry.key;
      final set = entry.value;
      try {
        await _dio.post(
          '/api/sessions/$sessionId/sets',
          data: {
            'exerciseId': exerciseId,
            'setNumber': index + 1,
            'weightKg': set.weight,
            'reps': set.reps,
            'rpe': set.rpe,
          },
        );
      } catch (_) {
        // Keep local draft; backend can catch up once sessions API is ready.
      }
    }
  }

  Future<WorkoutSessionLog?> finishSession({
    required String sessionId,
    double? perceivedExertion,
    String? notes,
  }) async {
    final session = _activeSessions.remove(sessionId);
    if (session == null) return null;

    final finishedAt = DateTime.now();
    final exercises = session.exerciseSets.entries.map((entry) {
      return SessionExerciseLog(
        exerciseId: entry.key,
        exerciseName: session.exerciseNames[entry.key] ?? 'Exercise',
        newPr: false,
        sets: entry.value,
      );
    }).toList();

    final computedAvgRpe = exercises.isEmpty
        ? (perceivedExertion ?? 0)
        : exercises
                .map((exercise) => exercise.avgRpe)
                .reduce((a, b) => a + b) /
            exercises.length;

    final localLog = WorkoutSessionLog(
      id: session.id,
      planName: session.planName,
      dayName: session.dayName,
      date: session.startedAt,
      durationMin: max(
        1,
        finishedAt.difference(session.startedAt).inMinutes,
      ),
      avgRpe: computedAvgRpe,
      calories: _estimateCalories(session.startedAt, finishedAt),
      exercises: exercises,
    );

    try {
      await _dio.put(
        '/api/sessions/$sessionId',
        data: {
          'finishedAt': finishedAt.toIso8601String(),
          'notes': notes,
          'perceivedExertion': perceivedExertion?.round(),
        },
      );
    } catch (_) {
      // Keep local session history fallback.
    }

    sessionHistoryStore.value = [
      localLog,
      ...currentSessionHistory.where((item) => item.id != localLog.id),
    ];
    return localLog;
  }

  Future<List<WorkoutSessionLog>> fetchHistory() async {
    try {
      final response = await _dio.get('/api/sessions/history');
      final items = (response.data['data'] as List? ?? const []);
      if (items.isEmpty) {
        sessionHistoryStore.value = [];
        return const [];
      }

      final history = items.map<WorkoutSessionLog>(_mapSessionSummary).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      sessionHistoryStore.value = history;
      return history;
    } catch (_) {
      return currentSessionHistory;
    }
  }

  Future<WorkoutSessionLog?> fetchSessionById(String sessionId) async {
    try {
      final response = await _dio.get('/api/sessions/$sessionId');
      final session = _mapSessionDetail(response.data['data']);
      _upsertHistory(session);
      return session;
    } catch (_) {
      return findSessionById(sessionId);
    }
  }

  Future<WorkoutSessionLog?> fetchPreviousSession(String sessionId) async {
    try {
      final response = await _dio.get('/api/sessions/$sessionId/previous');
      final data = response.data['data'];
      if (data == null) return null;
      final session = _mapSessionDetail(data);
      _upsertHistory(session);
      return session;
    } catch (_) {
      return findPreviousSessionById(sessionId);
    }
  }

  LastSessionHistory? getPreviousExerciseHistory(String exerciseId) {
    final sessions = [...currentSessionHistory]
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        if (exercise.exerciseId != exerciseId) continue;
        return LastSessionHistory(
          lastDate: DateFormat('dd MMM').format(session.date),
          sessionHistory: exercise.sets.asMap().entries.map((entry) {
            final set = entry.value;
            return ListSessionHistory(
              set: entry.key + 1,
              weight: set.weight,
              reps: set.reps,
            );
          }).toList(),
        );
      }
    }

    return null;
  }

  WorkoutSessionLog _mapSessionSummary(dynamic raw) {
    return WorkoutSessionLog(
      id: (raw['id'] ?? '') as String,
      planName: (raw['planName'] ?? raw['plan_name'] ?? 'Workout Plan') as String,
      dayName: (raw['dayName'] ?? raw['day_name'] ?? 'Workout Day') as String,
      date:
          DateTime.tryParse((raw['date'] ?? raw['startedAt'] ?? raw['started_at'] ?? '').toString()) ??
          DateTime.now(),
      durationMin: (raw['durationMin'] ?? raw['duration_min'] ?? 0) as int,
      avgRpe: ((raw['avgRpe'] ?? raw['avg_rpe'] ?? 0) as num).toDouble(),
      calories: (raw['calories'] ?? 0) as int,
      exercises: const [],
    );
  }

  WorkoutSessionLog _mapSessionDetail(dynamic raw) {
    final exercises = ((raw['exercises'] as List?) ?? const [])
        .map<SessionExerciseLog>((item) {
          final sets = ((item['sets'] as List?) ?? const [])
              .map<LoggedSet>((set) {
                return LoggedSet(
                  reps: (set['reps'] ?? 0) as int,
                  weight: ((set['weight'] ?? set['weightKg'] ?? set['weight_kg'] ?? 0)
                          as num)
                      .toDouble(),
                  rpe: ((set['rpe'] ?? 0) as num).toDouble(),
                );
              })
              .toList();

          return SessionExerciseLog(
            exerciseId: (item['exerciseId'] ?? item['exercise_id'] ?? '') as String,
            exerciseName:
                (item['name'] ?? item['exerciseName'] ?? item['exercise_name'] ?? 'Exercise')
                    as String,
            newPr: (item['newPr'] ?? item['new_pr'] ?? false) as bool,
            sets: sets,
          );
        })
        .toList();

    return WorkoutSessionLog(
      id: (raw['id'] ?? '') as String,
      planName: (raw['planName'] ?? raw['plan_name'] ?? 'Workout Plan') as String,
      dayName: (raw['dayName'] ?? raw['day_name'] ?? 'Workout Day') as String,
      date:
          DateTime.tryParse((raw['date'] ?? raw['startedAt'] ?? raw['started_at'] ?? '').toString()) ??
          DateTime.now(),
      durationMin: (raw['durationMin'] ?? raw['duration_min'] ?? 0) as int,
      avgRpe: ((raw['avgRpe'] ?? raw['avg_rpe'] ?? 0) as num).toDouble(),
      calories: (raw['calories'] ?? 0) as int,
      exercises: exercises,
    );
  }

  void _upsertHistory(WorkoutSessionLog session) {
    final updated = [...currentSessionHistory];
    final index = updated.indexWhere((item) => item.id == session.id);
    if (index >= 0) {
      updated[index] = session;
    } else {
      updated.add(session);
    }
    updated.sort((a, b) => b.date.compareTo(a.date));
    sessionHistoryStore.value = updated;
  }

  int _estimateCalories(DateTime startedAt, DateTime finishedAt) {
    final minutes = max(1, finishedAt.difference(startedAt).inMinutes);
    return minutes * 6;
  }
}
