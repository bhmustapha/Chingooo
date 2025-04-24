import 'package:flutter/material.dart';

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
                  title: Text('Notifications'),
                  secondary: Icon(Icons.notifications_on_sharp),
              
                ),
          
                SwitchListTile.adaptive(
                  value: reservations,
                  onChanged: (value) {  
                    setState(() {
                    reservations = value;
                  });

                  },
                  title: Text('Reservations'),
                  secondary: Icon(Icons.directions_car),
              
                ),
                SwitchListTile.adaptive(
                  value: offers,
                  onChanged: (bool value) {
                   setState(() {
                    offers = value;
                  });
                  },
                  title: Text('Offres'),
                  secondary: Icon(Icons.local_offer_sharp),
              
                ),
                SwitchListTile.adaptive(
                  value: evaluation,
                  onChanged: (value) {
                    setState(() {
                    evaluation = value;
                  });
                  },
                  title: Text('Evaluer'),
                  secondary: Icon(Icons.star),
              
                ),
              ]
            ),
          ),
        )
        
      ],
    );;
  }
}