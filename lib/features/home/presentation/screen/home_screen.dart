import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scifit/features/home/data/home_service.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/heart_rate_card.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/sleep_dashboard.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/stat_info.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/steps/step_card.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/workout_card.dart';
import 'package:mobile_scifit/features/plans/data/plan_store.dart';
import 'package:mobile_scifit/features/plans/types/plans_type.dart';
import 'package:mobile_scifit/features/profile/data/mock_profile.dart';
import 'package:mobile_scifit/features/shared/widgets/top_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _healthService = HomeService();

  int _mobileSteps = 0;
  int _wearableSteps = 0;

  int _heartRate = 0;

  Map<int, double> _weekSleepData = {for (int i = 0; i < 7; i++) i: 0.0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    final dataStep = await _healthService.getTodaySteps();
    final sleepData = await _healthService.getWeeklySleep();
    final heartRate = await _healthService.getAverageHeartRate();

    setState(() {
      _mobileSteps = dataStep['mobile'] ?? 0;
      _wearableSteps = dataStep['wearable'] ?? 0;

      _heartRate = heartRate;

      _weekSleepData = sleepData;

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TopNavbar(),
                const SizedBox(height: 16),

                ValueListenableBuilder<MockUserProfile>(
                  valueListenable: mockProfileStore,
                  builder: (context, profile, _) {
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2,
                      children: [
                        StatInfoCard(
                          label: 'CURRENT WEIGHT',
                          value: profile.weightKg.toStringAsFixed(1),
                          unit: 'kg',
                          icon: Icons.line_axis,
                        ),
                        StatInfoCard(
                          label: 'CURRENT GOAL',
                          value: profile.goalType.label.toUpperCase(),
                          unit: '',
                          icon: Icons.local_fire_department,
                        ),
                        StatInfoCard(
                          label: 'BMR',
                          value: profile.bmr.round().toString(),
                          unit: 'kcal',
                          icon: Icons.local_fire_department_outlined,
                        ),
                        StatInfoCard(
                          label: 'TDEE',
                          value: profile.tdee.round().toString(),
                          unit: 'kcal',
                          icon: Icons.line_axis,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                ValueListenableBuilder<List<MyPlans>>(
                  valueListenable: planStore,
                  builder: (context, plans, _) {
                    final activePlan = plans.where((p) => p.isActive).firstOrNull;
                    final activeDay = activePlan?.days.isNotEmpty == true
                        ? activePlan!.days.first
                        : null;

                    return WorkoutCard(
                      workoutTitle: activePlan == null || activeDay == null
                          ? 'No active workout plan'
                          : '${activePlan.name} - ${activeDay.name}',
                      totalExercise: activeDay?.exercises.length ?? 0,
                      timeDuration: activePlan?.stats.estDurationMin ?? 0,
                      onStartWorkout: () {
                        if (activeDay == null) {
                          context.push('/plans');
                          return;
                        }
                        context.push('/workout-plan/${activeDay.id}');
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : StepCard(
                        mobileSteps: _mobileSteps,
                        wearableSteps: _wearableSteps,
                        onTap: () {
                          context.push('/steps-history');
                        },
                      ),

                const Gap(16),
                _isLoading
                    ? const SizedBox.shrink()
                    : SleepDashboard(weeklySleep: _weekSleepData),
                const Gap(16),
                SizedBox(
                  height: 140,
                  child: HeartRateCard(heartRate: _heartRate),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
