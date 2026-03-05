import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class AuthRepository {
  final _supabase = Supabase.instance.client;

  final Dio _dio = Dio(
    BaseOptions(baseUrl: dotenv.env['BACKEND_URL'] ?? ''),
  );

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
    // print(response);
    return response;
  }
}
