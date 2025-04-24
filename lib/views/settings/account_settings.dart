import 'package:flutter/material.dart';

class AccountSettingsTile extends StatelessWidget {
  const AccountSettingsTile({super.key});

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
                ListTile(
                  title: Text('Modifier votre profile'),
                  trailing: Icon(Icons.edit),
                  onTap: () {
              },
                ),
          
                ListTile(
                  title: Text('Changer votre mot de passe'),
                  trailing: Icon(Icons.lock),
                  onTap: () {},
            
                ),
                 ListTile(
                  title: Text('Supprimer votre compte'),
                  trailing: Icon(Icons.delete),
                  onTap: () {},
                ),
              ],
            ),
          ),
        )
        
      ],
    );
     
  }
}