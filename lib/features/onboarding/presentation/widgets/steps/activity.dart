import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';

class Activity extends StatefulWidget {
  final Function(bool isValid, String? activity) onValidChanged;

  const Activity({super.key, required this.onValidChanged});
  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  String? _selectedActivity;

  void _checkValidation() {
    widget.onValidChanged(_selectedActivity != null, _selectedActivity);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Activity Level", "How active are you in a week?"),
          const SizedBox(height: 16),
          _buildActivityOption(
            "Sedentary",
            "Office job, little to no exercise",
            "BEGINNER",
          ),
          _buildActivityOption("Light Exercise", "1-2 days/week", "BEGINNER"),
          _buildActivityOption(
            "Moderate Exercise",
            "3-5 days/week",
            "INTERMEDIATE",
          ),
          _buildActivityOption(
            "Heavy Exercise",
            "6-7 days/week",
            "INTERMEDIATE",
          ),
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

  Widget _buildActivityOption(String title, String desc, String difficulty) {
    bool isSelected = _selectedActivity == title;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedActivity = title;
        _checkValidation();
      }),
      child: Container(
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }
}
