import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'glass_shape.dart';
import 'liquid_fill_painter.dart';
import 'rim_decoration.dart';
import 'garnish_animator.dart';
import 'bubble_stream.dart';
import 'recipe_progress_notifier.dart';
import '../depth/glass_reflection.dart';

/// Main adaptive glass visualization widget
class AdaptiveGlassWidget extends ConsumerWidget {
  const AdaptiveGlassWidget({
    super.key,
    this.size = const Size(120, 160),
    this.enableReflection = true,
    this.enableDepthEffects = true,
    this.onTap,
  });

  /// Size of the glass widget
  final Size size;
  
  /// Whether to show glass reflection effects
  final bool enableReflection;
  
  /// Whether to enable depth visual effects
  final bool enableDepthEffects;
  
  /// Callback when glass is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(recipeProgressProvider);
    final glassShape = _getGlassShape(progressState.glassType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: enableDepthEffects ? _buildDepthDecoration() : null,
        child: Stack(
          children: [
            // Glass outline and background
            _buildGlassOutline(glassShape),
            
            // Liquid fill layers
            if (progressState.fillLevel > 0)
              _buildLiquidFill(glassShape, progressState),
            
            // Bubble effects (behind rim and garnish)
            if (progressState.shouldShowBubbles)
              _buildBubbleStream(glassShape, progressState),
            
            // Rim decoration
            if (progressState.shouldShowRim)
              _buildRimDecoration(glassShape, progressState),
            
            // Garnish animation
            if (progressState.shouldShowGarnish)
              _buildGarnishAnimation(glassShape, progressState),
            
            // Glass reflection overlay
            if (enableReflection)
              _buildGlassReflection(),
            
            // Progress indicator overlay
            _buildProgressIndicator(progressState),
          ],
        ),
      ),
    );
  }

  /// Get glass shape instance based on type
  GlassShape _getGlassShape(GlassType glassType) {
    switch (glassType) {
      case GlassType.margarita:
        return MargaritaGlass();
      case GlassType.highball:
        return HighballGlass();
      case GlassType.wine:
        return WineGlass();
      case GlassType.rocks:
        return RocksGlass();
      case GlassType.coupe:
        return CoupeGlass();
    }
  }

  /// Build depth decoration for 3D effect
  BoxDecoration _buildDepthDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.1),
          blurRadius: 4,
          spreadRadius: 1,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }

  /// Build glass outline
  Widget _buildGlassOutline(GlassShape glassShape) {
    return CustomPaint(
      painter: _GlassOutlinePainter(glassShape: glassShape),
      size: size,
    );
  }

  /// Build liquid fill with layers
  Widget _buildLiquidFill(GlassShape glassShape, RecipeProgressState state) {
    final visibleLayers = ref.read(recipeProgressProvider.notifier).getVisibleLayers();
    
    return CustomPaint(
      painter: LiquidFillPainter(
        glassShape: glassShape,
        layers: visibleLayers,
        totalFillLevel: state.fillLevel,
        showMeniscus: true,
      ),
      size: size,
    );
  }

  /// Build bubble stream effects
  Widget _buildBubbleStream(GlassShape glassShape, RecipeProgressState state) {
    final bubbleConfig = state.hasCarbonation 
        ? BubblePresets.medium 
        : const BubbleConfig(bubbleCount: 0, intensity: 0.0, bubbleColor: Colors.transparent);

    return BubbleStream(
      glassShape: glassShape,
      isActive: state.shouldShowBubbles,
      size: size,
      bubbleCount: bubbleConfig.bubbleCount,
      fillLevel: state.fillLevel,
      intensity: bubbleConfig.intensity,
      bubbleColor: bubbleConfig.bubbleColor,
    );
  }

  /// Build rim decoration
  Widget _buildRimDecoration(GlassShape glassShape, RecipeProgressState state) {
    return RimDecoration(
      glassShape: glassShape,
      rimType: state.rimType,
      progress: state.rimProgress,
      size: size,
    );
  }

  /// Build garnish animation
  Widget _buildGarnishAnimation(GlassShape glassShape, RecipeProgressState state) {
    return GarnishAnimator(
      glassShape: glassShape,
      garnishType: state.garnishType,
      progress: state.garnishProgress,
      size: size,
    );
  }

  /// Build glass reflection overlay
  Widget _buildGlassReflection() {
    return Positioned.fill(
      child: GlassReflection(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build progress indicator overlay
  Widget _buildProgressIndicator(RecipeProgressState state) {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.stepDescription,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            LinearProgressIndicator(
              value: state.fillLevel,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(state.currentStep),
              ),
              minHeight: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// Get color for progress indicator based on step
  Color _getProgressColor(RecipeStep step) {
    switch (step) {
      case RecipeStep.empty:
        return Colors.grey;
      case RecipeStep.rimAdded:
        return Colors.blue;
      case RecipeStep.ingredientsAdded:
        return Colors.orange;
      case RecipeStep.mixed:
        return Colors.yellow;
      case RecipeStep.garnished:
        return Colors.green;
      case RecipeStep.complete:
        return Colors.green;
    }
  }
}

/// Custom painter for glass outline
class _GlassOutlinePainter extends CustomPainter {
  const _GlassOutlinePainter({required this.glassShape});

  final GlassShape glassShape;

  @override
  void paint(Canvas canvas, Size size) {
    final outlinePath = glassShape.getOutlinePath(size);
    
    // Glass stroke
    final strokePaint = Paint()
      ..color = Colors.grey[400]!.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    canvas.drawPath(outlinePath, strokePaint);
    
    // Inner shadow for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(outlinePath, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant _GlassOutlinePainter oldDelegate) {
    return oldDelegate.glassShape != glassShape;
  }
}

/// Recipe-specific glass widget with predefined configurations
class RecipeGlassWidget extends ConsumerStatefulWidget {
  const RecipeGlassWidget({
    super.key,
    required this.recipeName,
    required this.ingredients,
    this.size = const Size(120, 160),
    this.onIngredientToggle,
  });

  /// Name of the recipe
  final String recipeName;
  
  /// List of recipe ingredients
  final List<String> ingredients;
  
  /// Size of the glass widget
  final Size size;
  
  /// Callback when ingredient is toggled
  final Function(int index)? onIngredientToggle;

  @override
  ConsumerState<RecipeGlassWidget> createState() => _RecipeGlassWidgetState();
}

class _RecipeGlassWidgetState extends ConsumerState<RecipeGlassWidget> {
  @override
  void initState() {
    super.initState();
    _initializeRecipe();
  }

  @override
  void didUpdateWidget(RecipeGlassWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipeName != widget.recipeName || 
        oldWidget.ingredients.length != widget.ingredients.length) {
      _initializeRecipe();
    }
  }

  void _initializeRecipe() {
    final config = RecipeConfigurations.fromRecipeName(widget.recipeName);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipeProgressProvider.notifier).initializeRecipe(
        totalIngredients: widget.ingredients.length,
        rimType: config.rimType,
        garnishType: config.garnishType,
        liquidLayers: config.liquidLayers,
        hasCarbonation: config.hasCarbonation,
        glassType: config.glassType,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveGlassWidget(
      size: widget.size,
      onTap: () {
        // Toggle next unchecked ingredient
        final state = ref.read(recipeProgressProvider);
        for (int i = 0; i < widget.ingredients.length; i++) {
          if (!state.checkedIngredients.contains(i)) {
            ref.read(recipeProgressProvider.notifier).toggleIngredient(i);
            widget.onIngredientToggle?.call(i);
            break;
          }
        }
      },
    );
  }
}

/// Extension for easy glass integration
extension AdaptiveGlassExtensions on Widget {
  /// Wrap widget with glass visualization
  Widget withGlassVisualization({
    required String recipeName,
    required List<String> ingredients,
    Size glassSize = const Size(120, 160),
  }) {
    return Row(
      children: [
        Expanded(child: this),
        const SizedBox(width: 16),
        RecipeGlassWidget(
          recipeName: recipeName,
          ingredients: ingredients,
          size: glassSize,
        ),
      ],
    );
  }
}