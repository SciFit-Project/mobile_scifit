import 'package:dio/dio.dart';
import 'package:mobile_scifit/core/network/dio_client.dart';
import 'package:mobile_scifit/features/profile/data/mock_profile.dart';
import 'package:mobile_scifit/features/progress/data/body_weight_store.dart';
import 'package:mobile_scifit/features/progress/data/mock_progress_data.dart';

class BodyWeightRepository {
  BodyWeightRepository({Dio? dio}) : _dio = dio ?? DioClient().instance;

  final Dio _dio;

  Future<List<BodyWeightPoint>> fetchLogs() async {
    final response = await _dio.get('/api/health/summary');
    final data = response.data['data'] as Map<String, dynamic>? ?? const {};
    final items = (data['bodyWeightLogs'] as List? ?? const []);

    final logs = items.map<BodyWeightPoint>((item) {
      return BodyWeightPoint(
        date: DateTime.tryParse((item['date'] ?? '').toString()) ?? DateTime.now(),
        weight: ((item['bodyWeightKg'] ?? item['body_weight_kg'] ?? 0) as num)
            .toDouble(),
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    setBodyWeightLogs(logs);
    final latest = latestBodyWeightPoint();
    if (latest != null) {
      mockProfileStore.patch((current) => current.copyWith(weightKg: latest.weight));
    }
    return logs;
  }

  Future<void> saveLog({
    required DateTime date,
    required double weightKg,
  }) async {
    await _dio.post(
      '/api/health/manual',
      data: {
        'date': _formatDate(date),
        'bodyWeightKg': weightKg,
      },
    );

    await fetchLogs();
  }

  Future<void> deleteLog(DateTime date) async {
    await _dio.delete('/api/health/manual/${_formatDate(date)}');
    await fetchLogs();
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
