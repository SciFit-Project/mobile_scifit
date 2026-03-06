import 'package:flutter/material.dart';

class Permisson extends StatefulWidget {
  const Permisson({super.key});

  @override
  State<Permisson> createState() => _PermissonState();
}

class _PermissonState extends State<Permisson> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Permisson")
      ],
    );
  }
}