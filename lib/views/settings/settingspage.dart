import 'package:carpooling/components/container.dart';
import 'package:flutter/material.dart';
// all individual setting pages
import 'account_settings_page.dart';
import 'privacy_settings_page.dart';
import 'notifications_settings_page.dart';
import 'payment_settings_page.dart';
import 'ride_preferences_page.dart';
import 'music_preferences_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title + return button
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(title: 'Account'),
                    GreyContainer(
                      child: Column(
                        children: [
                          SettingsTile(
                            icon: Icons.person,
                            text: 'Profile',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AccountSettingsPage(),
                                ),
                              );
                            },
                          ),
                          SettingsTile(
                            icon: Icons.lock,
                            text: 'Privacy & Security',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => const PrivacySecuritySettingsPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                
                    const SizedBox(height: 24),
                
                    SectionTitle(title: 'Notifications'),
                    GreyContainer(
                      child: SettingsTile(
                        icon: Icons.notifications,
                        text: 'Notification Preferences',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationsSettingsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                
                    const SizedBox(height: 24),
                
                    SectionTitle(title: 'Payment'),
                    GreyContainer(
                      child: SettingsTile(
                        icon: Icons.payment,
                        text: 'Payment Methods',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PaymentSettingsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                
                    const SizedBox(height: 24),
                
                    SectionTitle(title: 'Ride Preferences'),
                    GreyContainer(
                      child: Column(
                        children: [
                          SettingsTile(
                            icon: Icons.directions_car,
                            text: 'Preferred Vehicle',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RidePreferencesPage(),
                                ),
                              );
                            },
                          ),
                          SettingsTile(
                            icon: Icons.music_note,
                            text: 'Music Preferences',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => const MusicPreferencesSettingsPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// reusable section title
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// reusable settings tile
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const SettingsTile({
    required this.icon,
    required this.text,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
