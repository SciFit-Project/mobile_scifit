import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';

class OnboardHeader extends StatelessWidget {
  const OnboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withAlpha(50),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(
            Icons.favorite,
            color: AppTheme.primaryLight,
            size: 28,
          ),
        ),
        const Gap(16),

        Text(
          'Setup Your Information',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -1,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(16),
        Text(
          'Let\'s set up your profile to personalize your \n health journey',
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
