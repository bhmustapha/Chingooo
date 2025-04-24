import 'package:flutter/material.dart';

class GreyContainer extends StatelessWidget {
  final Widget child;
  const GreyContainer({Key? key, required this.child}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 224, 224, 224),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: child,
              ),
    );
  }
}