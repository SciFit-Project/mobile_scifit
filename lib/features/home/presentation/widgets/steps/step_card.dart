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
    final hasWearable = wearableSteps > 0;
    final displaySteps = hasWearable ? wearableSteps : mobileSteps;
    final progress = (displaySteps / goalSteps).clamp(0.0, 1.0);
    final percentage = (progress * 100).round();
    final remainingSteps = (goalSteps - displaySteps).clamp(0, goalSteps);
    final nf = NumberFormat('#,##0');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF8FBFF), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFDCE9FF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3579E5).withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.directions_walk_rounded,
                    color: Color(0xFF3579E5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY STEPS',
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFF3579E5),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasWearable
                            ? 'Tracking from wearable'
                            : 'Tracking from phone',
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF5FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '$percentage%',
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF3579E5),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nf.format(displaySteps),
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 40,
                          height: 0.95,
                          letterSpacing: -1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'of ${nf.format(goalSteps)} step goal',
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 92,
                  height: 92,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 92,
                        height: 92,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: const Color(0xFFE8F0FF),
                          color: const Color(0xFF3579E5),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            percentage == 0 ? '--' : '$percentage',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              color: const Color(0xFF3579E5),
                              height: 1,
                            ),
                          ),
                          Text(
                            '%',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: const Color(0xFF3579E5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              height: 12,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5B9BFF), Color(0xFF3579E5)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricPill(
                  label: hasWearable ? 'Wearable' : 'Phone',
                  value: nf.format(displaySteps),
                  highlighted: true,
                ),
                if (hasWearable)
                  _MetricPill(
                    label: 'Phone backup',
                    value: nf.format(mobileSteps),
                  ),
                _MetricPill(
                  label: 'Remaining',
                  value: nf.format(remainingSteps),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  progress >= 1
                      ? 'Goal completed today'
                      : '$remainingSteps steps to go',
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  'View history',
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFF3579E5),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_outward_rounded,
                  size: 15,
                  color: Color(0xFF3579E5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;

  const _MetricPill({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFEDF4FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? const Color(0xFFCFE0FF) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
