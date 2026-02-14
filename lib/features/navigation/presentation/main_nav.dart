import 'package:flutter/material.dart';
import 'package:mobile_scifit/features/Home/presentation/home.dart';
import 'package:mobile_scifit/features/Sleep/presentation/main_sleep.dart';
import 'package:mobile_scifit/features/Steps/presentation/main_steps.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [HomePage(), StepPage(), SleepPage()];
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
