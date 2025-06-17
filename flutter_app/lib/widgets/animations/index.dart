/// Micro-Interaction Library for Mixologist
/// 
/// A comprehensive collection of delightful micro-interactions designed
/// specifically for cocktail-themed applications, featuring haptic feedback,
/// fluid animations, and consistent user experience patterns.
/// 
/// ## Components:
/// 
/// ### Services
/// - **HapticService**: Platform-specific haptic feedback patterns
/// - **InteractionFeedback**: Standardized feedback coordinator
/// 
/// ### Animations
/// - **LiquidDropAnimation**: Ingredient drop with bezier curves and splash
/// - **CocktailShakerAnimation**: Realistic shaker motion with condensation
/// - **MorphingFavoriteIcon**: Heart to cocktail glass transformation
/// - **GlassClinkAnimation**: Celebratory glass meeting animation
/// 
/// ### Usage Examples:
/// 
/// ```dart
/// // Basic haptic feedback
/// await HapticService.instance.ingredientCheck();
/// 
/// // Coordinated feedback patterns
/// await context.feedbackSuccess('Recipe completed!');
/// 
/// // Liquid drop on ingredient tap
/// LiquidDropWrapper(
///   onDropComplete: () => print('Ingredient added!'),
///   child: IngredientCard(),
/// )
/// 
/// // Interactive shaker
/// InteractiveCocktailShaker(
///   onShakeComplete: () => print('Mixed!'),
/// )
/// 
/// // Morphing favorite button
/// MorphingFavoriteIcon(
///   isFavorited: isLiked,
///   onToggle: () => setState(() => isLiked = !isLiked),
/// )
/// 
/// // Share with glass clink
/// CocktailShareButton(
///   onShare: () => shareRecipe(),
/// )
/// ```


// Services
export '../../services/haptic_service.dart';
export '../../services/interaction_feedback.dart';

// Animations
export 'liquid_drop_animation.dart';
export 'cocktail_shaker_animation.dart';
export 'morphing_favorite_icon.dart';
export 'glass_clink_animation.dart';

// Demo and utilities
export 'micro_interactions_demo.dart';