import 'package:flutter/material.dart';

// reusable setting section name
class SettingSectionName extends StatelessWidget {
  final String name;
  const SettingSectionName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
