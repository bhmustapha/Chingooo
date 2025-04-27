import 'views/home/home_page.dart';
import 'views/ride/create_ride.dart';
import 'views/splash/splash_page.dart';
import 'views/bookings/bookings_page.dart';
import 'views/profile/profile_page.dart';
import 'views/messages/message_page.dart';
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
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => const SplashPage(),
        "/mainnav" : (context) => const MainNavigator(),
        "/home": (context) => const HomePage(),
        "/settings": (context) => const SettingsPage(),
        "/bookings": (context) => const BookingsPage(),
        "/profile": (context) => const ProfilePage(),
        "/messages": (context) => const MessagesPage(),
        "/create" : (context) => const CreateRidePage()
      },
      
      home: MainNavigator(),
    );
  }
}
