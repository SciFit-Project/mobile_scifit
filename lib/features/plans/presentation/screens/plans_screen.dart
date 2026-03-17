import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/plans/data/mock_plan.dart';
import 'package:mobile_scifit/features/plans/presentation/widgets/myplan/active_card.dart';

class MyPlansScreen extends StatefulWidget {
  const MyPlansScreen({super.key});

  @override
  State<MyPlansScreen> createState() => _MyPlansScreenState();
}

class _MyPlansScreenState extends State<MyPlansScreen> {
  @override
  Widget build(BuildContext context) {
    final activePlan = myMockPlans.where((p) => p.isActive).firstOrNull;
    final otherPlans = myMockPlans.where((p) => !p.isActive).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _planHeader(),

                const SizedBox(height: 16),
                if (activePlan != null)
                  ActiveCard(plans: activePlan)
                else
                  const Text('No active plan'),

                const SizedBox(height: 16),
                const Text('My Other Plans'),

                const SizedBox(height: 16),
                ...otherPlans.map(
                  (plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _otherPlan(
                      plan.id,
                      plan.name,
                      '${plan.stats.totalDays} days · ${plan.stats.estDurationMin} min/session',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _planHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "My Plans",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withAlpha(30),
            borderRadius: BorderRadius.circular(50),
          ),
          child: IconButton(
            icon: const Icon(Icons.add_circle_outline_outlined),
            iconSize: 32,
            color: Colors.blue,
            onPressed: () {
              context.push('/plans/new');
            },
          ),
        ),
      ],
    );
  }

  Widget _otherPlan(String planId, String planTitle, String planDesc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(planDesc, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => {},
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight.withAlpha(30),
                ),
                child: const Text("ACTIVATE"),
              ),
              IconButton(
                onPressed: () => {context.push('/plans/$planId')},
                icon: const Icon(Icons.info),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
