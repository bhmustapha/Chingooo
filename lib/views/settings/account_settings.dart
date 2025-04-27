import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
                  title: Text(
                    'Modifier votre profile',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: Icon(LucideIcons.pencil),
                  onTap: () {},
                ),

                ListTile(
                  title: Text(
                    'Changer votre mot de passe',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: Icon(LucideIcons.userLock),
                  onTap: () {},
                ),
                ListTile(
                  title: Text(
                    'Supprimer votre compte',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: Icon(LucideIcons.trash),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
