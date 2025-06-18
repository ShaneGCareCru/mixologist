import 'package:flutter/material.dart';
import 'dart:math';

/// Premium polish animation collection for the "1% that makes 99% of the impression"
/// Includes shimmer effects, glow pulses, breathing animations, and easing curves
class PolishAnimations {
  /// Shimmer effect for loading states and emphasis
  static Widget shimmerEffect(
    Widget child, {
    Duration duration = const Duration(milliseconds: 1500),
    Color? baseColor,
    Color? highlightColor,
    ShimmerDirection direction = ShimmerDirection.leftToRight,
    bool enabled = true,
  }) {
    if (!enabled) return child;
    
    return _ShimmerWidget(
      duration: duration,
      baseColor: baseColor,
      highlightColor: highlightColor,
      direction: direction,
      child: child,
    );
  }
  
  /// Glow pulse effect for active elements and focus states
  static Widget glowPulse(
    Widget child, {
    Duration duration = const Duration(milliseconds: 2000),
    Color? glowColor,
    double intensity = 0.3,
    double radius = 10.0,
    bool enabled = true,
  }) {
    if (!enabled) return child;
    
    return _GlowPulseWidget(
      duration: duration,
      glowColor: glowColor ?? const Color(0xFFB8860B),
      intensity: intensity,
      radius: radius,
      child: child,
    );
  }
  
  /// Subtle breathing animation for waiting states and ambient effects
  static Widget subtleBreathing(
    Widget child, {
    Duration duration = const Duration(milliseconds: 3000),
    double scaleMin = 0.98,
    double scaleMax = 1.02,
    double opacityMin = 0.8,
    double opacityMax = 1.0,
    bool enabled = true,
  }) {
    if (!enabled) return child;
    
    return _BreathingWidget(
      duration: duration,
      scaleMin: scaleMin,
      scaleMax: scaleMax,
      opacityMin: opacityMin,
      opacityMax: opacityMax,
      child: child,
    );
  }
}

/// Direction for shimmer animation
enum ShimmerDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
  diagonal,
}

/// Shimmer effect implementation
class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;
  final ShimmerDirection direction;
  
  const _ShimmerWidget({
    required this.child,
    required this.duration,
    this.baseColor,
    this.highlightColor,
    required this.direction,
  });
  
  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: CustomEasing.shimmer,
    ));
    
    _controller.repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return _createShimmerGradient(
              bounds,
              baseColor,
              highlightColor,
              _animation.value,
            );
          },
          child: widget.child,
        );
      },
    );
  }
  
  Shader _createShimmerGradient(
    Rect bounds,
    Color baseColor,
    Color highlightColor,
    double progress,
  ) {
    final Offset start, end;
    
    switch (widget.direction) {
      case ShimmerDirection.leftToRight:
        start = Offset(bounds.left - bounds.width, bounds.top);
        end = Offset(bounds.right + bounds.width, bounds.top);
        break;
      case ShimmerDirection.rightToLeft:
        start = Offset(bounds.right + bounds.width, bounds.top);
        end = Offset(bounds.left - bounds.width, bounds.top);
        break;
      case ShimmerDirection.topToBottom:
        start = Offset(bounds.left, bounds.top - bounds.height);
        end = Offset(bounds.left, bounds.bottom + bounds.height);
        break;
      case ShimmerDirection.bottomToTop:
        start = Offset(bounds.left, bounds.bottom + bounds.height);
        end = Offset(bounds.left, bounds.top - bounds.height);
        break;
      case ShimmerDirection.diagonal:
        start = Offset(bounds.left - bounds.width, bounds.top - bounds.height);
        end = Offset(bounds.right + bounds.width, bounds.bottom + bounds.height);
        break;
    }
    
    final animatedStart = Offset.lerp(start, end, progress - 0.3)!;
    final animatedEnd = Offset.lerp(start, end, progress + 0.3)!;
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [baseColor, highlightColor, baseColor],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientRotation(progress * 2 * pi),
    ).createShader(Rect.fromPoints(animatedStart, animatedEnd));
  }
}

/// Glow pulse effect implementation
class _GlowPulseWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color glowColor;
  final double intensity;
  final double radius;
  
  const _GlowPulseWidget({
    required this.child,
    required this.duration,
    required this.glowColor,
    required this.intensity,
    required this.radius,
  });
  
  @override
  State<_GlowPulseWidget> createState() => _GlowPulseWidgetState();
}

class _GlowPulseWidgetState extends State<_GlowPulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: CustomEasing.glow,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.2,
      end: widget.intensity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(_opacityAnimation.value),
                blurRadius: widget.radius * _pulseAnimation.value,
                spreadRadius: (widget.radius * 0.3) * _pulseAnimation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Breathing animation implementation
class _BreathingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scaleMin;
  final double scaleMax;
  final double opacityMin;
  final double opacityMax;
  
  const _BreathingWidget({
    required this.child,
    required this.duration,
    required this.scaleMin,
    required this.scaleMax,
    required this.opacityMin,
    required this.opacityMax,
  });
  
  @override
  State<_BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<_BreathingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: widget.scaleMin,
      end: widget.scaleMax,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: CustomEasing.breathing,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: widget.opacityMin,
      end: widget.opacityMax,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Custom easing curves for premium polish effects
class CustomEasing {
  /// Shimmer easing with smooth acceleration
  static const Curve shimmer = Curves.easeInOut;
  
  /// Glow pulse with gentle breathing rhythm
  static const Curve glow = _GlowCurve();
  
  /// Natural breathing pattern
  static const Curve breathing = _BreathingCurve();
  
  /// Elastic bounce for interactive elements
  static const Curve elasticOut = Curves.elasticOut;
  
  /// Smooth deceleration for reveals
  static const Curve smoothOut = _SmoothOutCurve();
  
  /// Apple-inspired spring animation
  static const Curve appleSpring = _AppleSpringCurve();
}

/// Custom curve for glow effects
class _GlowCurve extends Curve {
  const _GlowCurve();
  
  @override
  double transform(double t) {
    // Sine wave for natural pulsing
    return 0.5 + 0.5 * sin(t * pi);
  }
}

/// Custom curve for breathing animation
class _BreathingCurve extends Curve {
  const _BreathingCurve();
  
  @override
  double transform(double t) {
    // Natural breathing pattern with pause at peak
    if (t < 0.4) {
      // Inhale - gradual acceleration
      return 0.5 * sin(t * pi * 2.5);
    } else if (t < 0.6) {
      // Hold - plateau
      return 1.0;
    } else {
      // Exhale - gradual deceleration
      return 0.5 + 0.5 * cos((t - 0.6) * pi * 2.5);
    }
  }
}

/// Smooth deceleration curve
class _SmoothOutCurve extends Curve {
  const _SmoothOutCurve();
  
  @override
  double transform(double t) {
    return 1.0 - pow(1.0 - t, 3);
  }
}

/// Apple-inspired spring curve
class _AppleSpringCurve extends Curve {
  const _AppleSpringCurve();
  
  @override
  double transform(double t) {
    // Approximation of Apple's spring animation
    return t * t * (3.0 - 2.0 * t);
  }
}

/// Cocktail-themed animation presets
class CocktailAnimations {
  /// Shimmer for premium ingredients
  static Widget ingredientShimmer(Widget child) {
    return PolishAnimations.shimmerEffect(
      child,
      duration: const Duration(milliseconds: 2000),
      baseColor: const Color(0xFFB8860B).withOpacity(0.1),
      highlightColor: const Color(0xFFB8860B).withOpacity(0.3),
      direction: ShimmerDirection.diagonal,
    );
  }
  
  /// Glow for active recipe steps
  static Widget stepGlow(Widget child, {bool isActive = false}) {
    return PolishAnimations.glowPulse(
      child,
      duration: const Duration(milliseconds: 1500),
      glowColor: isActive ? const Color(0xFF87A96B) : const Color(0xFFB8860B),
      intensity: isActive ? 0.4 : 0.2,
      radius: 8.0,
      enabled: isActive,
    );
  }
  
  /// Breathing for waiting states
  static Widget bartenderThinking(Widget child) {
    return PolishAnimations.subtleBreathing(
      child,
      duration: const Duration(milliseconds: 2500),
      scaleMin: 0.95,
      scaleMax: 1.05,
      opacityMin: 0.7,
      opacityMax: 1.0,
    );
  }
  
  /// Floating animation for garnish elements
  static Widget floatingGarnish(Widget child) {
    return _FloatingWidget(
      duration: const Duration(milliseconds: 4000),
      child: child,
    );
  }
  
  /// Loading shimmer for recipe cards
  static Widget recipeCardShimmer(Widget child) {
    return PolishAnimations.shimmerEffect(
      child,
      duration: const Duration(milliseconds: 1800),
      baseColor: Colors.grey[200],
      highlightColor: Colors.white.withOpacity(0.8),
      direction: ShimmerDirection.leftToRight,
    );
  }
}

/// Floating animation widget
class _FloatingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  
  const _FloatingWidget({
    required this.child,
    required this.duration,
  });
  
  @override
  State<_FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<_FloatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _floatAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Interactive animation helpers
class InteractiveAnimations {
  /// Ripple effect for touch interactions
  static Widget rippleEffect(
    Widget child, {
    required VoidCallback onTap,
    Color? rippleColor,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return _RippleWidget(
      onTap: onTap,
      rippleColor: rippleColor ?? const Color(0xFFB8860B).withOpacity(0.2),
      duration: duration,
      child: child,
    );
  }
  
  /// Scale animation for button presses
  static Widget pressScale(
    Widget child, {
    required VoidCallback onPressed,
    double scale = 0.95,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return _PressScaleWidget(
      onPressed: onPressed,
      scale: scale,
      duration: duration,
      child: child,
    );
  }
}

/// Ripple effect widget
class _RippleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color rippleColor;
  final Duration duration;
  
  const _RippleWidget({
    required this.child,
    required this.onTap,
    required this.rippleColor,
    required this.duration,
  });
  
  @override
  State<_RippleWidget> createState() => _RippleWidgetState();
}

class _RippleWidgetState extends State<_RippleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rippleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0.0);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _rippleAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _RipplePainter(
              progress: _rippleAnimation.value,
              color: widget.rippleColor,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Press scale widget
class _PressScaleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double scale;
  final Duration duration;
  
  const _PressScaleWidget({
    required this.child,
    required this.onPressed,
    required this.scale,
    required this.duration,
  });
  
  @override
  State<_PressScaleWidget> createState() => _PressScaleWidgetState();
}

class _PressScaleWidgetState extends State<_PressScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Ripple painter
class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  
  _RipplePainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.5 * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, paint);
  }
  
  @override
  bool shouldRepaint(_RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Extension methods for easy animation integration
extension PolishAnimationExtensions on Widget {
  /// Add shimmer effect to any widget
  Widget withShimmer({
    Duration duration = const Duration(milliseconds: 1500),
    Color? baseColor,
    Color? highlightColor,
    ShimmerDirection direction = ShimmerDirection.leftToRight,
  }) {
    return PolishAnimations.shimmerEffect(
      this,
      duration: duration,
      baseColor: baseColor,
      highlightColor: highlightColor,
      direction: direction,
    );
  }
  
  /// Add glow pulse to any widget
  Widget withGlowPulse({
    Duration duration = const Duration(milliseconds: 2000),
    Color? glowColor,
    double intensity = 0.3,
    double radius = 10.0,
  }) {
    return PolishAnimations.glowPulse(
      this,
      duration: duration,
      glowColor: glowColor,
      intensity: intensity,
      radius: radius,
    );
  }
  
  /// Add breathing animation to any widget
  Widget withBreathing({
    Duration duration = const Duration(milliseconds: 3000),
    double scaleMin = 0.98,
    double scaleMax = 1.02,
    double opacityMin = 0.8,
    double opacityMax = 1.0,
  }) {
    return PolishAnimations.subtleBreathing(
      this,
      duration: duration,
      scaleMin: scaleMin,
      scaleMax: scaleMax,
      opacityMin: opacityMin,
      opacityMax: opacityMax,
    );
  }
  
  /// Add press scale interaction
  Widget withPressScale({
    required VoidCallback onPressed,
    double scale = 0.95,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return InteractiveAnimations.pressScale(
      this,
      onPressed: onPressed,
      scale: scale,
      duration: duration,
    );
  }
  
  /// Add ripple effect interaction
  Widget withRipple({
    required VoidCallback onTap,
    Color? rippleColor,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return InteractiveAnimations.rippleEffect(
      this,
      onTap: onTap,
      rippleColor: rippleColor,
      duration: duration,
    );
  }
}

/// Performance monitoring for animations
class AnimationPerformanceMonitor {
  static bool _performanceModeEnabled = false;
  static int _frameDropCount = 0;
  static DateTime? _lastFrameTime;
  
  /// Enable performance monitoring
  static void enable() {
    _performanceModeEnabled = true;
  }
  
  /// Check if animations should be disabled for performance
  static bool shouldDisableAnimations() {
    return _performanceModeEnabled && _frameDropCount > 10;
  }
  
  /// Record animation frame performance
  static void recordFrame() {
    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!).inMilliseconds;
      if (frameDuration > 32) { // More than ~30fps
        _frameDropCount++;
      } else if (_frameDropCount > 0) {
        _frameDropCount--;
      }
    }
    _lastFrameTime = now;
  }
  
  /// Reset performance counters
  static void reset() {
    _frameDropCount = 0;
    _lastFrameTime = null;
  }
}