import 'package:flutter/material.dart';
import 'package:mobile_scifit/features/Sleep/widget/sleep_card.dart';
import 'package:mobile_scifit/features/Sleep/widget/sleep_summary_card.dart';
import 'package:mobile_scifit/services/sleep_services.dart';
import 'package:mobile_scifit/shared/widgets/global_appbar.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<SleepPage> {
  final SleepServices _services = SleepServices();
  Map<String, dynamic>? _sleepData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
    setState(() => _isLoading = true);

    try {
      final data = await _services.getSleep();
      setState(() {
        _sleepData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading sleep data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const GlobalAppbar(title: "SLEEP ANALYSIS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSleepData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sleepData == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bedtime_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No sleep data available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadSleepData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Load Sleep Data'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSleepData,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  // Summary Card
                  SleepSummaryCard(weekData: _sleepData!),

                  // Daily Cards
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Daily Sleep',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ...List.generate(8, (index) {
                    return SleepCard(
                      sleepData: _sleepData!['day_$index'],
                      dayIndex: index,
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
