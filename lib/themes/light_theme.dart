import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  // main color
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      secondary: Colors.white
    ),
  // app bar
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 3,
      shadowColor: Colors.black,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black
      ),
    ),
  // elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[600],
        elevation: 6,
        shadowColor: Colors.black,
        shape: CircleBorder(),
        padding: EdgeInsets.zero,
        fixedSize: Size(50, 50)
        ),
      ),
  //floating button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Colors.blue[600],
      elevation: 6,
      shape: CircleBorder()
    ),
  // bottom navigation bar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 6,
      selectedItemColor: Colors.blue[600],
      unselectedItemColor: Colors.grey
      
    )  
    );
   
    
  
