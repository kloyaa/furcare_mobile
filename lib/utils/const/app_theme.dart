import 'package:flutter/material.dart';
import 'package:furcare_app/utils/const/app_constants.dart';
import 'package:furcare_app/utils/const/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Colors.deepPurple;
  static const Color secondaryColor = Color(0xFF9C27B0);
  static const Color accentColor = Color(0xFFE040FB);

  static const Color textColorLight = Colors.black87;
  static const Color textColorDark = Colors.white;

  static const Color backgroundColorLight = Colors.white;
  static const Color backgroundColorDark = Color(0xFF121212);

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey[100],
    cardTheme: const CardTheme(color: Colors.white),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        textStyle: GoogleFonts.urbanist(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 12.0,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.primary.withAlpha(200), width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        textStyle: GoogleFonts.urbanist(
          color: AppColors.primary.withAlpha(200),
          fontWeight: FontWeight.bold,
          fontSize: 12.0,
        ),
      ),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColorDark,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardTheme(color: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        elevation: 2,
        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
