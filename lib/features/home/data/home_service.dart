import 'package:health/health.dart';

class HomeService {
  final health = Health();

  Future<Map<String, int>> getTodaySteps() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      List<HealthDataPoint> data = await health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.STEPS],
      );

      List<HealthDataPoint> wearablePoints = [];
      List<HealthDataPoint> mobilePoints = [];

      for (var p in data) {
        String source = p.sourceName.toLowerCase();

        if (source.contains("xiaomi") || source.contains("wearable")) {
          wearablePoints.add(p);
        } else {
          mobilePoints.add(p);
        }
      }

      int calculateSteps(List<HealthDataPoint> points) {
        if (points.isEmpty) return 0;

        int totalSum = 0;
        int maxSummaryValue = 0;
        bool hasSummary = false;

        for (var p in points) {
          int val = (p.value as NumericHealthValue).numericValue.toInt();

          int durationMs =
              p.dateTo.millisecondsSinceEpoch -
              p.dateFrom.millisecondsSinceEpoch;

          if (durationMs > 3600000) {
            hasSummary = true;
            if (val > maxSummaryValue) maxSummaryValue = val;
          } else {
            totalSum += val;
          }
        }
        return hasSummary ? maxSummaryValue : totalSum;
      }

      int wearableTotal = calculateSteps(wearablePoints);
      int mobileTotal = calculateSteps(mobilePoints);

      return {'mobile': mobileTotal, 'wearable': wearableTotal};
    } catch (e) {
      return {'mobile': 0, 'wearable': 0};
    }
  }

  Future<Map<int, Map<String, int>>> getWeeklySteps() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - 6);

    try {
      List<HealthDataPoint> data = await health.getHealthDataFromTypes(
        startTime: start,
        endTime: now,
        types: [HealthDataType.STEPS],
      );

      Map<int, Map<String, int>> weekly = {
        for (var i = 0; i < 7; i++) i: {'mobile': 0, 'wearable': 0},
      };

      DateTime today = DateTime(now.year, now.month, now.day);

      for (var p in data) {
        int val = (p.value as NumericHealthValue).numericValue.toInt();

        DateTime day = DateTime(
          p.dateFrom.year,
          p.dateFrom.month,
          p.dateFrom.day,
        );

        int daysAgo = today.difference(day).inDays;

        if (daysAgo >= 0 && daysAgo < 7) {
          String source = p.sourceName.toLowerCase();

          if (source.contains("xiaomi") || source.contains("wearable")) {
            weekly[daysAgo]!['wearable'] =
                (weekly[daysAgo]!['wearable'] ?? 0) + val;
          } else {
            weekly[daysAgo]!['mobile'] =
                (weekly[daysAgo]!['mobile'] ?? 0) + val;
          }
        }
      }

      return weekly;
    } catch (e) {
      return {
        for (var i = 0; i < 7; i++) i: {'mobile': 0, 'wearable': 0},
      };
    }
  }

  Future<int> getLatestHeartRate() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(hours: 12));

    try {
      List<HealthDataPoint> data = await health.getHealthDataFromTypes(
        startTime: start,
        endTime: now,
        types: [HealthDataType.HEART_RATE],
      );

      if (data.isEmpty) return 0;

      // เรียงตามเวลาวัดจริง
      data.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));

      final latest = data.first;

      final bpm = (latest.value as NumericHealthValue).numericValue.toInt();

      return bpm;
    } catch (e) {
      print("Error reading heart rate: $e");
      return 0;
    }
  }

  Future<Map<String, int>> getTodayCalories() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    int mobileCalories = 0;
    int wearableCalories = 0;

    try {
      List<HealthDataPoint> data = await health.getHealthDataFromTypes(
        startTime: start,
        endTime: now,
        types: [
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.TOTAL_CALORIES_BURNED,
        ],
      );

      if (data.isNotEmpty) {
        for (var d in data) {
          final value = (d.value as NumericHealthValue).numericValue.toInt();

          if (d.sourceName.toLowerCase().contains("watch") ||
              d.sourceName.toLowerCase().contains("band")) {
            wearableCalories += value;
          } else {
            mobileCalories += value;
          }
        }
      }

      if (mobileCalories == 0 && wearableCalories == 0) {
        final steps = await getTodaySteps();

        final wearableSteps = steps['wearable'] ?? 0;
        final mobileSteps = steps['mobile'] ?? 0;

        wearableCalories = (wearableSteps * 0.04).round();
        mobileCalories = (mobileSteps * 0.04).round();
      }

      return {'mobile': mobileCalories, 'wearable': wearableCalories};
    } catch (e) {
      print("Error getting calories: $e");
      return {'mobile': 0, 'wearable': 0};
    }
  }

  Future<Map<int, double>> getWeeklySleep() async {
    final now = DateTime.now();
    final queryStart = DateTime(now.year, now.month, now.day - 6);

    try {
      List<HealthDataPoint> sessions = await health.getHealthDataFromTypes(
        startTime: queryStart,
        endTime: now,
        types: [HealthDataType.SLEEP_SESSION],
      );

      Map<int, double> weeklySleep = {for (var i = 0; i < 7; i++) i: 0.0};

      for (var session in sessions) {
        DateTime wakeUpDate = DateTime(
          session.dateTo.year,
          session.dateTo.month,
          session.dateTo.day,
        );
        DateTime today = DateTime(now.year, now.month, now.day);
        int daysAgo = today.difference(wakeUpDate).inDays;

        if (daysAgo >= 0 && daysAgo < 7) {
          double sleepMinutes = (session.value as NumericHealthValue)
              .numericValue
              .toDouble();
          double sleepHours = sleepMinutes / 60.0;
          if (sleepHours > 14) sleepHours = 14;

          if (sleepHours > (weeklySleep[daysAgo] ?? 0)) {
            weeklySleep[daysAgo] = sleepHours;
          }
        }
      }

      return weeklySleep;
    } catch (e) {
      return {for (var i = 0; i < 7; i++) i: 0.0};
    }
  }
}
