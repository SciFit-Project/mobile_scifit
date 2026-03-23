import 'package:flutter/foundation.dart';
import 'package:mobile_scifit/features/progress/data/mock_progress_data.dart';

final ValueNotifier<List<WorkoutSessionLog>> sessionHistoryStore =
    ValueNotifier<List<WorkoutSessionLog>>(_cloneSessions(mockWorkoutSessions));

List<WorkoutSessionLog> get currentSessionHistory => sessionHistoryStore.value;

WorkoutSessionLog? findSessionById(String sessionId) {
  for (final session in currentSessionHistory) {
    if (session.id == sessionId) return session;
  }
  return null;
}

WorkoutSessionLog? findPreviousSessionById(String sessionId) {
  final sessions = [...currentSessionHistory]
    ..sort((a, b) => b.date.compareTo(a.date));
  final index = sessions.indexWhere((session) => session.id == sessionId);
  if (index == -1 || index == sessions.length - 1) return null;
  return sessions[index + 1];
}

List<WorkoutSessionLog> _cloneSessions(List<WorkoutSessionLog> sessions) {
  return sessions
      .map(
        (session) => WorkoutSessionLog(
          id: session.id,
          planName: session.planName,
          dayName: session.dayName,
          date: session.date,
          durationMin: session.durationMin,
          avgRpe: session.avgRpe,
          calories: session.calories,
          exercises: session.exercises
              .map(
                (exercise) => SessionExerciseLog(
                  exerciseId: exercise.exerciseId,
                  exerciseName: exercise.exerciseName,
                  newPr: exercise.newPr,
                  sets: exercise.sets
                      .map(
                        (set) => LoggedSet(
                          reps: set.reps,
                          weight: set.weight,
                          rpe: set.rpe,
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      )
      .toList();
}
