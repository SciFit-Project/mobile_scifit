import 'package:flutter/material.dart';

class StepPage extends StatefulWidget {
  const StepPage({super.key});

  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<StepPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: const Center(
        child: Text(
          'Hello Steps',
          textDirection: TextDirection.ltr,
          style: TextStyle(fontSize: 32, color: Colors.black87),
        ),
      ),
    );
  }
}
