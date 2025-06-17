import '../models/ingredient.dart';

/// Service for calculating ingredient costs and pour costs
class CostCalculator {
  // Private static instance
  static final CostCalculator _instance = CostCalculator._internal();
  
  // Factory constructor
  factory CostCalculator() {
    return _instance;
  }
  
  // Private constructor
  CostCalculator._internal();

  /// Base ingredient price database (price per ounce in USD)
  final Map<String, Map<QualityTier, double>> _basePrices = {
    // Spirits
    'vodka': {
      QualityTier.budget: 0.75,
      QualityTier.standard: 1.50,
      QualityTier.premium: 3.00,
      QualityTier.luxury: 8.00,
    },
    'gin': {
      QualityTier.budget: 0.80,
      QualityTier.standard: 1.75,
      QualityTier.premium: 3.50,
      QualityTier.luxury: 9.00,
    },
    'rum': {
      QualityTier.budget: 0.60,
      QualityTier.standard: 1.25,
      QualityTier.premium: 2.75,
      QualityTier.luxury: 7.50,
    },
    'whiskey': {
      QualityTier.budget: 0.90,
      QualityTier.standard: 2.00,
      QualityTier.premium: 4.50,
      QualityTier.luxury: 12.00,
    },
    'bourbon': {
      QualityTier.budget: 0.85,
      QualityTier.standard: 1.80,
      QualityTier.premium: 4.00,
      QualityTier.luxury: 10.00,
    },
    'scotch': {
      QualityTier.budget: 1.20,
      QualityTier.standard: 2.50,
      QualityTier.premium: 6.00,
      QualityTier.luxury: 15.00,
    },
    'tequila': {
      QualityTier.budget: 0.70,
      QualityTier.standard: 1.60,
      QualityTier.premium: 3.25,
      QualityTier.luxury: 8.50,
    },
    'mezcal': {
      QualityTier.budget: 1.50,
      QualityTier.standard: 3.00,
      QualityTier.premium: 6.50,
      QualityTier.luxury: 16.00,
    },
    'cognac': {
      QualityTier.budget: 2.00,
      QualityTier.standard: 4.50,
      QualityTier.premium: 9.00,
      QualityTier.luxury: 25.00,
    },
    
    // Liqueurs
    'triple_sec': {
      QualityTier.budget: 0.40,
      QualityTier.standard: 0.80,
      QualityTier.premium: 1.60,
      QualityTier.luxury: 3.50,
    },
    'cointreau': {
      QualityTier.budget: 1.25,
      QualityTier.standard: 1.25,
      QualityTier.premium: 1.25,
      QualityTier.luxury: 1.25,
    },
    'amaretto': {
      QualityTier.budget: 0.50,
      QualityTier.standard: 1.00,
      QualityTier.premium: 2.00,
      QualityTier.luxury: 4.50,
    },
    'kahlua': {
      QualityTier.budget: 0.60,
      QualityTier.standard: 0.85,
      QualityTier.premium: 1.20,
      QualityTier.luxury: 2.50,
    },
    'grand_marnier': {
      QualityTier.budget: 1.50,
      QualityTier.standard: 1.50,
      QualityTier.premium: 1.50,
      QualityTier.luxury: 1.50,
    },
    
    // Wine & Champagne
    'champagne': {
      QualityTier.budget: 0.60,
      QualityTier.standard: 1.20,
      QualityTier.premium: 2.50,
      QualityTier.luxury: 6.00,
    },
    'prosecco': {
      QualityTier.budget: 0.40,
      QualityTier.standard: 0.75,
      QualityTier.premium: 1.25,
      QualityTier.luxury: 2.50,
    },
    'white_wine': {
      QualityTier.budget: 0.25,
      QualityTier.standard: 0.50,
      QualityTier.premium: 1.00,
      QualityTier.luxury: 2.50,
    },
    'red_wine': {
      QualityTier.budget: 0.30,
      QualityTier.standard: 0.60,
      QualityTier.premium: 1.25,
      QualityTier.luxury: 3.00,
    },
    
    // Mixers & Syrups
    'simple_syrup': {
      QualityTier.budget: 0.05,
      QualityTier.standard: 0.10,
      QualityTier.premium: 0.20,
      QualityTier.luxury: 0.40,
    },
    'lime_juice': {
      QualityTier.budget: 0.10,
      QualityTier.standard: 0.20,
      QualityTier.premium: 0.35,
      QualityTier.luxury: 0.60,
    },
    'lemon_juice': {
      QualityTier.budget: 0.10,
      QualityTier.standard: 0.20,
      QualityTier.premium: 0.35,
      QualityTier.luxury: 0.60,
    },
    'orange_juice': {
      QualityTier.budget: 0.08,
      QualityTier.standard: 0.15,
      QualityTier.premium: 0.25,
      QualityTier.luxury: 0.45,
    },
    'cranberry_juice': {
      QualityTier.budget: 0.12,
      QualityTier.standard: 0.20,
      QualityTier.premium: 0.35,
      QualityTier.luxury: 0.55,
    },
    'grenadine': {
      QualityTier.budget: 0.15,
      QualityTier.standard: 0.30,
      QualityTier.premium: 0.60,
      QualityTier.luxury: 1.20,
    },
    
    // Bitters (typically used in small amounts)
    'angostura_bitters': {
      QualityTier.budget: 0.25,
      QualityTier.standard: 0.35,
      QualityTier.premium: 0.50,
      QualityTier.luxury: 0.85,
    },
    'orange_bitters': {
      QualityTier.budget: 0.30,
      QualityTier.standard: 0.45,
      QualityTier.premium: 0.70,
      QualityTier.luxury: 1.20,
    },
  };

  /// Regional price variations (multipliers)
  final Map<String, double> _regionalMultipliers = {
    'US': 1.0,      // Base prices
    'UK': 1.4,      // Higher due to taxes
    'CA': 1.3,      // Canadian markup
    'AU': 1.5,      // Australian markup
    'EU': 1.2,      // European average
    'MX': 0.7,      // Lower costs in Mexico
    'JP': 1.6,      // Higher costs in Japan
  };

  /// Calculate pour cost for a specific ingredient and amount
  double calculatePourCost(
    String ingredient, 
    double amount, 
    Unit unit, {
    QualityTier tier = QualityTier.standard,
    String region = 'US',
  }) {
    final sanitizedIngredient = _sanitizeIngredientName(ingredient);
    
    // Convert amount to ounces
    final amountInOz = unit.toOz(amount);
    
    // Get base price per ounce
    final basePrice = _getBasePrice(sanitizedIngredient, tier);
    
    // Apply regional multiplier
    final regionalMultiplier = _regionalMultipliers[region] ?? 1.0;
    final adjustedPrice = basePrice * regionalMultiplier;
    
    // Calculate total cost
    return amountInOz * adjustedPrice;
  }

  /// Calculate total cocktail cost
  double calculateCocktailCost(
    List<IngredientMeasurement> ingredients, {
    String region = 'US',
  }) {
    double totalCost = 0.0;
    
    for (final measurement in ingredients) {
      totalCost += calculatePourCost(
        measurement.ingredient.name,
        measurement.amount,
        measurement.unit,
        tier: measurement.ingredient.tier,
        region: region,
      );
    }
    
    return totalCost;
  }

  /// Get estimated price per ounce for an ingredient
  double getPricePerOz(
    String ingredient, 
    QualityTier tier, {
    String region = 'US',
  }) {
    final sanitizedIngredient = _sanitizeIngredientName(ingredient);
    final basePrice = _getBasePrice(sanitizedIngredient, tier);
    final regionalMultiplier = _regionalMultipliers[region] ?? 1.0;
    
    return basePrice * regionalMultiplier;
  }

  /// Get price breakdown for different quality tiers
  Map<QualityTier, double> getPriceTiers(
    String ingredient, {
    String region = 'US',
  }) {
    final sanitizedIngredient = _sanitizeIngredientName(ingredient);
    final tierPrices = _basePrices[sanitizedIngredient];
    final regionalMultiplier = _regionalMultipliers[region] ?? 1.0;
    
    if (tierPrices == null) {
      return _getDefaultPriceTiers(regionalMultiplier);
    }
    
    return tierPrices.map((tier, price) => 
      MapEntry(tier, price * regionalMultiplier));
  }

  /// Add or update ingredient pricing
  void updateIngredientPrice(
    String ingredient,
    QualityTier tier,
    double pricePerOz,
  ) {
    final sanitizedIngredient = _sanitizeIngredientName(ingredient);
    _basePrices.putIfAbsent(sanitizedIngredient, () => {});
    _basePrices[sanitizedIngredient]![tier] = pricePerOz;
  }

  /// Get all available regions
  List<String> getAvailableRegions() {
    return _regionalMultipliers.keys.toList();
  }

  /// Private helper to get base price
  double _getBasePrice(String ingredient, QualityTier tier) {
    final tierPrices = _basePrices[ingredient];
    
    if (tierPrices == null) {
      return _getDefaultPrice(tier);
    }
    
    return tierPrices[tier] ?? _getDefaultPrice(tier);
  }

  /// Private helper to get default price for unknown ingredients
  double _getDefaultPrice(QualityTier tier) {
    switch (tier) {
      case QualityTier.budget:
        return 0.50;
      case QualityTier.standard:
        return 1.00;
      case QualityTier.premium:
        return 2.50;
      case QualityTier.luxury:
        return 6.00;
    }
  }

  /// Private helper to get default price tiers
  Map<QualityTier, double> _getDefaultPriceTiers(double multiplier) {
    return {
      QualityTier.budget: 0.50 * multiplier,
      QualityTier.standard: 1.00 * multiplier,
      QualityTier.premium: 2.50 * multiplier,
      QualityTier.luxury: 6.00 * multiplier,
    };
  }

  /// Private helper to sanitize ingredient names
  String _sanitizeIngredientName(String ingredient) {
    return ingredient
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_')
        .replaceAll(RegExp(r'[^\w_]'), '');
  }
}

/// Helper class for ingredient measurements in cocktails
class IngredientMeasurement {
  final Ingredient ingredient;
  final double amount;
  final Unit unit;

  const IngredientMeasurement({
    required this.ingredient,
    required this.amount,
    required this.unit,
  });

  /// Convert to a different unit
  IngredientMeasurement convertTo(Unit newUnit) {
    final ozAmount = unit.toOz(amount);
    final newAmount = newUnit.fromOz(ozAmount);
    
    return IngredientMeasurement(
      ingredient: ingredient,
      amount: newAmount,
      unit: newUnit,
    );
  }

  /// Calculate cost for this measurement
  double calculateCost({String region = 'US'}) {
    return CostCalculator().calculatePourCost(
      ingredient.name,
      amount,
      unit,
      tier: ingredient.tier,
      region: region,
    );
  }
}