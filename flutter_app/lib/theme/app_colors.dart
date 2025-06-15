import 'package:flutter/material.dart';

/// Color palette for the Mixologist app
/// Cocktail-inspired colors for both light and dark themes
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // =========================
  // LIGHT THEME COLORS
  // =========================
  
  /// Rich whiskey brown - primary color
  static const Color richWhiskey = Color(0xFF6D4C2D);
  
  /// Golden amber - secondary color
  static const Color goldenAmber = Color(0xFFD4A574);
  
  /// Champagne gold - accent color
  static const Color champagneGold = Color(0xFFF7E7CE);
  
  /// Deep bitters red - error color
  static const Color deepBitters = Color(0xFF722F37);
  
  /// Citrus zest orange - tertiary color
  static const Color citrushZest = Color(0xFFE67E22);
  
  /// Crystal ice - surface color
  static const Color crystallIce = Color(0xFFF8FAFE);

  // =========================
  // DARK THEME COLORS
  // =========================
  
  /// Dark amber - primary color for dark theme
  static const Color darkAmber = Color(0xFFD4A574);
  
  /// Warm copper - secondary color for dark theme
  static const Color warmCopper = Color(0xFFB8860B);
  
  /// Charcoal surface - main surface color for dark theme
  static const Color charcoalSurface = Color(0xFF1C1C1E);
  
  /// Smoky glass - secondary surface color for dark theme
  static const Color smokyGlass = Color(0xFF2C2C2E);
  
  /// Crimson bitters - error color for dark theme
  static const Color crimsonBitters = Color(0xFF8B1538);
  
  /// Citrus glow - tertiary color for dark theme
  static const Color citrusGlow = Color(0xFFFFB347);

  // =========================
  // GRADIENT COLORS
  // =========================
  
  /// Light theme gradient colors
  static const List<Color> lightGradientColors = [
    Color(0xFFF7E7CE), // Champagne gold
    Color(0xFFE8D5B7), // Warm cream
    Color(0xFFD4A574), // Golden amber
    Color(0xFFF8FAFE), // Crystal ice
  ];
  
  /// Dark theme gradient colors
  static const List<Color> darkGradientColors = [
    Color(0xFF1C1C1E), // Charcoal surface
    Color(0xFF2C2C2E), // Smoky glass
    Color(0xFF1A1A1A), // Deep black
    Color(0xFF2A2A2A), // Warm charcoal
  ];

  // =========================
  // GRADIENT STOPS
  // =========================
  
  /// Standard gradient stops for backgrounds
  static const List<double> gradientStops = [0.0, 0.3, 0.7, 1.0];

  // =========================
  // HELPER METHODS
  // =========================
  
  /// Get the primary color for the given brightness
  static Color getPrimaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkAmber : richWhiskey;
  }
  
  /// Get the secondary color for the given brightness
  static Color getSecondaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? warmCopper : goldenAmber;
  }
  
  /// Get the surface color for the given brightness
  static Color getSurfaceColor(Brightness brightness) {
    return brightness == Brightness.dark ? charcoalSurface : crystallIce;
  }
  
  /// Get the error color for the given brightness
  static Color getErrorColor(Brightness brightness) {
    return brightness == Brightness.dark ? crimsonBitters : deepBitters;
  }
  
  /// Get the tertiary color for the given brightness
  static Color getTertiaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? citrusGlow : citrushZest;
  }
  
  /// Get the gradient colors for the given brightness
  static List<Color> getGradientColors(Brightness brightness) {
    return brightness == Brightness.dark ? darkGradientColors : lightGradientColors;
  }
}