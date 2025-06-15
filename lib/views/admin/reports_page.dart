import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Reports')),
      body: const Center(
        child: Text('Reported issues will be reviewed here.'),
      ),
    );
  }
}
