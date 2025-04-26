import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
      foregroundColor: Colors.blue[600],
      children: [
        SpeedDialChild(
          child: Icon(LucideIcons.settings),
          onTap: () {Navigator.pushNamed(context, '/settings');},
          shape: CircleBorder(),
          foregroundColor: Colors.blue[600]
        ),
        SpeedDialChild(
          child: Icon(LucideIcons.carTaxiFront),
          onTap: () {Navigator.pushNamed(context, '/create');},
          shape: CircleBorder(),
          foregroundColor: Colors.blue[600]
        ),
        SpeedDialChild(
          child: Icon(LucideIcons.info),
          shape: CircleBorder(),
          foregroundColor: Colors.blue[600]
        )
      ],
    );
  }
}