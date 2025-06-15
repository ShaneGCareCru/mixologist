import 'package:flutter/material.dart';

/// Centralized constants for spacing, sizing, animations, and other design tokens
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Spacing Constants
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  
  // iOS Specific Spacing (from ios_theme.dart)
  static const double smallPadding = spacing8;
  static const double mediumPadding = spacing16;
  static const double largePadding = spacing20;
  static const double extraLargePadding = spacing24;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 20.0;
  static const double radiusRound = 100.0;

  // Icon Sizes
  static const double iconSmall = 18.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconExtraLarge = 48.0;

  // Button Sizes
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;
  static const double minimumTouchTarget = 44.0; // iOS minimum

  // Card Properties
  static const double cardElevation = 12.0;
  static const double cardRadius = radiusLarge;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration extraLongAnimation = Duration(milliseconds: 1000);

  // Animation Curves
  static const Curve iOSCurve = Curves.easeInOutCubic;
  static const Curve materialCurve = Curves.easeInOutCubic;
  static const Curve bounceInCurve = Curves.bounceIn;
  static const Curve bounceOutCurve = Curves.bounceOut;

  // Layout Breakpoints
  static const double mobileBreakpoint = 480.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;

  // Common Padding EdgeInsets
  static const EdgeInsets paddingAll8 = EdgeInsets.all(spacing8);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(spacing20);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(spacing24);

  static const EdgeInsets paddingHorizontal16 = EdgeInsets.symmetric(horizontal: spacing16);
  static const EdgeInsets paddingHorizontal20 = EdgeInsets.symmetric(horizontal: spacing20);
  static const EdgeInsets paddingVertical8 = EdgeInsets.symmetric(vertical: spacing8);
  static const EdgeInsets paddingVertical16 = EdgeInsets.symmetric(vertical: spacing16);

  // iOS Specific Padding (from ios_theme.dart)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: largePadding,
    vertical: mediumPadding,
  );
  
  static const EdgeInsets cardPadding = EdgeInsets.all(mediumPadding);
  
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: largePadding,
    vertical: 12.0,
  );

  // Shadow Definitions
  static List<BoxShadow> get cardShadow => [
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
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // Input Decoration Constants
  static const double inputBorderRadius = radiusMedium;
  static const double inputBorderWidth = 1.5;
  static const double inputFocusedBorderWidth = 2.0;
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    horizontal: spacing16,
    vertical: spacing12,
  );

  // App Bar Constants
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;

  // Bottom Navigation Constants
  static const double bottomNavHeight = 60.0;
  static const double bottomNavElevation = 8.0;

  // List Item Constants
  static const double listItemHeight = 56.0;
  static const double listItemPadding = spacing16;

  // Glassmorphic Constants
  static const double glassBlur = 10.0;
  static const double glassOpacity = 0.2;
  static const double glassBorderOpacity = 0.3;

  // Loading Indicator Size
  static const double loadingIndicatorSize = 24.0;

  // Dialog Constants
  static const double dialogMaxWidth = 400.0;
  static const EdgeInsets dialogPadding = EdgeInsets.all(spacing24);
  static const double dialogRadius = radiusLarge;

  // Snackbar Constants
  static const EdgeInsets snackbarMargin = EdgeInsets.all(spacing16);
  static const double snackbarRadius = radiusMedium;

  // Helper methods
  static bool isMobile(double width) => width < mobileBreakpoint;
  static bool isTablet(double width) => width >= mobileBreakpoint && width < tabletBreakpoint;
  static bool isDesktop(double width) => width >= tabletBreakpoint;
  
  static EdgeInsets responsivePadding(double width) {
    if (isMobile(width)) return paddingAll16;
    if (isTablet(width)) return paddingAll20;
    return paddingAll24;
  }
}