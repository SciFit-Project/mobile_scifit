import 'package:flutter/material.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';
import 'package:mobile_scifit/features/plans/presentation/widgets/create/add_day.dart';
import 'package:mobile_scifit/features/plans/presentation/widgets/create/plan_details.dart';
import 'package:mobile_scifit/features/plans/presentation/widgets/create/workout_day_card.dart';
import 'package:mobile_scifit/features/plans/types/plans_type.dart';

class CreatePlan extends StatefulWidget {
  const CreatePlan({super.key});

  @override
  State<CreatePlan> createState() => _CreatePlanState();
}

class _CreatePlanState extends State<CreatePlan> {
  final _planName = TextEditingController();
  final _planDescription = TextEditingController();

  void submit() {
    final name = _planName.text;
    final description = _planDescription.text;
    debugPrint("Name: $name");
    debugPrint("Description: $description");

    _dayWorkout.clear();
  }

  final List<WorkoutPlan> _dayWorkout = [];
  void addDay() {
    debugPrint("Added");
    setState(() {
      _dayWorkout.add(
        WorkoutPlan(workoutTitle: "Untitled Plan", totalExercise: 0),
      );
    });
    debugPrint(_dayWorkout.toString());
  }

  @override
  void dispose() {
    _planName.dispose();
    _planDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        title: const Text(
          "Create Plans",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PlanDetails(
                      planName: _planName,
                      planDescription: _planDescription,
                    ),
                    const SizedBox(height: 16),
                    AddDay(onTap: addDay),

                    ..._dayWorkout.asMap().entries.map((e) {
                      final index = e.key;
                      final w = e.value;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: WorkoutDayCard(
                          idx: index,
                          workoutTitle: w.workoutTitle,
                          totalExercise: w.totalExercise,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(onPressed: submit, child: const Text("Submit")),
        ),
      ),
    );
  }
}
