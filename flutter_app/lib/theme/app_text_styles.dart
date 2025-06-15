import 'package:flutter/material.dart';

/// Centralized text styles for the Mixologist app
/// Follows Material Design 3 typography scale
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Display Text Styles - Largest headlines
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32, 
    fontWeight: FontWeight.w800, 
    letterSpacing: -0.5,
    height: 1.1,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28, 
    fontWeight: FontWeight.w700, 
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24, 
    fontWeight: FontWeight.w600, 
    letterSpacing: -0.25,
    height: 1.3,
  );

  // Headline Text Styles - Section headers
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24, 
    fontWeight: FontWeight.w600, 
    letterSpacing: -0.25,
    height: 1.3,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20, 
    fontWeight: FontWeight.w600, 
    letterSpacing: -0.25,
    height: 1.3,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18, 
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Title Text Styles - Component titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18, 
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16, 
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14, 
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body Text Styles - Main content
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, 
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, 
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, 
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // Label Text Styles - Buttons and UI elements
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14, 
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12, 
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10, 
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // Complete Material Design 3 TextTheme
  static const TextTheme lightTextTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
  
  static const TextTheme darkTextTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  // Helper methods for commonly used text styles
  static TextStyle get appBarTitle => titleLarge;
  static TextStyle get cardTitle => titleMedium;
  static TextStyle get cardSubtitle => bodyMedium;
  static TextStyle get buttonText => labelLarge;
  static TextStyle get inputText => bodyMedium;
  static TextStyle get hintText => bodySmall;
  static TextStyle get errorText => bodySmall;
}