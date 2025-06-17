import 'package:flutter/material.dart';

/// Quality tiers for ingredients
enum QualityTier { 
  budget, 
  standard, 
  premium, 
  luxury 
}

/// Units for measurements
enum Unit { 
  oz, 
  ml, 
  cl, 
  shots,
  tsp,
  tbsp,
  dash,
  splash
}

/// Budget levels for recommendations
enum BudgetLevel {
  budget,
  mid,
  premium
}

/// Enhanced ingredient model with intelligence features
class Ingredient {
  final String id;
  final String name;
  final String category;
  final QualityTier tier;
  final double fillLevel; // 0.0 to 1.0
  final String? brand;
  final String? imageUrl;
  final String? tastingNote;
  final double pricePerOz; // Price per ounce for cost calculation
  final List<String> substitutes;
  final Map<String, dynamic> metadata;

  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
    required this.tier,
    required this.fillLevel,
    this.brand,
    this.imageUrl,
    this.tastingNote,
    required this.pricePerOz,
    this.substitutes = const [],
    this.metadata = const {},
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      tier: QualityTier.values.firstWhere(
        (e) => e.toString().split('.').last == json['tier'],
        orElse: () => QualityTier.standard,
      ),
      fillLevel: (json['fillLevel'] ?? 1.0).toDouble(),
      brand: json['brand'],
      imageUrl: json['imageUrl'],
      tastingNote: json['tastingNote'],
      pricePerOz: (json['pricePerOz'] ?? 0.0).toDouble(),
      substitutes: List<String>.from(json['substitutes'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'tier': tier.toString().split('.').last,
      'fillLevel': fillLevel,
      'brand': brand,
      'imageUrl': imageUrl,
      'tastingNote': tastingNote,
      'pricePerOz': pricePerOz,
      'substitutes': substitutes,
      'metadata': metadata,
    };
  }

  Ingredient copyWith({
    String? id,
    String? name,
    String? category,
    QualityTier? tier,
    double? fillLevel,
    String? brand,
    String? imageUrl,
    String? tastingNote,
    double? pricePerOz,
    List<String>? substitutes,
    Map<String, dynamic>? metadata,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      fillLevel: fillLevel ?? this.fillLevel,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      tastingNote: tastingNote ?? this.tastingNote,
      pricePerOz: pricePerOz ?? this.pricePerOz,
      substitutes: substitutes ?? this.substitutes,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Substitution option with compatibility rating
class Substitution {
  final Ingredient ingredient;
  final double compatibilityRating; // 0.0 to 1.0
  final String reasonWhy;
  final String conversionRatio; // e.g., "1:1", "2:1", etc.

  const Substitution({
    required this.ingredient,
    required this.compatibilityRating,
    required this.reasonWhy,
    this.conversionRatio = "1:1",
  });

  factory Substitution.fromJson(Map<String, dynamic> json) {
    return Substitution(
      ingredient: Ingredient.fromJson(json['ingredient']),
      compatibilityRating: (json['compatibilityRating'] ?? 0.0).toDouble(),
      reasonWhy: json['reasonWhy'] ?? '',
      conversionRatio: json['conversionRatio'] ?? "1:1",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient': ingredient.toJson(),
      'compatibilityRating': compatibilityRating,
      'reasonWhy': reasonWhy,
      'conversionRatio': conversionRatio,
    };
  }
}

/// Brand recommendation model
class BrandRecommendation {
  final String name;
  final String spiritType;
  final BudgetLevel budgetLevel;
  final double rating; // 0.0 to 5.0
  final bool isStaffPick;
  final double priceRange;
  final String? description;

  const BrandRecommendation({
    required this.name,
    required this.spiritType,
    required this.budgetLevel,
    required this.rating,
    this.isStaffPick = false,
    required this.priceRange,
    this.description,
  });

  factory BrandRecommendation.fromJson(Map<String, dynamic> json) {
    return BrandRecommendation(
      name: json['name'],
      spiritType: json['spiritType'],
      budgetLevel: BudgetLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['budgetLevel'],
        orElse: () => BudgetLevel.mid,
      ),
      rating: (json['rating'] ?? 0.0).toDouble(),
      isStaffPick: json['isStaffPick'] ?? false,
      priceRange: (json['priceRange'] ?? 0.0).toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'spiritType': spiritType,
      'budgetLevel': budgetLevel.toString().split('.').last,
      'rating': rating,
      'isStaffPick': isStaffPick,
      'priceRange': priceRange,
      'description': description,
    };
  }
}

/// Extension methods for QualityTier
extension QualityTierExtension on QualityTier {
  String get displayName {
    switch (this) {
      case QualityTier.budget:
        return 'Budget';
      case QualityTier.standard:
        return 'Standard';
      case QualityTier.premium:
        return 'Premium';
      case QualityTier.luxury:
        return 'Luxury';
    }
  }

  Color get badgeColor {
    switch (this) {
      case QualityTier.budget:
        return Colors.green;
      case QualityTier.standard:
        return Colors.blue;
      case QualityTier.premium:
        return Colors.amber;
      case QualityTier.luxury:
        return Colors.purple;
    }
  }
}

/// Extension methods for Unit
extension UnitExtension on Unit {
  String get displayName {
    switch (this) {
      case Unit.oz:
        return 'oz';
      case Unit.ml:
        return 'ml';
      case Unit.cl:
        return 'cl';
      case Unit.shots:
        return 'shots';
      case Unit.tsp:
        return 'tsp';
      case Unit.tbsp:
        return 'tbsp';
      case Unit.dash:
        return 'dash';
      case Unit.splash:
        return 'splash';
    }
  }

  /// Convert from this unit to fluid ounces
  double toOz(double amount) {
    switch (this) {
      case Unit.oz:
        return amount;
      case Unit.ml:
        return amount / 29.5735; // 1 oz = 29.5735 ml
      case Unit.cl:
        return amount / 2.95735; // 1 oz = 2.95735 cl
      case Unit.shots:
        return amount * 1.5; // 1 shot = 1.5 oz
      case Unit.tsp:
        return amount / 6; // 1 oz = 6 tsp
      case Unit.tbsp:
        return amount / 2; // 1 oz = 2 tbsp
      case Unit.dash:
        return amount / 32; // Approximate: 1 oz = 32 dashes
      case Unit.splash:
        return amount / 8; // Approximate: 1 oz = 8 splashes
    }
  }

  /// Convert from fluid ounces to this unit
  double fromOz(double ozAmount) {
    switch (this) {
      case Unit.oz:
        return ozAmount;
      case Unit.ml:
        return ozAmount * 29.5735;
      case Unit.cl:
        return ozAmount * 2.95735;
      case Unit.shots:
        return ozAmount / 1.5;
      case Unit.tsp:
        return ozAmount * 6;
      case Unit.tbsp:
        return ozAmount * 2;
      case Unit.dash:
        return ozAmount * 32;
      case Unit.splash:
        return ozAmount * 8;
    }
  }
}