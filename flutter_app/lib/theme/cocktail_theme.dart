import 'package:flutter/material.dart';

/// Ingredient categories used for color coding.
enum IngredientCategory { spirit, citrus, mixer }

/// Theme extension providing swatches for ingredient categories.
class CocktailTheme extends ThemeExtension<CocktailTheme> {
  const CocktailTheme({
    required this.spirit,
    required this.citrus,
    required this.mixer,
  });

  final Color spirit;
  final Color citrus;
  final Color mixer;

  @override
  CocktailTheme copyWith({Color? spirit, Color? citrus, Color? mixer}) {
    return CocktailTheme(
      spirit: spirit ?? this.spirit,
      citrus: citrus ?? this.citrus,
      mixer: mixer ?? this.mixer,
    );
  }

  @override
  CocktailTheme lerp(ThemeExtension<CocktailTheme>? other, double t) {
    if (other is! CocktailTheme) return this;
    return CocktailTheme(
      spirit: Color.lerp(spirit, other.spirit, t)!,
      citrus: Color.lerp(citrus, other.citrus, t)!,
      mixer: Color.lerp(mixer, other.mixer, t)!,
    );
  }
}

/// Helper to interpolate colors between two categories.
Color lerpCategory(IngredientCategory a, IngredientCategory b, BuildContext context) {
  final theme = Theme.of(context).extension<CocktailTheme>()!;
  final ca = _colorForCategory(a, theme);
  final cb = _colorForCategory(b, theme);
  return Color.lerp(ca, cb, 0.5)!;
}

Color _colorForCategory(IngredientCategory c, CocktailTheme theme) {
  switch (c) {
    case IngredientCategory.spirit:
      return theme.spirit;
    case IngredientCategory.citrus:
      return theme.citrus;
    case IngredientCategory.mixer:
      return theme.mixer;
  }
}
