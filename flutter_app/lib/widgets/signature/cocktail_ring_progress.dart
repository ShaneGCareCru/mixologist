import 'package:flutter/material.dart';
import 'dart:math';

/// Rim types for the cocktail ring progress indicator
enum RimType {
  salt,
  sugar,
  none,
  cinnamon,
  tajin,
}

/// Signature cocktail ring progress indicator that looks like a glass rim
/// view from above with optional salt/sugar rim highlighting
class CocktailRingProgress extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final bool hasRim;
  final RimType rimType;
  final double size;
  final Color cocktailColor;
  final Color rimColor;
  final double strokeWidth;
  final bool animated;
  final Duration animationDuration;
  final Widget? centerIcon;
  final String? centerText;
  final bool showDroplets;
  final VoidCallback? onComplete;
  
  const CocktailRingProgress({
    super.key,
    required this.progress,
    this.hasRim = true,
    this.rimType = RimType.salt,
    this.size = 120.0,
    this.cocktailColor = const Color(0xFFB8860B), // Amber
    this.rimColor = const Color(0xFFF5F5DC), // Cream
    this.strokeWidth = 8.0,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.centerIcon,
    this.centerText,
    this.showDroplets = true,
    this.onComplete,
  });

  @override
  State<CocktailRingProgress> createState() => _CocktailRingProgressState();
}

class _CocktailRingProgressState extends State<CocktailRingProgress>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _dropletsController;
  
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _dropletsAnimation;
  
  bool _hasTriggeredComplete = false;
  
  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _dropletsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // DISABLED: Static animations to prevent curve endpoint errors
    _progressAnimation = Tween<double>(
      begin: widget.progress,
      end: widget.progress, // Static progress value
    ).animate(_progressController);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0, // No pulsing
    ).animate(_pulseController);
    
    _dropletsAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0, // No droplets animation
    ).animate(_dropletsController);
    
    // DISABLED: No animations to prevent curve errors
    _progressController.value = 1.0;
    
    // DISABLED: No droplets animation
    // No animation listeners to prevent curve usage
  }
  
  @override
  void didUpdateWidget(CocktailRingProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.progress != widget.progress) {
      // DISABLED: Static progress update without curve animation
      _progressAnimation = Tween<double>(
        begin: widget.progress,
        end: widget.progress, // Static value
      ).animate(_progressController);
      
      _progressController.value = 1.0; // Set to complete immediately
    }
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _dropletsController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _progressAnimation,
        _pulseAnimation,
        _dropletsAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _CocktailRingPainter(
                progress: _progressAnimation.value,
                hasRim: widget.hasRim,
                rimType: widget.rimType,
                cocktailColor: widget.cocktailColor,
                rimColor: widget.rimColor,
                strokeWidth: widget.strokeWidth,
                dropletsProgress: _dropletsAnimation.value,
                showDroplets: widget.showDroplets,
              ),
              child: _buildCenter(),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCenter() {
    return Center(
      child: widget.centerIcon ??
          (widget.centerText != null
              ? Text(
                  widget.centerText!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: widget.cocktailColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )
              : Icon(
                  Icons.local_bar,
                  color: widget.cocktailColor,
                  size: widget.size * 0.3,
                )),
    );
  }
}

/// Custom painter for the cocktail ring progress indicator
class _CocktailRingPainter extends CustomPainter {
  final double progress;
  final bool hasRim;
  final RimType rimType;
  final Color cocktailColor;
  final Color rimColor;
  final double strokeWidth;
  final double dropletsProgress;
  final bool showDroplets;
  
  _CocktailRingPainter({
    required this.progress,
    required this.hasRim,
    required this.rimType,
    required this.cocktailColor,
    required this.rimColor,
    required this.strokeWidth,
    required this.dropletsProgress,
    required this.showDroplets,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Draw background ring (glass rim)
    _drawBackgroundRing(canvas, center, radius);
    
    // Draw rim texture if enabled
    if (hasRim && rimType != RimType.none) {
      _drawRimTexture(canvas, center, radius);
    }
    
    // Draw progress arc (liquid)
    _drawProgressArc(canvas, center, radius);
    
    // Draw condensation droplets
    if (showDroplets) {
      _drawCondensationDroplets(canvas, center, radius);
    }
    
    // Draw rim highlights for garnish steps
    if (hasRim && progress > 0.8) {
      _drawRimHighlights(canvas, center, radius);
    }
  }
  
  void _drawBackgroundRing(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, paint);
  }
  
  void _drawRimTexture(Canvas canvas, Offset center, double radius) {
    final rimPaint = Paint()
      ..color = rimColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.2;
    
    // Create textured rim effect
    final textureRadius = radius + strokeWidth * 0.1;
    
    switch (rimType) {
      case RimType.salt:
        _drawSaltTexture(canvas, center, textureRadius, rimPaint);
        break;
      case RimType.sugar:
        _drawSugarTexture(canvas, center, textureRadius, rimPaint);
        break;
      case RimType.cinnamon:
        _drawCinnamonTexture(canvas, center, textureRadius, rimPaint);
        break;
      case RimType.tajin:
        _drawTajinTexture(canvas, center, textureRadius, rimPaint);
        break;
      case RimType.none:
        break;
    }
  }
  
  void _drawSaltTexture(Canvas canvas, Offset center, double radius, Paint paint) {
    // Draw small irregular dots for salt crystals
    final random = Random(42); // Fixed seed for consistent pattern
    
    for (int i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * pi;
      final variance = random.nextDouble() * 0.8 + 0.6;
      final dotRadius = radius * variance;
      
      final x = center.dx + cos(angle) * dotRadius;
      final y = center.dy + sin(angle) * dotRadius;
      
      final dotSize = random.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(
        Offset(x, y),
        dotSize,
        Paint()
          ..color = rimColor.withOpacity(0.8)
          ..style = PaintingStyle.fill,
      );
    }
  }
  
  void _drawSugarTexture(Canvas canvas, Offset center, double radius, Paint paint) {
    // Draw crystalline sugar texture
    final random = Random(43);
    
    for (int i = 0; i < 50; i++) {
      final angle = (i / 50) * 2 * pi;
      final variance = random.nextDouble() * 0.6 + 0.7;
      final dotRadius = radius * variance;
      
      final x = center.dx + cos(angle) * dotRadius;
      final y = center.dy + sin(angle) * dotRadius;
      
      // Draw small squares for sugar crystals
      final rect = Rect.fromCenter(
        center: Offset(x, y),
        width: random.nextDouble() * 2 + 1,
        height: random.nextDouble() * 2 + 1,
      );
      
      canvas.drawRect(
        rect,
        Paint()
          ..color = rimColor.withOpacity(0.9)
          ..style = PaintingStyle.fill,
      );
    }
  }
  
  void _drawCinnamonTexture(Canvas canvas, Offset center, double radius, Paint paint) {
    // Draw cinnamon spice texture with warm brown color
    final random = Random(44);
    final cinnamonColor = const Color(0xFFD2691E);
    
    for (int i = 0; i < 40; i++) {
      final angle = (i / 40) * 2 * pi;
      final variance = random.nextDouble() * 0.7 + 0.65;
      final dotRadius = radius * variance;
      
      final x = center.dx + cos(angle) * dotRadius;
      final y = center.dy + sin(angle) * dotRadius;
      
      canvas.drawCircle(
        Offset(x, y),
        random.nextDouble() * 1.2 + 0.8,
        Paint()
          ..color = cinnamonColor.withOpacity(0.7)
          ..style = PaintingStyle.fill,
      );
    }
  }
  
  void _drawTajinTexture(Canvas canvas, Offset center, double radius, Paint paint) {
    // Draw Tajín texture with orange/red spice color
    final random = Random(45);
    final tajinColor = const Color(0xFFFF4500);
    
    for (int i = 0; i < 45; i++) {
      final angle = (i / 45) * 2 * pi;
      final variance = random.nextDouble() * 0.8 + 0.6;
      final dotRadius = radius * variance;
      
      final x = center.dx + cos(angle) * dotRadius;
      final y = center.dy + sin(angle) * dotRadius;
      
      // Irregular spice granules
      final path = Path();
      final size = random.nextDouble() * 1.5 + 0.5;
      path.addOval(Rect.fromCircle(center: Offset(x, y), radius: size));
      
      canvas.drawPath(
        path,
        Paint()
          ..color = tajinColor.withOpacity(0.8)
          ..style = PaintingStyle.fill,
      );
    }
  }
  
  void _drawProgressArc(Canvas canvas, Offset center, double radius) {
    if (progress <= 0) return;
    
    final progressPaint = Paint()
      ..color = cocktailColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Add gradient effect to the progress
    final rect = Rect.fromCircle(center: center, radius: radius);
    progressPaint.shader = SweepGradient(
      startAngle: -pi / 2,
      endAngle: -pi / 2 + (2 * pi * progress),
      colors: [
        cocktailColor.withOpacity(0.8),
        cocktailColor,
        cocktailColor.withOpacity(0.9),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);
    
    final startAngle = -pi / 2; // Start from top
    final sweepAngle = 2 * pi * progress;
    
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }
  
  void _drawCondensationDroplets(Canvas canvas, Offset center, double radius) {
    final random = Random(46);
    final dropletPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    // Animate droplets around the rim
    for (int i = 0; i < 8; i++) {
      final baseAngle = (i / 8) * 2 * pi;
      final animatedAngle = baseAngle + (dropletsProgress * pi / 4);
      
      final dropletRadius = radius + strokeWidth * 1.5;
      final x = center.dx + cos(animatedAngle) * dropletRadius;
      final y = center.dy + sin(animatedAngle) * dropletRadius;
      
      final dropletSize = random.nextDouble() * 1.5 + 1.0;
      final opacity = sin(dropletsProgress * pi + i) * 0.3 + 0.3;
      
      canvas.drawCircle(
        Offset(x, y),
        dropletSize,
        Paint()
          ..color = Colors.white.withOpacity(opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }
  
  void _drawRimHighlights(Canvas canvas, Offset center, double radius) {
    // Highlight rim sections for garnish steps
    final highlightPaint = Paint()
      ..color = cocktailColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.5;
    
    final highlightRadius = radius + strokeWidth * 0.8;
    
    // Draw 4 highlight sections around the rim
    for (int i = 0; i < 4; i++) {
      final startAngle = (i * pi / 2) - (pi / 8);
      final sweepAngle = pi / 4;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: highlightRadius),
        startAngle,
        sweepAngle,
        false,
        highlightPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _CocktailRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.dropletsProgress != dropletsProgress ||
        oldDelegate.hasRim != hasRim ||
        oldDelegate.rimType != rimType;
  }
}

/// Extension methods for easy cocktail ring progress usage
extension CocktailRingProgressExtensions on Widget {
  /// Wrap widget with cocktail ring progress overlay
  Widget withCocktailProgress({
    required double progress,
    bool hasRim = true,
    RimType rimType = RimType.salt,
    Color? cocktailColor,
    VoidCallback? onComplete,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        this,
        CocktailRingProgress(
          progress: progress,
          hasRim: hasRim,
          rimType: rimType,
          cocktailColor: cocktailColor ?? const Color(0xFFB8860B),
          onComplete: onComplete,
        ),
      ],
    );
  }
}