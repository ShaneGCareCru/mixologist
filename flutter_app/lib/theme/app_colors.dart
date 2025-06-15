import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Centralized color palette for the Mixologist app
/// Supports both light and dark themes with cocktail-inspired colors
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Light Theme Colors - Cocktail Inspired
  static const Color richWhiskey = Color(0xFF6D4C2D);
  static const Color goldenAmber = Color(0xFFD4A574);
  static const Color champagneGold = Color(0xFFF7E7CE);
  static const Color deepBitters = Color(0xFF722F37);
  static const Color citrushZest = Color(0xFFE67E22);
  static const Color crystallIce = Color(0xFFF8FAFE);
  static const Color warmCream = Color(0xFFE8D5B7);
  
  // Dark Theme Colors - Evening Cocktail Ambiance
  static const Color darkAmber = Color(0xFFD4A574);
  static const Color warmCopper = Color(0xFFB8860B);
  static const Color charcoalSurface = Color(0xFF1C1C1E);
  static const Color smokyGlass = Color(0xFF2C2C2E);
  static const Color crimsonBitters = Color(0xFF8B1538);
  static const Color citrusGlow = Color(0xFFFFB347);
  static const Color deepBlack = Color(0xFF1A1A1A);
  static const Color warmCharcoal = Color(0xFF2A2A2A);
  
  // UI System Colors
  static const Color errorRed = Color(0xFFFF3B30);
  static const Color secondaryText = Color(0xFF8E8E93);
  
  // Light Theme Color Scheme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: richWhiskey,
    onPrimary: Colors.white,
    secondary: goldenAmber,
    onSecondary: richWhiskey,
    surface: crystallIce,
    onSurface: richWhiskey,
    background: crystallIce,
    onBackground: richWhiskey,
    error: deepBitters,
    onError: Colors.white,
    primaryContainer: champagneGold,
    onPrimaryContainer: richWhiskey,
    secondaryContainer: champagneGold,
    onSecondaryContainer: richWhiskey,
    tertiary: citrushZest,
    onTertiary: Colors.white,
  );
  
  // Dark Theme Color Scheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: darkAmber,
    onPrimary: deepBlack,
    secondary: warmCopper,
    onSecondary: deepBlack,
    surface: charcoalSurface,
    onSurface: darkAmber,
    background: deepBlack,
    onBackground: darkAmber,
    error: crimsonBitters,
    onError: Colors.white,
    primaryContainer: smokyGlass,
    onPrimaryContainer: darkAmber,
    secondaryContainer: warmCharcoal,
    onSecondaryContainer: warmCopper,
    tertiary: citrusGlow,
    onTertiary: deepBlack,
  );
  
  // Gradient Colors for Backgrounds
  static const List<Color> lightGradient = [
    champagneGold,
    warmCream,
    goldenAmber,
    crystallIce,
  ];
  
  static const List<Color> darkGradient = [
    charcoalSurface,
    smokyGlass,
    deepBlack,
    warmCharcoal,
  ];
  
  // Helper method to get gradient based on brightness
  static List<Color> getGradient(Brightness brightness) {
    return brightness == Brightness.dark ? darkGradient : lightGradient;
  }
  
  // Helper method to get adaptive colors
  static Color adaptiveColor(BuildContext context, Color lightColor, Color darkColor) {
    return Theme.of(context).brightness == Brightness.dark ? darkColor : lightColor;
  }
  
  // Card color helpers
  static Color cardColor(BuildContext context) {
    return adaptiveColor(context, Colors.white.withOpacity(0.9), smokyGlass.withOpacity(0.8));
  }
  
  static Color cardShadowColor(BuildContext context) {
    return adaptiveColor(context, richWhiskey.withOpacity(0.2), Colors.black54);
  }
}