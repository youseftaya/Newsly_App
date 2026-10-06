import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme =
      ThemeData.light().copyWith(
    scaffoldBackgroundColor:
        const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF3B82F6),
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData darkTheme =
      ThemeData.dark().copyWith(
    scaffoldBackgroundColor:
        const Color(0xFF1C1C1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF3B82F6),
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
    ),
  );
}