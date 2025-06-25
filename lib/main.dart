import 'package:carpooling/views/auth/login_page.dart';
import 'package:carpooling/themes/dark_theme.dart';
import 'package:carpooling/views/ride/pickUp_create.dart';
import 'package:carpooling/views/ride/requested_rides.dart';
import 'package:carpooling/views/splash/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // used in the theme
import 'views/home/home_page.dart';
import 'views/messages/conversations_list.dart';
import 'views/settings/settingspage.dart';
import 'widgets/main_navigator.dart';
import 'package:flutter/material.dart';
import 'themes/light_theme.dart';
import 'package:flutter/services.dart'; // to hide the state bar
import 'views/about/about_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// for the theme
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
// load selcted theme from the storage
Future<void> loadTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkTheme') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // must be before any async in main
  await loadTheme(); // wait to get the theme
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // barre transparente
    ),
  );
  await Firebase.initializeApp();
  // Enable verbose logging for debugging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("924b44f7-e96e-477c-8547-55b98800accc");


  OneSignal.Notifications.requestPermission(false);
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
            "/pickup": (context) => LocationSearchPage(),
            "/convList": (context) => ChatListPage(),
            "/auth": (context) => LoginPage(),
            "/reqrides": (context) => RequestedRidesPage(),
            "/aboutapp": (context) => AboutAppPage(),
          },
          home: SplashScreen(),
        );
      },
    );
  }
}
