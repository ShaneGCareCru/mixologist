class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String quantity;
  final double fullness; // 0.0 to 1.0
  final String? imagePath; // local path to stylized image
  final String? brand;
  final String? notes;
  final DateTime addedDate;
  final DateTime lastUpdated;
  final bool expiresSoon;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.fullness,
    this.imagePath,
    this.brand,
    this.notes,
    required this.addedDate,
    required this.lastUpdated,
    this.expiresSoon = false,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      fullness: (json['fullness'] ?? 1.0).toDouble(),
      imagePath: json['image_path'],
      brand: json['brand'],
      notes: json['notes'],
      addedDate: DateTime.parse(json['added_date']),
      lastUpdated: DateTime.parse(json['last_updated']),
      expiresSoon: json['expires_soon'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'fullness': fullness,
      'image_path': imagePath,
      'brand': brand,
      'notes': notes,
      'added_date': addedDate.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
      'expires_soon': expiresSoon,
    };
  }

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    String? quantity,
    double? fullness,
    String? imagePath,
    String? brand,
    String? notes,
    DateTime? addedDate,
    DateTime? lastUpdated,
    bool? expiresSoon,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      fullness: fullness ?? this.fullness,
      imagePath: imagePath ?? this.imagePath,
      brand: brand ?? this.brand,
      notes: notes ?? this.notes,
      addedDate: addedDate ?? this.addedDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      expiresSoon: expiresSoon ?? this.expiresSoon,
    );
  }
}

class RecognizedIngredient {
  final String name;
  final String category;
  final double confidence;
  final String? brand;
  final String? quantityEstimate;
  final String? locationDescription;

  RecognizedIngredient({
    required this.name,
    required this.category,
    required this.confidence,
    this.brand,
    this.quantityEstimate,
    this.locationDescription,
  });

  factory RecognizedIngredient.fromJson(Map<String, dynamic> json) {
    return RecognizedIngredient(
      name: json['name'],
      category: json['category'],
      confidence: json['confidence'].toDouble(),
      brand: json['brand'],
      quantityEstimate: json['quantity_estimate'],
      locationDescription: json['location_description'],
    );
  }
}

class ImageRecognitionResponse {
  final List<RecognizedIngredient> recognizedIngredients;
  final List<String> suggestions;
  final double? processingTime;

  ImageRecognitionResponse({
    required this.recognizedIngredients,
    required this.suggestions,
    this.processingTime,
  });

  factory ImageRecognitionResponse.fromJson(Map<String, dynamic> json) {
    var ingredientsList = json['recognized_ingredients'] as List;
    List<RecognizedIngredient> ingredients = ingredientsList
        .map((item) => RecognizedIngredient.fromJson(item))
        .toList();

    return ImageRecognitionResponse(
      recognizedIngredients: ingredients,
      suggestions: List<String>.from(json['suggestions']),
      processingTime: json['processing_time']?.toDouble(),
    );
  }
}

class InventoryStats {
  final int totalItems;
  final Map<String, int> byCategory;
  final Map<String, int> byQuantity;
  final int expiringSoon;
  final DateTime lastUpdated;

  InventoryStats({
    required this.totalItems,
    required this.byCategory,
    required this.byQuantity,
    required this.expiringSoon,
    required this.lastUpdated,
  });

  factory InventoryStats.fromJson(Map<String, dynamic> json) {
    return InventoryStats(
      totalItems: json['total_items'],
      byCategory: Map<String, int>.from(json['by_category']),
      byQuantity: Map<String, int>.from(json['by_quantity']),
      expiringSoon: json['expiring_soon'],
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}

class IngredientCategory {
  static const String spirits = 'spirits';
  static const String liqueurs = 'liqueurs';
  static const String bitters = 'bitters';
  static const String syrups = 'syrups';
  static const String juices = 'juices';
  static const String freshIngredients = 'fresh_ingredients';
  static const String garnishes = 'garnishes';
  static const String mixers = 'mixers';
  static const String equipment = 'equipment';
  static const String other = 'other';

  static List<String> get all => [
        spirits,
        liqueurs,
        bitters,
        syrups,
        juices,
        freshIngredients,
        garnishes,
        mixers,
        equipment,
        other,
      ];

  static String getDisplayName(String category) {
    switch (category) {
      case spirits:
        return 'Spirits';
      case liqueurs:
        return 'Liqueurs';
      case bitters:
        return 'Bitters';
      case syrups:
        return 'Syrups';
      case juices:
        return 'Juices';
      case freshIngredients:
        return 'Fresh Ingredients';
      case garnishes:
        return 'Garnishes';
      case mixers:
        return 'Mixers';
      case equipment:
        return 'Equipment';
      case other:
        return 'Other';
      default:
        return category;
    }
  }
}

class QuantityDescription {
  static const String empty = 'empty';
  static const String almostEmpty = 'almost_empty';
  static const String quarterBottle = 'quarter_bottle';
  static const String halfBottle = 'half_bottle';
  static const String threeQuarterBottle = 'three_quarter_bottle';
  static const String fullBottle = 'full_bottle';
  static const String multipleBottles = 'multiple_bottles';
  static const String smallAmount = 'small_amount';
  static const String mediumAmount = 'medium_amount';
  static const String largeAmount = 'large_amount';
  static const String veryLargeAmount = 'very_large_amount';

  static List<String> get all => [
        empty,
        almostEmpty,
        quarterBottle,
        halfBottle,
        threeQuarterBottle,
        fullBottle,
        multipleBottles,
        smallAmount,
        mediumAmount,
        largeAmount,
        veryLargeAmount,
      ];

  static String getDisplayName(String quantity) {
    switch (quantity) {
      case empty:
        return 'Empty';
      case almostEmpty:
        return 'Almost Empty';
      case quarterBottle:
        return 'Quarter Bottle';
      case halfBottle:
        return 'Half Bottle';
      case threeQuarterBottle:
        return 'Three Quarter Bottle';
      case fullBottle:
        return 'Full Bottle';
      case multipleBottles:
        return 'Multiple Bottles';
      case smallAmount:
        return 'Small Amount';
      case mediumAmount:
        return 'Medium Amount';
      case largeAmount:
        return 'Large Amount';
      case veryLargeAmount:
        return 'Very Large Amount';
      default:
        return quantity;
    }
  }

  static double getFullnessValue(String quantity) {
    switch (quantity) {
      case empty:
        return 0.0;
      case almostEmpty:
        return 0.1;
      case quarterBottle:
        return 0.25;
      case halfBottle:
        return 0.5;
      case threeQuarterBottle:
        return 0.75;
      case fullBottle:
        return 1.0;
      case multipleBottles:
        return 1.0; // Could be > 1.0 but we'll cap at 1.0 for display
      case smallAmount:
        return 0.2;
      case mediumAmount:
        return 0.5;
      case largeAmount:
        return 0.8;
      case veryLargeAmount:
        return 1.0;
      default:
        return 1.0;
    }
  }
}