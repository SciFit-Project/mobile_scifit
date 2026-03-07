import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 28,
          ),
        ),
        Text(
          'Let\'s SciFit\n make your fit.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            // color: Colors.white,
            height: 1.1,
            letterSpacing: -1,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Log workouts, monitor progress,\nand crush your goals.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            color: const Color(0xFF888888),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
