import 'package:flutter/material.dart';
import 'package:mobile_scifit/shared/widgets/global_appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: GlobalAppbar(title: "OVERVIEW")),
      body: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: const Center(
          child: Text(
            'Hello World',
            textDirection: TextDirection.ltr,
            style: TextStyle(fontSize: 32, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
