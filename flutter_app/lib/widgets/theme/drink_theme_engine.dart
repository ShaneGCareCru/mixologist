import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Enum representing color temperature for drinks
enum ColorTemperature { cool, neutral, warm }

/// Data class containing all theme information for a specific drink
class DrinkThemeData {
  const DrinkThemeData({
    required this.primary,
    required this.accent,
    required this.temperature,
    required this.gradientColors,
    this.shadowColor,
    this.highlightColor,
  });

  final Color primary;
  final Color accent;
  final ColorTemperature temperature;
  final List<Color> gradientColors;
  final Color? shadowColor;
  final Color? highlightColor;

  /// Creates a copy of this theme with optional overrides
  DrinkThemeData copyWith({
    Color? primary,
    Color? accent,
    ColorTemperature? temperature,
    List<Color>? gradientColors,
    Color? shadowColor,
    Color? highlightColor,
  }) {
    return DrinkThemeData(
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      temperature: temperature ?? this.temperature,
      gradientColors: gradientColors ?? this.gradientColors,
      shadowColor: shadowColor ?? this.shadowColor,
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }

  /// Interpolates between two drink themes
  static DrinkThemeData lerp(DrinkThemeData a, DrinkThemeData b, double t) {
    return DrinkThemeData(
      primary: Color.lerp(a.primary, b.primary, t)!,
      accent: Color.lerp(a.accent, b.accent, t)!,
      temperature: t < 0.5 ? a.temperature : b.temperature,
      gradientColors: List.generate(
        a.gradientColors.length,
        (index) => Color.lerp(
          a.gradientColors[index],
          b.gradientColors.length > index ? b.gradientColors[index] : a.gradientColors[index],
          t,
        )!,
      ),
      shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t),
      highlightColor: Color.lerp(a.highlightColor, b.highlightColor, t),
    );
  }
}

/// Engine for managing drink-specific themes
class DrinkThemeEngine {
  static const Map<String, DrinkThemeData> _drinkThemes = {
    // Mojito - Cool, minty palette
    'mojito': DrinkThemeData(
      primary: Color(0xFF00CC88),
      accent: Color(0xFF4DFFA6),
      temperature: ColorTemperature.cool,
      gradientColors: [
        Color(0xFF00CC88),
        Color(0xFF33FFB2),
        Color(0xFF80FFCC),
        Color(0xFFB3FFDB),
      ],
      shadowColor: Color(0xFF004D33),
      highlightColor: Color(0xFF99FFCC),
    ),

    // Margarita - Warm, sunset tones
    'margarita': DrinkThemeData(
      primary: AppColors.goldenAmber,
      accent: AppColors.citrushZest,
      temperature: ColorTemperature.warm,
      gradientColors: [
        AppColors.goldenAmber,
        AppColors.citrushZest,
        AppColors.citrusGlow,
        AppColors.champagneGold,
      ],
      shadowColor: AppColors.richWhiskey,
      highlightColor: AppColors.champagneGold,
    ),

    // Martini - Sophisticated grays and silvers
    'martini': DrinkThemeData(
      primary: Color(0xFF8E8E93),
      accent: Color(0xFFC7C7CC),
      temperature: ColorTemperature.neutral,
      gradientColors: [
        Color(0xFF8E8E93),
        Color(0xFFC7C7CC),
        Color(0xFFE5E5EA),
        AppColors.crystallIce,
      ],
      shadowColor: Color(0xFF48484A),
      highlightColor: Color(0xFFF2F2F7),
    ),

    // Bloody Mary - Rich, warm reds
    'bloody_mary': DrinkThemeData(
      primary: AppColors.crimsonBitters,
      accent: AppColors.deepBitters,
      temperature: ColorTemperature.warm,
      gradientColors: [
        AppColors.crimsonBitters,
        AppColors.deepBitters,
        Color(0xFFCD5C5C),
        Color(0xFFF08080),
      ],
      shadowColor: Color(0xFF4A0E1A),
      highlightColor: Color(0xFFFFB6C1),
    ),

    // Old Fashioned - Warm whiskey tones
    'old_fashioned': DrinkThemeData(
      primary: AppColors.richWhiskey,
      accent: AppColors.warmCopper,
      temperature: ColorTemperature.warm,
      gradientColors: [
        AppColors.richWhiskey,
        AppColors.darkAmber,
        AppColors.warmCopper,
        AppColors.goldenAmber,
      ],
      shadowColor: Color(0xFF3A241A),
      highlightColor: AppColors.champagneGold,
    ),

    // Gin & Tonic - Cool, crisp palette
    'gin_tonic': DrinkThemeData(
      primary: Color(0xFF00B8D4),
      accent: Color(0xFF4DD0E1),
      temperature: ColorTemperature.cool,
      gradientColors: [
        Color(0xFF00B8D4),
        Color(0xFF4DD0E1),
        Color(0xFF80DEEA),
        Color(0xFFB2EBF2),
      ],
      shadowColor: Color(0xFF00595C),
      highlightColor: Color(0xFFE0F2F1),
    ),
  };

  /// Default neutral theme for unknown drinks
  static const DrinkThemeData _defaultTheme = DrinkThemeData(
    primary: AppColors.smokyGlass,
    accent: AppColors.crystallIce,
    temperature: ColorTemperature.neutral,
    gradientColors: [
      AppColors.smokyGlass,
      AppColors.charcoalSurface,
      Color(0xFF48484A),
      AppColors.crystallIce,
    ],
    shadowColor: Color(0xFF1C1C1E),
    highlightColor: AppColors.crystallIce,
  );

  /// Gets the theme for a specific drink name
  static DrinkThemeData getThemeForDrink(String drinkName) {
    final normalizedName = drinkName.toLowerCase().replaceAll(' ', '_');
    return _drinkThemes[normalizedName] ?? _defaultTheme;
  }

  /// Gets all available drink themes
  static Map<String, DrinkThemeData> getAllThemes() => Map.unmodifiable(_drinkThemes);

  /// Gets themes filtered by temperature
  static Map<String, DrinkThemeData> getThemesByTemperature(ColorTemperature temperature) {
    return Map.fromEntries(
      _drinkThemes.entries.where((entry) => entry.value.temperature == temperature),
    );
  }

  /// Searches for drink themes by name pattern
  static Map<String, DrinkThemeData> searchThemes(String pattern) {
    final lowerPattern = pattern.toLowerCase();
    return Map.fromEntries(
      _drinkThemes.entries.where((entry) => entry.key.contains(lowerPattern)),
    );
  }

  /// Gets a random theme from the collection
  static DrinkThemeData getRandomTheme() {
    final themes = _drinkThemes.values.toList();
    final randomIndex = DateTime.now().millisecondsSinceEpoch % themes.length;
    return themes[randomIndex];
  }

  /// Creates a gradient from the theme's gradient colors
  static LinearGradient createGradient(DrinkThemeData theme, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: theme.gradientColors,
      begin: begin,
      end: end,
    );
  }

  /// Creates a radial gradient for ambient effects
  static RadialGradient createRadialGradient(DrinkThemeData theme, {
    AlignmentGeometry center = Alignment.center,
    double radius = 0.8,
  }) {
    return RadialGradient(
      colors: theme.gradientColors,
      center: center,
      radius: radius,
    );
  }

  /// Gets the temperature warmth factor (-1.0 to 1.0)
  static double getTemperatureWarmth(ColorTemperature temperature) {
    switch (temperature) {
      case ColorTemperature.cool:
        return -0.7;
      case ColorTemperature.neutral:
        return 0.0;
      case ColorTemperature.warm:
        return 0.7;
    }
  }
}