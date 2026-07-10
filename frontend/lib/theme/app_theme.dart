import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFFD32F2F);
  static const Color secondary = Color(0xFFFF9800);

  static const Color background = Color(0xFFF5F5F5);
  static const Color card = Colors.white;

  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 60),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    cardTheme: CardThemeData(
      color: card,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}