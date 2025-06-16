
import 'package:carpooling/views/auth/login_page.dart';
import 'package:carpooling/views/profile/profile/edit_profile.dart';
import 'package:carpooling/views/settings/account%20settings/change_password.dart';
import 'package:carpooling/views/settings/account%20settings/emergency_contact.dart';
import 'package:carpooling/views/settings/account%20settings/linked_account.dart';
import 'package:flutter/material.dart';
import 'package:carpooling/services/auth_service.dart'; 


class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Lowered the horizontal padding of the entire SingleChildScrollView
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10), // Small space after title

              // Account Management Options - List without the surrounding Container
              _buildSettingsListItem(
                context,
                icon: Icons.edit,
                text: 'Edit Personal Information',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfilePage(),
                    ),
                  );
                },
              ),
              // Increased space between list items using SizedBox and Divider
              const SizedBox(height: 8), // Added space
              const Divider(height: 0, thickness: 1, indent: 16, endIndent: 16),
              const SizedBox(height: 8), // Added space

              _buildSettingsListItem(
                context,
                icon: Icons.lock_reset,
                text: 'Change Password',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChangePasswordPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8), // Added space
              const Divider(height: 0, thickness: 1, indent: 16, endIndent: 16),
              const SizedBox(height: 8), // Added space

              _buildSettingsListItem(
                context,
                icon: Icons.people,
                text: 'Emergency Contacts',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EmergencyContactsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8), // Added space
              const Divider(height: 0, thickness: 1, indent: 16, endIndent: 16),
              const SizedBox(height: 8), // Added space

              _buildSettingsListItem(
                context,
                icon: Icons.link,
                text: 'Linked Accounts',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LinkedAccountsPage(),
                    ),
                  );
                },
              ),
              // --- End of Account Management Section ---

              const SizedBox(height: 32),

              // Sign Out Section
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    final confirmSignOut = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Sign Out', style: TextStyle(color: Colors.red),),
                          ),
                        ],
                      ),
                    );

                    if (confirmSignOut == true) {
                      await AuthService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out', style: TextStyle(fontFamily: 'Poppins'),),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build each list item consistently
  Widget _buildSettingsListItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        // Retained horizontal padding for text/icon alignment within the item
        // Vertical padding within the item itself is kept for internal spacing.
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}