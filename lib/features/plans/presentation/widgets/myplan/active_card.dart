import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/plans/data/plans_repository.dart';
import 'package:mobile_scifit/features/plans/types/plans_type.dart';

class ActiveCard extends StatelessWidget {
  final MyPlans plans;
  const ActiveCard({super.key, required this.plans});

  @override
  Widget build(BuildContext context) {
    final plansRepository = PlansRepository();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ACTIVE PLAN"),
        const SizedBox(height: 12),
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
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => context.push('/plans/${plans.id}'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit),
                            const SizedBox(width: 5),
                            Text(
                              "Edit",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          await plansRepository.deactivatePlan(plans.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${plans.name} deactivated'),
                            ),
                          );
                          context.go('/plans');
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.power_settings_new),
                            const SizedBox(width: 5),
                            Text(
                              "Deactivate",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
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
}
