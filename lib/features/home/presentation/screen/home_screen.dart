import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scifit/features/home/data/home_service.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/sleep_dashboard.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/step_card.dart';
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
    setState(() {
      _mobileSteps = dataStep['mobile'] ?? 0;
      _wearableSteps = dataStep['wearable'] ?? 0;

      _weekSleepData = sleepData;

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TopNavbar(),
                const SizedBox(height: 32),

                const SizedBox(height: 16),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : StepCard(
                        mobileSteps: _mobileSteps,
                        wearableSteps: _wearableSteps,
                      ),

                const Gap(16),
                _isLoading
                    ? const SizedBox.shrink()
                    : SleepDashboard(weeklySleep: _weekSleepData),

                const SizedBox(height: 24),

                Text(
                  "Last updated: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFF888888),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
