class ActivePlansProgram {
  final String workoutTitle;
  final String workoutDescription;
  final int totalExercise;
  final int timeDuration;

  ActivePlansProgram({
    required this.workoutTitle,
    required this.workoutDescription,
    required this.totalExercise,
    required this.timeDuration,
  });
}

class WorkoutPlan {
  final String workoutTitle;
  final int totalExercise;

  WorkoutPlan({required this.workoutTitle, required this.totalExercise});

  @override
  String toString() {
    return 'WorkoutPlan(title: $workoutTitle, exercises: $totalExercise)';
  }
}

// ==================

class MyPlans {
  final String id;
  final String userId;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final List<WorkoutDay> days;
  final PlanStats stats;

  MyPlans({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.days,
    required this.stats,
  });
}

class WorkoutDay {
  final String id;
  final int dayNumber;
  final String name;
  final List<PlanExercise> exercises;

  WorkoutDay({
    required this.id,
    required this.dayNumber,
    required this.name,
    required this.exercises,
  });
}

class PlanExercise {
  final String exerciseId;
  final String name;
  final String muscleGroup;
  int sets;
  int reps;
  final int order;

  PlanExercise({
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.order,
  });
}

class PlanStats {
  final int totalDays;
  final int totalExercises;
  final int estDurationMin;
  final int timesUsed;

  PlanStats({
    required this.totalDays,
    required this.totalExercises,
    required this.estDurationMin,
    required this.timesUsed,
  });
}

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  quads,
  hamstrings,
  calves,
  glutes,
  core, legs, arms,
}

enum Equipment { barbell, dumbbell, cable, machine, bodyweight, band }

class Exercise {
  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final List<String>? secondaryMuscles;
  final Equipment? equipment;
  final String? instruction;
  final DateTime createdAt;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.secondaryMuscles,
    this.equipment,
    this.instruction,
    required this.createdAt,
  });
}
