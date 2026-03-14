import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StepCard extends StatelessWidget {
  final int mobileSteps;
  final int wearableSteps;
  final int goalSteps;
  final VoidCallback? onTap;

  const StepCard({
    super.key,
    required this.mobileSteps,
    required this.wearableSteps,
    this.goalSteps = 10000,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasWearable = wearableSteps > 0;

    final int displaySteps = hasWearable ? (wearableSteps) : mobileSteps;

    final double progress = (displaySteps / goalSteps).clamp(0.0, 1.0);
    final int percentage = (progress * 100).toInt();
    final NumberFormat nf = NumberFormat('#,##0');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_walk,
                        color: Color(0xFF4285F4),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'DAILY STEPS',
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFF4285F4),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nf.format(displaySteps),
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                  Text(
                    'Goal: ${nf.format(goalSteps)} steps',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "view history",
                    style: GoogleFonts.spaceGrotesk(
                      color: hasWearable ? Colors.blue : Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: AlignmentGeometry.center,
              children: [
                SizedBox(
                  width: 85,
                  height: 85,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 9,
                    backgroundColor: const Color(0xFFF0F7FF),
                    color: const Color(0xFF4285F4),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color(0xFF4285F4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
