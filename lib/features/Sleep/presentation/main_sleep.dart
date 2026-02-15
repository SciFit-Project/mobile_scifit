import 'package:flutter/material.dart';
import 'package:mobile_scifit/shared/widgets/global_appbar.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<SleepPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: GlobalAppbar(title: "SLEEP ANALYSIS")),
      body: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: const Center(
          child: Text(
            'Hello SLEEP',
            textDirection: TextDirection.ltr,
            style: TextStyle(fontSize: 32, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
