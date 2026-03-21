import 'package:flutter/foundation.dart';
import 'package:mobile_scifit/features/plans/data/mock_plan.dart';
import 'package:mobile_scifit/features/plans/types/plans_type.dart';

final ValueNotifier<List<MyPlans>> planStore = ValueNotifier<List<MyPlans>>(
  buildMockPlans(),
);

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
