import 'package:carpooling/views/home/home_page.dart';
import 'package:carpooling/views/ride/create_ride.dart';
import 'package:carpooling/widgets/toggle_menu.dart';
import 'views/splash/splash_page.dart';
import 'views/bookings/bookings_page.dart';
import 'views/profile/profile_page.dart';
import 'views/messages/message_page.dart';


import 'package:flutter/material.dart';
import 'themes/light_theme.dart';
import 'views/settings/settingspage.dart';

import 'package:flutter/services.dart'; // pour masquer la barre d'etat


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
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => const SplashPage(),
        "/home": (context) => const HomePage(),
        "/settings": (context) => const SettingsPage(),
        "/bookings": (context) => const BookingsPage(),
        "/profile": (context) => const ProfilePage(),
        "/messages": (context) => const MessagesPage(),
        "/create" : (context) => const CreateRidePage()
      },
      
      home: HomePage(),
    );
  }
}
