import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool notifyMessages = true;
  bool notifyRideUpdates = true;
  bool notifyAnnouncements = true;
  bool isLoading = true;

  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final settings = doc.data()?['notificationSettings'] ?? {};

    setState(() {
      notifyMessages = settings['messages'] ?? true;
      notifyRideUpdates = settings['rideUpdates'] ?? true;
      notifyAnnouncements = settings['announcements'] ?? true;
      isLoading = false;
    });
  }

  Future<void> _updateSettings() async {
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'notificationSettings': {
        'messages': notifyMessages,
        'rideUpdates': notifyRideUpdates,
        'announcements': notifyAnnouncements,
      },
    });
  }

  Widget _buildSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (val) {
        onChanged(val);
        _updateSettings();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
        elevation: 0,
      ),
      body: SafeArea(
        child: 
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                      children: [
                        _buildSwitch(
                          title: 'Messages',
                          value: notifyMessages,
                          onChanged: (val) => setState(() => notifyMessages = val),
                        ),
                        _buildSwitch(
                          title: 'Ride Updates',
                          value: notifyRideUpdates,
                          onChanged: (val) => setState(() => notifyRideUpdates = val),
                        ),
                        _buildSwitch(
                          title: 'Announcements',
                          value: notifyAnnouncements,
                          onChanged: (val) => setState(() => notifyAnnouncements = val),
                        ),
                      ],
                    ),
                  
          
      ),
    );
  }
}
