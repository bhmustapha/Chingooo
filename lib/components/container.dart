import 'package:flutter/material.dart';

// reusable grey container
class GreyContainer extends StatelessWidget {
  final Widget child;
  const GreyContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current theme's colorScheme or colors for background
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.surfaceContainerHighest; 
   

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}
