import 'package:mobile_scifit/features/plans/types/plans_type.dart';

final List<MyPlans> myMockPlans = [
  MyPlans(
    id: 'plan-001',
    userId: 'user-001',
    name: 'PPL Program',
    description: 'Push Pull Legs 6 days/weeks',
    isActive: false,
    createdAt: DateTime(2026, 1, 10),
    stats: PlanStats(
      totalDays: 6,
      totalExercises: 32,
      estDurationMin: 55,
      timesUsed: 14,
    ),
    days: [
      WorkoutDay(
        id: 'day-001',
        dayNumber: 1,
        name: 'Push Day A',
        exercises: [
          PlanExercise(
            order: 1,
            exerciseId: 'ex-001',
            name: 'Barbell Bench Press',
            muscleGroup: 'Chest',
            sets: 4,
            reps: 8,
          ),
          PlanExercise(
            order: 2,
            exerciseId: 'ex-002',
            name: 'Overhead Press',
            muscleGroup: 'Shoulders',
            sets: 4,
            reps: 8,
          ),
          PlanExercise(
            order: 3,
            exerciseId: 'ex-003',
            name: 'Incline DB Press',
            muscleGroup: 'Chest',
            sets: 3,
            reps: 10,
          ),
          PlanExercise(
            order: 4,
            exerciseId: 'ex-004',
            name: 'Cable Fly',
            muscleGroup: 'Chest',
            sets: 3,
            reps: 12,
          ),
          PlanExercise(
            order: 5,
            exerciseId: 'ex-005',
            name: 'Lateral Raise',
            muscleGroup: 'Shoulders',
            sets: 3,
            reps: 15,
          ),
          PlanExercise(
            order: 6,
            exerciseId: 'ex-006',
            name: 'Tricep Pushdown',
            muscleGroup: 'Triceps',
            sets: 3,
            reps: 12,
          ),
        ],
      ),
      WorkoutDay(
        id: 'day-002',
        dayNumber: 2,
        name: 'Pull Day A',
        exercises: [
          PlanExercise(
            order: 1,
            exerciseId: 'ex-007',
            name: 'Deadlift',
            muscleGroup: 'Back',
            sets: 4,
            reps: 5,
          ),
          PlanExercise(
            order: 2,
            exerciseId: 'ex-008',
            name: 'Pull-Up',
            muscleGroup: 'Back',
            sets: 4,
            reps: 8,
          ),
          PlanExercise(
            order: 3,
            exerciseId: 'ex-009',
            name: 'Barbell Row',
            muscleGroup: 'Back',
            sets: 4,
            reps: 8,
          ),
          PlanExercise(
            order: 4,
            exerciseId: 'ex-010',
            name: 'Face Pull',
            muscleGroup: 'Rear Delt',
            sets: 3,
            reps: 15,
          ),
          PlanExercise(
            order: 5,
            exerciseId: 'ex-011',
            name: 'Barbell Curl',
            muscleGroup: 'Biceps',
            sets: 3,
            reps: 10,
          ),
        ],
      ),
      WorkoutDay(
        id: 'day-003',
        dayNumber: 3,
        name: 'Leg Day A',
        exercises: [
          PlanExercise(
            order: 1,
            exerciseId: 'ex-012',
            name: 'Barbell Squat',
            muscleGroup: 'Quads',
            sets: 4,
            reps: 8,
          ),
          PlanExercise(
            order: 2,
            exerciseId: 'ex-013',
            name: 'Romanian Deadlift',
            muscleGroup: 'Hamstrings',
            sets: 4,
            reps: 10,
          ),
          PlanExercise(
            order: 3,
            exerciseId: 'ex-014',
            name: 'Leg Press',
            muscleGroup: 'Quads',
            sets: 3,
            reps: 12,
          ),
          PlanExercise(
            order: 4,
            exerciseId: 'ex-015',
            name: 'Leg Curl',
            muscleGroup: 'Hamstrings',
            sets: 3,
            reps: 12,
          ),
          PlanExercise(
            order: 5,
            exerciseId: 'ex-016',
            name: 'Calf Raise',
            muscleGroup: 'Calves',
            sets: 4,
            reps: 15,
          ),
        ],
      ),
    ],
  ),

  MyPlans(
    id: 'plan-002',
    userId: 'user-001',
    name: 'Upper Lower Split',
    description: 'Upper/Lower 4 วัน/สัปดาห์ เหมาะสำหรับ intermediate',
    isActive: true,
    createdAt: DateTime(2026, 2, 1),
    stats: PlanStats(
      totalDays: 4,
      totalExercises: 22,
      estDurationMin: 60,
      timesUsed: 3,
    ),
    days: [
      WorkoutDay(
        id: 'day-007',
        dayNumber: 1,
        name: 'Upper A',
        exercises: [
          PlanExercise(
            order: 1,
            exerciseId: 'ex-001',
            name: 'Barbell Bench Press',
            muscleGroup: 'Chest',
            sets: 4,
            reps: 6,
          ),
          PlanExercise(
            order: 2,
            exerciseId: 'ex-007',
            name: 'Deadlift',
            muscleGroup: 'Back',
            sets: 4,
            reps: 6,
          ),
          PlanExercise(
            order: 3,
            exerciseId: 'ex-002',
            name: 'Overhead Press',
            muscleGroup: 'Shoulders',
            sets: 3,
            reps: 8,
          ),
          PlanExercise(
            order: 4,
            exerciseId: 'ex-008',
            name: 'Pull-Up',
            muscleGroup: 'Back',
            sets: 3,
            reps: 8,
          ),
          PlanExercise(
            order: 5,
            exerciseId: 'ex-011',
            name: 'Barbell Curl',
            muscleGroup: 'Biceps',
            sets: 3,
            reps: 10,
          ),
          PlanExercise(
            order: 6,
            exerciseId: 'ex-006',
            name: 'Tricep Pushdown',
            muscleGroup: 'Triceps',
            sets: 3,
            reps: 10,
          ),
        ],
      ),
      WorkoutDay(
        id: 'day-008',
        dayNumber: 2,
        name: 'Lower A',
        exercises: [
          PlanExercise(
            order: 1,
            exerciseId: 'ex-012',
            name: 'Barbell Squat',
            muscleGroup: 'Quads',
            sets: 4,
            reps: 6,
          ),
          PlanExercise(
            order: 2,
            exerciseId: 'ex-013',
            name: 'Romanian Deadlift',
            muscleGroup: 'Hamstrings',
            sets: 4,
            reps: 8,
          ),
          PlanExercise(
            order: 3,
            exerciseId: 'ex-014',
            name: 'Leg Press',
            muscleGroup: 'Quads',
            sets: 3,
            reps: 12,
          ),
          PlanExercise(
            order: 4,
            exerciseId: 'ex-015',
            name: 'Leg Curl',
            muscleGroup: 'Hamstrings',
            sets: 3,
            reps: 12,
          ),
          PlanExercise(
            order: 5,
            exerciseId: 'ex-016',
            name: 'Calf Raise',
            muscleGroup: 'Calves',
            sets: 3,
            reps: 15,
          ),
        ],
      ),
    ],
  ),

  MyPlans(
    id: 'plan-003',
    userId: 'user-001',
    name: 'Full Body Beginner',
    description: 'Full body 3 วัน/สัปดาห์ เหมาะสำหรับมือใหม่',
    isActive: false,
    createdAt: DateTime(2025, 9, 15),
    stats: PlanStats(
      totalDays: 3,
      totalExercises: 15,
      estDurationMin: 40,
      timesUsed: 24,
    ),
    days: [
      WorkoutDay(
        id: 'day-011',
        dayNumber: 1,
        name: 'Full Body A',
        exercises: [
          PlanExercise(
            order: 1,
            exerciseId: 'ex-012',
            name: 'Barbell Squat',
            muscleGroup: 'Quads',
            sets: 3,
            reps: 8,
          ),
          PlanExercise(
            order: 2,
            exerciseId: 'ex-001',
            name: 'Barbell Bench Press',
            muscleGroup: 'Chest',
            sets: 3,
            reps: 8,
          ),
          PlanExercise(
            order: 3,
            exerciseId: 'ex-009',
            name: 'Barbell Row',
            muscleGroup: 'Back',
            sets: 3,
            reps: 8,
          ),
          PlanExercise(
            order: 4,
            exerciseId: 'ex-002',
            name: 'Overhead Press',
            muscleGroup: 'Shoulders',
            sets: 3,
            reps: 8,
          ),
          PlanExercise(
            order: 5,
            exerciseId: 'ex-016',
            name: 'Calf Raise',
            muscleGroup: 'Calves',
            sets: 2,
            reps: 15,
          ),
        ],
      ),
      WorkoutDay(
        id: 'day-012',
        dayNumber: 2,
        name: 'Full Body B',
        exercises: [
          PlanExercise(
            order: 1,
            exerciseId: 'ex-012',
            name: 'Barbell Squat',
            muscleGroup: 'Quads',
            sets: 3,
            reps: 8,
          ),
          PlanExercise(
            order: 2,
            exerciseId: 'ex-007',
            name: 'Deadlift',
            muscleGroup: 'Back',
            sets: 3,
            reps: 5,
          ),
          PlanExercise(
            order: 3,
            exerciseId: 'ex-008',
            name: 'Pull-Up',
            muscleGroup: 'Back',
            sets: 3,
            reps: 6,
          ),
          PlanExercise(
            order: 4,
            exerciseId: 'ex-017',
            name: 'DB Shoulder Press',
            muscleGroup: 'Shoulders',
            sets: 3,
            reps: 10,
          ),
          PlanExercise(
            order: 5,
            exerciseId: 'ex-016',
            name: 'Calf Raise',
            muscleGroup: 'Calves',
            sets: 2,
            reps: 15,
          ),
        ],
      ),
      WorkoutDay(
        id: 'day-013',
        dayNumber: 3,
        name: 'Full Body C',
        exercises: [
          PlanExercise(
            order: 1,
            exerciseId: 'ex-014',
            name: 'Leg Press',
            muscleGroup: 'Quads',
            sets: 3,
            reps: 10,
          ),
          PlanExercise(
            order: 2,
            exerciseId: 'ex-026',
            name: 'Incline Barbell Press',
            muscleGroup: 'Chest',
            sets: 3,
            reps: 10,
          ),
          PlanExercise(
            order: 3,
            exerciseId: 'ex-022',
            name: 'Lat Pulldown',
            muscleGroup: 'Back',
            sets: 3,
            reps: 10,
          ),
          PlanExercise(
            order: 4,
            exerciseId: 'ex-005',
            name: 'Lateral Raise',
            muscleGroup: 'Shoulders',
            sets: 3,
            reps: 15,
          ),
          PlanExercise(
            order: 5,
            exerciseId: 'ex-016',
            name: 'Calf Raise',
            muscleGroup: 'Calves',
            sets: 2,
            reps: 15,
          ),
        ],
      ),
    ],
  ),
];

List<MyPlans> buildMockPlans() {
  return myMockPlans.map(_clonePlan).toList();
}

MyPlans _clonePlan(MyPlans plan) {
  return MyPlans(
    id: plan.id,
    userId: plan.userId,
    name: plan.name,
    description: plan.description,
    isActive: plan.isActive,
    createdAt: plan.createdAt,
    days: plan.days.map(_cloneDay).toList(),
    stats: PlanStats(
      totalDays: plan.stats.totalDays,
      totalExercises: plan.stats.totalExercises,
      estDurationMin: plan.stats.estDurationMin,
      timesUsed: plan.stats.timesUsed,
    ),
  );
}

WorkoutDay _cloneDay(WorkoutDay day) {
  return WorkoutDay(
    id: day.id,
    dayNumber: day.dayNumber,
    name: day.name,
    exercises: day.exercises.map(_cloneExercise).toList(),
  );
}

PlanExercise _cloneExercise(PlanExercise exercise) {
  return PlanExercise(
    exerciseId: exercise.exerciseId,
    name: exercise.name,
    muscleGroup: exercise.muscleGroup,
    sets: exercise.sets,
    reps: exercise.reps,
    order: exercise.order,
  );
}

MyPlans? getActiveMockPlan() {
  for (final plan in myMockPlans) {
    if (plan.isActive) return plan;
  }
  return null;
}

WorkoutDay? getWorkoutDayById(String dayId) {
  for (final plan in myMockPlans) {
    for (final day in plan.days) {
      if (day.id == dayId) return day;
    }
  }
  return null;
}

void setActiveMockPlan(String? planId) {
  for (var i = 0; i < myMockPlans.length; i++) {
    final current = myMockPlans[i];
    myMockPlans[i] = MyPlans(
      id: current.id,
      userId: current.userId,
      name: current.name,
      description: current.description,
      isActive: current.id == planId,
      createdAt: current.createdAt,
      days: current.days,
      stats: current.stats,
    );
  }
}

final List<Exercise> mockExercises = [
  // ── Chest ──
  Exercise(
    id: 'ex-001',
    name: 'Barbell Bench Press',
    muscleGroup: MuscleGroup.chest,
    secondaryMuscles: ['shoulders', 'arms'],
    equipment: Equipment.barbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-002',
    name: 'Incline Dumbbell Press',
    muscleGroup: MuscleGroup.chest,
    secondaryMuscles: ['shoulders', 'arms'],
    equipment: Equipment.dumbbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-003',
    name: 'Cable Fly',
    muscleGroup: MuscleGroup.chest,
    secondaryMuscles: ['shoulders'],
    equipment: Equipment.cable,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-004',
    name: 'Chest Dip',
    muscleGroup: MuscleGroup.chest,
    secondaryMuscles: ['arms', 'shoulders'],
    equipment: Equipment.bodyweight,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-005',
    name: 'Machine Chest Press',
    muscleGroup: MuscleGroup.chest,
    secondaryMuscles: ['shoulders', 'arms'],
    equipment: Equipment.machine,
    createdAt: DateTime(2026, 1, 1),
  ),

  // ── Back ──
  Exercise(
    id: 'ex-006',
    name: 'Deadlift',
    muscleGroup: MuscleGroup.back,
    secondaryMuscles: ['legs', 'arms'],
    equipment: Equipment.barbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-007',
    name: 'Pull-Up',
    muscleGroup: MuscleGroup.back,
    secondaryMuscles: ['arms', 'shoulders'],
    equipment: Equipment.bodyweight,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-008',
    name: 'Barbell Row',
    muscleGroup: MuscleGroup.back,
    secondaryMuscles: ['arms'],
    equipment: Equipment.barbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-009',
    name: 'Lat Pulldown',
    muscleGroup: MuscleGroup.back,
    secondaryMuscles: ['arms', 'shoulders'],
    equipment: Equipment.cable,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-010',
    name: 'Cable Row',
    muscleGroup: MuscleGroup.back,
    secondaryMuscles: ['arms'],
    equipment: Equipment.cable,
    createdAt: DateTime(2026, 1, 1),
  ),

  // ── Shoulders ──
  Exercise(
    id: 'ex-011',
    name: 'Overhead Press',
    muscleGroup: MuscleGroup.shoulders,
    secondaryMuscles: ['arms'],
    equipment: Equipment.barbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-012',
    name: 'Lateral Raise',
    muscleGroup: MuscleGroup.shoulders,
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-013',
    name: 'Rear Delt Fly',
    muscleGroup: MuscleGroup.shoulders,
    secondaryMuscles: ['back'],
    equipment: Equipment.dumbbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-014',
    name: 'Arnold Press',
    muscleGroup: MuscleGroup.shoulders,
    secondaryMuscles: ['arms'],
    equipment: Equipment.dumbbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-015',
    name: 'Face Pull',
    muscleGroup: MuscleGroup.shoulders,
    secondaryMuscles: ['back'],
    equipment: Equipment.cable,
    createdAt: DateTime(2026, 1, 1),
  ),

  // ── Legs ──
  Exercise(
    id: 'ex-016',
    name: 'Barbell Squat',
    muscleGroup: MuscleGroup.legs,
    secondaryMuscles: ['core'],
    equipment: Equipment.barbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-017',
    name: 'Romanian Deadlift',
    muscleGroup: MuscleGroup.legs,
    secondaryMuscles: ['back', 'core'],
    equipment: Equipment.barbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-018',
    name: 'Leg Press',
    muscleGroup: MuscleGroup.legs,
    secondaryMuscles: [],
    equipment: Equipment.machine,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-019',
    name: 'Bulgarian Split Squat',
    muscleGroup: MuscleGroup.legs,
    secondaryMuscles: ['core'],
    equipment: Equipment.dumbbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-020',
    name: 'Calf Raise',
    muscleGroup: MuscleGroup.legs,
    secondaryMuscles: [],
    equipment: Equipment.machine,
    createdAt: DateTime(2026, 1, 1),
  ),

  // ── Arms ──
  Exercise(
    id: 'ex-021',
    name: 'Barbell Curl',
    muscleGroup: MuscleGroup.arms,
    secondaryMuscles: ['shoulders'],
    equipment: Equipment.barbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-022',
    name: 'Hammer Curl',
    muscleGroup: MuscleGroup.arms,
    secondaryMuscles: [],
    equipment: Equipment.dumbbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-023',
    name: 'Tricep Pushdown',
    muscleGroup: MuscleGroup.arms,
    secondaryMuscles: [],
    equipment: Equipment.cable,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-024',
    name: 'Skull Crusher',
    muscleGroup: MuscleGroup.arms,
    secondaryMuscles: ['shoulders'],
    equipment: Equipment.barbell,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-025',
    name: 'Tricep Dip',
    muscleGroup: MuscleGroup.arms,
    secondaryMuscles: ['chest', 'shoulders'],
    equipment: Equipment.bodyweight,
    createdAt: DateTime(2026, 1, 1),
  ),

  // ── Core ──
  Exercise(
    id: 'ex-026',
    name: 'Plank',
    muscleGroup: MuscleGroup.core,
    secondaryMuscles: ['shoulders'],
    equipment: Equipment.bodyweight,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-027',
    name: 'Hanging Leg Raise',
    muscleGroup: MuscleGroup.core,
    secondaryMuscles: ['arms'],
    equipment: Equipment.bodyweight,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-028',
    name: 'Cable Crunch',
    muscleGroup: MuscleGroup.core,
    secondaryMuscles: [],
    equipment: Equipment.cable,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-029',
    name: 'Ab Wheel Rollout',
    muscleGroup: MuscleGroup.core,
    secondaryMuscles: ['shoulders', 'back'],
    equipment: Equipment.bodyweight,
    createdAt: DateTime(2026, 1, 1),
  ),
  Exercise(
    id: 'ex-030',
    name: 'Russian Twist',
    muscleGroup: MuscleGroup.core,
    secondaryMuscles: [],
    equipment: Equipment.bodyweight,
    createdAt: DateTime(2026, 1, 1),
  ),
];
