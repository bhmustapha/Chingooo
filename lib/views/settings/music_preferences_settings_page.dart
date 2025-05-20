import 'package:flutter/material.dart';
import '../../components/settings_header.dart';

class MusicPreferencesSettingsPage extends StatelessWidget {
  const MusicPreferencesSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Header(title: 'Music Settings'),
            Expanded(
              child: Center(
                child: Text('Edit your Music details here.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}