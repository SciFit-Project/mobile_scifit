import 'package:dio/dio.dart';
import 'package:mobile_scifit/core/network/dio_client.dart';

class ProfileRepository {
  final Dio _dio = DioClient().instance;

  Future<Response?> updateProfile(Map<String, dynamic> data) async {
    return _dio.put('/api/users/profile', data: data);
  }
}
