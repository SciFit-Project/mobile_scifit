import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';

class Goal extends StatefulWidget {
  final Function(bool isValid, String? plan) onValidChanged;

  const Goal({super.key, required this.onValidChanged});

  @override
  State<Goal> createState() => _GoalState();
}

class _GoalState extends State<Goal> {
  String? _selectedPlan;

  void _checkValidation() {
    widget.onValidChanged(_selectedPlan != null, _selectedPlan);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            "Workout Plan",
            "Choose a goal that fits your lifestyle.",
          ),
          const SizedBox(height: 16),
          _buildPlanOption("Cutting", "Lose fat while maintaining muscle."),
          _buildPlanOption(
            "Maintenance",
            "Keep your current weight and stay fit.",
          ),
          _buildPlanOption("Bulking", "Gain muscle mass and strength."),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- Widget Helpers ---

  Widget _buildHeader(String title, String subTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subTitle,
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.mutedLight,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // สำหรับ Workout Plan
  Widget _buildPlanOption(String title, String desc) {
    bool isSelected = _selectedPlan == title;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedPlan = title;
        _checkValidation();
      }),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight.withAlpha(10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryLight
                : AppTheme.mutedLight.withAlpha(20),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? AppTheme.primaryLight : null,
              ),
            ),
            Text(
              desc,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: AppTheme.mutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
