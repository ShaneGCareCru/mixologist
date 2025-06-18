import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'haptic_service.dart';
import '../widgets/animations/liquid_drop_animation.dart';
import '../widgets/animations/cocktail_shaker_animation.dart';
import '../widgets/animations/glass_clink_animation.dart';

/// Standardized interaction feedback patterns that coordinate haptics, 
/// animations, and sound effects for consistent user experience
class InteractionFeedback {
  static bool _soundEnabled = true;
  static bool _animationsEnabled = true;
  
  /// Configure global feedback settings
  static void configure({
    bool? enableSound,
    bool? enableAnimations,
  }) {
    if (enableSound != null) _soundEnabled = enableSound;
    if (enableAnimations != null) _animationsEnabled = enableAnimations;
  }
  
  /// Success feedback pattern
  /// Used for: Recipe completion, successful actions, achievements
  static Future<void> success(BuildContext context, {
    String? message,
    Duration? duration,
    bool? showVisual,
  }) async {
    // Haptic feedback
    await HapticService.instance.recipeFinish();
    
    // Sound effect (using haptic as sound substitute)
    if (_soundEnabled) {
      HapticService.instance.selection();
    }
    
    // Visual feedback
    if (_animationsEnabled && (showVisual ?? true)) {
      _showSuccessSnackBar(context, message ?? 'Success!', duration);
    }
  }
  
  /// Progress feedback pattern
  /// Used for: Step completion, ingredient checking, partial progress
  static Future<void> progress(BuildContext context, {
    String? message,
    double? progressValue,
    bool? showLiquidDrop,
  }) async {
    // Haptic feedback
    await HapticService.instance.stepComplete();
    
    // Sound effect (using haptic as sound substitute)
    if (_soundEnabled) {
      HapticService.instance.selection();
    }
    
    // Visual feedback
    if (_animationsEnabled) {
      if (showLiquidDrop ?? false) {
        _showLiquidDropOverlay(context);
      } else {
        _showProgressSnackBar(context, message ?? 'Progress made!');
      }
    }
  }
  
  /// Error feedback pattern
  /// Used for: Failed actions, validation errors, network issues
  static Future<void> error(BuildContext context, {
    String? message,
    Duration? duration,
    bool? showVisual,
  }) async {
    // Haptic feedback
    await HapticService.instance.error();
    
    // Sound effect (system error sound)
    if (_soundEnabled) {
      await HapticService.instance.error(); // Use haptic for error sound
    }
    
    // Visual feedback
    if (_animationsEnabled && (showVisual ?? true)) {
      _showErrorSnackBar(context, message ?? 'Something went wrong', duration);
    }
  }
  
  /// Selection feedback pattern
  /// Used for: Button taps, menu selections, toggles
  static Future<void> selection(BuildContext context, {
    FeedbackType type = FeedbackType.light,
  }) async {
    switch (type) {
      case FeedbackType.light:
        await HapticService.instance.selection();
        break;
      case FeedbackType.medium:
        await HapticService.instance.ingredientCheck();
        break;
      case FeedbackType.heavy:
        await HapticService.instance.heavyImpact();
        break;
    }
    
    if (_soundEnabled) {
      HapticService.instance.selection();
    }
  }
  
  /// Ingredient check feedback pattern
  /// Used for: Ingredient checklist, shopping list items
  static Future<void> ingredientCheck(BuildContext context, {
    required Offset position,
    Color? liquidColor,
    VoidCallback? onComplete,
  }) async {
    // Haptic feedback
    await HapticService.instance.ingredientCheck();
    
    // Sound effect (using haptic as sound substitute)
    if (_soundEnabled) {
      HapticService.instance.selection();
    }
    
    // Liquid drop animation
    if (_animationsEnabled) {
      _showLiquidDropAt(context, position, liquidColor, onComplete);
    }
  }
  
  /// Cocktail shake feedback pattern
  /// Used for: Shake gestures, mixing animations
  static Future<void> cocktailShake(BuildContext context, {
    Duration? duration,
    VoidCallback? onComplete,
  }) async {
    // Haptic shake pattern
    await HapticService.instance.cocktailShake();
    
    // Visual shake animation
    if (_animationsEnabled) {
      _showShakerOverlay(context, duration, onComplete);
    }
  }
  
  /// Share action feedback pattern
  /// Used for: Share button, social actions
  static Future<void> share(BuildContext context, {
    VoidCallback? onComplete,
  }) async {
    // Haptic glass clink
    await HapticService.instance.glassClink();
    
    // Glass clink animation
    if (_animationsEnabled) {
      _showGlassClinkOverlay(context, onComplete);
    }
  }
  
  /// Favorite toggle feedback pattern
  /// Used for: Favorite buttons, bookmark actions
  static Future<void> favorite(BuildContext context, {
    required bool isFavorited,
    VoidCallback? onComplete,
  }) async {
    if (isFavorited) {
      await HapticService.instance.heavyImpact();
    } else {
      await HapticService.instance.selection();
    }
    
    if (_soundEnabled) {
      HapticService.instance.selection();
    }
    
    onComplete?.call();
  }
  
  /// Long press feedback pattern
  /// Used for: Context menus, drag operations
  static Future<void> longPress(BuildContext context) async {
    await HapticService.instance.heavyImpact();
    
    if (_soundEnabled) {
      HapticService.instance.selection();
    }
  }
  
  /// Swipe feedback pattern
  /// Used for: Swipe gestures, navigation
  static Future<void> swipe(BuildContext context, {
    SwipeDirection direction = SwipeDirection.horizontal,
  }) async {
    await HapticService.instance.selection();
    
    if (_soundEnabled) {
      HapticService.instance.selection();
    }
  }
  
  /// Focus feedback pattern
  /// Used for: Input focus, accessibility navigation
  static Future<void> focus(BuildContext context) async {
    await HapticService.instance.selection();
  }
  
  /// Accessibility feedback pattern
  /// Used for: Screen reader navigation, accessibility actions
  static Future<void> accessibility(BuildContext context, {
    String? message,
  }) async {
    final mediaQuery = MediaQuery.of(context);
    
    // Only provide feedback if accessibility features are enabled
    if (mediaQuery.accessibleNavigation) {
      await HapticService.instance.selection();
      
      if (message != null) {
        // Announce to screen reader (simplified)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }
  
  // Private helper methods
  
  static void _showSuccessSnackBar(BuildContext context, String message, Duration? duration) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF87A96B), // Sage green
        duration: duration ?? const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  static void _showProgressSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFFB8860B), // Amber
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  static void _showErrorSnackBar(BuildContext context, String message, Duration? duration) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F), // Red
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  static void _showLiquidDropOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => LiquidDropAnimation(
        startPosition: const Offset(100, 50),
        glassPosition: const Offset(200, 200),
        onAnimationComplete: () {
          overlayEntry.remove();
        },
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  static void _showLiquidDropAt(BuildContext context, Offset position, Color? liquidColor, VoidCallback? onComplete) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => LiquidDropAnimation(
        startPosition: position,
        glassPosition: Offset(position.dx, position.dy + 100),
        liquidColor: liquidColor ?? const Color(0xFFB8860B),
        onAnimationComplete: () {
          overlayEntry.remove();
          onComplete?.call();
        },
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  static void _showShakerOverlay(BuildContext context, Duration? duration, VoidCallback? onComplete) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: InteractiveCocktailShaker(
              shakeDuration: duration ?? const Duration(milliseconds: 2000),
              onShakeComplete: () {
                overlayEntry.remove();
                onComplete?.call();
              },
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  static void _showGlassClinkOverlay(BuildContext context, VoidCallback? onComplete) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => GlassClinkOverlay(
        onComplete: () {
          overlayEntry.remove();
          onComplete?.call();
        },
      ),
    );
    
    overlay.insert(overlayEntry);
  }
}

/// Feedback intensity types
enum FeedbackType {
  light,
  medium,
  heavy,
}

/// Swipe direction types
enum SwipeDirection {
  horizontal,
  vertical,
  diagonal,
}

/// Extension methods for easy access to feedback patterns
extension InteractionFeedbackExtensions on BuildContext {
  /// Quick access to success feedback
  Future<void> feedbackSuccess([String? message]) async {
    return InteractionFeedback.success(this, message: message);
  }
  
  /// Quick access to progress feedback
  Future<void> feedbackProgress([String? message]) async {
    return InteractionFeedback.progress(this, message: message);
  }
  
  /// Quick access to error feedback
  Future<void> feedbackError([String? message]) async {
    return InteractionFeedback.error(this, message: message);
  }
  
  /// Quick access to selection feedback
  Future<void> feedbackSelection([FeedbackType type = FeedbackType.light]) async {
    return InteractionFeedback.selection(this, type: type);
  }
  
  /// Quick access to ingredient check feedback
  Future<void> feedbackIngredientCheck(Offset position, [VoidCallback? onComplete]) async {
    return InteractionFeedback.ingredientCheck(this, position: position, onComplete: onComplete);
  }
  
  /// Quick access to shake feedback
  Future<void> feedbackShake([VoidCallback? onComplete]) async {
    return InteractionFeedback.cocktailShake(this, onComplete: onComplete);
  }
  
  /// Quick access to share feedback
  Future<void> feedbackShare([VoidCallback? onComplete]) async {
    return InteractionFeedback.share(this, onComplete: onComplete);
  }
  
  /// Quick access to favorite feedback
  Future<void> feedbackFavorite(bool isFavorited, [VoidCallback? onComplete]) async {
    return InteractionFeedback.favorite(this, isFavorited: isFavorited, onComplete: onComplete);
  }
}

/// Widget mixin for adding interaction feedback capabilities
mixin InteractionFeedbackMixin<T extends StatefulWidget> on State<T> {
  /// Provides haptic service access
  HapticService get haptics => HapticService.instance;
  
  /// Provides quick feedback access to static methods
  Type get feedback => InteractionFeedback;
  
  /// Handle success with feedback
  Future<void> handleSuccess({String? message, VoidCallback? onComplete}) async {
    await context.feedbackSuccess(message);
    onComplete?.call();
  }
  
  /// Handle error with feedback
  Future<void> handleError({String? message, VoidCallback? onComplete}) async {
    await context.feedbackError(message);
    onComplete?.call();
  }
  
  /// Handle selection with feedback
  Future<void> handleSelection({FeedbackType type = FeedbackType.light, VoidCallback? onComplete}) async {
    await context.feedbackSelection(type);
    onComplete?.call();
  }
}

/// Widget wrapper that adds interaction feedback to any child widget
class FeedbackWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final FeedbackType tapFeedbackType;
  final bool enableFeedback;
  
  const FeedbackWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.tapFeedbackType = FeedbackType.light,
    this.enableFeedback = true,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!enableFeedback) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: child,
      );
    }
    
    return GestureDetector(
      onTap: onTap != null ? () async {
        await context.feedbackSelection(tapFeedbackType);
        onTap!();
      } : null,
      onLongPress: onLongPress != null ? () async {
        await InteractionFeedback.longPress(context);
        onLongPress!();
      } : null,
      child: child,
    );
  }
}