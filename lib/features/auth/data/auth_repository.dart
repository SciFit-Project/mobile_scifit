import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scifit/core/network/dio_client.dart';
import 'package:mobile_scifit/core/storage/secure_storage_service.dart';
import 'package:mobile_scifit/features/profile/data/mock_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum PostAuthDestination { home, onboarding }

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
    try {
      await _dio.post('/api/auth/logout');
    } catch (_) {
    }

    await SecureStorageService.deleteToken();
    await _supabase.auth.signOut();
    mockProfileStore.reset();
  }

  Future<PostAuthDestination> signInWithEmail(
    String email,
    String password,
  ) async {
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
        return await restoreSession();
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

  Future<PostAuthDestination> syncGoogleSession() async {
    final session = _supabase.auth.currentSession;
    final user = _supabase.auth.currentUser;

    if (session == null || user == null) {
      throw Exception('No active Google session found');
    }

    final fullName =
        user.userMetadata?['full_name'] ??
        user.userMetadata?['name'] ??
        user.userMetadata?['user_name'];
    final avatarUrl =
        user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'];

    final response = await _dio.post(
      '/api/auth/google-sync',
      data: {
        if (fullName != null) 'fullname': fullName,
        if (avatarUrl != null) 'avatar': avatarUrl,
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      ),
    );

    final data = response.data;
    if (data is Map &&
        data['success'] == true &&
        data['accessToken'] != null) {
      await SecureStorageService.saveToken(data['accessToken']);
      return await restoreSession();
    }

    throw Exception('Google sync failed: missing access token');
  }

  Future<PostAuthDestination> restoreSession() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No active session found');
    }

    final response = await _dio.get('/api/auth/me');
    final data = response.data;

    if (response.statusCode != 200 || data is! Map || data['success'] != true) {
      throw Exception('Failed to load user profile');
    }

    final user = data['user'];
    if (user is! Map) {
      throw Exception('Invalid user profile response');
    }

    _hydrateProfile(user);

    return user['onboardingCompleted'] == true
        ? PostAuthDestination.home
        : PostAuthDestination.onboarding;
  }

  void _hydrateProfile(Map user) {
    final email = (user['email'] as String?) ?? defaultMockUserProfile().email;
    final fullName =
        (user['fullName'] as String?)?.trim().isNotEmpty == true
        ? (user['fullName'] as String).trim()
        : email.split('@').first;
    final weightKg =
        (user['weightKg'] as num?)?.toDouble() ??
        defaultMockUserProfile().weightKg;
    final heightCm =
        (user['heightCm'] as num?)?.toDouble() ??
        defaultMockUserProfile().heightCm;
    final age = (user['age'] as num?)?.toInt() ?? defaultMockUserProfile().age;
    final now = DateTime.now();

    mockProfileStore.update(
      defaultMockUserProfile().copyWith(
        name: fullName,
        email: email,
        avatarUrl: user['avatarUrl'] as String?,
        clearAvatarUrl: user['avatarUrl'] == null,
        weightKg: weightKg,
        heightCm: heightCm,
        gender: _mapGender(user['gender'] as String?),
        goalType: _mapGoal(user['goal'] as String?),
        activityLevel: _mapActivityLevel(user['experienceLevel'] as String?),
        dateOfBirth: DateTime(now.year - age, now.month, now.day),
      ),
    );
  }

  ProfileGender _mapGender(String? gender) {
    switch (gender?.toUpperCase()) {
      case 'FEMALE':
        return ProfileGender.female;
      case 'MALE':
        return ProfileGender.male;
      default:
        return ProfileGender.other;
    }
  }

  ProfileGoalType _mapGoal(String? goal) {
    switch (goal?.toUpperCase()) {
      case 'BULKING':
        return ProfileGoalType.muscleGain;
      case 'CUTTING':
        return ProfileGoalType.fatLoss;
      case 'RECOMP':
      default:
        return ProfileGoalType.maintain;
    }
  }

  ProfileActivityLevel _mapActivityLevel(String? experienceLevel) {
    switch (experienceLevel?.toUpperCase()) {
      case 'BEGINNER':
        return ProfileActivityLevel.lightlyActive;
      case 'INTERMEDIATE':
        return ProfileActivityLevel.active;
      case 'ADVANCED':
        return ProfileActivityLevel.veryActive;
      default:
        return ProfileActivityLevel.sedentary;
    }
  }
}
