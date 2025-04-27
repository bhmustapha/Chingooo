import 'package:flutter/material.dart';

// reusable grey container
class GreyContainer extends StatelessWidget {
  final Widget child;
  const GreyContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 236, 236, 236),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}
