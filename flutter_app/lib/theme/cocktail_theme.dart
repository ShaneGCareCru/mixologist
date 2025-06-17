import 'package:flutter/material.dart';

/// Ingredient categories used to color liquid drops.
enum IngredientCategory { spirit, citrus, mixer }

/// Theme extension containing swatches for each ingredient category.
class CocktailTheme extends ThemeExtension<CocktailTheme> {
  CocktailTheme({
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

/// Returns a color blended between the two categories.
Color lerpCategory(IngredientCategory a, IngredientCategory b, CocktailTheme theme) {
  Color first = _catColor(a, theme);
  Color second = _catColor(b, theme);
  return Color.lerp(first, second, 0.5)!;
}

Color _catColor(IngredientCategory c, CocktailTheme theme) {
  switch (c) {
    case IngredientCategory.spirit:
      return theme.spirit;
    case IngredientCategory.citrus:
      return theme.citrus;
    case IngredientCategory.mixer:
      return theme.mixer;
  }
}
