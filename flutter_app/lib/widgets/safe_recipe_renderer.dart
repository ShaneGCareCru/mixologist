import 'package:flutter/material.dart';

/// Utility class for safely accessing recipe data with graceful fallbacks
/// Implements the "Graceful Data Handling" principle from our design philosophy
class SafeRecipeData {
  final Map<String, dynamic> _rawData;
  
  const SafeRecipeData(this._rawData);
  
  /// Safely get the recipe name with fallback
  String get name => _rawData['drink_name']?.toString() ?? _rawData['name']?.toString() ?? 'Unnamed Cocktail';
  
  /// Safely get recipe description with fallback
  String get description => _rawData['description']?.toString() ?? 'A delicious cocktail worth trying.';
  
  /// Safely get ingredients list with validation
  List<Map<String, dynamic>> get ingredients {
    final rawIngredients = _rawData['ingredients'];
    if (rawIngredients is! List) return [];
    
    return rawIngredients.map((ingredient) {
      if (ingredient is Map<String, dynamic>) {
        return ingredient;
      } else if (ingredient is String) {
        // Handle simple string ingredients
        return {'name': ingredient, 'quantity': '1 part'};
      } else {
        return {'name': 'Unknown ingredient', 'quantity': 'To taste'};
      }
    }).toList();
  }
  
  /// Safely get steps/method list with validation
  List<String> get steps {
    final rawSteps = _rawData['steps'] ?? _rawData['method'];
    if (rawSteps is! List) return ['Preparation instructions will be available soon.'];
    
    return rawSteps.map((step) => step?.toString() ?? 'Step information missing').toList();
  }
  
  /// Safely get equipment list with validation
  List<String> get equipment {
    final rawEquipment = _rawData['equipment_needed'] ?? _rawData['equipment'];
    if (rawEquipment is! List) return [];
    
    return rawEquipment.map((item) {
      if (item is Map<String, dynamic>) {
        return item['item']?.toString() ?? item['name']?.toString() ?? 'Unknown equipment';
      } else if (item is String) {
        return item;
      } else {
        return 'Standard bar equipment';
      }
    }).toList();
  }
  
  /// Safely get glass type with fallback
  String get glassType => _rawData['serving_glass']?.toString() ?? _rawData['glass']?.toString() ?? 'Cocktail glass';
  
  /// Safely get garnish with fallback
  String get garnish => _rawData['garnish']?.toString() ?? 'Garnish as desired';
  
  /// Check if recipe has sufficient data for display
  bool get isComplete => ingredients.isNotEmpty && steps.isNotEmpty;
  
  /// Get ingredient by index safely
  Map<String, dynamic>? getIngredient(int index) {
    if (index < 0 || index >= ingredients.length) return null;
    return ingredients[index];
  }
  
  /// Get step by index safely
  String? getStep(int index) {
    if (index < 0 || index >= steps.length) return null;
    return steps[index];
  }
  
  /// Get equipment by index safely  
  String? getEquipment(int index) {
    if (index < 0 || index >= equipment.length) return null;
    return equipment[index];
  }
  
  /// Safely get ingredient name with fallback
  String getIngredientName(int index) {
    final ingredient = getIngredient(index);
    return ingredient?['name']?.toString() ?? 'Unknown ingredient';
  }
  
  /// Safely get ingredient quantity with fallback
  String getIngredientQuantity(int index) {
    final ingredient = getIngredient(index);
    return ingredient?['quantity']?.toString() ?? ingredient?['amount']?.toString() ?? 'To taste';
  }
}

/// Widget wrapper that provides safe recipe data access
/// Implements defensive design patterns from our design philosophy
class SafeRecipeRenderer extends StatelessWidget {
  final Map<String, dynamic> recipeData;
  final Widget Function(BuildContext context, SafeRecipeData safeData) builder;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  
  const SafeRecipeRenderer({
    super.key,
    required this.recipeData,
    required this.builder,
    this.errorWidget,
    this.emptyWidget,
  });
  
  @override
  Widget build(BuildContext context) {
    try {
      final safeData = SafeRecipeData(recipeData);
      
      // Show empty state if recipe is fundamentally incomplete
      if (!safeData.isComplete) {
        return emptyWidget ?? _buildEmptyState(context);
      }
      
      return builder(context, safeData);
    } catch (error) {
      // Fallback for any unexpected errors
      return errorWidget ?? _buildErrorState(context, error);
    }
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.recipe_long,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Recipe Information Incomplete',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This recipe is missing essential information. We\'re working to complete it for you.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                // Could trigger recipe completion flow
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recipe completion requested')),
                );
              },
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Request Complete Recipe'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, dynamic error) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Recipe Display Error',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'There was an issue displaying this recipe. Please try refreshing or contact support.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    // Could trigger error reporting
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error reported')),
                    );
                  },
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Report Issue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}