import '../models/ingredient.dart';

/// Service for managing brand recommendations
class BrandRecommendationService {
  // Private static instance
  static final BrandRecommendationService _instance = BrandRecommendationService._internal();
  
  // Factory constructor
  factory BrandRecommendationService() {
    return _instance;
  }
  
  // Private constructor
  BrandRecommendationService._internal();

  /// Brand recommendations database organized by spirit type
  final Map<String, List<BrandRecommendation>> _recommendations = {
    'vodka': [
      BrandRecommendation(
        name: 'Tito\'s Handmade Vodka',
        spiritType: 'vodka',
        budgetLevel: BudgetLevel.mid,
        rating: 4.5,
        isStaffPick: true,
        priceRange: 25,
        description: 'Smooth, clean, and gluten-free. Perfect for cocktails.',
      ),
      BrandRecommendation(
        name: 'Grey Goose',
        spiritType: 'vodka',
        budgetLevel: BudgetLevel.premium,
        rating: 4.8,
        priceRange: 45,
        description: 'French luxury vodka with exceptional smoothness.',
      ),
      BrandRecommendation(
        name: 'Svedka',
        spiritType: 'vodka',
        budgetLevel: BudgetLevel.budget,
        rating: 4.0,
        priceRange: 15,
        description: 'Swedish vodka with great value for mixing.',
      ),
    ],
    
    'gin': [
      BrandRecommendation(
        name: 'Tanqueray',
        spiritType: 'gin',
        budgetLevel: BudgetLevel.mid,
        rating: 4.6,
        isStaffPick: true,
        priceRange: 30,
        description: 'Classic London Dry with perfect juniper balance.',
      ),
      BrandRecommendation(
        name: 'Hendrick\'s',
        spiritType: 'gin',
        budgetLevel: BudgetLevel.premium,
        rating: 4.7,
        priceRange: 40,
        description: 'Cucumber and rose petal infused Scottish gin.',
      ),
      BrandRecommendation(
        name: 'Gordon\'s',
        spiritType: 'gin',
        budgetLevel: BudgetLevel.budget,
        rating: 4.1,
        priceRange: 18,
        description: 'Classic London Dry gin, great for mixing.',
      ),
    ],
    
    'rum': [
      BrandRecommendation(
        name: 'Bacardi Superior',
        spiritType: 'rum',
        budgetLevel: BudgetLevel.budget,
        rating: 4.2,
        priceRange: 16,
        description: 'Light, clean white rum perfect for mojitos.',
      ),
      BrandRecommendation(
        name: 'Diplomatico Reserva',
        spiritType: 'rum',
        budgetLevel: BudgetLevel.premium,
        rating: 4.8,
        isStaffPick: true,
        priceRange: 50,
        description: 'Venezuelan dark rum with complex sweetness.',
      ),
      BrandRecommendation(
        name: 'Captain Morgan Spiced',
        spiritType: 'rum',
        budgetLevel: BudgetLevel.mid,
        rating: 4.3,
        priceRange: 22,
        description: 'Popular spiced rum with vanilla and caramel notes.',
      ),
    ],
    
    'whiskey': [
      BrandRecommendation(
        name: 'Buffalo Trace',
        spiritType: 'whiskey',
        budgetLevel: BudgetLevel.mid,
        rating: 4.7,
        isStaffPick: true,
        priceRange: 28,
        description: 'Kentucky bourbon with perfect balance of sweet and spice.',
      ),
      BrandRecommendation(
        name: 'Jameson',
        spiritType: 'whiskey',
        budgetLevel: BudgetLevel.mid,
        rating: 4.4,
        priceRange: 30,
        description: 'Smooth Irish whiskey with triple distillation.',
      ),
      BrandRecommendation(
        name: 'Evan Williams',
        spiritType: 'whiskey',
        budgetLevel: BudgetLevel.budget,
        rating: 4.0,
        priceRange: 15,
        description: 'Affordable Kentucky bourbon with solid flavor.',
      ),
      BrandRecommendation(
        name: 'Macallan 12',
        spiritType: 'whiskey',
        budgetLevel: BudgetLevel.premium,
        rating: 4.9,
        priceRange: 80,
        description: 'Highland single malt with sherry cask maturation.',
      ),
    ],
    
    'bourbon': [
      BrandRecommendation(
        name: 'Maker\'s Mark',
        spiritType: 'bourbon',
        budgetLevel: BudgetLevel.mid,
        rating: 4.5,
        priceRange: 32,
        description: 'Wheated bourbon with smooth, sweet profile.',
      ),
      BrandRecommendation(
        name: 'Pappy Van Winkle 15',
        spiritType: 'bourbon',
        budgetLevel: BudgetLevel.premium,
        rating: 5.0,
        isStaffPick: true,
        priceRange: 1200,
        description: 'Legendary wheated bourbon with exceptional complexity.',
      ),
      BrandRecommendation(
        name: 'Wild Turkey 101',
        spiritType: 'bourbon',
        budgetLevel: BudgetLevel.budget,
        rating: 4.3,
        priceRange: 24,
        description: 'High-proof bourbon with bold flavor profile.',
      ),
    ],
    
    'tequila': [
      BrandRecommendation(
        name: 'Espolòn',
        spiritType: 'tequila',
        budgetLevel: BudgetLevel.budget,
        rating: 4.4,
        isStaffPick: true,
        priceRange: 22,
        description: '100% agave blanco with bright, crisp flavor.',
      ),
      BrandRecommendation(
        name: 'Casamigos Blanco',
        spiritType: 'tequila',
        budgetLevel: BudgetLevel.premium,
        rating: 4.6,
        priceRange: 50,
        description: 'Celebrity-backed premium tequila with smooth finish.',
      ),
      BrandRecommendation(
        name: 'Herradura Silver',
        spiritType: 'tequila',
        budgetLevel: BudgetLevel.mid,
        rating: 4.5,
        priceRange: 35,
        description: 'Traditional tequila with 100% blue agave.',
      ),
    ],
    
    'mezcal': [
      BrandRecommendation(
        name: 'Del Maguey Vida',
        spiritType: 'mezcal',
        budgetLevel: BudgetLevel.mid,
        rating: 4.6,
        isStaffPick: true,
        priceRange: 40,
        description: 'Entry-level mezcal with authentic smoky character.',
      ),
      BrandRecommendation(
        name: 'Montelobos Joven',
        spiritType: 'mezcal',
        budgetLevel: BudgetLevel.mid,
        rating: 4.4,
        priceRange: 45,
        description: 'Organic mezcal with subtle smoke and citrus notes.',
      ),
    ],
    
    'scotch': [
      BrandRecommendation(
        name: 'Glenlivet 12',
        spiritType: 'scotch',
        budgetLevel: BudgetLevel.mid,
        rating: 4.5,
        priceRange: 45,
        description: 'Speyside single malt with smooth, fruity character.',
      ),
      BrandRecommendation(
        name: 'Laphroaig 10',
        spiritType: 'scotch',
        budgetLevel: BudgetLevel.mid,
        rating: 4.7,
        isStaffPick: true,
        priceRange: 50,
        description: 'Islay single malt with intense peat and smoke.',
      ),
      BrandRecommendation(
        name: 'Johnnie Walker Black',
        spiritType: 'scotch',
        budgetLevel: BudgetLevel.mid,
        rating: 4.3,
        priceRange: 35,
        description: 'Blended Scotch with rich, complex flavor.',
      ),
    ],
  };

  /// Get brand recommendations for a specific spirit type
  List<BrandRecommendation> getRecommendations(String spiritType) {
    final key = _sanitizeKey(spiritType);
    return _recommendations[key] ?? [];
  }

  /// Get recommendations filtered by budget level
  List<BrandRecommendation> getRecommendationsByBudget(
    String spiritType,
    BudgetLevel budgetLevel,
  ) {
    final allRecs = getRecommendations(spiritType);
    return allRecs.where((rec) => rec.budgetLevel == budgetLevel).toList();
  }

  /// Get staff pick recommendations
  List<BrandRecommendation> getStaffPicks(String spiritType) {
    final allRecs = getRecommendations(spiritType);
    return allRecs.where((rec) => rec.isStaffPick).toList();
  }

  /// Get recommendations sorted by rating
  List<BrandRecommendation> getRecommendationsByRating(String spiritType) {
    final recs = getRecommendations(spiritType);
    recs.sort((a, b) => b.rating.compareTo(a.rating));
    return recs;
  }

  /// Get recommendations within price range
  List<BrandRecommendation> getRecommendationsByPrice(
    String spiritType,
    double minPrice,
    double maxPrice,
  ) {
    final allRecs = getRecommendations(spiritType);
    return allRecs.where((rec) => 
      rec.priceRange >= minPrice && rec.priceRange <= maxPrice
    ).toList();
  }

  /// Add a new brand recommendation
  void addRecommendation(BrandRecommendation recommendation) {
    final key = _sanitizeKey(recommendation.spiritType);
    _recommendations.putIfAbsent(key, () => []);
    _recommendations[key]!.add(recommendation);
  }

  /// Update an existing recommendation
  void updateRecommendation(
    String spiritType,
    String brandName,
    BrandRecommendation updatedRecommendation,
  ) {
    final key = _sanitizeKey(spiritType);
    final recs = _recommendations[key];
    
    if (recs != null) {
      final index = recs.indexWhere((rec) => rec.name == brandName);
      if (index != -1) {
        recs[index] = updatedRecommendation;
      }
    }
  }

  /// Remove a recommendation
  void removeRecommendation(String spiritType, String brandName) {
    final key = _sanitizeKey(spiritType);
    _recommendations[key]?.removeWhere((rec) => rec.name == brandName);
  }

  /// Get all available spirit types
  List<String> getAvailableSpiritTypes() {
    return _recommendations.keys.toList();
  }

  /// Search recommendations by keyword
  Map<String, List<BrandRecommendation>> searchRecommendations(String query) {
    final results = <String, List<BrandRecommendation>>{};
    final lowerQuery = query.toLowerCase();
    
    _recommendations.forEach((spiritType, recs) {
      final matchingRecs = recs.where((rec) =>
        rec.name.toLowerCase().contains(lowerQuery) ||
        rec.description?.toLowerCase().contains(lowerQuery) == true ||
        spiritType.contains(lowerQuery)
      ).toList();
      
      if (matchingRecs.isNotEmpty) {
        results[spiritType] = matchingRecs;
      }
    });
    
    return results;
  }

  /// Get recommendations statistics
  Map<String, dynamic> getRecommendationStats() {
    int totalRecs = 0;
    int staffPicks = 0;
    double avgRating = 0.0;
    double avgPrice = 0.0;
    
    _recommendations.forEach((spiritType, recs) {
      totalRecs += recs.length;
      staffPicks += recs.where((rec) => rec.isStaffPick).length;
      avgRating += recs.fold(0.0, (sum, rec) => sum + rec.rating);
      avgPrice += recs.fold(0.0, (sum, rec) => sum + rec.priceRange);
    });
    
    if (totalRecs > 0) {
      avgRating /= totalRecs;
      avgPrice /= totalRecs;
    }
    
    return {
      'totalRecommendations': totalRecs,
      'staffPicks': staffPicks,
      'averageRating': avgRating,
      'averagePrice': avgPrice,
      'spiritTypes': _recommendations.keys.length,
    };
  }

  /// Private helper to sanitize spirit type names
  String _sanitizeKey(String spiritType) {
    return spiritType
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_')
        .replaceAll(RegExp(r'[^\w_]'), '');
  }
}