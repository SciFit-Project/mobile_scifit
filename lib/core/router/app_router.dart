import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scifit/core/storage/secure_storage_service.dart';
import 'package:mobile_scifit/features/auth/presentation/screens/home_screen.dart';
import 'package:mobile_scifit/features/onboarding/presentation/screen/onboardingscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static final _supabase = Supabase.instance.client;

  static final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(_supabase.auth.onAuthStateChange),
    redirect: (context, state) async {
      final session = _supabase.auth.currentSession;

      final customToken = await SecureStorageService.getToken();
      final isLoggedIn = (session != null) || (customToken != null);

      final isSplash = state.matchedLocation == '/splash';
      final isLogin = state.matchedLocation == '/login';

      if (isSplash) return null;
      if (!isLoggedIn && !isLogin) return '/login';
      if (isLoggedIn && isLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const Onboardingscreen()),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final dynamic _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
