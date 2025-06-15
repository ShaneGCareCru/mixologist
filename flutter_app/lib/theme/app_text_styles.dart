import 'package:flutter/material.dart';

class AppTextStyles {
  // Light theme text styles
  static const lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32, 
      fontWeight: FontWeight.w800, 
      letterSpacing: -0.5,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontSize: 28, 
      fontWeight: FontWeight.w700, 
      letterSpacing: -0.5,
      height: 1.2,
    ),
    headlineLarge: TextStyle(
      fontSize: 24, 
      fontWeight: FontWeight.w600, 
      letterSpacing: -0.25,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 20, 
      fontWeight: FontWeight.w600, 
      letterSpacing: -0.25,
      height: 1.3,
    ),
    titleLarge: TextStyle(
      fontSize: 18, 
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 16, 
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16, 
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14, 
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12, 
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14, 
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12, 
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelSmall: TextStyle(
      fontSize: 10, 
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
  );

  // Dark theme text styles
  static const darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32, 
      fontWeight: FontWeight.w800, 
      letterSpacing: -0.5, 
      color: Colors.white,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontSize: 28, 
      fontWeight: FontWeight.w700, 
      letterSpacing: -0.5, 
      color: Colors.white,
      height: 1.2,
    ),
    headlineLarge: TextStyle(
      fontSize: 24, 
      fontWeight: FontWeight.w600, 
      letterSpacing: -0.25, 
      color: Colors.white,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 20, 
      fontWeight: FontWeight.w600, 
      letterSpacing: -0.25, 
      color: Colors.white,
      height: 1.3,
    ),
    titleLarge: TextStyle(
      fontSize: 18, 
      fontWeight: FontWeight.w600, 
      color: Colors.white,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 16, 
      fontWeight: FontWeight.w600, 
      color: Colors.white,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16, 
      fontWeight: FontWeight.w400, 
      color: Colors.white54,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14, 
      fontWeight: FontWeight.w400, 
      color: Colors.white70,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12, 
      fontWeight: FontWeight.w400, 
      color: Colors.white60,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14, 
      fontWeight: FontWeight.w500, 
      color: Colors.white,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12, 
      fontWeight: FontWeight.w500, 
      color: Colors.white,
      letterSpacing: 0.1,
    ),
    labelSmall: TextStyle(
      fontSize: 10, 
      fontWeight: FontWeight.w500, 
      color: Colors.white,
      letterSpacing: 0.1,
    ),
  );
}