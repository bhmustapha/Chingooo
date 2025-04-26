import 'package:flutter/material.dart';

class PaymentSettingTile extends StatelessWidget {
  const PaymentSettingTile({super.key});

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
                  title: Text('Ajouter/Modifier une carte',style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Icon(Icons.credit_card),
                  onTap: () {
              },
                ),
          
                ListTile(
                  title: Text('Methode de paiement par defaut',style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Icon(Icons.monetization_on),
                  onTap: () {},
            
                ),
                 ListTile(
                  title: Text('Historique de paiement',style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Icon(Icons.history_rounded),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('Codes promo!',style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Icon(Icons.discount),
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