import 'package:carpooling/auth/login_page.dart';
import 'package:carpooling/intro.dart';
import 'package:carpooling/views/ride/pickUp_create.dart';

import 'views/home/home_page.dart';
import 'views/ride/test_create.dart';
import 'views/splash/splash_page.dart';
import 'views/messages/conversations_list.dart';
import 'views/settings/settingspage.dart';

import 'widgets/main_navigator.dart';

import 'package:flutter/material.dart';
import 'themes/light_theme.dart';


import 'package:flutter/services.dart'; // to hide the state bar


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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      debugShowCheckedModeBanner: false,
      // initialRoute: "/mainnav",
      routes: {
        
        "/mainnav" : (context) => const MainNavigator(),
        "/home": (context) => const HomePage(),
        "/settings": (context) => const SettingsPage(),
        "/createTest": (context) => const CreateRideMap(),
        "/chatgpt": (context) =>  LocationSearchPage(),
        "/convList": (context) => ChatListPage(),
        "/auth": (context) => LoginPage(),
      },
      
      home: OnBoardingPage(),
    );
  }
}
