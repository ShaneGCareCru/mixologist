import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'drink_theme_engine.dart';

/// Utility class for adjusting color temperature and HSL properties
class ColorTemperatureFilter {
  /// Adjusts the temperature of a color
  /// [warmth] ranges from -1.0 (cool) to 1.0 (warm)
  static Color adjustTemperature(Color base, double warmth) {
    // Clamp warmth to valid range
    warmth = warmth.clamp(-1.0, 1.0);
    
    final hsl = HSLColor.fromColor(base);
    
    // Adjust hue based on warmth
    double hueShift = 0.0;
    if (warmth > 0) {
      // Warm: shift towards red/orange (lower hue values)
      hueShift = -warmth * 30.0; // Up to 30 degrees towards red
    } else {
      // Cool: shift towards blue/cyan (higher hue values)
      hueShift = -warmth * 40.0; // Up to 40 degrees towards blue
    }
    
    final newHue = (hsl.hue + hueShift) % 360.0;
    
    // Adjust saturation - warm colors tend to be more saturated
    final saturationAdjustment = warmth * 0.1; // Up to 10% saturation change
    final newSaturation = (hsl.saturation + saturationAdjustment).clamp(0.0, 1.0);
    
    // Adjust lightness - cool colors slightly brighter, warm colors slightly deeper
    final lightnessAdjustment = -warmth * 0.05; // Up to 5% lightness change
    final newLightness = (hsl.lightness + lightnessAdjustment).clamp(0.0, 1.0);
    
    return hsl.withHue(newHue)
              .withSaturation(newSaturation)
              .withLightness(newLightness)
              .toColor();
  }

  /// Applies temperature curve adjustments for more natural color transitions
  static Color adjustWithCurve(Color base, double warmth, {TemperatureCurve curve = TemperatureCurve.natural}) {
    final adjustedWarmth = _applyCurve(warmth, curve);
    return adjustTemperature(base, adjustedWarmth);
  }

  /// Preserves color relationships when adjusting temperature
  static List<Color> adjustColorsPreservingRelationships(List<Color> colors, double warmth) {
    if (colors.isEmpty) return colors;
    
    // Calculate the average hue and saturation of all colors
    double totalHue = 0.0;
    double totalSaturation = 0.0;
    
    final hslColors = colors.map((c) => HSLColor.fromColor(c)).toList();
    
    for (final hsl in hslColors) {
      totalHue += hsl.hue;
      totalSaturation += hsl.saturation;
    }
    
    final averageHue = totalHue / hslColors.length;
    final averageSaturation = totalSaturation / hslColors.length;
    
    // Apply temperature adjustment while preserving relative differences
    return hslColors.map((hsl) {
      final hueOffset = hsl.hue - averageHue;
      final saturationOffset = hsl.saturation - averageSaturation;
      
      final adjustedBase = adjustTemperature(hsl.toColor(), warmth);
      final adjustedHsl = HSLColor.fromColor(adjustedBase);
      
      // Preserve relative differences
      final finalHue = (adjustedHsl.hue + hueOffset * 0.7) % 360.0;
      final finalSaturation = (adjustedHsl.saturation + saturationOffset * 0.5).clamp(0.0, 1.0);
      
      return adjustedHsl.withHue(finalHue)
                       .withSaturation(finalSaturation)
                       .toColor();
    }).toList();
  }

  /// Adjusts a color for accessibility while maintaining visual appeal
  static Color adjustForAccessibility(Color base, double warmth, {
    double minContrast = 4.5,
    Color? backgroundColor,
  }) {
    backgroundColor ??= Colors.white;
    
    Color adjusted = adjustTemperature(base, warmth);
    
    // Check contrast ratio and adjust if needed
    final contrast = _calculateContrastRatio(adjusted, backgroundColor);
    
    if (contrast < minContrast) {
      final hsl = HSLColor.fromColor(adjusted);
      
      // Adjust lightness to meet contrast requirements
      double newLightness = hsl.lightness;
      const step = 0.05;
      
      // Try darkening first
      while (newLightness > 0.0 && _calculateContrastRatio(
        hsl.withLightness(newLightness).toColor(),
        backgroundColor,
      ) < minContrast) {
        newLightness -= step;
      }
      
      // If darkening didn't work, try lightening
      if (newLightness <= 0.0) {
        newLightness = hsl.lightness;
        while (newLightness < 1.0 && _calculateContrastRatio(
          hsl.withLightness(newLightness).toColor(),
          backgroundColor,
        ) < minContrast) {
          newLightness += step;
        }
      }
      
      adjusted = hsl.withLightness(newLightness.clamp(0.0, 1.0)).toColor();
    }
    
    return adjusted;
  }

  /// Creates a temperature-adjusted gradient
  static LinearGradient createTemperatureGradient(
    List<Color> baseColors,
    double warmth, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    final adjustedColors = adjustColorsPreservingRelationships(baseColors, warmth);
    
    return LinearGradient(
      colors: adjustedColors,
      begin: begin,
      end: end,
      stops: stops,
    );
  }

  /// Applies temperature filter to a drink theme
  static DrinkThemeData applyTemperatureFilter(DrinkThemeData theme, double warmth) {
    return theme.copyWith(
      primary: adjustTemperature(theme.primary, warmth),
      accent: adjustTemperature(theme.accent, warmth),
      gradientColors: adjustColorsPreservingRelationships(theme.gradientColors, warmth),
      shadowColor: theme.shadowColor != null ? adjustTemperature(theme.shadowColor!, warmth) : null,
      highlightColor: theme.highlightColor != null ? adjustTemperature(theme.highlightColor!, warmth) : null,
    );
  }

  /// Gets the warmth factor for a color temperature
  static double getWarmthFactor(ColorTemperature temperature) {
    switch (temperature) {
      case ColorTemperature.cool:
        return -0.7;
      case ColorTemperature.neutral:
        return 0.0;
      case ColorTemperature.warm:
        return 0.7;
    }
  }

  /// Calculates relative luminance for contrast calculations
  static double _calculateRelativeLuminance(Color color) {
    final r = _gammaCorrect(color.red / 255.0);
    final g = _gammaCorrect(color.green / 255.0);
    final b = _gammaCorrect(color.blue / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Applies gamma correction
  static double _gammaCorrect(double value) {
    return value <= 0.03928 ? value / 12.92 : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Calculates contrast ratio between two colors
  static double _calculateContrastRatio(Color color1, Color color2) {
    final lum1 = _calculateRelativeLuminance(color1);
    final lum2 = _calculateRelativeLuminance(color2);
    
    final lighter = math.max(lum1, lum2);
    final darker = math.min(lum1, lum2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Applies temperature curve for more natural adjustments
  static double _applyCurve(double warmth, TemperatureCurve curve) {
    switch (curve) {
      case TemperatureCurve.linear:
        return warmth;
      
      case TemperatureCurve.natural:
        // S-curve for more natural temperature transitions
        return _sCurve(warmth);
      
      case TemperatureCurve.gentle:
        // Gentle curve for subtle adjustments
        return warmth * 0.7;
      
      case TemperatureCurve.dramatic:
        // Dramatic curve for strong adjustments
        return _dramaticCurve(warmth);
    }
  }

  /// S-curve function for natural temperature transitions
  static double _sCurve(double x) {
    // Cubic S-curve: f(x) = 3x² - 2x³ for x in [0,1]
    // Adapted for range [-1,1]
    final normalized = (x + 1.0) / 2.0; // Convert to [0,1]
    final curved = 3 * normalized * normalized - 2 * normalized * normalized * normalized;
    return curved * 2.0 - 1.0; // Convert back to [-1,1]
  }

  /// Dramatic curve for strong temperature adjustments
  static double _dramaticCurve(double x) {
    return x * math.pow(x.abs(), 0.5) * (x.abs() > 0 ? (x > 0 ? 1 : -1) : 0);
  }
}

/// Enum for different temperature adjustment curves
enum TemperatureCurve {
  linear,    // Direct linear adjustment
  natural,   // S-curve for natural looking transitions
  gentle,    // Subtle adjustments
  dramatic,  // Strong adjustments
}

/// Extension for easy color temperature adjustments
extension ColorTemperatureExtension on Color {
  /// Adjusts this color's temperature
  Color adjustTemperature(double warmth) {
    return ColorTemperatureFilter.adjustTemperature(this, warmth);
  }
  
  /// Adjusts this color's temperature with a curve
  Color adjustTemperatureWithCurve(double warmth, {TemperatureCurve curve = TemperatureCurve.natural}) {
    return ColorTemperatureFilter.adjustWithCurve(this, warmth, curve: curve);
  }
  
  /// Makes this color accessible against a background
  Color makeAccessible({double minContrast = 4.5, Color? backgroundColor}) {
    return ColorTemperatureFilter.adjustForAccessibility(this, 0.0, 
      minContrast: minContrast, backgroundColor: backgroundColor);
  }
}

/// Extension for color lists
extension ColorListTemperatureExtension on List<Color> {
  /// Adjusts all colors while preserving relationships
  List<Color> adjustTemperature(double warmth) {
    return ColorTemperatureFilter.adjustColorsPreservingRelationships(this, warmth);
  }
  
  /// Creates a temperature-adjusted gradient
  LinearGradient toTemperatureGradient(double warmth, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return ColorTemperatureFilter.createTemperatureGradient(this, warmth, begin: begin, end: end);
  }
}