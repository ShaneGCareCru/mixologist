import 'package:flutter/material.dart';

/// Dynamic typography system that adapts to drink categories and contexts
/// Each drink type has its own personality reflected in typography choices
class DrinkAwareTypography {
  /// Get typography theme based on drink category and brightness
  static TextTheme getThemeForDrink(
    DrinkCategory category,
    Brightness brightness, {
    double? scaleFactor,
  }) {
    final scale = scaleFactor ?? 1.0;
    final isDark = brightness == Brightness.dark;
    
    switch (category) {
      case DrinkCategory.cocktail:
        return _buildCocktailTheme(isDark, scale);
      case DrinkCategory.mocktail:
        return _buildMocktailTheme(isDark, scale);
      case DrinkCategory.classic:
        return _buildClassicTheme(isDark, scale);
      case DrinkCategory.modern:
        return _buildModernTheme(isDark, scale);
      case DrinkCategory.tiki:
        return _buildTikiTheme(isDark, scale);
      case DrinkCategory.wine:
        return _buildWineTheme(isDark, scale);
      case DrinkCategory.beer:
        return _buildBeerTheme(isDark, scale);
      case DrinkCategory.spirit:
        return _buildSpiritTheme(isDark, scale);
    }
  }
  
  /// Get color scheme for drink category
  static ColorScheme getColorSchemeForDrink(
    DrinkCategory category,
    Brightness brightness,
  ) {
    final isDark = brightness == Brightness.dark;
    
    switch (category) {
      case DrinkCategory.cocktail:
        return _buildCocktailColors(isDark);
      case DrinkCategory.mocktail:
        return _buildMocktailColors(isDark);
      case DrinkCategory.classic:
        return _buildClassicColors(isDark);
      case DrinkCategory.modern:
        return _buildModernColors(isDark);
      case DrinkCategory.tiki:
        return _buildTikiColors(isDark);
      case DrinkCategory.wine:
        return _buildWineColors(isDark);
      case DrinkCategory.beer:
        return _buildBeerColors(isDark);
      case DrinkCategory.spirit:
        return _buildSpiritColors(isDark);
    }
  }
  
  // Cocktail Theme - Elegant and sophisticated
  static TextTheme _buildCocktailTheme(bool isDark, double scale) {
    final baseColor = isDark ? const Color(0xFFF5F5DC) : const Color(0xFF36454F);
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: baseColor,
        fontFamily: 'Playfair Display', // Elegant serif
      ),
      displayMedium: TextStyle(
        fontSize: 45 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: baseColor,
        fontFamily: 'Playfair Display',
      ),
      displaySmall: TextStyle(
        fontSize: 36 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: baseColor,
        fontFamily: 'Playfair Display',
      ),
      headlineLarge: TextStyle(
        fontSize: 32 * scale,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: baseColor,
        fontFamily: 'Inter',
      ),
      headlineMedium: TextStyle(
        fontSize: 28 * scale,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: baseColor,
        fontFamily: 'Inter',
      ),
      headlineSmall: TextStyle(
        fontSize: 24 * scale,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: baseColor,
        fontFamily: 'Inter',
      ),
      titleLarge: TextStyle(
        fontSize: 22 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: baseColor,
        fontFamily: 'Inter',
      ),
      titleMedium: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: baseColor,
        fontFamily: 'Inter',
      ),
      titleSmall: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: baseColor,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: baseColor,
        fontFamily: 'Inter',
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: baseColor,
        fontFamily: 'Inter',
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: baseColor,
        fontFamily: 'Inter',
        height: 1.33,
      ),
      labelLarge: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: baseColor,
        fontFamily: 'Inter',
      ),
      labelMedium: TextStyle(
        fontSize: 12 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: baseColor,
        fontFamily: 'Inter',
      ),
      labelSmall: TextStyle(
        fontSize: 11 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: baseColor,
        fontFamily: 'Inter',
      ),
    );
  }
  
  // Mocktail Theme - Fresh and playful
  static TextTheme _buildMocktailTheme(bool isDark, double scale) {
    final baseColor = isDark ? const Color(0xFFE8F5E8) : const Color(0xFF2E7D32);
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 54 * scale,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
        color: baseColor,
        fontFamily: 'Poppins', // Friendly sans-serif
      ),
      headlineLarge: TextStyle(
        fontSize: 30 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.8,
        color: baseColor,
        fontFamily: 'Poppins',
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.6,
        color: baseColor,
        fontFamily: 'Poppins',
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: baseColor,
        fontFamily: 'Poppins',
      ),
    );
  }
  
  // Classic Theme - Timeless and traditional
  static TextTheme _buildClassicTheme(bool isDark, double scale) {
    final baseColor = isDark ? const Color(0xFFF5F5DC) : const Color(0xFF1B1B1B);
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 60 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
        color: baseColor,
        fontFamily: 'Crimson Text', // Classic serif
      ),
      headlineLarge: TextStyle(
        fontSize: 34 * scale,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: baseColor,
        fontFamily: 'Crimson Text',
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: baseColor,
        fontFamily: 'Source Serif Pro',
        height: 1.7,
      ),
      labelLarge: TextStyle(
        fontSize: 13 * scale,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: baseColor,
        fontFamily: 'Source Sans Pro',
      ),
    );
  }
  
  // Modern Theme - Clean and minimalist
  static TextTheme _buildModernTheme(bool isDark, double scale) {
    final baseColor = isDark ? Colors.white : Colors.black;
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 56 * scale,
        fontWeight: FontWeight.w100,
        letterSpacing: -1.5,
        color: baseColor,
        fontFamily: 'Roboto', // Clean sans-serif
      ),
      headlineLarge: TextStyle(
        fontSize: 32 * scale,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
        color: baseColor,
        fontFamily: 'Roboto',
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
        color: baseColor,
        fontFamily: 'Roboto',
        height: 1.8,
      ),
      labelLarge: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.0,
        color: baseColor,
        fontFamily: 'Roboto',
      ),
    );
  }
  
  // Tiki Theme - Tropical and adventurous
  static TextTheme _buildTikiTheme(bool isDark, double scale) {
    final baseColor = isDark ? const Color(0xFFFFE082) : const Color(0xFF5D4037);
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 58 * scale,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: baseColor,
        fontFamily: 'Fredoka One', // Playful display font
      ),
      headlineLarge: TextStyle(
        fontSize: 36 * scale,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: baseColor,
        fontFamily: 'Nunito',
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.8,
        color: baseColor,
        fontFamily: 'Nunito',
        height: 1.6,
      ),
      labelLarge: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: baseColor,
        fontFamily: 'Nunito',
      ),
    );
  }
  
  // Wine Theme - Refined and sophisticated
  static TextTheme _buildWineTheme(bool isDark, double scale) {
    final baseColor = isDark ? const Color(0xFFE1BEE7) : const Color(0xFF4A148C);
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 55 * scale,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.8,
        color: baseColor,
        fontFamily: 'Cormorant Garamond', // Elegant serif
      ),
      headlineLarge: TextStyle(
        fontSize: 32 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        color: baseColor,
        fontFamily: 'Cormorant Garamond',
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: baseColor,
        fontFamily: 'Lato',
        height: 1.6,
      ),
    );
  }
  
  // Beer Theme - Casual and approachable
  static TextTheme _buildBeerTheme(bool isDark, double scale) {
    final baseColor = isDark ? const Color(0xFFFFCC02) : const Color(0xFF795548);
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 52 * scale,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: baseColor,
        fontFamily: 'Oswald', // Bold condensed font
      ),
      headlineLarge: TextStyle(
        fontSize: 30 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        color: baseColor,
        fontFamily: 'Oswald',
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: baseColor,
        fontFamily: 'Open Sans',
        height: 1.5,
      ),
    );
  }
  
  // Spirit Theme - Strong and bold
  static TextTheme _buildSpiritTheme(bool isDark, double scale) {
    final baseColor = isDark ? const Color(0xFFFFAB40) : const Color(0xFF1A1A1A);
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 62 * scale,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: baseColor,
        fontFamily: 'Bebas Neue', // Strong display font
      ),
      headlineLarge: TextStyle(
        fontSize: 38 * scale,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: baseColor,
        fontFamily: 'Bebas Neue',
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: baseColor,
        fontFamily: 'Source Sans Pro',
        height: 1.4,
      ),
    );
  }
  
  // Color scheme builders
  static ColorScheme _buildCocktailColors(bool isDark) {
    return isDark
        ? const ColorScheme.dark(
            primary: Color(0xFFB8860B), // Amber
            secondary: Color(0xFF87A96B), // Sage
            surface: Color(0xFF1A1A1A),
            background: Color(0xFF121212),
            onPrimary: Color(0xFF000000),
            onSecondary: Color(0xFFFFFFFF),
            onSurface: Color(0xFFF5F5DC),
            onBackground: Color(0xFFF5F5DC),
          )
        : const ColorScheme.light(
            primary: Color(0xFFB8860B),
            secondary: Color(0xFF87A96B),
            surface: Color(0xFFFAFAFA),
            background: Color(0xFFFFFFFF),
            onPrimary: Color(0xFFFFFFFF),
            onSecondary: Color(0xFF000000),
            onSurface: Color(0xFF36454F),
            onBackground: Color(0xFF36454F),
          );
  }
  
  static ColorScheme _buildMocktailColors(bool isDark) {
    return isDark
        ? const ColorScheme.dark(
            primary: Color(0xFF4CAF50),
            secondary: Color(0xFF81C784),
            surface: Color(0xFF1B1B1B),
            tertiary: Color(0xFFFFEB3B),
          )
        : const ColorScheme.light(
            primary: Color(0xFF2E7D32),
            secondary: Color(0xFF66BB6A),
            surface: Color(0xFFF1F8E9),
            tertiary: Color(0xFFFBC02D),
          );
  }
  
  static ColorScheme _buildClassicColors(bool isDark) {
    return isDark
        ? const ColorScheme.dark(
            primary: Color(0xFFD4AF37), // Gold
            secondary: Color(0xFF8B4513), // Saddle Brown
            surface: Color(0xFF2C2C2C),
          )
        : const ColorScheme.light(
            primary: Color(0xFF8B4513),
            secondary: Color(0xFFD4AF37),
            surface: Color(0xFFFAF0E6),
          );
  }
  
  static ColorScheme _buildModernColors(bool isDark) {
    return isDark
        ? const ColorScheme.dark(
            primary: Color(0xFF00BCD4),
            secondary: Color(0xFF607D8B),
            surface: Color(0xFF0A0A0A),
          )
        : const ColorScheme.light(
            primary: Color(0xFF212121),
            secondary: Color(0xFF757575),
            surface: Color(0xFFFFFFFE),
          );
  }
  
  static ColorScheme _buildTikiColors(bool isDark) {
    return isDark
        ? const ColorScheme.dark(
            primary: Color(0xFFFF5722),
            secondary: Color(0xFFFFAB00),
            surface: Color(0xFF3E2723),
            tertiary: Color(0xFF4CAF50),
          )
        : const ColorScheme.light(
            primary: Color(0xFFD84315),
            secondary: Color(0xFFFFA000),
            surface: Color(0xFFFFF3E0),
            tertiary: Color(0xFF388E3C),
          );
  }
  
  static ColorScheme _buildWineColors(bool isDark) {
    return isDark
        ? const ColorScheme.dark(
            primary: Color(0xFF9C27B0),
            secondary: Color(0xFFE1BEE7),
            surface: Color(0xFF1A0E1A),
          )
        : const ColorScheme.light(
            primary: Color(0xFF6A1B9A),
            secondary: Color(0xFFBA68C8),
            surface: Color(0xFFF3E5F5),
          );
  }
  
  static ColorScheme _buildBeerColors(bool isDark) {
    return isDark
        ? const ColorScheme.dark(
            primary: Color(0xFFFFB300),
            secondary: Color(0xFF8D6E63),
            surface: Color(0xFF2E1A00),
          )
        : const ColorScheme.light(
            primary: Color(0xFFFF8F00),
            secondary: Color(0xFF6D4C41),
            surface: Color(0xFFFFF8E1),
          );
  }
  
  static ColorScheme _buildSpiritColors(bool isDark) {
    return isDark
        ? const ColorScheme.dark(
            primary: Color(0xFFFF6F00),
            secondary: Color(0xFFBF360C),
            surface: Color(0xFF1C1208),
          )
        : const ColorScheme.light(
            primary: Color(0xFFE65100),
            secondary: Color(0xFF8D2F00),
            surface: Color(0xFFFFF3E0),
          );
  }
}

/// Drink categories for typography theming
enum DrinkCategory {
  cocktail,
  mocktail,
  classic,
  modern,
  tiki,
  wine,
  beer,
  spirit,
}

/// Context-aware typography that adapts to current screen
class ContextualTypography extends StatelessWidget {
  final String text;
  final DrinkCategory category;
  final TypographyLevel level;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final double? scaleFactor;
  
  const ContextualTypography({
    super.key,
    required this.text,
    required this.category,
    required this.level,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.scaleFactor,
  });
  
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textTheme = DrinkAwareTypography.getThemeForDrink(
      category,
      brightness,
      scaleFactor: scaleFactor,
    );
    
    TextStyle? style;
    switch (level) {
      case TypographyLevel.displayLarge:
        style = textTheme.displayLarge;
        break;
      case TypographyLevel.displayMedium:
        style = textTheme.displayMedium;
        break;
      case TypographyLevel.displaySmall:
        style = textTheme.displaySmall;
        break;
      case TypographyLevel.headlineLarge:
        style = textTheme.headlineLarge;
        break;
      case TypographyLevel.headlineMedium:
        style = textTheme.headlineMedium;
        break;
      case TypographyLevel.headlineSmall:
        style = textTheme.headlineSmall;
        break;
      case TypographyLevel.titleLarge:
        style = textTheme.titleLarge;
        break;
      case TypographyLevel.titleMedium:
        style = textTheme.titleMedium;
        break;
      case TypographyLevel.titleSmall:
        style = textTheme.titleSmall;
        break;
      case TypographyLevel.bodyLarge:
        style = textTheme.bodyLarge;
        break;
      case TypographyLevel.bodyMedium:
        style = textTheme.bodyMedium;
        break;
      case TypographyLevel.bodySmall:
        style = textTheme.bodySmall;
        break;
      case TypographyLevel.labelLarge:
        style = textTheme.labelLarge;
        break;
      case TypographyLevel.labelMedium:
        style = textTheme.labelMedium;
        break;
      case TypographyLevel.labelSmall:
        style = textTheme.labelSmall;
        break;
    }
    
    return Text(
      text,
      style: color != null ? style?.copyWith(color: color) : style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Typography levels for contextual text
enum TypographyLevel {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

/// Font pairing recommendations for different drink categories
class FontPairings {
  /// Get font pairing for a drink category
  static FontPairing getFontPairing(DrinkCategory category) {
    switch (category) {
      case DrinkCategory.cocktail:
        return const FontPairing(
          display: 'Playfair Display',
          heading: 'Inter',
          body: 'Inter',
          accent: 'Dancing Script',
        );
      case DrinkCategory.mocktail:
        return const FontPairing(
          display: 'Poppins',
          heading: 'Poppins',
          body: 'Poppins',
          accent: 'Quicksand',
        );
      case DrinkCategory.classic:
        return const FontPairing(
          display: 'Crimson Text',
          heading: 'Crimson Text',
          body: 'Source Serif Pro',
          accent: 'Source Sans Pro',
        );
      case DrinkCategory.modern:
        return const FontPairing(
          display: 'Roboto',
          heading: 'Roboto',
          body: 'Roboto',
          accent: 'Roboto Mono',
        );
      case DrinkCategory.tiki:
        return const FontPairing(
          display: 'Fredoka One',
          heading: 'Nunito',
          body: 'Nunito',
          accent: 'Pacifico',
        );
      case DrinkCategory.wine:
        return const FontPairing(
          display: 'Cormorant Garamond',
          heading: 'Cormorant Garamond',
          body: 'Lato',
          accent: 'Great Vibes',
        );
      case DrinkCategory.beer:
        return const FontPairing(
          display: 'Oswald',
          heading: 'Oswald',
          body: 'Open Sans',
          accent: 'Patua One',
        );
      case DrinkCategory.spirit:
        return const FontPairing(
          display: 'Bebas Neue',
          heading: 'Bebas Neue',
          body: 'Source Sans Pro',
          accent: 'Orbitron',
        );
    }
  }
}

/// Font pairing data model
class FontPairing {
  final String display;   // For large titles and hero text
  final String heading;   // For section headers
  final String body;      // For main content
  final String accent;    // For special emphasis
  
  const FontPairing({
    required this.display,
    required this.heading,
    required this.body,
    required this.accent,
  });
}

/// Utility for calculating responsive font sizes
class ResponsiveFontSizes {
  /// Calculate font size based on screen width
  static double getResponsiveSize(
    double baseSize,
    double screenWidth, {
    double minSize = 12.0,
    double maxSize = 72.0,
    double breakpoint = 600.0,
  }) {
    if (screenWidth <= breakpoint) {
      // Mobile scaling
      final scale = (screenWidth / breakpoint).clamp(0.8, 1.0);
      return (baseSize * scale).clamp(minSize, maxSize);
    } else {
      // Desktop scaling
      final scale = 1.0 + ((screenWidth - breakpoint) / 1200) * 0.2;
      return (baseSize * scale).clamp(minSize, maxSize);
    }
  }
  
  /// Get scale factor based on device type
  static double getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 400) {
      return 0.9; // Small phones
    } else if (screenWidth < 600) {
      return 1.0; // Regular phones
    } else if (screenWidth < 900) {
      return 1.1; // Tablets
    } else {
      return 1.2; // Desktop
    }
  }
}

/// Extension methods for easy typography integration
extension TypographyExtensions on String {
  /// Convert string to contextual typography widget
  Widget toContextualText({
    required DrinkCategory category,
    required TypographyLevel level,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) {
    return ContextualTypography(
      text: this,
      category: category,
      level: level,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      color: color,
    );
  }
  
  /// Create a cocktail-themed headline
  Widget toCocktailHeadline({
    TextAlign? textAlign,
    Color? color,
  }) {
    return ContextualTypography(
      text: this,
      category: DrinkCategory.cocktail,
      level: TypographyLevel.headlineLarge,
      textAlign: textAlign,
      color: color,
    );
  }
  
  /// Create a mocktail-themed title
  Widget toMocktailTitle({
    TextAlign? textAlign,
    Color? color,
  }) {
    return ContextualTypography(
      text: this,
      category: DrinkCategory.mocktail,
      level: TypographyLevel.titleLarge,
      textAlign: textAlign,
      color: color,
    );
  }
}