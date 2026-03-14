import 'package:flutter/material.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/home/data/home_service.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scifit/features/home/presentation/widgets/steps/steps_bar_chart.dart';

class StepsHistoryScreen extends StatefulWidget {
  const StepsHistoryScreen({super.key});

  @override
  State<StepsHistoryScreen> createState() => _StepsHistoryScreenState();
}

class _StepsHistoryScreenState extends State<StepsHistoryScreen> {
  final HomeService _service = HomeService();

  Map<int, Map<String, int>> _weeklySteps = {};
  bool _loading = true;

  final int goalSteps = 10000;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getWeeklySteps();

    setState(() {
      _weeklySteps = data;
      _loading = false;
    });
  }

  String getDate(int daysAgo) {
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    return DateFormat('d MMM yy').format(date);
  }

  int getDisplaySteps(int day) {
    final mobile = _weeklySteps[day]?['mobile'] ?? 0;
    final wearable = _weeklySteps[day]?['wearable'] ?? 0;

    return wearable > 0 ? wearable : mobile;
  }

  int get todaySteps => getDisplaySteps(0);

  String getWeekday(int daysAgo) {
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    return DateFormat('EEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0');

    double progress = (todaySteps / goalSteps).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        title: const Text(
          "Steps",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight(800)),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Progress",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nf.format(todaySteps),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),

                        /// PROGRESS BAR
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.black12,
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF6C63FF),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "${(progress * 100).toInt()}% of $goalSteps goal",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// CHART CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "LAST 7 DAYS HISTORY",
                          style: TextStyle(
                            fontWeight: FontWeight(900),
                            color: Colors.grey,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        StepsBarChart(data: _weeklySteps),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// HISTORY LIST
                  const Text(
                    "History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...List.generate(7, (i) {
                    final steps = getDisplaySteps(i);
                    final wearable = _weeklySteps[i]?['wearable'] ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getWeekday(i),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                getDate(i),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          Text(
                            wearable > 0 ? "Wearable" : "Mobile",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Text(
                            nf.format(steps),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
