import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/plans/data/mock_plan.dart';
import 'package:mobile_scifit/features/plans/types/plans_type.dart';

class PlanDetailsScreen extends StatefulWidget {
  final String id;
  const PlanDetailsScreen({super.key, required this.id});

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final editPlan = myMockPlans.where((p) => p.id == widget.id).first;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          editPlan.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _planDetailsCard(editPlan),
              const SizedBox(height: 20),
              const Text(
                "Workout Days",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ...editPlan.days.map(
                (day) => Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: (_workoutDays(day, widget.id)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _workoutDays(WorkoutDay day, String planId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Day ${day.dayNumber.toString()}: ${day.name}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    context.push('/plans/$planId/days/${day.id}/edit'),
                label: const Text('Edit', style: TextStyle(color: Colors.blue)),
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ), // The icon widget
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  day.exercises.map((e) => e.name).join(" • "),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _planDetailsCard(MyPlans plans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: const Border(
              left: BorderSide(color: AppTheme.primaryLight, width: 4),
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plans.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Badge(
                    label: const Text(
                      "ACTIVE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    backgroundColor: const Color(0xFF16A34A).withAlpha(80),
                  ),
                ],
              ),
              Text(
                plans.description,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withAlpha(80),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.fitness_center_sharp,
                    size: 16,
                    color: Colors.black.withAlpha(80),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    ('${plans.stats.totalExercises} exercises'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withAlpha(80),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: Colors.black.withAlpha(80),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    ('${plans.stats.totalDays} days'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withAlpha(80),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.save),
                        label: Text(
                          'Save',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: _primaryButtonStyle(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.power_settings_new),
                        label: Text(
                          'Deactivate',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: _secondaryButtonStyle(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  ButtonStyle _secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.black87,
      side: const BorderSide(color: Colors.black26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
