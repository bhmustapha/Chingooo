import 'package:carpooling/views/home/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomAppBarTheme: BottomAppBarTheme(
          color: Colors.white,
          elevation: 0,
          shape: CircularNotchedRectangle()
        )
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
