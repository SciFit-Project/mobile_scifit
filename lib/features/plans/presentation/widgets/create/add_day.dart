import 'package:flutter/material.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';

class AddDay extends StatelessWidget {
  final VoidCallback onTap;
  const AddDay({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Workout Days",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),),
            Row(
              children: [
                Text(
                  'Add Day',
                  style: TextStyle(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.add, color: AppTheme.primaryLight),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
