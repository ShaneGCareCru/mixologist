import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class Ingredient {
  Ingredient(this.name, {this.checked = false, this.fill = 0});
  final String name;
  bool checked;
  double fill;
}

class IngredientNotifier extends StateNotifier<List<Ingredient>> {
  IngredientNotifier() : super([]);

  void toggleCheck(int index) {
    final item = state[index];
    item.checked = !item.checked;
    item.fill = item.checked ? 1.0 : 0.0;
    // Placeholder for analytics hook
    state = [...state];
  }
}

final ingredientProvider =
    StateNotifierProvider<IngredientNotifier, List<Ingredient>>(
        (ref) => IngredientNotifier());
