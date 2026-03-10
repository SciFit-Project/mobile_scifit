import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scifit/core/network/dio_client.dart';
import 'package:mobile_scifit/core/storage/secure_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;
  final Dio _dio = DioClient().instance;

  User? get currentUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<void> signInWithGoogle() async {
    const redirectTo = kIsWeb
        ? null
        : 'io.supabase.fitnessapp://login-callback/';
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<Response?> signInWithEmail(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      if (data is Map &&
          data['success'] == true &&
          data['accessToken'] != null) {
        await SecureStorageService.saveToken(data['accessToken']);
        return response;
      }

      throw Exception("Login failed: Invalid credentials or missing token");
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> signUpWithEmail(
    String fullname,
    String email,
    String password,
  ) async {
    final response = await _dio.post(
      '/api/auth/signup',
      data: {'fullname': fullname, 'email': email, 'password': password},
    );
    return response;
  }
}
