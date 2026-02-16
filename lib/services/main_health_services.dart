import 'package:health/health.dart';

class MainHealthServices {
  final Health health = Health();

  static const types = [
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.STEPS,
  ];

  Future<bool> reqPermission() async {
    return await health.requestAuthorization(types);
  }

  Future<void> init() async {
    await health.configure();
  }
}
