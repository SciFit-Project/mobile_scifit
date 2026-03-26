import 'package:flutter/foundation.dart';
import 'package:mobile_scifit/features/progress/data/mock_progress_data.dart';

final ValueNotifier<List<BodyWeightPoint>> bodyWeightStore =
    ValueNotifier<List<BodyWeightPoint>>([]);

List<BodyWeightPoint> get currentBodyWeightLogs => bodyWeightStore.value;

void setBodyWeightLogs(List<BodyWeightPoint> logs) {
  final updated = [...logs]..sort((a, b) => a.date.compareTo(b.date));
  bodyWeightStore.value = updated;
}

void seedBodyWeightIfEmpty(double weightKg) {
  if (weightKg <= 0 || bodyWeightStore.value.isNotEmpty) return;
  final now = DateTime.now();
  bodyWeightStore.value = [
    BodyWeightPoint(
      date: DateTime(now.year, now.month, now.day),
      weight: weightKg,
    ),
  ];
}

void upsertBodyWeightLog({
  required DateTime date,
  required double weightKg,
}) {
  final normalized = DateTime(date.year, date.month, date.day);
  final updated = [...bodyWeightStore.value];
  final index = updated.indexWhere(
    (entry) =>
        entry.date.year == normalized.year &&
        entry.date.month == normalized.month &&
        entry.date.day == normalized.day,
  );

  final nextPoint = BodyWeightPoint(date: normalized, weight: weightKg);
  if (index >= 0) {
    updated[index] = nextPoint;
  } else {
    updated.add(nextPoint);
  }

  updated.sort((a, b) => a.date.compareTo(b.date));
  bodyWeightStore.value = updated;
}

void deleteBodyWeightLog(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  bodyWeightStore.value = bodyWeightStore.value.where((entry) {
    return !(entry.date.year == normalized.year &&
        entry.date.month == normalized.month &&
        entry.date.day == normalized.day);
  }).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}

BodyWeightPoint? latestBodyWeightPoint() {
  if (bodyWeightStore.value.isEmpty) return null;
  final points = [...bodyWeightStore.value]..sort((a, b) => b.date.compareTo(a.date));
  return points.first;
}
