import 'package:health/health.dart';
import 'package:mobile_scifit/services/main_health_services.dart';

class StepServices extends MainHealthServices {
  // GET STEPS FOR LAST 7 DAYS
  Future<List<DailyStepData>> getStep() async {
    List<DailyStepData> dailySteps = [];

    final now = DateTime.now();

    for (int day = 0; day <= 7; day++) {
      final targetDate = now.subtract(Duration(days: day));

      final startTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        0,
        0,
      );

      final endTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        23,
        59,
        59,
      );

      // fetch steps
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startTime,
        endTime: endTime,
      );

      Map<String, int> stepsBySource = {};

      for (var dataPoint in healthData) {
        String source = mapSourceName(dataPoint.sourceName);
        int steps = (dataPoint.value as NumericHealthValue).numericValue
            .toInt();

        stepsBySource[source] = (stepsBySource[source] ?? 0) + steps;
      }

      // seperate devices
      int healthConnectSteps = stepsBySource["Health Connect"] ?? 0;
      int wearableSteps = stepsBySource["Wearable"] ?? 0;

      dailySteps.add(
        DailyStepData(
          date: targetDate,
          healthConnectSteps: healthConnectSteps,
          wearableSteps: wearableSteps,
        ),
      );
    }

    return dailySteps;
  }

  String mapSourceName(String source) {
    if (source.contains("sec")) {
      return "Health Connect";
    }
    if (source.contains("xiaomi")) {
      return "Wearable";
    }
    return source;
  }

  String formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class DailyStepData {
  final DateTime date;
  final int healthConnectSteps;
  final int wearableSteps;

  DailyStepData({
    required this.date,
    required this.healthConnectSteps,
    required this.wearableSteps,
  });

  int get totalSteps => healthConnectSteps + wearableSteps;
}
