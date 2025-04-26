import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_switch/flutter_switch.dart';

class NotificationSettingsTile extends StatefulWidget {
   NotificationSettingsTile({super.key});

  @override
  State<NotificationSettingsTile> createState() => _NotificationSettingsTileState();
}

class _NotificationSettingsTileState extends State<NotificationSettingsTile> {
   
   //switches states
   bool notification = false;
   bool reservations = false;
   bool offers = false;
   bool evaluation = false;
   bool test = false;

  @override
 

  Widget build(BuildContext context) {
    return Column(
        
        children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  value: notification,
                  onChanged: (value) {
                    setState(() {
                    notification = value;
                  });
                  },
                  title: Text('Notifications', style: Theme.of(context).textTheme.bodyMedium),
                  secondary: Icon(LucideIcons.bell),
              
                ),
          
                SwitchListTile.adaptive(
                  value: reservations,
                  onChanged: (value) {  
                    setState(() {
                    reservations = value;
                  });

                  },
                  title: Text('Reservations', style: Theme.of(context).textTheme.bodyMedium),
                  secondary: Icon(LucideIcons.car),
              
                ),
                SwitchListTile.adaptive(
                  value: offers,
                  onChanged: (bool value) {
                   setState(() {
                    offers = value;
                  });
                  },
                  title: Text('Offres', style: Theme.of(context).textTheme.bodyMedium),
                  secondary: Icon(LucideIcons.ticketCheck),
              
                ),
                SwitchListTile.adaptive(
                  value: evaluation,
                  onChanged: (value) {
                    setState(() {
                    evaluation = value;
                  });
                  },
                  title: Text('Evaluer', style: Theme.of(context).textTheme.bodyMedium),
                  secondary: Transform.scale(scale: 0.8,child: Icon(Icons.star)),
              
                ),
                
              ]
            ),
          ),
        )
        
      ],
    );
  }
}