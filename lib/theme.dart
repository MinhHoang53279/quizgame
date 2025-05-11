import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6A1B9A);
  static const Color secondaryColor = Color(0xFFF3E5F5);
  static const Color accentColor = Color(0xFFAB47BC);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;

  static ThemeData get themeData => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple).copyWith(
      secondary: accentColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: Colors.grey),
    ),
    cardColor: cardColor,
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
    ),
  );
} 