import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scifit/features/home/data/home_service.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/heart_rate_card.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/sleep_dashboard.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/stat_info.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/steps/step_card.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/workout_card.dart';
import 'package:mobile_scifit/features/shared/widgets/main_navbar.dart';
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
    final heartRate = await _healthService.getLatestHeartRate();

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

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2,
                  children: const [
                    StatInfoCard(
                      label: 'CURRENT WEIGHT',
                      value: '75.5',
                      unit: 'kg',
                      icon: Icons.line_axis,
                    ),
                    StatInfoCard(
                      label: 'CURRENT GOAL',
                      value: 'CUTTING',
                      unit: '',
                      icon: Icons.local_fire_department,
                    ),
                    StatInfoCard(
                      label: 'BMR',
                      value: '1,820',
                      unit: 'kcal',
                      icon: Icons.local_fire_department_outlined,
                    ),
                    StatInfoCard(
                      label: 'TDEE',
                      value: '2,750',
                      unit: 'kcal',
                      icon: Icons.line_axis,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const WorkoutCard(
                  workoutTitle: 'PPL Program - Push Day A',
                  totalExercise: 6,
                  timeDuration: 45,
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
      bottomNavigationBar: const MainNavbar(currentIndex: 0),
    );
  }
}
