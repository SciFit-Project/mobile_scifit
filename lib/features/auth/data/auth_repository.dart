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
    final response = await _dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
    if (response.data['success'] && response.data['token'] != "") {
      await SecureStorageService.saveToken(response.data['token']);
      return response;
    }
    return response;
  }

  Future<Response?> signUpWithEmail(String fullname ,String email, String password) async {
    final response = await _dio.post(
      '/api/auth/signup',
      data: {'email': email, 'password': password},
    );
    return response;
  }
}
