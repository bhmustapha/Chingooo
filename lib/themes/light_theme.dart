import 'package:flutter/material.dart';

// light theme
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  //disable the splash
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  splashFactory: NoSplash.splashFactory,
  // main color
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    secondary: Colors.white,
  ),

  // font family
  fontFamily: 'Poppins',

  // app bar
  appBarTheme: AppBarTheme(
    toolbarHeight: 70,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 3,
    shadowColor: Colors.black,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.black,
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
      fixedSize: Size(50, 50),
    ),
  ),
  //floating button
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.white,
    foregroundColor: Colors.blue[600],
    elevation: 6,
    shape: CircleBorder(),
  ),
  // bottom navigation bar
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 6,
    selectedItemColor: Colors.blue[600],
    unselectedItemColor: Colors.grey,
    selectedLabelStyle: TextStyle(fontSize: 14),
    unselectedLabelStyle: TextStyle(fontSize: 11),
  ),
  // text field
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.all(10),
    hintStyle: TextStyle(
      color: Colors.grey[300],
      fontSize: 13,
      fontWeight: FontWeight.w100,
    ),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
  ),
  //text style
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: const Color.fromARGB(255, 8, 36, 59),
    ),
    headlineMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
    titleSmall: TextStyle(
      fontSize: 6,
      fontWeight: FontWeight.w300,
      color: Colors.blue[500],
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      color: const Color.fromARGB(255, 4, 20, 32),
    ),
    bodySmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  ),


  // Date Picker Theme
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: Colors.blue,         // Header background
        headerForegroundColor: Colors.white,        // Text color in header

         // Text inside selected day circle

        dayStyle: TextStyle(color: Colors.black),    // Default day text color
        // Today's text color
      ),

      // Time Picker Theme
      timePickerTheme: const TimePickerThemeData(
        backgroundColor: Colors.white,
        hourMinuteTextColor: Colors.white,
        hourMinuteColor: Colors.blue,               // Hour/Minute box color
        dayPeriodTextColor: Colors.white,           // AM/PM text color
        dayPeriodColor: Colors.blue,                // AM/PM background color
        dialHandColor: Colors.blue,                 // Dial hand color
        dialBackgroundColor: Colors.blueAccent,    // Dial background color
        dialTextColor: Colors.white,                // Dial text color
        entryModeIconColor: Colors.blue,            // Icon color for switching modes
      ),

      // Buttons in Date/Time Pickers
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.blue), // Button color
      ),
);
