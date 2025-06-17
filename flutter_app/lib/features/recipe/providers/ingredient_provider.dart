import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/bubble_burst.dart';
import '../../../theme/cocktail_theme.dart';

class Ingredient {
  Ingredient({required this.name, required this.category, this.filled = 0.0});

  final String name;
  final IngredientCategory category;
  double filled;
  bool checked = false;
}

final ingredientProvider = StateNotifierProvider<IngredientNotifier, List<Ingredient>>(
  (ref) => IngredientNotifier([]),
);

class IngredientNotifier extends StateNotifier<List<Ingredient>> {
  IngredientNotifier(List<Ingredient> ingredients) : super(ingredients);

  void toggleCheck(int index, BuildContext context) {
    final ingredient = state[index];
    ingredient.checked = !ingredient.checked;
    ingredient.filled = ingredient.checked ? 1.0 : 0.0;
    state = [...state];
    // spawn bubble effect (simplified)
    Overlay.of(context)?.insert(
      OverlayEntry(builder: (_) => BubbleBurst(ingredientColor(context, ingredient.category))),
    );
    // TODO: analytics hook could be placed here
  }
}

Color ingredientColor(BuildContext context, IngredientCategory category) {
  final theme = Theme.of(context).extension<CocktailTheme>()!;
  switch (category) {
    case IngredientCategory.spirit:
      return theme.spirit;
    case IngredientCategory.citrus:
      return theme.citrus;
    case IngredientCategory.mixer:
      return theme.mixer;
  }
}
