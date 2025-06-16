import 'package:carpooling/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // for the menu
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

// function to change the theme in shared preferences
Future<void> toggleTheme() async {
  final prefs = await SharedPreferences.getInstance();
  if (themeNotifier.value == ThemeMode.light) {
    themeNotifier.value = ThemeMode.dark;
    await prefs.setBool('isDarkTheme', true);
  } else {
    themeNotifier.value = ThemeMode.light;
    await prefs.setBool('isDarkTheme', false);
  }
}


class ToggleMenu extends StatefulWidget {
  const ToggleMenu({super.key});

  @override
  State<ToggleMenu> createState() => _ToggleMenuState();
}

class _ToggleMenuState extends State<ToggleMenu> {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      direction: SpeedDialDirection.down,
      animatedIcon: AnimatedIcons.menu_close,
      buttonSize: Size(50, 50),
      children: [
        SpeedDialChild(
          child: Icon(LucideIcons.calendarPlus),
          onTap: () {
            Navigator.pushNamed(context, '/pickup');
          },
          shape: CircleBorder(),
          foregroundColor: Colors.blue[600],
        ),
        SpeedDialChild(
          child: Icon(LucideIcons.calendarSearch),
          onTap: () {
            Navigator.pushNamed(context, '/reqrides');
          },
          shape: CircleBorder(),
          foregroundColor: Colors.blue[600],
        ),
        SpeedDialChild(
          child:
              themeNotifier.value == ThemeMode.light
                  ? Icon(Icons.dark_mode)
                  : Icon(Icons.light_mode),
          onTap: () {
           toggleTheme();
            setState(() {});
            
          },
          foregroundColor: Colors.blue[600],
        ),
        SpeedDialChild(
          child: Icon(LucideIcons.settings),
          onTap: () {
            Navigator.pushNamed(context, '/settings');
          },
          shape: CircleBorder(),
          foregroundColor: Colors.blue[600],
        ),
        SpeedDialChild(
          child: Icon(LucideIcons.info),
          shape: CircleBorder(),
          foregroundColor: Colors.blue[600],
          onTap: () {
            Navigator.pushNamed(context, '/aboutapp');
          },
        ),
        
      ],
    );
  }
}
