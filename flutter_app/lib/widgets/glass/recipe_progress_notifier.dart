import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'liquid_fill_painter.dart';
import 'rim_decoration.dart';
import 'garnish_animator.dart';
import 'bubble_stream.dart';

/// Recipe progress state
class RecipeProgressState {
  const RecipeProgressState({
    this.checkedIngredients = const [],
    this.totalIngredients = 0,
    this.currentStep = RecipeStep.empty,
    this.rimType = RimType.none,
    this.garnishType = GarnishType.none,
    this.liquidLayers = const [],
    this.hasCarbonation = false,
    this.glassType = GlassType.highball,
  });

  /// List of checked ingredient indices
  final List<int> checkedIngredients;
  
  /// Total number of ingredients in recipe
  final int totalIngredients;
  
  /// Current step in the recipe process
  final RecipeStep currentStep;
  
  /// Type of rim decoration
  final RimType rimType;
  
  /// Type of garnish
  final GarnishType garnishType;
  
  /// Liquid layers for the drink
  final List<LiquidLayer> liquidLayers;
  
  /// Whether the drink has carbonation
  final bool hasCarbonation;
  
  /// Type of glass for the recipe
  final GlassType glassType;

  /// Calculate fill level based on checked ingredients
  double get fillLevel {
    if (totalIngredients == 0) return 0.0;
    return (checkedIngredients.length / totalIngredients).clamp(0.0, 1.0);
  }

  /// Whether rim should be shown
  bool get shouldShowRim {
    return currentStep.index >= RecipeStep.rimAdded.index && rimType != RimType.none;
  }

  /// Whether garnish should be shown
  bool get shouldShowGarnish {
    return currentStep.index >= RecipeStep.garnished.index && garnishType != GarnishType.none;
  }

  /// Whether bubbles should be active
  bool get shouldShowBubbles {
    return hasCarbonation && fillLevel > 0.1;
  }

  /// Progress for rim decoration animation (0.0 to 1.0)
  double get rimProgress {
    if (!shouldShowRim) return 0.0;
    return currentStep == RecipeStep.rimAdded ? 1.0 : 0.5;
  }

  /// Progress for garnish animation (0.0 to 1.0)
  double get garnishProgress {
    if (!shouldShowGarnish) return 0.0;
    return 1.0;
  }

  RecipeProgressState copyWith({
    List<int>? checkedIngredients,
    int? totalIngredients,
    RecipeStep? currentStep,
    RimType? rimType,
    GarnishType? garnishType,
    List<LiquidLayer>? liquidLayers,
    bool? hasCarbonation,
    GlassType? glassType,
  }) {
    return RecipeProgressState(
      checkedIngredients: checkedIngredients ?? this.checkedIngredients,
      totalIngredients: totalIngredients ?? this.totalIngredients,
      currentStep: currentStep ?? this.currentStep,
      rimType: rimType ?? this.rimType,
      garnishType: garnishType ?? this.garnishType,
      liquidLayers: liquidLayers ?? this.liquidLayers,
      hasCarbonation: hasCarbonation ?? this.hasCarbonation,
      glassType: glassType ?? this.glassType,
    );
  }
}

/// Recipe preparation steps
enum RecipeStep {
  empty(0),
  rimAdded(1),
  ingredientsAdded(2),
  mixed(3),
  garnished(4),
  complete(5);

  const RecipeStep(this.index);
  final int index;
}

/// Supported glass types
enum GlassType {
  margarita,
  highball,
  wine,
  rocks,
  coupe,
}

/// Notifier for recipe progress state
class RecipeProgressNotifier extends StateNotifier<RecipeProgressState> {
  RecipeProgressNotifier() : super(const RecipeProgressState());

  /// Initialize recipe with ingredients and settings
  void initializeRecipe({
    required int totalIngredients,
    required RimType rimType,
    required GarnishType garnishType,
    required List<LiquidLayer> liquidLayers,
    required bool hasCarbonation,
    required GlassType glassType,
  }) {
    state = RecipeProgressState(
      totalIngredients: totalIngredients,
      rimType: rimType,
      garnishType: garnishType,
      liquidLayers: liquidLayers,
      hasCarbonation: hasCarbonation,
      glassType: glassType,
      currentStep: RecipeStep.empty,
      checkedIngredients: [],
    );
  }

  /// Toggle ingredient check state
  void toggleIngredient(int ingredientIndex) {
    final newChecked = List<int>.from(state.checkedIngredients);
    
    if (newChecked.contains(ingredientIndex)) {
      newChecked.remove(ingredientIndex);
    } else {
      newChecked.add(ingredientIndex);
    }
    
    newChecked.sort();
    
    // Update current step based on progress
    final newStep = _calculateCurrentStep(newChecked.length);
    
    state = state.copyWith(
      checkedIngredients: newChecked,
      currentStep: newStep,
    );
  }

  /// Calculate current recipe step based on ingredient count
  RecipeStep _calculateCurrentStep(int checkedCount) {
    if (checkedCount == 0) {
      return RecipeStep.empty;
    } else if (checkedCount < state.totalIngredients) {
      return RecipeStep.ingredientsAdded;
    } else if (checkedCount == state.totalIngredients) {
      if (state.rimType != RimType.none) {
        return RecipeStep.rimAdded;
      } else if (state.garnishType != GarnishType.none) {
        return RecipeStep.garnished;
      } else {
        return RecipeStep.complete;
      }
    }
    return RecipeStep.complete;
  }

  /// Mark rim as added
  void addRim() {
    if (state.rimType != RimType.none) {
      state = state.copyWith(currentStep: RecipeStep.rimAdded);
    }
  }

  /// Mark drink as mixed
  void markAsMixed() {
    state = state.copyWith(currentStep: RecipeStep.mixed);
  }

  /// Add garnish and complete recipe
  void addGarnish() {
    if (state.garnishType != GarnishType.none) {
      state = state.copyWith(currentStep: RecipeStep.garnished);
    } else {
      state = state.copyWith(currentStep: RecipeStep.complete);
    }
  }

  /// Reset recipe progress
  void reset() {
    state = state.copyWith(
      checkedIngredients: [],
      currentStep: RecipeStep.empty,
    );
  }

  /// Get liquid layers filtered by current progress
  List<LiquidLayer> getVisibleLayers() {
    final fillLevel = state.fillLevel;
    if (fillLevel <= 0) return [];

    final visibleLayers = <LiquidLayer>[];
    double accumulatedThickness = 0.0;

    for (final layer in state.liquidLayers) {
      accumulatedThickness += layer.thickness;
      
      if (accumulatedThickness <= fillLevel || visibleLayers.isEmpty) {
        // Adjust layer thickness if it extends beyond fill level
        final adjustedThickness = (accumulatedThickness > fillLevel)
            ? layer.thickness - (accumulatedThickness - fillLevel)
            : layer.thickness;

        visibleLayers.add(LiquidLayer(
          color: layer.color,
          thickness: adjustedThickness,
          opacity: layer.opacity,
          isTranslucent: layer.isTranslucent,
        ));

        if (accumulatedThickness >= fillLevel) break;
      }
    }

    return visibleLayers;
  }
}

/// Provider for recipe progress
final recipeProgressProvider = StateNotifierProvider<RecipeProgressNotifier, RecipeProgressState>(
  (ref) => RecipeProgressNotifier(),
);

/// Helper class for common recipe configurations
class RecipeConfigurations {
  /// Create configuration for a Margarita
  static RecipeProgressState margarita() {
    return const RecipeProgressState(
      totalIngredients: 3,
      rimType: RimType.salt,
      garnishType: GarnishType.limeWheel,
      liquidLayers: LiquidPresets.margarita,
      hasCarbonation: false,
      glassType: GlassType.margarita,
    );
  }

  /// Create configuration for an Old Fashioned
  static RecipeProgressState oldFashioned() {
    return const RecipeProgressState(
      totalIngredients: 4,
      rimType: RimType.none,
      garnishType: GarnishType.cherry,
      liquidLayers: LiquidPresets.oldFashioned,
      hasCarbonation: false,
      glassType: GlassType.rocks,
    );
  }

  /// Create configuration for a Mojito
  static RecipeProgressState mojito() {
    return const RecipeProgressState(
      totalIngredients: 5,
      rimType: RimType.none,
      garnishType: GarnishType.mintSprig,
      liquidLayers: LiquidPresets.mojito,
      hasCarbonation: true,
      glassType: GlassType.highball,
    );
  }

  /// Create configuration for a Cosmopolitan
  static RecipeProgressState cosmopolitan() {
    return const RecipeProgressState(
      totalIngredients: 4,
      rimType: RimType.sugar,
      garnishType: GarnishType.limeWheel,
      liquidLayers: LiquidPresets.cosmopolitan,
      hasCarbonation: false,
      glassType: GlassType.coupe,
    );
  }

  /// Create configuration from recipe name
  static RecipeProgressState fromRecipeName(String recipeName) {
    final lowerName = recipeName.toLowerCase();
    
    if (lowerName.contains('margarita')) {
      return margarita();
    } else if (lowerName.contains('old fashioned') || lowerName.contains('whiskey')) {
      return oldFashioned();
    } else if (lowerName.contains('mojito')) {
      return mojito();
    } else if (lowerName.contains('cosmopolitan')) {
      return cosmopolitan();
    }
    
    // Default configuration
    return const RecipeProgressState(
      totalIngredients: 3,
      rimType: RimType.none,
      garnishType: GarnishType.none,
      liquidLayers: [
        LiquidLayer(color: Color(0xFFE6F3FF), thickness: 1.0),
      ],
      hasCarbonation: false,
      glassType: GlassType.highball,
    );
  }
}

/// Extension for easy access to progress calculations
extension RecipeProgressCalculations on RecipeProgressState {
  /// Get percentage completion as string
  String get completionPercentage {
    final percentage = (fillLevel * 100).round();
    return '$percentage%';
  }

  /// Get current step description
  String get stepDescription {
    switch (currentStep) {
      case RecipeStep.empty:
        return 'Ready to start';
      case RecipeStep.rimAdded:
        return 'Rim prepared';
      case RecipeStep.ingredientsAdded:
        return 'Adding ingredients';
      case RecipeStep.mixed:
        return 'Mixed and ready';
      case RecipeStep.garnished:
        return 'Garnished';
      case RecipeStep.complete:
        return 'Complete!';
    }
  }

  /// Whether the recipe is complete
  bool get isComplete => currentStep == RecipeStep.complete;

  /// Whether ingredients are being added
  bool get isInProgress => currentStep == RecipeStep.ingredientsAdded;
}