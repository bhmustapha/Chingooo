
import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
@override
void initState() {
  super.initState();
Timer(const Duration(seconds: 2), () {
  if (mounted) {
    Navigator.pushReplacementNamed(context, '/mainnav');
  }
});
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // add dark mode later
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/chingooo.png',
              
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}
