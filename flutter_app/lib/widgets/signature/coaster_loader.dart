import 'package:flutter/material.dart';
import 'dart:math';

/// Animated coaster loading state with brand mark and condensation
/// While loading, shows animated coaster with brand mark and condensation drops
class CoasterLoader extends StatefulWidget {
  final String? brandLogo;
  final Duration animationDuration;
  final double size;
  final Color coasterColor;
  final Color brandColor;
  final bool showCondensation;
  final bool showShimmer;
  final String? loadingText;
  final TextStyle? textStyle;
  final EdgeInsets padding;
  
  const CoasterLoader({
    super.key,
    this.brandLogo,
    this.animationDuration = const Duration(seconds: 2),
    this.size = 120.0,
    this.coasterColor = const Color(0xFFB8860B), // Amber
    this.brandColor = const Color(0xFFF5F5DC), // Cream
    this.showCondensation = true,
    this.showShimmer = true,
    this.loadingText,
    this.textStyle,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  State<CoasterLoader> createState() => _CoasterLoaderState();
}

class _CoasterLoaderState extends State<CoasterLoader>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _condensationController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _condensationAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _condensationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _condensationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _condensationController,
      curve: Curves.easeInOut,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _rotationController.repeat();
    if (widget.showCondensation) {
      _condensationController.repeat();
    }
    if (widget.showShimmer) {
      _shimmerController.repeat();
    }
    _pulseController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _condensationController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([
              _rotationAnimation,
              _condensationAnimation,
              _shimmerAnimation,
              _pulseAnimation,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CustomPaint(
                    painter: _CoasterPainter(
                      rotationProgress: _rotationAnimation.value,
                      condensationProgress: _condensationAnimation.value,
                      shimmerProgress: _shimmerAnimation.value,
                      coasterColor: widget.coasterColor,
                      brandColor: widget.brandColor,
                      showCondensation: widget.showCondensation,
                      showShimmer: widget.showShimmer,
                      brandLogo: widget.brandLogo,
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.loadingText != null) ...[
            const SizedBox(height: 16),
            DefaultTextStyle(
              style: widget.textStyle ??
                  Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: widget.coasterColor,
                    fontWeight: FontWeight.w500,
                  ),
              child: Text(
                widget.loadingText!,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom painter for the animated coaster
class _CoasterPainter extends CustomPainter {
  final double rotationProgress;
  final double condensationProgress;
  final double shimmerProgress;
  final Color coasterColor;
  final Color brandColor;
  final bool showCondensation;
  final bool showShimmer;
  final String? brandLogo;
  
  _CoasterPainter({
    required this.rotationProgress,
    required this.condensationProgress,
    required this.shimmerProgress,
    required this.coasterColor,
    required this.brandColor,
    required this.showCondensation,
    required this.showShimmer,
    this.brandLogo,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw coaster base
    _drawCoasterBase(canvas, center, radius);
    
    // Draw texture pattern
    _drawTexture(canvas, center, radius);
    
    // Draw shimmer effect
    if (showShimmer) {
      _drawShimmer(canvas, size, center, radius);
    }
    
    // Draw brand mark
    _drawBrandMark(canvas, center, radius);
    
    // Draw condensation droplets
    if (showCondensation) {
      _drawCondensation(canvas, center, radius);
    }
    
    // Draw rim highlight
    _drawRimHighlight(canvas, center, radius);
  }
  
  void _drawCoasterBase(Canvas canvas, Offset center, double radius) {
    // Coaster shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawCircle(
      Offset(center.dx + 2, center.dy + 2),
      radius * 0.95,
      shadowPaint,
    );
    
    // Main coaster body
    final coasterPaint = Paint()
      ..color = coasterColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.9, coasterPaint);
    
    // Coaster rim
    final rimPaint = Paint()
      ..color = coasterColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    canvas.drawCircle(center, radius * 0.9, rimPaint);
  }
  
  void _drawTexture(Canvas canvas, Offset center, double radius) {
    // Draw subtle texture lines in a radial pattern
    final texturePaint = Paint()
      ..color = brandColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationProgress * 2 * pi);
    
    for (int i = 0; i < 24; i++) {
      final angle = (i / 24) * 2 * pi;
      final startRadius = radius * 0.3;
      final endRadius = radius * 0.85;
      
      final start = Offset(
        cos(angle) * startRadius,
        sin(angle) * startRadius,
      );
      final end = Offset(
        cos(angle) * endRadius,
        sin(angle) * endRadius,
      );
      
      canvas.drawLine(start, end, texturePaint);
    }
    
    canvas.restore();
  }
  
  void _drawShimmer(Canvas canvas, Size size, Offset center, double radius) {
    final shimmerRect = Rect.fromCircle(center: center, radius: radius * 0.9);
    
    final shimmerGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.transparent,
        brandColor.withOpacity(0.3),
        Colors.transparent,
      ],
      stops: [
        (shimmerProgress - 0.3).clamp(0.0, 1.0),
        shimmerProgress.clamp(0.0, 1.0),
        (shimmerProgress + 0.3).clamp(0.0, 1.0),
      ],
    );
    
    final shimmerPaint = Paint()
      ..shader = shimmerGradient.createShader(shimmerRect)
      ..blendMode = BlendMode.overlay;
    
    canvas.drawCircle(center, radius * 0.9, shimmerPaint);
  }
  
  void _drawBrandMark(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationProgress * 2 * pi);
    
    if (brandLogo != null && brandLogo!.isNotEmpty) {
      // Draw text logo
      final textPainter = TextPainter(
        text: TextSpan(
          text: brandLogo,
          style: TextStyle(
            color: brandColor,
            fontSize: radius * 0.3,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
    } else {
      // Draw default cocktail icon
      _drawDefaultIcon(canvas, Offset.zero, radius);
    }
    
    canvas.restore();
  }
  
  void _drawDefaultIcon(Canvas canvas, Offset center, double radius) {
    final iconPaint = Paint()
      ..color = brandColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw martini glass outline
    final glassPath = Path();
    
    // Glass bowl (triangle)
    glassPath.moveTo(-radius * 0.25, -radius * 0.1);
    glassPath.lineTo(radius * 0.25, -radius * 0.1);
    glassPath.lineTo(0, radius * 0.2);
    glassPath.close();
    
    // Glass stem
    glassPath.moveTo(0, radius * 0.2);
    glassPath.lineTo(0, radius * 0.35);
    
    // Glass base
    glassPath.moveTo(-radius * 0.15, radius * 0.35);
    glassPath.lineTo(radius * 0.15, radius * 0.35);
    
    canvas.drawPath(glassPath, iconPaint);
    
    // Olive or cherry
    final garnishPaint = Paint()
      ..color = brandColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(0, radius * 0.05), 3, garnishPaint);
  }
  
  void _drawCondensation(Canvas canvas, Offset center, double radius) {
    final dropletPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final random = Random(42); // Fixed seed for consistent pattern
    
    // Animate droplets around the rim
    for (int i = 0; i < 12; i++) {
      final baseAngle = (i / 12) * 2 * pi;
      final animatedAngle = baseAngle + (condensationProgress * pi / 6);
      
      // Droplets at varying distances from rim
      for (int j = 0; j < 3; j++) {
        final dropletRadius = radius * (0.92 + j * 0.05);
        final variance = random.nextDouble() * 0.1 - 0.05;
        final actualRadius = dropletRadius + variance * radius;
        
        final x = center.dx + cos(animatedAngle) * actualRadius;
        final y = center.dy + sin(animatedAngle) * actualRadius;
        
        final dropletSize = random.nextDouble() * 1.5 + 0.5;
        final opacity = (sin(condensationProgress * pi * 2 + i + j) * 0.3 + 0.4).clamp(0.0, 0.7);
        
        canvas.drawCircle(
          Offset(x, y),
          dropletSize,
          Paint()
            ..color = Colors.white.withOpacity(opacity)
            ..style = PaintingStyle.fill,
        );
      }
    }
    
    // Larger droplets that occasionally form and drop
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi;
      final dropProgress = (condensationProgress * 3 + i) % 1.0;
      
      if (dropProgress > 0.7) {
        final dropRadius = radius * 0.88;
        final dropY = center.dy + sin(angle) * dropRadius + (dropProgress - 0.7) * 20;
        final dropX = center.dx + cos(angle) * dropRadius;
        
        final dropSize = 2.0 + (1.0 - dropProgress) * 2.0;
        final dropOpacity = (1.0 - dropProgress) * 0.8;
        
        canvas.drawCircle(
          Offset(dropX, dropY),
          dropSize,
          Paint()
            ..color = Colors.white.withOpacity(dropOpacity)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }
  
  void _drawRimHighlight(Canvas canvas, Offset center, double radius) {
    // Subtle highlight around the rim
    final highlightPaint = Paint()
      ..color = brandColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawCircle(center, radius * 0.92, highlightPaint);
    
    // Inner shadow effect
    final shadowPaint = Paint()
      ..color = coasterColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawCircle(center, radius * 0.88, shadowPaint);
  }
  
  @override
  bool shouldRepaint(covariant _CoasterPainter oldDelegate) {
    return oldDelegate.rotationProgress != rotationProgress ||
           oldDelegate.condensationProgress != condensationProgress ||
           oldDelegate.shimmerProgress != shimmerProgress;
  }
}

/// Preset coaster styles for different brands/themes
enum CoasterStyle {
  classic,
  modern,
  vintage,
  elegant,
}

/// Factory class for creating themed coaster loaders
class CoasterThemes {
  static CoasterLoader classic({
    String? brandLogo,
    String? loadingText,
    double size = 120.0,
  }) {
    return CoasterLoader(
      brandLogo: brandLogo,
      loadingText: loadingText ?? 'Preparing cocktail...',
      size: size,
      coasterColor: const Color(0xFFB8860B), // Amber
      brandColor: const Color(0xFFF5F5DC), // Cream
      showCondensation: true,
      showShimmer: true,
    );
  }
  
  static CoasterLoader modern({
    String? brandLogo,
    String? loadingText,
    double size = 120.0,
  }) {
    return CoasterLoader(
      brandLogo: brandLogo,
      loadingText: loadingText ?? 'Loading...',
      size: size,
      coasterColor: const Color(0xFF87A96B), // Sage
      brandColor: Colors.white,
      showCondensation: false,
      showShimmer: true,
      animationDuration: const Duration(milliseconds: 1500),
    );
  }
  
  static CoasterLoader vintage({
    String? brandLogo,
    String? loadingText,
    double size = 120.0,
  }) {
    return CoasterLoader(
      brandLogo: brandLogo,
      loadingText: loadingText ?? 'Crafting recipe...',
      size: size,
      coasterColor: const Color(0xFF8B4513), // Saddle Brown
      brandColor: const Color(0xFFDEB887), // Burlywood
      showCondensation: true,
      showShimmer: false,
      animationDuration: const Duration(milliseconds: 2500),
    );
  }
  
  static CoasterLoader elegant({
    String? brandLogo,
    String? loadingText,
    double size = 120.0,
  }) {
    return CoasterLoader(
      brandLogo: brandLogo,
      loadingText: loadingText ?? 'Mixing...',
      size: size,
      coasterColor: const Color(0xFF36454F), // Charcoal
      brandColor: const Color(0xFFB8860B), // Amber
      showCondensation: true,
      showShimmer: true,
      animationDuration: const Duration(milliseconds: 3000),
    );
  }
}

/// Extension methods for easy coaster loader usage
extension CoasterLoaderExtensions on Widget {
  /// Wrap widget with coaster loader overlay
  Widget withCoasterLoader({
    bool isLoading = false,
    String? brandLogo,
    String? loadingText,
    CoasterStyle style = CoasterStyle.classic,
  }) {
    if (!isLoading) return this;
    
    CoasterLoader loader;
    switch (style) {
      case CoasterStyle.classic:
        loader = CoasterThemes.classic(brandLogo: brandLogo, loadingText: loadingText);
        break;
      case CoasterStyle.modern:
        loader = CoasterThemes.modern(brandLogo: brandLogo, loadingText: loadingText);
        break;
      case CoasterStyle.vintage:
        loader = CoasterThemes.vintage(brandLogo: brandLogo, loadingText: loadingText);
        break;
      case CoasterStyle.elegant:
        loader = CoasterThemes.elegant(brandLogo: brandLogo, loadingText: loadingText);
        break;
    }
    
    return Stack(
      children: [
        this,
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(child: loader),
          ),
        ),
      ],
    );
  }
}