import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppConstants {
  // Border radius constants
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 20.0;

  // Elevation constants
  static const double elevationLow = 6.0;
  static const double elevationMedium = 12.0;
  static const double elevationHigh = 16.0;

  // Padding constants
  static const EdgeInsets paddingSmall = EdgeInsets.all(8.0);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16.0);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24.0);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(horizontal: 32, vertical: 18);
  static const EdgeInsets paddingInput = EdgeInsets.all(20);

  // Gradient definitions
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.champagneGold,
      AppColors.warmCream,
      AppColors.goldenAmber,
      AppColors.crystallIce,
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.charcoalSurface,
      AppColors.deepCharcoal,
      AppColors.richMahogany,
      AppColors.nightSky,
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // Component-specific gradients
  static const LinearGradient whiskyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.richWhiskey,
      AppColors.goldenAmber,
    ],
  );
}