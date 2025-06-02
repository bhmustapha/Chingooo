import 'package:carpooling/views/auth/auth_service.dart';
import 'package:flutter/material.dart';
import '../../components/settings_header.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Header(title: 'Account Settings'),
            Expanded(
              child: Center(
                child: TextButton(
                      onPressed: () async {
                        try {
                          await AuthService.signOut();
                          Navigator.pushReplacementNamed(context, '/auth');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logout failed: $e')),
                          );
                        }
                      },
                      child: Text('logout'),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
