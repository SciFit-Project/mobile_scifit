import 'package:dio/dio.dart';
import 'package:mobile_scifit/core/router/app_router.dart';
import 'package:mobile_scifit/core/config/app_config.dart';
import 'package:mobile_scifit/core/storage/secure_storage_service.dart';
import 'package:mobile_scifit/features/profile/data/mock_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DioClient {
  late Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.backendUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          final statusCode = e.response?.statusCode;
          final hasAuthHeader =
              e.requestOptions.headers['Authorization'] != null;
          final path = e.requestOptions.path;
          final isAuthFormRequest =
              path.contains('/api/auth/login') || path.contains('/api/auth/signup');

          if (statusCode == 401 && hasAuthHeader && !isAuthFormRequest) {
            SecureStorageService.deleteToken();
            Supabase.instance.client.auth.signOut();
            mockProfileStore.reset();
            AppRouter.router.go('/login');
          }
          return handler.next(e);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Dio get instance => _dio;
}
