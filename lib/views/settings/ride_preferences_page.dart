import 'package:flutter/material.dart';
import '../../components/settings_header.dart';

class RidePreferencesPage extends StatelessWidget {
  const RidePreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Header(title: 'Ride Preferences'),
            Expanded(
              child: Center(
                child: Text(
                  'Set your ride preferences here.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
