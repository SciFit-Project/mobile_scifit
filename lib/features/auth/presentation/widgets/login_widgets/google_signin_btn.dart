import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/auth_repository.dart';

class GoogleSigninBtn extends StatefulWidget {
  const GoogleSigninBtn({super.key});

  @override
  State<GoogleSigninBtn> createState() => _GoogleSigninBtnState();
}

class _GoogleSigninBtnState extends State<GoogleSigninBtn> {
  final _authRepo = AuthRepository();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await _authRepo.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sign in failed'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _isLoading ? null : _handleGoogleSignIn,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 60,
            decoration: BoxDecoration(
              color: _isLoading
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isLoading
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFF333333),
              ),
            ),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFE8FF47),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.g_mobiledata_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                      const Gap(12),
                      Text(
                        'Continue with Google',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const Gap(16),
        Text(
          'By continuing, you agree to our Terms & Privacy Policy',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            color: const Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}
