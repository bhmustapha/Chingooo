import 'package:flutter/material.dart';

// dark theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,

  // slider
  sliderTheme: SliderThemeData(
    activeTrackColor: Colors.blue,
    inactiveTrackColor: Colors.grey[700],
    thumbColor: Colors.blue,
    overlayColor: Colors.blue.withAlpha(32),
    trackHeight: 4.0,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
    valueIndicatorTextStyle: TextStyle(color: Colors.black, fontSize: 14),
  ),

  // disable the splash
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  splashFactory: NoSplash.splashFactory,

  // main color
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
    secondary: Colors.grey[900], // Changed from black for uniform background
    surface: Colors.grey[850], // For light containers like GreyContainer
    onSurface: Colors.grey[300], // For dividers or borders
    onPrimary: Colors.white, // Primary white text
    onSecondary: Colors.grey[500], // Secondary/hint text
  ),

  // font family
  fontFamily: 'Poppins',

  // app bar
  appBarTheme: AppBarTheme(
    toolbarHeight: 70,
    backgroundColor: Colors.grey[900], // Changed from Colors.black
    foregroundColor: Colors.white,
    elevation: 3,
    shadowColor: Colors.white12,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.white,
    ),
  ),

  // elevated button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      splashFactory: NoSplash.splashFactory,
      backgroundColor: Colors.grey[900], // Changed from Colors.black
      foregroundColor: Colors.blue[300],
      elevation: 6,
      shadowColor: Colors.white24,
      shape: CircleBorder(),
      padding: EdgeInsets.zero,
      fixedSize: Size(50, 50),
    ),
  ),

  // floating button
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.grey[900], // Changed from Colors.black
    foregroundColor: Colors.blue[300],
    elevation: 6,
    shape: CircleBorder(),
  ),

  // bottom navigation bar
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 6,
    selectedItemColor: Colors.blue[300],
    unselectedItemColor: Colors.grey[500],
    backgroundColor: Colors.grey[900], // Changed from Colors.black
    selectedLabelStyle: TextStyle(fontSize: 14),
    unselectedLabelStyle: TextStyle(fontSize: 11),
  ),

  // text field
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[900],
    contentPadding: EdgeInsets.all(10),
    hintStyle: TextStyle(
      color: Colors.grey[500],
      fontSize: 13,
      fontWeight: FontWeight.w100,
    ),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
  ),

  // text style
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.white, // Used for body text
    ),
    headlineMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    titleSmall: TextStyle(
      fontSize: 6,
      fontWeight: FontWeight.w300,
      color: Colors.blue[200],
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      color:
          Colors.white70, // Used for secondary white text (e.g., hint titles)
    ),
    bodySmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),

  // Date Picker Theme
  datePickerTheme: const DatePickerThemeData(
    backgroundColor: Colors.black,
    headerBackgroundColor: Colors.blue,
    headerForegroundColor: Colors.white,
    dayStyle: TextStyle(color: Colors.white),
  ),

  // Time Picker Theme
  timePickerTheme: TimePickerThemeData(
    backgroundColor: Colors.grey[900],
    hourMinuteTextColor: Colors.white,
    hourMinuteColor: Colors.grey[800],
    dayPeriodTextColor: Colors.white,
    dayPeriodColor: Colors.blue,
    dialHandColor: Colors.blue,
    dialBackgroundColor: Colors.grey[800],
    dialTextColor: Colors.white,
    entryModeIconColor: Colors.blue,
  ),

  // Buttons in Date/Time Pickers
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.blue),
  ),
  // outlined buttons
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.grey,
      side: BorderSide(color: Colors.grey, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: EdgeInsets.symmetric(vertical: 14),
    ),
  ),
);
