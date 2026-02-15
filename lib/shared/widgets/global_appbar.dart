import 'package:flutter/material.dart';

class GlobalAppbar extends StatelessWidget {
  final String title;
  const GlobalAppbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      spacing: 64,
      children: [
        Icon(Icons.arrow_back_ios),
        Text(title, style: TextStyle(fontSize: 14)),
        Icon(Icons.edit),
      ],
    );
  }
}
