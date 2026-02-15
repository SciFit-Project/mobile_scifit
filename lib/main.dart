import 'package:flutter/material.dart';
import 'package:mobile_scifit/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:mobile_scifit/features/dashboard/presentation/pages/sleep_dash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SleepDataTest(),
    );
  }
}
