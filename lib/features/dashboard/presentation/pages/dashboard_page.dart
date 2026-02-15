import 'package:flutter/material.dart';
import 'package:mobile_scifit/features/dashboard/presentation/widgets/step_cards.dart';
import 'package:mobile_scifit/services/health_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final HealthService _service = HealthService();
  Map<String,int> steps ={};
  String totalSleep = "";

  Future<void> loadSteps() async {

    bool granted = await _service.requestPermissions();
    if (!granted) return;

    Map<String, int> result = await _service.getTodaySteps();
    String res = await _service.getTodaySleep();
    setState(() {
      steps = result;
      totalSleep = res;
    });
  }

  Future<void> setupHealth() async {
    await _service.init();
    await loadSteps();
  }

  @override
  void initState() {
    super.initState();
    setupHealth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.desktop_mac_outlined),
            SizedBox(width: 10),
            Text("Dashboard"),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        color: Colors.blue,
        child: Column(
          children: [
            StepCard(steps: steps, totalSleep: totalSleep,),
            ElevatedButton(onPressed: setupHealth, child: Text("Sync")),
          ],
        ),
      ),
    );
  }
}
