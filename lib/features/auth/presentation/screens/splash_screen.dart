import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scifit/core/storage/secure_storage_service.dart';
import 'package:mobile_scifit/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final customToken = await SecureStorageService.getToken();
    if (!mounted) return;
    if (customToken != null && customToken.isNotEmpty) {
      try {
        final destination = await _authRepository.restoreSession();
        if (!mounted) return;
        context.go(
          destination == PostAuthDestination.onboarding
              ? '/onboarding'
              : '/home',
        );
      } catch (_) {
        await _authRepository.signOut();
        if (!mounted) return;
        context.go('/login');
      }
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      try {
        final destination = await _authRepository.syncGoogleSession();
        if (!mounted) return;
        context.go(
          destination == PostAuthDestination.onboarding
              ? '/onboarding'
              : '/home',
        );
        return;
      } catch (_) {
        await _authRepository.signOut();
      }
    }

    if (!mounted) return;
    context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FF47),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 40,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'FITNESS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
