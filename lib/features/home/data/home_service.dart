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

        int val = (p.value as NumericHealthValue).numericValue.toInt();
        print("DEBUG: Source: $source | Value: $val | Time: ${p.dateFrom} - ${p.dateTo}");
        
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

      print("Final Result -> Mobile: $mobileTotal, Wearable: $wearableTotal");
      return {'mobile': mobileTotal, 'wearable': wearableTotal};
    } catch (e) {
      print("Error getting steps: $e");
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
