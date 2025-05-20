import 'package:carpooling/components/settings_header.dart';
import 'package:flutter/material.dart';

class PrivacySecuritySettingsPage extends StatelessWidget {
  const PrivacySecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Header(title: 'Privacy Settings'),
            Expanded(
              child: Center(
                child: Text('Edit your Privacy details here.',
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


