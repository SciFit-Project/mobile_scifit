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

      int wearableSteps = 0;
      List<HealthDataPoint> mobilePoints = [];

      for (var p in data) {
        String source = p.sourceName.toLowerCase();
        if (source.contains("xiaomi") || source.contains("wearable")) {
          wearableSteps += (p.value as NumericHealthValue).numericValue.toInt();
        } else {
          mobilePoints.add(p);
        }
      }

      int mobileSteps = 0;
      bool hasSamsungData = mobilePoints.any(
        (p) => p.sourceName.toLowerCase().contains("shealth"),
      );

      if (hasSamsungData) {
        mobileSteps = mobilePoints
            .where((p) => p.sourceName.toLowerCase().contains("shealth"))
            .fold(
              0,
              (sum, p) =>
                  sum + (p.value as NumericHealthValue).numericValue.toInt(),
            );
      } else {
        Map<String, int> uniquePoints = {};
        for (var p in mobilePoints) {
          String key =
              "${p.dateFrom.millisecondsSinceEpoch}-${p.dateTo.millisecondsSinceEpoch}";
          int val = (p.value as NumericHealthValue).numericValue.toInt();
          if (!uniquePoints.containsKey(key) || val > uniquePoints[key]!) {
            uniquePoints[key] = val;
          }
        }
        mobileSteps = uniquePoints.values.fold(0, (sum, v) => sum + v);
      }

      return {'mobile': mobileSteps, 'wearable': wearableSteps};
    } catch (e) {
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
