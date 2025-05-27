import 'package:carpooling/intro.dart';
import 'package:carpooling/widgets/main_navigator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // delay for splash effect

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in — go to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  MainNavigator()),
      );
    } else {
      // Not signed in — go to intro or login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  OnBoardingPage()), // or LoginPage()
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // or your logo
      ),
    );
  }
}
