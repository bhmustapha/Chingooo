import 'package:carpooling/views/settings/payment_settings.dart';
import 'package:flutter/material.dart';
import '../../components/container.dart';
import '../../components/setting-section-name.dart';

// settings sections
import 'account_settings.dart';
import 'notifications_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COMPTE
              SettingSectionName(name: 'Parametres de compte'),
              GreyContainer( child: AccountSettingsTile()),
        
              //NOTIFICATIONS
              SettingSectionName(name: 'Notifications'),
              GreyContainer( child: NotificationSettingsTile()),

              //PAYMENT
              SettingSectionName(name: 'Paiement'),
              GreyContainer(child: PaymentSettingTile())
            ],
          ),
           ),
      ) ,
    );
  }
}