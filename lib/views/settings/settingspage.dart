import 'package:carpooling/views/settings/account%20settings/account_settings_page.dart';
import 'package:carpooling/views/settings/music_preferences_settings_page.dart';
import 'package:carpooling/views/settings/notifications_settings_page.dart';
import 'package:carpooling/views/settings/payment_settings_page.dart';
import 'package:carpooling/views/settings/ride_preferences_page.dart';
import 'package:flutter/material.dart';

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
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 16.0, top: 16.0), // Added padding for the row
              child: Row(
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
            ),
            const SizedBox(height: 24),
            Expanded( // Use Expanded to make SingleChildScrollView take remaining space
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // Added horizontal padding here
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(title: 'Account'),
                    // Removed GreyContainer
                    Column( // Column directly wrapping SettingsTiles
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
                        
                      ],
                    ),

                    const SizedBox(height: 24),

                    SectionTitle(title: 'Notifications'),
                    // Removed GreyContainer
                    SettingsTile( // SettingsTile directly here
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

                    const SizedBox(height: 24),

                    SectionTitle(title: 'Payment'),
                    // Removed GreyContainer
                    SettingsTile( // SettingsTile directly here
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

                    const SizedBox(height: 24),

                    SectionTitle(title: 'Ride Preferences'),
                    // Removed GreyContainer
                    Column( // Column directly wrapping SettingsTiles
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
                                builder: (_) => const MusicPreferencesSettingsPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24), // Add some bottom spacing
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
  // Added optional trailingText and textColor for more flexibility
  final String? trailingText;
  final Color? textColor;
  final Color? trailingTextColor;


  const SettingsTile({
    required this.icon,
    required this.text,
    required this.onTap,
    this.trailingText, // Make it nullable
    this.textColor, // Make it nullable
    this.trailingTextColor, // Make it nullable
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).primaryColor), // Use primary color if textColor is null
      title: Text(text, style: TextStyle(fontSize: 16, color: textColor)), // Apply textColor
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) // Show trailing text only if provided
            Text(trailingText!, style: TextStyle(color: trailingTextColor ?? Colors.grey)), // Apply trailingTextColor
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), // Consistent grey for arrow
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0), // Removed horizontal padding from here as it's now on SingleChildScrollView
    );
  }
}