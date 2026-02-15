import 'package:flutter/material.dart';

class StepCard extends StatelessWidget {
  final Map<String, int> steps;
  final String totalSleep;
  const StepCard({super.key, required this.steps, required this.totalSleep});

  String formatWithComma(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              ...steps.entries.map((e) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      formatWithComma(e.value),
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                );
              }),

              SizedBox(height: 12),

              Text(
                "TOTAL SLEEP $totalSleep",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
