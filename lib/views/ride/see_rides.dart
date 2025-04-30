import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SeeRidesPage extends StatefulWidget {
  const SeeRidesPage({super.key});

  @override
  State<SeeRidesPage> createState() => _SeeRidesPageState();
}

class _SeeRidesPageState extends State<SeeRidesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: Text('no available rides!')),
          Positioned(
            top: 30,
            left: 14,
            child: IconButton(
              color: Colors.blue,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(LucideIcons.arrowLeft),
            ),
          ),
          Positioned(
            bottom: 15,
            right: 10,
            left: 10,
            child: TextButton(
              onPressed: () {},
              child: Text('Post a ride request'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
