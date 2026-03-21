import 'package:mobile_scifit/features/plans/data/mock_plan.dart';
import 'package:mobile_scifit/features/plans/data/plan_store.dart';
import 'package:mobile_scifit/features/plans/types/plans_type.dart';

class PlansRepository {
  Future<List<MyPlans>> fetchPlans() async {
    // TODO(scifit-api): Replace with GET /api/plans.
    return currentPlans;
  }

  Future<MyPlans?> fetchPlanById(String id) async {
    // TODO(scifit-api): Replace with GET /api/plans/:id.
    return findPlanById(id);
  }

  Future<MyPlans?> fetchActivePlan() async {
    // TODO(scifit-api): Replace with GET /api/plans and filter active plan.
    return findActivePlan();
  }

  Future<WorkoutDay?> fetchWorkoutDayById(String dayId) async {
    // TODO(scifit-api): Replace with plan detail lookup from API.
    return findWorkoutDayById(dayId);
  }

  Future<MyPlans> createPlan({
    required String name,
    required String description,
    required List<WorkoutDay> days,
  }) async {
    // TODO(scifit-api): Replace with POST /api/plans.
    final newPlan = MyPlans(
      id: 'plan-${DateTime.now().microsecondsSinceEpoch}',
      userId: 'current-user',
      name: name,
      description: description,
      isActive: currentPlans.isEmpty,
      createdAt: DateTime.now(),
      days: days,
      stats: _buildStats(days),
    );

    planStore.value = [...currentPlans, newPlan];
    return newPlan;
  }

  Future<MyPlans> savePlan(MyPlans plan) async {
    // TODO(scifit-api): Replace with PUT /api/plans/:id.
    planStore.value = [
      for (final current in currentPlans)
        if (current.id == plan.id) plan else current,
    ];
    return plan;
  }

  Future<void> deletePlan(String id) async {
    // TODO(scifit-api): Replace with DELETE /api/plans/:id.
    final target = findPlanById(id);
    if (target == null) return;

    final remainingPlans = currentPlans.where((plan) => plan.id != id).toList();
    if (target.isActive && remainingPlans.isNotEmpty) {
      final first = remainingPlans.first;
      remainingPlans[0] = MyPlans(
        id: first.id,
        userId: first.userId,
        name: first.name,
        description: first.description,
        isActive: true,
        createdAt: first.createdAt,
        days: first.days,
        stats: first.stats,
      );
    }

    planStore.value = remainingPlans;
  }

  Future<void> activatePlan(String? planId) async {
    // TODO(scifit-api): Replace with PUT /api/plans/:id/activate.
    planStore.value = [
      for (final current in currentPlans)
        MyPlans(
          id: current.id,
          userId: current.userId,
          name: current.name,
          description: current.description,
          isActive: current.id == planId,
          createdAt: current.createdAt,
          days: current.days,
          stats: current.stats,
        ),
    ];
  }

  Future<MyPlans?> saveDay({
    required String planId,
    required String dayId,
    required String dayName,
    required List<PlanExercise> exercises,
  }) async {
    // TODO(scifit-api): Replace with PUT /api/plans/:id plus day payload.
    final plan = findPlanById(planId);
    if (plan == null) return null;

    final updatedDays = [
      for (final day in plan.days)
        if (day.id == dayId)
          WorkoutDay(
            id: day.id,
            dayNumber: day.dayNumber,
            name: dayName,
            exercises: exercises,
          )
        else
          day,
    ];

    final updatedPlan = MyPlans(
      id: plan.id,
      userId: plan.userId,
      name: plan.name,
      description: plan.description,
      isActive: plan.isActive,
      createdAt: plan.createdAt,
      days: updatedDays,
      stats: _buildStats(updatedDays, previousTimesUsed: plan.stats.timesUsed),
    );

    await savePlan(updatedPlan);
    return updatedPlan;
  }

  List<Exercise> getExercises() {
    // TODO(scifit-api): Replace with exercises endpoint when ready.
    return mockExercises;
  }

  PlanStats _buildStats(List<WorkoutDay> days, {int previousTimesUsed = 0}) {
    final totalExercises = days.fold<int>(
      0,
      (sum, day) => sum + day.exercises.length,
    );

    final estDurationMin = days.isEmpty
        ? 0
        : (days
                    .map((day) => day.exercises.length * 8)
                    .reduce((a, b) => a + b) ~/
                days.length)
            .clamp(20, 120);

    return PlanStats(
      totalDays: days.length,
      totalExercises: totalExercises,
      estDurationMin: estDurationMin,
      timesUsed: previousTimesUsed,
    );
  }
}
