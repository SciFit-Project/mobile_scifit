import 'package:flutter/material.dart';
import 'package:mobile_scifit/features/Home/presentation/home.dart';
import 'package:mobile_scifit/features/Sleep/presentation/main_sleep.dart';
import 'package:mobile_scifit/features/Steps/presentation/main_steps.dart';
import 'package:mobile_scifit/services/main_health_services.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  final MainHealthServices _services = MainHealthServices();
  int _currentIndex = 0;
  final List<Widget> _screens = const [HomePage(), StepPage(), SleepPage()];

  Future<void> loadSteps() async {
    bool granted = await _services.reqPermission();
    if (!granted) {
      return;
    }
  }

  Future<void> setupHealth() async {
    await _services.init();
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
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: 'Steps',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bed), label: 'Sleep'),
        ],
      ),
    );
  }
}
