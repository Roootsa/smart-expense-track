import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light Theme
  static const Color primaryLight = Color(0xFF4A90E2);
  static const Color accentLight = Color(0xFF50E3C2);
  static const Color backgroundLight = Color(0xFFF4F6F8);
  static const Color cardLight = Colors.white;
  static const Color textLight = Color(0xFF2D3748);
  static const Color subtextLight = Color(0xFF718096);

  // Dark Theme
  static const Color primaryDark = Color(0xFF4A90E2);
  static const Color accentDark = Color(0xFF50E3C2);
  static const Color backgroundDark = Color(0xFF1A202C);
  static const Color cardDark = Color(0xFF2D3748);
  static const Color textDark = Color(0xFFEDF2F7);
  static const Color subtextDark = Color(0xFFA0AEC0);
  
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(bodyColor: textLight),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      iconTheme: IconThemeData(color: textLight),
      titleTextStyle: TextStyle(color: textLight, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: accentLight,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        surface: cardLight,
        background: backgroundLight
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(bodyColor: textDark),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: accentDark,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      surface: cardDark,
      background: backgroundDark
    ),
  );
}