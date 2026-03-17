import 'package:dio/dio.dart';
import 'package:mobile_scifit/core/network/dio_client.dart';
import 'package:mobile_scifit/features/onboarding/data/onboard_data_model.dart';

class OnboardingRepository {
  final Dio _dio = DioClient().instance;

  Future<Response?> submitProfile(OnboardingData data) async {
    return _dio.put('/api/users/profile', data: data.toJson());
  }
}
