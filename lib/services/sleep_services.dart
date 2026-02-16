import 'package:health/health.dart';
import 'package:mobile_scifit/services/main_health_services.dart';

class SleepServices extends MainHealthServices {
  Future<Map<String, dynamic>> getSleep() async {
    final now = DateTime.now();

    final queryStart = DateTime(now.year, now.month, now.day - 10, 0, 0);
    final queryEnd = now;

    try {
      List<HealthDataPoint> allSessions = await health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_SESSION],
        startTime: queryStart,
        endTime: queryEnd,
      );


      Map<String, dynamic> sleepByDay = {};

      for (var session in allSessions) {
        DateTime sleepDate = _getSleepDate(session);
        int daysAgo = _calculateDaysAgo(now, sleepDate);

        if (daysAgo >= 0 && daysAgo <= 7) {
          String key = 'day_$daysAgo';

          double duration = (session.value as NumericHealthValue).numericValue
              .toDouble();

          if (!sleepByDay.containsKey(key)) {
            sleepByDay[key] = await _processSession(session);
          } else {
            double existing = sleepByDay[key]['totalSleep'] ?? 0;

            if (duration > existing) {
              sleepByDay[key] = await _processSession(session);
            } else {
            }
          }
        }
      }

      for (int i = 0; i <= 7; i++) {
        if (!sleepByDay.containsKey('day_$i')) {
          sleepByDay['day_$i'] = null;
        }
      }

      return sleepByDay;
    } catch (e) {
      Map<String, dynamic> emptyData = {};
      for (int i = 0; i <= 7; i++) {
        emptyData['day_$i'] = null;
      }
      return emptyData;
    }
  }

  DateTime _getSleepDate(HealthDataPoint session) {
    return DateTime(
      session.dateTo.year,
      session.dateTo.month,
      session.dateTo.day,
    );
  }

  int _calculateDaysAgo(DateTime now, DateTime sleepDate) {
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(sleepDate.year, sleepDate.month, sleepDate.day);
    return today.difference(target).inDays;
  }

  Future<Map<String, dynamic>> _processSession(HealthDataPoint session) async {
    double reportedSleep = (session.value as NumericHealthValue).numericValue
        .toDouble();

    List<HealthDataPoint> stages = await health.getHealthDataFromTypes(
      types: [
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_REM,
        HealthDataType.SLEEP_AWAKE,
      ],
      startTime: session.dateFrom,
      endTime: session.dateTo,
    );

    double light = _calculateDuration(
      stages.where((s) => s.type == HealthDataType.SLEEP_LIGHT).toList(),
    );
    double deep = _calculateDuration(
      stages.where((s) => s.type == HealthDataType.SLEEP_DEEP).toList(),
    );
    double rem = _calculateDuration(
      stages.where((s) => s.type == HealthDataType.SLEEP_REM).toList(),
    );
    double awake = _calculateDuration(
      stages.where((s) => s.type == HealthDataType.SLEEP_AWAKE).toList(),
    );

    double stagesTotal = light + deep + rem;
    double totalSleep = reportedSleep;

    // ตรวจสอบและแก้ไข overlap
    if (stagesTotal > reportedSleep && reportedSleep > 0) {

      double ratio = reportedSleep / stagesTotal;
      light = light * ratio;
      deep = deep * ratio;
      rem = rem * ratio;
      awake = awake * ratio;

    } else if (stagesTotal > 0) {
      totalSleep = stagesTotal;
    }

    return {
      'totalSleep': totalSleep,
      'timeInBed': session.dateTo
          .difference(session.dateFrom)
          .inMinutes
          .toDouble(),
      'light': light,
      'deep': deep,
      'rem': rem,
      'awake': awake,
      'start': session.dateFrom,
      'end': session.dateTo,
    };
  }

  double _calculateDuration(List<HealthDataPoint> data) {
    double totalMinutes = 0;
    for (var point in data) {
      totalMinutes += point.dateTo.difference(point.dateFrom).inMinutes;
    }
    return totalMinutes;
  }

  String _getPercentage(double minutes, double total) {
    if (total == 0) return "0";
    return ((minutes / total) * 100).toStringAsFixed(0);
  }

  String _formatDuration(double minutes) {
    int h = minutes ~/ 60;
    int m = (minutes % 60).round();
    if (h > 0 && m > 0) return '${h}hr ${m}min';
    if (h > 0) return '${h}hr';
    return '${m}min';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
