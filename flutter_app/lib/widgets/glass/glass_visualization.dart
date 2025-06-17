/// Adaptive Glass Visualization System
/// 
/// This package provides a comprehensive glass visualization system for cocktail recipes
/// with progressive filling animations, rim decorations, garnish animations, and bubble effects.
/// 
/// ## Main Components:
/// 
/// - [AdaptiveGlassWidget]: Main widget that combines all glass visualization features
/// - [RecipeGlassWidget]: Recipe-specific glass with predefined configurations
/// - [GlassShape]: Abstract base class for different glass types
/// - [LiquidFillPainter]: Custom painter for layered liquid fills
/// - [RimDecoration]: Animated rim decorations (salt, sugar, etc.)
/// - [GarnishAnimator]: Physics-based garnish animations
/// - [BubbleStream]: Carbonation bubble effects
/// - [RecipeProgressNotifier]: State management for recipe progress
/// 
/// ## Usage:
/// 
/// ```dart
/// // Basic usage with automatic configuration
/// RecipeGlassWidget(
///   recipeName: 'Margarita',
///   ingredients: ['Tequila', 'Lime juice', 'Triple sec'],
///   size: Size(120, 160),
/// )
/// 
/// // Advanced usage with custom configuration
/// Consumer(
///   builder: (context, ref, child) {
///     return AdaptiveGlassWidget(
///       size: Size(120, 160),
///       onTap: () {
///         ref.read(recipeProgressProvider.notifier).toggleIngredient(0);
///       },
///     );
///   },
/// )
/// ```

library glass_visualization;

// Core glass system
export 'glass_shape.dart';
export 'liquid_fill_painter.dart';
export 'rim_decoration.dart';
export 'garnish_animator.dart';
export 'bubble_stream.dart';
export 'recipe_progress_notifier.dart';
export 'adaptive_glass_widget.dart';

// Re-export commonly used types
export 'package:flutter/material.dart' show Size, Color, Offset;
export 'package:flutter_riverpod/flutter_riverpod.dart' show Consumer, ConsumerWidget, WidgetRef;