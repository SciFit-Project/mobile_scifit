import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scifit/core/storage/secure_storage_service.dart';
import 'package:mobile_scifit/features/auth/presentation/screens/register_screen.dart';
import 'package:mobile_scifit/features/home/presentation/screen/home_screen.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/steps/steps_history_screen.dart';
import 'package:mobile_scifit/features/onboarding/presentation/screen/onboardingscreen.dart';
import 'package:mobile_scifit/features/plans/presentation/screens/add_exercises_screen.dart';
import 'package:mobile_scifit/features/plans/presentation/screens/create_plan_screen.dart';
import 'package:mobile_scifit/features/plans/presentation/screens/day_builder_screen.dart';
import 'package:mobile_scifit/features/plans/presentation/screens/plans_screen.dart';
import 'package:mobile_scifit/features/plans/presentation/screens/plan_details_screen.dart';
import 'package:mobile_scifit/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:mobile_scifit/features/profile/presentation/screens/goal_setting_screen.dart';
import 'package:mobile_scifit/features/profile/presentation/screens/profile_page.dart';
import 'package:mobile_scifit/features/profile/presentation/screens/settings_screen.dart';
import 'package:mobile_scifit/features/progress/presentation/screens/progress_page.dart';
import 'package:mobile_scifit/features/shared/widgets/main_navbar.dart';
import 'package:mobile_scifit/features/workout/presentation/screens/exercise_log_screen.dart';
import 'package:mobile_scifit/features/workout/presentation/screens/workout_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static final _supabase = Supabase.instance.client;

  static final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(_supabase.auth.onAuthStateChange),

    redirect: (context, state) async {
      final session = _supabase.auth.currentSession;
      final customToken = await SecureStorageService.getToken();
      final isLoggedIn = (session != null) || (customToken != null);

      final loc = state.matchedLocation;

      final publicPages = ['/login', '/register', '/splash', '/onboarding'];
      final isPublicPage = publicPages.contains(loc);

      if (loc == '/splash') return null;

      if (!isLoggedIn && !isPublicPage) return '/login';

      if (isLoggedIn && (loc == '/login' || loc == '/register')) {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/plans/new',
        builder: (context, state) => const CreatePlan(),
      ),
      GoRoute(
        path: '/plans/:id/days/:dayId/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final dayId = state.pathParameters['dayId']!;
          return DayBuilderScreen(id: id, dayId: dayId);
        },
        routes: [
          GoRoute(
            path: 'exercises/browse',
            builder: (context, state) => AddExercisesScreen(
              planId: state.pathParameters['id']!,
              dayId: state.pathParameters['dayId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/goals',
        builder: (context, state) => const GoalSettingScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(body: child, bottomNavigationBar: const MainNavbar());
        },
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const Onboardingscreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),

          GoRoute(
            path: '/plans',
            builder: (context, state) => const MyPlansScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PlanDetailsScreen(id: id);
                },
              ),
            ],
          ),

          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressPage(),
          ),

          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),

          GoRoute(
            path: '/steps-history',
            builder: (context, state) => const StepsHistoryScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/workout-plan/:dayId',
        builder: (c, s) => WorkoutPlanScreen(dayId: s.pathParameters['dayId']!),
        routes: [
          GoRoute(
            path: 'exercise/:exerciseId',
            builder: (c, s) => ExerciseLogScreen(
              exerciseId: s.pathParameters['exerciseId']!,
              sessionId: s.uri.queryParameters['sessionId']!,
            ),
          ),
        ],
      ),
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
