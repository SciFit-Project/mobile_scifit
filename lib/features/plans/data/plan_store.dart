import 'package:flutter/foundation.dart';
import 'package:mobile_scifit/features/plans/data/mock_plan.dart';
import 'package:mobile_scifit/features/plans/types/plans_type.dart';

final ValueNotifier<List<MyPlans>> planStore = ValueNotifier<List<MyPlans>>(
  buildMockPlans(),
);
final ValueNotifier<Map<String, int>> planDayIndexStore =
    ValueNotifier<Map<String, int>>({});

List<MyPlans> get currentPlans => planStore.value;

MyPlans? findPlanById(String id) {
  for (final plan in currentPlans) {
    if (plan.id == id) return plan;
  }
  return null;
}

MyPlans? findActivePlan() {
  for (final plan in currentPlans) {
    if (plan.isActive) return plan;
  }
  return null;
}

WorkoutDay? findWorkoutDayById(String dayId) {
  for (final plan in currentPlans) {
    for (final day in plan.days) {
      if (day.id == dayId) return day;
    }
  }
  return null;
}

int getCurrentPlanDayIndex(String planId, int totalDays) {
  if (totalDays <= 0) return 0;
  final currentIndex = planDayIndexStore.value[planId] ?? 0;
  if (currentIndex < 0) return 0;
  if (currentIndex >= totalDays) return totalDays - 1;
  return currentIndex;
}

WorkoutDay? getCurrentWorkoutDay(MyPlans? plan) {
  if (plan == null || plan.days.isEmpty) return null;
  final index = getCurrentPlanDayIndex(plan.id, plan.days.length);
  return plan.days[index];
}

void advancePlanDay(String planId, int totalDays) {
  if (totalDays <= 0) return;
  final currentIndex = getCurrentPlanDayIndex(planId, totalDays);
  final nextIndex = (currentIndex + 1) % totalDays;
  planDayIndexStore.value = {
    ...planDayIndexStore.value,
    planId: nextIndex,
  };
}

void resetPlanDay(String planId) {
  planDayIndexStore.value = {
    ...planDayIndexStore.value,
    planId: 0,
  };
}
