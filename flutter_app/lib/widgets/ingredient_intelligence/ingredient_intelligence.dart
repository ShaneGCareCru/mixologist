/// Ingredient Intelligence Cards - Export barrel file
/// 
/// This file provides easy access to all ingredient intelligence widgets
/// and services for the Mixologist app.
/// 
/// Features:
/// - Smart ingredient cards with quality tiers and fill levels
/// - Tasting notes database with regional variations
/// - Cost estimation for cocktail ingredients
/// - Substitution suggestions with compatibility ratings
/// - Swipeable measurement converter with haptic feedback
/// - Brand recommendations by budget level

// Models
export '../../models/ingredient.dart';

// Services
export '../../services/tasting_note_service.dart';
export '../../services/cost_calculator.dart';
export '../../services/substitution_service.dart';
export '../../services/brand_recommendation_service.dart';

// Widgets
export 'ingredient_card.dart';
export 'substitution_sheet.dart';
export 'measurement_selector.dart';
export 'brand_recommendations.dart';