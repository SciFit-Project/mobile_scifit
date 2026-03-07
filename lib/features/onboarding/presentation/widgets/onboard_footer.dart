import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';

class OnboardFooter extends StatelessWidget {
  const OnboardFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, color: AppTheme.primaryLight, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Your health data is encrypted and secure. We never share your personal information with third parties.",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.mutedLight, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}
