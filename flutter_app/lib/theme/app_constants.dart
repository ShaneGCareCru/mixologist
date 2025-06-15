import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Theme constants for the Mixologist app
/// Contains gradients, spacing, borders, shadows, and other design tokens
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // =========================
  // GRADIENTS
  // =========================
  
  /// Light theme background gradient
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.lightGradientColors,
    stops: AppColors.gradientStops,
  );
  
  /// Dark theme background gradient
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.darkGradientColors,
    stops: AppColors.gradientStops,
  );

  // =========================
  // SPACING
  // =========================
  
  /// Extra small spacing (4dp)
  static const double spacingXS = 4.0;
  
  /// Small spacing (8dp)
  static const double spacingS = 8.0;
  
  /// Medium spacing (16dp)
  static const double spacingM = 16.0;
  
  /// Large spacing (20dp)
  static const double spacingL = 20.0;
  
  /// Extra large spacing (24dp)
  static const double spacingXL = 24.0;
  
  /// Extra extra large spacing (32dp)
  static const double spacingXXL = 32.0;

  // =========================
  // BORDER RADIUS
  // =========================
  
  /// Small border radius
  static const double radiusS = 8.0;
  
  /// Medium border radius
  static const double radiusM = 12.0;
  
  /// Large border radius  
  static const double radiusL = 16.0;
  
  /// Extra large border radius
  static const double radiusXL = 20.0;

  // =========================
  // ELEVATIONS
  // =========================
  
  /// Light theme card elevation
  static const double lightCardElevation = 12.0;
  
  /// Dark theme card elevation
  static const double darkCardElevation = 16.0;
  
  /// Light theme button elevation
  static const double lightButtonElevation = 6.0;
  
  /// Dark theme button elevation
  static const double darkButtonElevation = 8.0;

  // =========================
  // PADDING
  // =========================
  
  /// Standard button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 32.0, 
    vertical: 18.0,
  );
  
  /// Standard card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(spacingL);
  
  /// Input field padding
  static const EdgeInsets inputPadding = EdgeInsets.all(spacingL);
  
  /// Screen edge padding
  static const EdgeInsets screenPadding = EdgeInsets.all(spacingM);

  // =========================
  // GLASSMORPHIC EFFECTS
  // =========================
  
  /// Light theme glassmorphic gradient
  static final LinearGradient lightGlassmorphicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.25),
      Colors.white.withOpacity(0.1),
    ],
  );
  
  /// Dark theme glassmorphic gradient
  static final LinearGradient darkGlassmorphicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.1),
      Colors.white.withOpacity(0.05),
    ],
  );

  // =========================
  // SHADOWS
  // =========================
  
  /// Light theme card shadow color
  static Color lightCardShadowColor = AppColors.richWhiskey.withOpacity(0.2);
  
  /// Dark theme card shadow color
  static const Color darkCardShadowColor = Colors.black54;
  
  /// Light theme button shadow color
  static Color lightButtonShadowColor = AppColors.richWhiskey.withOpacity(0.3);
  
  /// Dark theme button shadow color
  static const Color darkButtonShadowColor = Colors.black45;

  // =========================
  // OPACITY VALUES
  // =========================
  
  /// Standard overlay opacity
  static const double overlayOpacity = 0.1;
  
  /// Glassmorphic background opacity
  static const double glassmorphicOpacity = 0.9;
  
  /// Light theme card opacity
  static const double lightCardOpacity = 0.9;
  
  /// Dark theme card opacity
  static const double darkCardOpacity = 0.85;

  // =========================
  // HELPER METHODS
  // =========================
  
  /// Get the appropriate gradient for the given brightness
  static LinearGradient getBackgroundGradient(Brightness brightness) {
    return brightness == Brightness.dark ? darkGradient : lightGradient;
  }
  
  /// Get the appropriate glassmorphic gradient for the given brightness
  static LinearGradient getGlassmorphicGradient(Brightness brightness) {
    return brightness == Brightness.dark 
        ? darkGlassmorphicGradient 
        : lightGlassmorphicGradient;
  }
  
  /// Get the appropriate card elevation for the given brightness
  static double getCardElevation(Brightness brightness) {
    return brightness == Brightness.dark ? darkCardElevation : lightCardElevation;
  }
  
  /// Get the appropriate button elevation for the given brightness
  static double getButtonElevation(Brightness brightness) {
    return brightness == Brightness.dark ? darkButtonElevation : lightButtonElevation;
  }
  
  /// Get the appropriate card shadow color for the given brightness
  static Color getCardShadowColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkCardShadowColor : lightCardShadowColor;
  }
  
  /// Get the appropriate button shadow color for the given brightness
  static Color getButtonShadowColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkButtonShadowColor : lightButtonShadowColor;
  }
  
  /// Get the appropriate card opacity for the given brightness
  static double getCardOpacity(Brightness brightness) {
    return brightness == Brightness.dark ? darkCardOpacity : lightCardOpacity;
  }
  
  /// Get overlay color for the given brightness
  static Color getOverlayColor(Brightness brightness) {
    return brightness == Brightness.dark 
        ? Colors.black.withOpacity(overlayOpacity)
        : Colors.white.withOpacity(overlayOpacity);
  }
  
  /// Get glassmorphic border color for the given brightness
  static Color getGlassmorphicBorderColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? Colors.white.withOpacity(0.2)
        : Colors.white.withOpacity(0.3);
  }
  
  /// Get glassmorphic background color for the given brightness
  static Color getGlassmorphicBackgroundColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? Colors.black.withOpacity(0.2)
        : Colors.white.withOpacity(0.1);
  }
}