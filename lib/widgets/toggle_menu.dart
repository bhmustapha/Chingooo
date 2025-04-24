import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ToggleMenu extends StatefulWidget {
  const ToggleMenu({super.key});

  @override
  State<ToggleMenu> createState() => _ToggleMenuState();
}

class _ToggleMenuState extends State<ToggleMenu> {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      direction:SpeedDialDirection.down,
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      children: [
        SpeedDialChild(
          child: Icon(Icons.settings),
          onTap: () {Navigator.pushNamed(context, '/settings');}

        ),
        SpeedDialChild(
          child: Icon(Icons.drive_eta),
          onTap: () {Navigator.pushNamed(context, '/create');}

        ),
        SpeedDialChild(
          child: Icon(Icons.info)
        )
      ],
    );
  }
}