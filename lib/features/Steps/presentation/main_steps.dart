import 'package:flutter/material.dart';
import 'package:mobile_scifit/features/Steps/widget/goal_card.dart';
import 'package:mobile_scifit/shared/widgets/global_appbar.dart';

class StepPage extends StatefulWidget {
  const StepPage({super.key});

  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<StepPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: GlobalAppbar(title: "ACTIVITY")),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          width: double.infinity,
          child: GoalCard(),
        ),
      ),
    );
  }
}