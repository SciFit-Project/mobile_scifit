import 'dart:ffi';

import 'package:health/health.dart';

class HealthService {
  final Health health = Health();

  // Data Type
  static const Sleeptypes = [
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_AWAKE,
  ];
  static const types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
  ];

  Future<void> init() async {
    return await health.configure();
  }

  Future<bool> requestPermissions() async {
    return await health.requestAuthorization(types);
  }

  //GET STEPS
  Future<Map<String, int>> getTodaySteps() async {
    Map<String, int> stepsBySource = {};

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    List<HealthDataPoint> data = await health.getHealthDataFromTypes(
      startTime: midnight,
      endTime: now,
      types: [HealthDataType.STEPS],
    );

    for (var e in data) {
      String source = mapSourceName(e.sourceName);
      int steps = (e.value as NumericHealthValue).numericValue.toInt();
      stepsBySource[source] = (stepsBySource[source] ?? 0) + steps;
    }

    return stepsBySource;
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

  //GET SLEEP
  Future<String> getTodaySleep() async {
    final now = DateTime.now();
    final midnightToday = DateTime(now.year, now.month, now.day);
    final yesterday = midnightToday.subtract(Duration(days: 1));

    List<HealthDataPoint> data = await health.getHealthDataFromTypes(
      startTime: yesterday,
      endTime: now,
      types: Sleeptypes,
    );

    final totalSlept = calculateActualSleepMinutes(data);

    return totalSlept;
  }

  String calculateActualSleepMinutes(List<HealthDataPoint> data) {
    int totalMinutes = 0;

    for (var p in data) {
      int minutes = p.dateTo.difference(p.dateFrom).inMinutes;

      totalMinutes += minutes;
    }

    return formatSleep(totalMinutes);
  }

  String formatSleep(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return "${hours} hr ${minutes} min";
  }

  Future<Map<String, dynamic>> getSleepDataForNight(DateTime date) async {
    try {
      // กำหนดช่วงเวลา: จาก 20:00 ของวันที่เลือก ถึง 14:00 ของวันถัดไป
      final startTime = DateTime(date.year, date.month, date.day, 20, 0);
      final endTime = DateTime(date.year, date.month, date.day + 1, 14, 0);

      // ดึงข้อมูล
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        types: [
          HealthDataType.SLEEP_SESSION,
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_AWAKE,
          HealthDataType.SLEEP_IN_BED,
        ],
        startTime: startTime,
        endTime: endTime,
      );

      // แยกประเภทข้อมูล
      Duration totalAsleep = Duration.zero;
      Duration totalAwake = Duration.zero;
      Duration totalInBed = Duration.zero;

      DateTime? bedTime;
      DateTime? wakeTime;

      for (var point in healthData) {
        final duration = point.dateFrom.difference(point.dateTo).abs();

        switch (point.type) {
          case HealthDataType.SLEEP_ASLEEP:
            totalAsleep += duration;
            break;
          case HealthDataType.SLEEP_AWAKE:
            totalAwake += duration;
            break;
          case HealthDataType.SLEEP_IN_BED:
            totalInBed += duration;
            // หาเวลาเข้านอนและตื่น
            if (bedTime == null || point.dateFrom.isBefore(bedTime)) {
              bedTime = point.dateFrom;
            }
            if (wakeTime == null || point.dateTo.isAfter(wakeTime)) {
              wakeTime = point.dateTo;
            }
            break;
          case HealthDataType.SLEEP_SESSION:
            // Session รวมทั้งหมด
            if (bedTime == null || point.dateFrom.isBefore(bedTime)) {
              bedTime = point.dateFrom;
            }
            if (wakeTime == null || point.dateTo.isAfter(wakeTime)) {
              wakeTime = point.dateTo;
            }
            break;
          default:
            break;
        }
      }

      // คำนวณ Sleep Quality (%)
      double sleepQuality = 0;
      if (totalInBed.inMinutes > 0) {
        sleepQuality = (totalAsleep.inMinutes / totalInBed.inMinutes) * 100;
      }

      return {
        'bedTime': bedTime,
        'wakeTime': wakeTime,
        'totalSleep': totalAsleep,
        'totalAsleep': totalAsleep,
        'totalAwake': totalAwake,
        'totalInBed': totalInBed,
        'sleepQuality': sleepQuality.toStringAsFixed(1),
        'rawData': healthData,
      };
    } catch (e) {
      print('Error fetching sleep data: $e');
      return {};
    }
  }

  // แปลง Duration เป็น String อ่านง่าย
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
