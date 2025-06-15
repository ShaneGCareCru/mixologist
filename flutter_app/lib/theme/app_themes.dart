import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_constants.dart';

class AppThemes {
  static ThemeData buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.richWhiskey,
        brightness: Brightness.light,
        primary: AppColors.richWhiskey,
        secondary: AppColors.goldenAmber,
        surface: AppColors.crystallIce,
        error: AppColors.deepBitters,
        tertiary: AppColors.citrushZest,
        primaryContainer: AppColors.champagneGold,
        secondaryContainer: AppColors.champagneGold.withOpacity(0.3),
      ),
      textTheme: AppTextStyles.lightTextTheme,
      cardTheme: CardThemeData(
        elevation: AppConstants.elevationMedium,
        shadowColor: AppColors.richWhiskey.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white.withOpacity(0.9),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppConstants.elevationLow,
          shadowColor: AppColors.richWhiskey.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
          padding: AppConstants.paddingButton,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: AppColors.richWhiskey.withOpacity(0.2),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.richWhiskey,
        titleTextStyle: const TextStyle(
          color: AppColors.richWhiskey,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.goldenAmber.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.goldenAmber.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.richWhiskey, width: 2),
        ),
        contentPadding: AppConstants.paddingInput,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkAmber,
        brightness: Brightness.dark,
        primary: AppColors.darkAmber,
        secondary: AppColors.warmCopper,
        surface: AppColors.charcoalSurface,
        error: AppColors.crimsonBitters,
        tertiary: AppColors.citrusGlow,
        primaryContainer: AppColors.warmCopper.withOpacity(0.3),
        secondaryContainer: AppColors.smokyGlass,
      ),
      textTheme: AppTextStyles.darkTextTheme,
      cardTheme: CardThemeData(
        elevation: AppConstants.elevationHigh,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
        clipBehavior: Clip.antiAlias,
        color: AppColors.smokyGlass.withOpacity(0.85),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
          padding: AppConstants.paddingButton,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 8,
        shadowColor: Colors.black54,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkAmber,
        titleTextStyle: const TextStyle(
          color: AppColors.darkAmber,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.smokyGlass.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.warmCopper.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.warmCopper.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.darkAmber, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        contentPadding: AppConstants.paddingInput,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}