import 'package:flutter/material.dart';
import 'dart:math';

/// Signature transition animations for the mixologist app
/// Includes liquid pour and shaker shake effects
class MixologistTransitions {
  /// Liquid pour transition effect
  static Route<T> cocktailPour<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 800),
    Color liquidColor = const Color(0xFFB8860B), // Amber
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _CocktailPourTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          liquidColor: liquidColor,
          child: child,
        );
      },
    );
  }
  
  /// Shaker shake transition effect
  static Route<T> shakerShake<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 600),
    bool enableSoundEffects = false,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _ShakerShakeTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          enableSoundEffects: enableSoundEffects,
          child: child,
        );
      },
    );
  }
  
  /// Elegant glass clink transition
  static Route<T> glassClink<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 700),
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _GlassClinkTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }
  
  /// Muddle press transition
  static Route<T> muddlePress<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 500),
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _MuddlePressTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }
  
  /// Ingredient drop transition
  static Route<T> ingredientDrop<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 900),
    Color dropColor = const Color(0xFF87A96B), // Sage
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _IngredientDropTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          dropColor: dropColor,
          child: child,
        );
      },
    );
  }
}

/// Liquid pour transition implementation
class _CocktailPourTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Color liquidColor;
  final Widget child;
  
  const _CocktailPourTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.liquidColor,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Liquid pour overlay
            CustomPaint(
              painter: _LiquidPourPainter(
                progress: animation.value,
                liquidColor: liquidColor,
              ),
              size: MediaQuery.of(context).size,
            ),
            // Page content with slide and fade
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
              )),
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
                )),
                child: this.child,
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}

/// Shaker shake transition implementation
class _ShakerShakeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final bool enableSoundEffects;
  final Widget child;
  
  const _ShakerShakeTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.enableSoundEffects,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final shakeIntensity = animation.value < 0.7 
            ? animation.value / 0.7 
            : (1.0 - animation.value) / 0.3;
        
        return Transform.translate(
          offset: Offset(
            sin(animation.value * pi * 12) * 8 * shakeIntensity,
            cos(animation.value * pi * 16) * 4 * shakeIntensity,
          ),
          child: Transform.rotate(
            angle: sin(animation.value * pi * 10) * 0.05 * shakeIntensity,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.elasticOut,
              )),
              child: FadeTransition(
                opacity: animation,
                child: Stack(
                  children: [
                    this.child,
                    // Shaker ice particle effects
                    if (animation.value > 0.2)
                      CustomPaint(
                        painter: _IceParticlesPainter(
                          progress: animation.value,
                          shakeIntensity: shakeIntensity,
                        ),
                        size: MediaQuery.of(context).size,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// Glass clink transition implementation
class _GlassClinkTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;
  
  const _GlassClinkTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Flash effect at the moment of "clink"
            if (animation.value >= 0.4 && animation.value <= 0.6)
              Container(
                color: Colors.white.withOpacity(
                  (1.0 - (animation.value - 0.4) / 0.2) * 0.3,
                ),
              ),
            // Main content with elegant slide
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.95,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                )),
                child: this.child,
              ),
            ),
            // Glass reflection effect
            CustomPaint(
              painter: _GlassReflectionPainter(
                progress: animation.value,
              ),
              size: MediaQuery.of(context).size,
            ),
          ],
        );
      },
      child: child,
    );
  }
}

/// Muddle press transition implementation
class _MuddlePressTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;
  
  const _MuddlePressTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final pressAnimation = animation.value < 0.5
            ? animation.value * 2
            : 2 - (animation.value * 2);
        
        return Transform.scale(
          scale: 1.0 - (pressAnimation * 0.05),
          child: Transform.translate(
            offset: Offset(0, pressAnimation * 10),
            child: FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
              )),
              child: this.child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// Ingredient drop transition implementation
class _IngredientDropTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Color dropColor;
  final Widget child;
  
  const _IngredientDropTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.dropColor,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Ingredient drops
            CustomPaint(
              painter: _IngredientDropsPainter(
                progress: animation.value,
                dropColor: dropColor,
              ),
              size: MediaQuery.of(context).size,
            ),
            // Page content
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: const Interval(0.2, 1.0, curve: Curves.bounceOut),
              )),
              child: this.child,
            ),
          ],
        );
      },
      child: child,
    );
  }
}

/// Custom painter for liquid pour effect
class _LiquidPourPainter extends CustomPainter {
  final double progress;
  final Color liquidColor;
  
  _LiquidPourPainter({
    required this.progress,
    required this.liquidColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final paint = Paint()
      ..color = liquidColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    // Pour from top center
    final pourWidth = 20.0;
    final pourHeight = size.height * progress * 0.6;
    
    // Main pour stream
    final pourRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, pourHeight / 2),
        width: pourWidth,
        height: pourHeight,
      ),
      const Radius.circular(10),
    );
    
    canvas.drawRRect(pourRect, paint);
    
    // Splash at bottom
    if (progress > 0.3) {
      final splashProgress = (progress - 0.3) / 0.7;
      final splashRadius = splashProgress * 60;
      
      final splashPaint = Paint()
        ..color = liquidColor.withOpacity(0.5 * (1 - splashProgress))
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(size.width / 2, pourHeight),
        splashRadius,
        splashPaint,
      );
      
      // Splash droplets
      final random = Random(42);
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * pi;
        final dropletDistance = splashRadius * 0.8;
        final dropletX = size.width / 2 + cos(angle) * dropletDistance;
        final dropletY = pourHeight + sin(angle) * dropletDistance * 0.5;
        
        canvas.drawCircle(
          Offset(dropletX, dropletY),
          random.nextDouble() * 3 + 1,
          splashPaint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant _LiquidPourPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Custom painter for ice particles during shake
class _IceParticlesPainter extends CustomPainter {
  final double progress;
  final double shakeIntensity;
  
  _IceParticlesPainter({
    required this.progress,
    required this.shakeIntensity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    final random = Random(123);
    
    for (int i = 0; i < 15; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      
      final shakeX = baseX + sin(progress * pi * 8 + i) * 20 * shakeIntensity;
      final shakeY = baseY + cos(progress * pi * 6 + i) * 15 * shakeIntensity;
      
      final particleSize = random.nextDouble() * 3 + 1;
      
      canvas.drawCircle(
        Offset(shakeX, shakeY),
        particleSize,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _IceParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.shakeIntensity != shakeIntensity;
  }
}

/// Custom painter for glass reflection effect
class _GlassReflectionPainter extends CustomPainter {
  final double progress;
  
  _GlassReflectionPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    
    final reflectionWidth = 80.0;
    final reflectionAngle = -pi / 6; // 30 degrees
    
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.3),
        Colors.white.withOpacity(0.0),
      ],
    );
    
    final reflectionX = (size.width + reflectionWidth) * progress - reflectionWidth;
    
    canvas.save();
    canvas.translate(reflectionX, 0);
    canvas.rotate(reflectionAngle);
    
    final reflectionRect = Rect.fromLTWH(0, 0, reflectionWidth, size.height * 1.5);
    final paint = Paint()
      ..shader = gradient.createShader(reflectionRect);
    
    canvas.drawRect(reflectionRect, paint);
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant _GlassReflectionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Custom painter for ingredient drops
class _IngredientDropsPainter extends CustomPainter {
  final double progress;
  final Color dropColor;
  
  _IngredientDropsPainter({
    required this.progress,
    required this.dropColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final random = Random(456);
    
    for (int i = 0; i < 6; i++) {
      final dropProgress = ((progress * 3) - i * 0.2).clamp(0.0, 1.0);
      if (dropProgress <= 0) continue;
      
      final startX = random.nextDouble() * size.width;
      final startY = -20.0;
      final endY = size.height * 0.3 + random.nextDouble() * size.height * 0.4;
      
      final currentY = startY + (endY - startY) * dropProgress;
      
      // Drop with trail
      final dropPaint = Paint()
        ..color = dropColor.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      // Main drop
      canvas.drawCircle(
        Offset(startX, currentY),
        4.0,
        dropPaint,
      );
      
      // Trail
      if (dropProgress > 0.2) {
        final trailPaint = Paint()
          ..color = dropColor.withOpacity(0.4)
          ..style = PaintingStyle.fill;
        
        final trailLength = 20.0 * dropProgress;
        final trailRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(startX, currentY - trailLength / 2),
            width: 2.0,
            height: trailLength,
          ),
          const Radius.circular(1),
        );
        
        canvas.drawRRect(trailRect, trailPaint);
      }
      
      // Splash on impact
      if (dropProgress >= 0.9) {
        final splashPaint = Paint()
          ..color = dropColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(
          Offset(startX, currentY),
          8.0 * (dropProgress - 0.9) / 0.1,
          splashPaint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant _IngredientDropsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Extension methods for easy transition usage
extension TransitionExtensions on Widget {
  /// Navigate with cocktail pour transition
  Future<T?> pushWithPour<T extends Object?>(
    BuildContext context, {
    Color liquidColor = const Color(0xFFB8860B),
  }) {
    return Navigator.of(context).push<T>(
      MixologistTransitions.cocktailPour(
        this,
        liquidColor: liquidColor,
      ),
    );
  }
  
  /// Navigate with shaker shake transition
  Future<T?> pushWithShake<T extends Object?>(
    BuildContext context, {
    bool enableSoundEffects = false,
  }) {
    return Navigator.of(context).push<T>(
      MixologistTransitions.shakerShake(
        this,
        enableSoundEffects: enableSoundEffects,
      ),
    );
  }
  
  /// Navigate with glass clink transition
  Future<T?> pushWithClink<T extends Object?>(BuildContext context) {
    return Navigator.of(context).push<T>(
      MixologistTransitions.glassClink(this),
    );
  }
}