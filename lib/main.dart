import 'package:carpooling/auth/login_page.dart';
import 'package:carpooling/intro.dart';
import 'package:carpooling/themes/dark_theme.dart';
import 'package:carpooling/views/ride/pickUp_create.dart';
import 'package:carpooling/widgets/toggle_menu.dart';

import 'views/home/home_page.dart';
import 'views/splash/splash_page.dart';
import 'views/messages/conversations_list.dart';
import 'views/settings/settingspage.dart';

import 'widgets/main_navigator.dart';

import 'package:flutter/material.dart';
import 'themes/light_theme.dart';


import 'package:flutter/services.dart'; // to hide the state bar
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);



void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // barre transparente
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: currentTheme,
          debugShowCheckedModeBanner: false,
          routes: {
            "/mainnav": (context) => const MainNavigator(),
            "/home": (context) => const HomePage(),
            "/settings": (context) => const SettingsPage(),
            "/chatgpt": (context) => LocationSearchPage(),
            "/convList": (context) => ChatListPage(),
            "/auth": (context) => LoginPage(),
          },
          home: OnBoardingPage(),
        );
      },
    );
  }
}

