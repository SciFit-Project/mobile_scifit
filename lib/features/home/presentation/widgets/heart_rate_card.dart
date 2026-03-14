import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeartRateCard extends StatelessWidget {
  final int heartRate;

  const HeartRateCard({super.key, required this.heartRate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 20),
              const SizedBox(width: 6),
              Text(
                "HEART RATE",
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const Spacer(),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                heartRate == 0 ? "--" : "$heartRate",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "bpm",
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            heartRate == 0 ? "No data" : "Resting avg today",
            style: GoogleFonts.spaceGrotesk(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
