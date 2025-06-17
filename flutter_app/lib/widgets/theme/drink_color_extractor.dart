import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'drink_theme_engine.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:math' as math;

/// Palette of colors extracted from an image
class ColorPalette {
  const ColorPalette({
    required this.dominant,
    required this.vibrant,
    required this.muted,
    required this.lightVibrant,
    required this.darkVibrant,
    required this.lightMuted,
    required this.darkMuted,
  });

  final Color dominant;
  final Color vibrant;
  final Color muted;
  final Color lightVibrant;
  final Color darkVibrant;
  final Color lightMuted;
  final Color darkMuted;

  /// Converts the palette to a JSON map for caching
  Map<String, dynamic> toJson() {
    return {
      'dominant': dominant.value,
      'vibrant': vibrant.value,
      'muted': muted.value,
      'lightVibrant': lightVibrant.value,
      'darkVibrant': darkVibrant.value,
      'lightMuted': lightMuted.value,
      'darkMuted': darkMuted.value,
    };
  }

  /// Creates a palette from a JSON map
  factory ColorPalette.fromJson(Map<String, dynamic> json) {
    return ColorPalette(
      dominant: Color(json['dominant']),
      vibrant: Color(json['vibrant']),
      muted: Color(json['muted']),
      lightVibrant: Color(json['lightVibrant']),
      darkVibrant: Color(json['darkVibrant']),
      lightMuted: Color(json['lightMuted']),
      darkMuted: Color(json['darkMuted']),
    );
  }
}

/// Service for extracting colors from drink images and generating themes
class DrinkColorExtractor {
  static const String _cacheKeyPrefix = 'extracted_theme_';
  static const int _maxCacheAge = 7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds

  /// Extracts a color palette from an image path
  static Future<ColorPalette> extractFromImage(String imagePath) async {
    try {
      // Check cache first
      final cachedPalette = await _getCachedPalette(imagePath);
      if (cachedPalette != null) {
        return cachedPalette;
      }

      // Load image
      final imageBytes = await _loadImageBytes(imagePath);
      final image = await _decodeImage(imageBytes);
      
      // Extract colors
      final palette = await _extractColors(image);
      
      // Cache the result
      await _cachePalette(imagePath, palette);
      
      return palette;
    } catch (e) {
      // Return a fallback palette based on the image path
      return _generateFallbackPalette(imagePath);
    }
  }

  /// Generates a DrinkThemeData from an extracted color palette
  static DrinkThemeData generateThemeFromPalette(ColorPalette palette, {
    String? drinkName,
    ColorTemperature? overrideTemperature,
  }) {
    // Determine color temperature from the palette
    final temperature = overrideTemperature ?? _determineTemperature(palette);
    
    // Select primary and accent colors based on vibrancy and contrast
    final primary = _selectPrimaryColor(palette);
    final accent = _selectAccentColor(palette, primary);
    
    // Generate gradient colors
    final gradientColors = _generateGradientColors(palette);
    
    // Generate shadow and highlight colors
    final shadowColor = _generateShadowColor(primary);
    final highlightColor = _generateHighlightColor(accent);
    
    return DrinkThemeData(
      primary: primary,
      accent: accent,
      temperature: temperature,
      gradientColors: gradientColors,
      shadowColor: shadowColor,
      highlightColor: highlightColor,
    );
  }

  /// Extracts colors and generates a complete theme in one step
  static Future<DrinkThemeData> extractThemeFromImage(
    String imagePath, {
    String? drinkName,
    ColorTemperature? overrideTemperature,
  }) async {
    final palette = await extractFromImage(imagePath);
    return generateThemeFromPalette(
      palette,
      drinkName: drinkName,
      overrideTemperature: overrideTemperature,
    );
  }

  /// Generates complementary themes based on a base theme
  static List<DrinkThemeData> generateComplementaryThemes(DrinkThemeData baseTheme) {
    final baseHsl = HSLColor.fromColor(baseTheme.primary);
    
    return [
      // Analogous theme (30 degrees)
      _generateAnalogousTheme(baseTheme, 30),
      
      // Complementary theme (180 degrees)
      _generateComplementaryTheme(baseTheme),
      
      // Triadic themes (120 degrees)
      _generateTriadicTheme(baseTheme, 120),
      _generateTriadicTheme(baseTheme, 240),
      
      // Monochromatic variations
      _generateMonochromaticTheme(baseTheme, 0.3),
      _generateMonochromaticTheme(baseTheme, -0.3),
    ];
  }

  /// Clears the theme cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix));
    
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  // Private helper methods

  static Future<Uint8List> _loadImageBytes(String imagePath) async {
    if (imagePath.startsWith('assets/')) {
      final data = await rootBundle.load(imagePath);
      return data.buffer.asUint8List();
    } else {
      // For network images, this would need to be implemented with http
      throw UnimplementedError('Network image loading not implemented');
    }
  }

  static Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  static Future<ColorPalette> _extractColors(ui.Image image) async {
    // Convert image to raw pixels
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) throw Exception('Failed to get image bytes');
    
    final pixels = byteData.buffer.asUint8List();
    final colorCounts = <int, int>{};
    
    // Sample pixels (for performance, we sample every 4th pixel)
    for (int i = 0; i < pixels.length; i += 16) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      final a = pixels[i + 3];
      
      if (a > 128) { // Only consider non-transparent pixels
        final color = (r << 16) | (g << 8) | b;
        colorCounts[color] = (colorCounts[color] ?? 0) + 1;
      }
    }
    
    // Get the most frequent colors
    final sortedColors = colorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Extract different types of colors
    final colors = sortedColors.map((e) => Color(0xFF000000 | e.key)).take(20).toList();
    
    return ColorPalette(
      dominant: colors.isNotEmpty ? colors.first : Colors.grey,
      vibrant: _findVibrantColor(colors),
      muted: _findMutedColor(colors),
      lightVibrant: _findLightVibrantColor(colors),
      darkVibrant: _findDarkVibrantColor(colors),
      lightMuted: _findLightMutedColor(colors),
      darkMuted: _findDarkMutedColor(colors),
    );
  }

  static Color _findVibrantColor(List<Color> colors) {
    Color mostVibrant = colors.first;
    double maxSaturation = 0.0;
    
    for (final color in colors) {
      final hsl = HSLColor.fromColor(color);
      if (hsl.saturation > maxSaturation && hsl.lightness > 0.3 && hsl.lightness < 0.8) {
        maxSaturation = hsl.saturation;
        mostVibrant = color;
      }
    }
    
    return mostVibrant;
  }

  static Color _findMutedColor(List<Color> colors) {
    Color mostMuted = colors.first;
    double minSaturation = 1.0;
    
    for (final color in colors) {
      final hsl = HSLColor.fromColor(color);
      if (hsl.saturation < minSaturation && hsl.lightness > 0.2 && hsl.lightness < 0.9) {
        minSaturation = hsl.saturation;
        mostMuted = color;
      }
    }
    
    return mostMuted;
  }

  static Color _findLightVibrantColor(List<Color> colors) {
    return _findColorByProperties(colors, minSaturation: 0.4, minLightness: 0.6);
  }

  static Color _findDarkVibrantColor(List<Color> colors) {
    return _findColorByProperties(colors, minSaturation: 0.4, maxLightness: 0.4);
  }

  static Color _findLightMutedColor(List<Color> colors) {
    return _findColorByProperties(colors, maxSaturation: 0.4, minLightness: 0.6);
  }

  static Color _findDarkMutedColor(List<Color> colors) {
    return _findColorByProperties(colors, maxSaturation: 0.4, maxLightness: 0.4);
  }

  static Color _findColorByProperties(
    List<Color> colors, {
    double minSaturation = 0.0,
    double maxSaturation = 1.0,
    double minLightness = 0.0,
    double maxLightness = 1.0,
  }) {
    for (final color in colors) {
      final hsl = HSLColor.fromColor(color);
      if (hsl.saturation >= minSaturation &&
          hsl.saturation <= maxSaturation &&
          hsl.lightness >= minLightness &&
          hsl.lightness <= maxLightness) {
        return color;
      }
    }
    return colors.first;
  }

  static ColorTemperature _determineTemperature(ColorPalette palette) {
    final dominantHsl = HSLColor.fromColor(palette.dominant);
    final hue = dominantHsl.hue;
    
    if (hue >= 180 && hue <= 270) {
      return ColorTemperature.cool; // Blue/cyan range
    } else if (hue >= 0 && hue <= 60 || hue >= 300 && hue <= 360) {
      return ColorTemperature.warm; // Red/orange/yellow range
    } else {
      return ColorTemperature.neutral;
    }
  }

  static Color _selectPrimaryColor(ColorPalette palette) {
    // Prefer vibrant over muted, but ensure good contrast
    final candidates = [palette.vibrant, palette.darkVibrant, palette.dominant];
    
    for (final color in candidates) {
      final hsl = HSLColor.fromColor(color);
      if (hsl.saturation > 0.3 && hsl.lightness > 0.2 && hsl.lightness < 0.8) {
        return color;
      }
    }
    
    return palette.dominant;
  }

  static Color _selectAccentColor(ColorPalette palette, Color primary) {
    // Find a complementary or contrasting color
    final primaryHsl = HSLColor.fromColor(primary);
    final candidates = [
      palette.lightVibrant,
      palette.lightMuted,
      palette.vibrant,
      palette.muted,
    ];
    
    Color bestAccent = candidates.first;
    double bestContrast = 0.0;
    
    for (final color in candidates) {
      if (color == primary) continue;
      
      final contrast = _calculateContrastRatio(primary, color);
      if (contrast > bestContrast) {
        bestContrast = contrast;
        bestAccent = color;
      }
    }
    
    return bestAccent;
  }

  static List<Color> _generateGradientColors(ColorPalette palette) {
    return [
      palette.dominant,
      palette.vibrant,
      palette.lightVibrant,
      palette.lightMuted,
    ];
  }

  static Color _generateShadowColor(Color primary) {
    final hsl = HSLColor.fromColor(primary);
    return hsl.withLightness((hsl.lightness * 0.3).clamp(0.0, 1.0)).toColor();
  }

  static Color _generateHighlightColor(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    return hsl.withLightness((hsl.lightness * 1.3).clamp(0.0, 1.0))
              .withSaturation((hsl.saturation * 0.7).clamp(0.0, 1.0))
              .toColor();
  }

  static double _calculateContrastRatio(Color color1, Color color2) {
    final lum1 = _calculateLuminance(color1);
    final lum2 = _calculateLuminance(color2);
    
    final lighter = math.max(lum1, lum2);
    final darker = math.min(lum1, lum2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _calculateLuminance(Color color) {
    final r = _gammaCorrect(color.red / 255.0);
    final g = _gammaCorrect(color.green / 255.0);
    final b = _gammaCorrect(color.blue / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _gammaCorrect(double value) {
    return value <= 0.03928 
        ? value / 12.92 
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  static Future<ColorPalette?> _getCachedPalette(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _cacheKeyPrefix + imagePath.hashCode.toString();
      final cachedData = prefs.getString(cacheKey);
      
      if (cachedData != null) {
        final data = jsonDecode(cachedData);
        final timestamp = data['timestamp'] as int;
        
        if (DateTime.now().millisecondsSinceEpoch - timestamp < _maxCacheAge) {
          return ColorPalette.fromJson(data['palette']);
        } else {
          // Cache expired, remove it
          await prefs.remove(cacheKey);
        }
      }
    } catch (e) {
      // Ignore cache errors
    }
    
    return null;
  }

  static Future<void> _cachePalette(String imagePath, ColorPalette palette) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _cacheKeyPrefix + imagePath.hashCode.toString();
      final data = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'palette': palette.toJson(),
      };
      
      await prefs.setString(cacheKey, jsonEncode(data));
    } catch (e) {
      // Ignore cache errors
    }
  }

  static ColorPalette _generateFallbackPalette(String imagePath) {
    // Generate a palette based on the image path hash
    final hash = imagePath.hashCode;
    final random = math.Random(hash);
    
    final baseHue = random.nextDouble() * 360;
    final baseSaturation = 0.5 + random.nextDouble() * 0.3;
    final baseLightness = 0.4 + random.nextDouble() * 0.2;
    
    final baseColor = HSLColor.fromAHSL(1.0, baseHue, baseSaturation, baseLightness);
    
    return ColorPalette(
      dominant: baseColor.toColor(),
      vibrant: baseColor.withSaturation(0.8).toColor(),
      muted: baseColor.withSaturation(0.3).toColor(),
      lightVibrant: baseColor.withLightness(0.7).withSaturation(0.8).toColor(),
      darkVibrant: baseColor.withLightness(0.3).withSaturation(0.8).toColor(),
      lightMuted: baseColor.withLightness(0.7).withSaturation(0.3).toColor(),
      darkMuted: baseColor.withLightness(0.3).withSaturation(0.3).toColor(),
    );
  }

  static DrinkThemeData _generateAnalogousTheme(DrinkThemeData baseTheme, double hueShift) {
    final baseHsl = HSLColor.fromColor(baseTheme.primary);
    final shiftedHue = (baseHsl.hue + hueShift) % 360;
    
    final newPrimary = baseHsl.withHue(shiftedHue).toColor();
    final newAccent = HSLColor.fromColor(baseTheme.accent).withHue(shiftedHue + 30).toColor();
    
    return baseTheme.copyWith(
      primary: newPrimary,
      accent: newAccent,
      gradientColors: baseTheme.gradientColors.map((color) {
        final hsl = HSLColor.fromColor(color);
        return hsl.withHue((hsl.hue + hueShift) % 360).toColor();
      }).toList(),
    );
  }

  static DrinkThemeData _generateComplementaryTheme(DrinkThemeData baseTheme) {
    return _generateAnalogousTheme(baseTheme, 180);
  }

  static DrinkThemeData _generateTriadicTheme(DrinkThemeData baseTheme, double hueShift) {
    return _generateAnalogousTheme(baseTheme, hueShift);
  }

  static DrinkThemeData _generateMonochromaticTheme(DrinkThemeData baseTheme, double lightnessShift) {
    final adjustColor = (Color color) {
      final hsl = HSLColor.fromColor(color);
      return hsl.withLightness((hsl.lightness + lightnessShift).clamp(0.0, 1.0)).toColor();
    };
    
    return baseTheme.copyWith(
      primary: adjustColor(baseTheme.primary),
      accent: adjustColor(baseTheme.accent),
      gradientColors: baseTheme.gradientColors.map(adjustColor).toList(),
    );
  }
}