import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// iOS-optimized theme constants and design system for the Mixologist app
class iOSTheme {
  // iOS-specific color palette
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGray2 = Color(0xFFAEAEB2);
  static const Color systemGray3 = Color(0xFFC7C7CC);
  static const Color systemGray4 = Color(0xFFD1D1D6);
  static const Color systemGray5 = Color(0xFFE5E5EA);
  static const Color systemGray6 = Color(0xFFF2F2F7);
  
  // Cocktail-inspired iOS colors
  static const Color whiskey = Color(0xFF6D4C2D);
  static const Color amber = Color(0xFFD4A574);
  static const Color champagne = Color(0xFFF7E7CE);
  static const Color bitters = Color(0xFF722F37);
  static const Color citrus = Color(0xFFE67E22);
  static const Color ice = Color(0xFFF8FAFE);
  
  // iOS spacing constants
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 20.0;
  static const double extraLargePadding = 24.0;
  
  // iOS touch targets (minimum 44pt)
  static const double minimumTouchTarget = 44.0;
  
  // iOS corner radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 20.0;
  
  // iOS-optimized typography scale
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );
  
  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle subhead = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  // iOS-style shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // iOS-style padding helper
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: largePadding,
    vertical: mediumPadding,
  );
  
  static const EdgeInsets cardPadding = EdgeInsets.all(mediumPadding);
  
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: largePadding,
    vertical: 12.0,
  );
  
  // iOS-style transitions
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  static const Curve iOSCurve = Curves.easeInOutCubic;
  
  // Dark mode support
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSecondaryBackground = Color(0xFF1C1C1E);
  static const Color darkTertiaryBackground = Color(0xFF2C2C2E);
  
  // Helper method to get adaptive colors
  static Color adaptiveColor(BuildContext context, Color lightColor, Color darkColor) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark 
        ? darkColor 
        : lightColor;
  }
  
  // Helper method to create iOS-style cards
  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: adaptiveColor(context, CupertinoColors.systemBackground, darkSecondaryBackground),
      borderRadius: BorderRadius.circular(largeRadius),
      boxShadow: cardShadow,
    );
  }
}