import '../models/ingredient.dart';

/// Service for managing ingredient substitutions
class SubstitutionService {
  // Private static instance
  static final SubstitutionService _instance = SubstitutionService._internal();
  
  // Factory constructor
  factory SubstitutionService() {
    return _instance;
  }
  
  // Private constructor
  SubstitutionService._internal();

  /// Substitution database mapping ingredients to their substitutes
  final Map<String, List<SubstitutionData>> _substitutions = {
    // Spirits
    'vodka': [
      SubstitutionData(
        substitute: 'gin',
        rating: 0.8,
        reason: 'Similar neutral base, but gin adds botanical complexity',
        ratio: '1:1',
        category: 'spirit',
      ),
      SubstitutionData(
        substitute: 'white_rum',
        rating: 0.7,
        reason: 'Clean profile works well, adds subtle tropical notes',
        ratio: '1:1',
        category: 'spirit',
      ),
    ],
    
    'gin': [
      SubstitutionData(
        substitute: 'vodka',
        rating: 0.6,
        reason: 'Loses botanical complexity but maintains strength',
        ratio: '1:1',
        category: 'spirit',
      ),
      SubstitutionData(
        substitute: 'white_rum',
        rating: 0.5,
        reason: 'Different flavor profile but similar mixability',
        ratio: '1:1',
        category: 'spirit',
      ),
    ],
    
    'rum': [
      SubstitutionData(
        substitute: 'bourbon',
        rating: 0.7,
        reason: 'Adds vanilla and oak notes, works in darker cocktails',
        ratio: '1:1',
        category: 'spirit',
      ),
      SubstitutionData(
        substitute: 'cognac',
        rating: 0.8,
        reason: 'Premium substitute with fruit and oak complexity',
        ratio: '1:1',
        category: 'spirit',
      ),
    ],
    
    'tequila': [
      SubstitutionData(
        substitute: 'mezcal',
        rating: 0.9,
        reason: 'Both agave-based, mezcal adds smoky complexity',
        ratio: '1:1',
        category: 'spirit',
      ),
      SubstitutionData(
        substitute: 'white_rum',
        rating: 0.6,
        reason: 'Clean profile, but loses agave character',
        ratio: '1:1',
        category: 'spirit',
      ),
    ],
    
    'whiskey': [
      SubstitutionData(
        substitute: 'bourbon',
        rating: 0.9,
        reason: 'Bourbon is a type of whiskey, very similar profile',
        ratio: '1:1',
        category: 'spirit',
      ),
      SubstitutionData(
        substitute: 'rum',
        rating: 0.7,
        reason: 'Different flavor but similar complexity',
        ratio: '1:1',
        category: 'spirit',
      ),
    ],
    
    // Liqueurs
    'triple_sec': [
      SubstitutionData(
        substitute: 'cointreau',
        rating: 0.95,
        reason: 'Premium orange liqueur, more refined flavor',
        ratio: '1:1',
        category: 'liqueur',
      ),
      SubstitutionData(
        substitute: 'grand_marnier',
        rating: 0.8,
        reason: 'Orange cognac base adds complexity',
        ratio: '1:1',
        category: 'liqueur',
      ),
      SubstitutionData(
        substitute: 'orange_juice',
        rating: 0.4,
        reason: 'Loses alcohol content but maintains orange flavor',
        ratio: '1:2',
        category: 'mixer',
      ),
    ],
    
    'cointreau': [
      SubstitutionData(
        substitute: 'triple_sec',
        rating: 0.8,
        reason: 'More budget-friendly, slightly less refined',
        ratio: '1:1',
        category: 'liqueur',
      ),
      SubstitutionData(
        substitute: 'grand_marnier',
        rating: 0.7,
        reason: 'Adds cognac complexity to orange profile',
        ratio: '1:1',
        category: 'liqueur',
      ),
    ],
    
    'amaretto': [
      SubstitutionData(
        substitute: 'orgeat',
        rating: 0.7,
        reason: 'Both almond-based, orgeat is sweeter syrup',
        ratio: '1:1',
        category: 'syrup',
      ),
      SubstitutionData(
        substitute: 'simple_syrup',
        rating: 0.3,
        reason: 'Adds sweetness but loses almond flavor',
        ratio: '1:1',
        category: 'syrup',
      ),
    ],
    
    // Citrus
    'lime_juice': [
      SubstitutionData(
        substitute: 'lemon_juice',
        rating: 0.8,
        reason: 'Similar acidity, lemon is slightly more tart',
        ratio: '1:1',
        category: 'citrus',
      ),
      SubstitutionData(
        substitute: 'orange_juice',
        rating: 0.5,
        reason: 'Sweeter profile, loses tartness',
        ratio: '1:1.5',
        category: 'citrus',
      ),
    ],
    
    'lemon_juice': [
      SubstitutionData(
        substitute: 'lime_juice',
        rating: 0.8,
        reason: 'Similar acidity, lime is slightly more tropical',
        ratio: '1:1',
        category: 'citrus',
      ),
      SubstitutionData(
        substitute: 'white_wine_vinegar',
        rating: 0.4,
        reason: 'Provides acidity but different flavor profile',
        ratio: '1:0.5',
        category: 'acid',
      ),
    ],
    
    // Syrups
    'simple_syrup': [
      SubstitutionData(
        substitute: 'agave_nectar',
        rating: 0.8,
        reason: 'Natural sweetener with subtle flavor',
        ratio: '1:0.75',
        category: 'sweetener',
      ),
      SubstitutionData(
        substitute: 'honey',
        rating: 0.7,
        reason: 'Adds floral notes and complexity',
        ratio: '1:0.75',
        category: 'sweetener',
      ),
      SubstitutionData(
        substitute: 'maple_syrup',
        rating: 0.6,
        reason: 'Adds maple flavor, works in whiskey cocktails',
        ratio: '1:0.75',
        category: 'sweetener',
      ),
    ],
    
    'grenadine': [
      SubstitutionData(
        substitute: 'pomegranate_juice',
        rating: 0.7,
        reason: 'Natural pomegranate flavor, less sweet',
        ratio: '1:1',
        category: 'fruit',
      ),
      SubstitutionData(
        substitute: 'cranberry_juice',
        rating: 0.5,
        reason: 'Similar color and tartness, different flavor',
        ratio: '1:1',
        category: 'fruit',
      ),
    ],
    
    // Bitters
    'angostura_bitters': [
      SubstitutionData(
        substitute: 'orange_bitters',
        rating: 0.6,
        reason: 'Different flavor profile but similar aromatic function',
        ratio: '1:1',
        category: 'bitters',
      ),
      SubstitutionData(
        substitute: 'peychauds_bitters',
        rating: 0.7,
        reason: 'Cherry-anise notes, traditional in some cocktails',
        ratio: '1:1',
        category: 'bitters',
      ),
    ],
  };

  /// Get substitution options for a given ingredient
  List<Substitution> getSubstitutions(String originalIngredient) {
    final key = _sanitizeKey(originalIngredient);
    final substitutionData = _substitutions[key] ?? [];
    
    // Convert to Substitution objects
    return substitutionData.map((data) {
      return Substitution(
        ingredient: _createSubstituteIngredient(data.substitute),
        compatibilityRating: data.rating,
        reasonWhy: data.reason,
        conversionRatio: data.ratio,
      );
    }).toList();
  }

  /// Get substitutions filtered by category
  List<Substitution> getSubstitutionsByCategory(
    String originalIngredient,
    String category,
  ) {
    final allSubs = getSubstitutions(originalIngredient);
    return allSubs.where((sub) => 
      _inferCategory(sub.ingredient.name) == category
    ).toList();
  }

  /// Get substitutions sorted by compatibility rating
  List<Substitution> getSubstitutionsSorted(String originalIngredient) {
    final subs = getSubstitutions(originalIngredient);
    subs.sort((a, b) => b.compatibilityRating.compareTo(a.compatibilityRating));
    return subs;
  }

  /// Add a new substitution
  void addSubstitution(
    String originalIngredient,
    String substitute,
    double rating,
    String reason, {
    String ratio = '1:1',
  }) {
    final key = _sanitizeKey(originalIngredient);
    _substitutions.putIfAbsent(key, () => []);
    
    _substitutions[key]!.add(SubstitutionData(
      substitute: substitute,
      rating: rating,
      reason: reason,
      ratio: ratio,
      category: _inferCategory(substitute),
    ));
  }

  /// Check if substitutions exist for an ingredient
  bool hasSubstitutions(String ingredient) {
    final key = _sanitizeKey(ingredient);
    return _substitutions.containsKey(key) && 
           _substitutions[key]!.isNotEmpty;
  }

  /// Get all ingredients that have substitutions
  List<String> getIngredientsWithSubstitutions() {
    return _substitutions.keys.toList();
  }

  /// Search substitutions by keyword
  Map<String, List<Substitution>> searchSubstitutions(String query) {
    final results = <String, List<Substitution>>{};
    final lowerQuery = query.toLowerCase();
    
    _substitutions.forEach((ingredient, subs) {
      if (ingredient.contains(lowerQuery)) {
        results[ingredient] = getSubstitutions(ingredient);
      } else {
        final matchingSubs = subs.where((sub) =>
          sub.substitute.toLowerCase().contains(lowerQuery) ||
          sub.reason.toLowerCase().contains(lowerQuery)
        ).toList();
        
        if (matchingSubs.isNotEmpty) {
          results[ingredient] = matchingSubs.map((data) => Substitution(
            ingredient: _createSubstituteIngredient(data.substitute),
            compatibilityRating: data.rating,
            reasonWhy: data.reason,
            conversionRatio: data.ratio,
          )).toList();
        }
      }
    });
    
    return results;
  }

  /// Private helper to create a substitute ingredient
  Ingredient _createSubstituteIngredient(String name) {
    return Ingredient(
      id: name,
      name: name,
      category: _inferCategory(name),
      tier: QualityTier.standard,
      fillLevel: 1.0,
      pricePerOz: 1.0, // Default price
    );
  }

  /// Private helper to sanitize ingredient names
  String _sanitizeKey(String ingredient) {
    return ingredient
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_')
        .replaceAll(RegExp(r'[^\w_]'), '');
  }

  /// Private helper to infer category from ingredient name
  String _inferCategory(String ingredient) {
    final lower = ingredient.toLowerCase();
    
    if (lower.contains('vodka') || lower.contains('gin') ||
        lower.contains('rum') || lower.contains('whiskey') ||
        lower.contains('bourbon') || lower.contains('tequila') ||
        lower.contains('mezcal') || lower.contains('scotch')) {
      return 'spirits';
    }
    
    if (lower.contains('triple_sec') || lower.contains('cointreau') ||
        lower.contains('amaretto') || lower.contains('kahlua') ||
        lower.contains('grand_marnier')) {
      return 'liqueurs';
    }
    
    if (lower.contains('juice')) {
      return 'mixers';
    }
    
    if (lower.contains('syrup') || lower.contains('honey') ||
        lower.contains('agave')) {
      return 'syrups';
    }
    
    if (lower.contains('bitters')) {
      return 'bitters';
    }
    
    return 'other';
  }
}

/// Internal data class for substitution information
class SubstitutionData {
  final String substitute;
  final double rating;
  final String reason;
  final String ratio;
  final String category;

  const SubstitutionData({
    required this.substitute,
    required this.rating,
    required this.reason,
    required this.ratio,
    required this.category,
  });
}