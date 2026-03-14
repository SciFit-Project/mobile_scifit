import 'package:flutter/material.dart';
import 'package:mobile_scifit/core/theme/app_theme.dart';

class AddSetButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddSetButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppTheme.primaryLight),
            SizedBox(width: 8),
            Text(
              'Add Set',
              style: TextStyle(
                color: AppTheme.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
