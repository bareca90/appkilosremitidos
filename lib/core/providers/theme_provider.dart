import 'package:appkilosremitidos/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeData _currentTheme = lightTheme;

  ThemeData get currentTheme => _currentTheme;

  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryRed,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryRed,
      secondary: AppColors.primaryBlue,
    ),
    scaffoldBackgroundColor: AppColors.lightGray,
    appBarTheme: const AppBarTheme(
      color: AppColors.primaryBlue,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      filled: true,
      fillColor: AppColors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16.0),
      bodySmall: TextStyle(fontSize: 12.0),
    ),
  );
}
