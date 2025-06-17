import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'glass_shape.dart';

/// Types of rim decorations
enum RimType {
  none,
  salt,
  sugar,
  coloredSalt, // Colored salt (e.g., black salt, pink salt)
  customSpice, // Custom spice rim (e.g., chili, cinnamon)
}

/// Widget for displaying animated rim decorations on glasses
class RimDecoration extends StatefulWidget {
  const RimDecoration({
    super.key,
    required this.glassShape,
    required this.rimType,
    required this.progress,
    this.size = const Size(120, 120),
    this.rimThickness = 8.0,
    this.customColor,
    this.sparkleIntensity = 0.7,
  });

  /// The glass shape to decorate
  final GlassShape glassShape;
  
  /// Type of rim decoration
  final RimType rimType;
  
  /// Animation progress (0.0 to 1.0)
  final double progress;
  
  /// Size of the glass widget
  final Size size;
  
  /// Thickness of the rim decoration
  final double rimThickness;
  
  /// Custom color for colored salt or spice rims
  final Color? customColor;
  
  /// Intensity of sparkle effect for sugar (0.0 to 1.0)
  final double sparkleIntensity;

  @override
  State<RimDecoration> createState() => _RimDecorationState();
}

class _RimDecorationState extends State<RimDecoration>
    with TickerProviderStateMixin {
  late AnimationController _appearController;
  late AnimationController _sparkleController;
  late Animation<double> _appearAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    
    _appearController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _appearAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _appearController,
      curve: Curves.easeOutBack,
    ));
    
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
    
    // Start sparkle animation for sugar
    if (widget.rimType == RimType.sugar) {
      _sparkleController.repeat();
    }
  }

  @override
  void didUpdateWidget(RimDecoration oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.progress != widget.progress) {
      _appearController.animateTo(widget.progress);
    }
    
    // Handle sparkle animation
    if (widget.rimType == RimType.sugar && oldWidget.rimType != RimType.sugar) {
      _sparkleController.repeat();
    } else if (widget.rimType != RimType.sugar && oldWidget.rimType == RimType.sugar) {
      _sparkleController.stop();
    }
  }

  @override
  void dispose() {
    _appearController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rimType == RimType.none || widget.progress <= 0) {
      return SizedBox.fromSize(size: widget.size);
    }

    return SizedBox.fromSize(
      size: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_appearAnimation, _sparkleAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: _RimPainter(
              glassShape: widget.glassShape,
              rimType: widget.rimType,
              progress: _appearAnimation.value,
              rimThickness: widget.rimThickness,
              customColor: widget.customColor,
              sparklePhase: _sparkleAnimation.value,
              sparkleIntensity: widget.sparkleIntensity,
            ),
            size: widget.size,
          );
        },
      ),
    );
  }
}

/// Custom painter for rim decorations
class _RimPainter extends CustomPainter {
  const _RimPainter({
    required this.glassShape,
    required this.rimType,
    required this.progress,
    required this.rimThickness,
    this.customColor,
    required this.sparklePhase,
    required this.sparkleIntensity,
  });

  final GlassShape glassShape;
  final RimType rimType;
  final double progress;
  final double rimThickness;
  final Color? customColor;
  final double sparklePhase;
  final double sparkleIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final rimPath = glassShape.getRimPath(size, rimThickness);
    
    switch (rimType) {
      case RimType.none:
        return;
      case RimType.salt:
        _paintSaltRim(canvas, size, rimPath);
        break;
      case RimType.sugar:
        _paintSugarRim(canvas, size, rimPath);
        break;
      case RimType.coloredSalt:
        _paintColoredSaltRim(canvas, size, rimPath);
        break;
      case RimType.customSpice:
        _paintCustomSpiceRim(canvas, size, rimPath);
        break;
    }
  }

  /// Paint salt rim texture
  void _paintSaltRim(Canvas canvas, Size size, Path rimPath) {
    final paint = Paint()
      ..color = const Color(0xFFF5F5F5).withOpacity(progress * 0.9)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(rimPath, paint);
    
    // Add salt crystal texture
    _paintSaltCrystals(canvas, size, rimPath, const Color(0xFFE0E0E0));
  }

  /// Paint sugar rim with sparkle effect
  void _paintSugarRim(Canvas canvas, Size size, Path rimPath) {
    final basePaint = Paint()
      ..color = const Color(0xFFFAFAFA).withOpacity(progress * 0.95)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(rimPath, basePaint);
    
    // Add sugar crystal texture
    _paintSugarCrystals(canvas, size, rimPath);
    
    // Add sparkle effect
    if (sparkleIntensity > 0 && progress > 0.5) {
      _paintSparkles(canvas, size, rimPath);
    }
  }

  /// Paint colored salt rim
  void _paintColoredSaltRim(Canvas canvas, Size size, Path rimPath) {
    final color = customColor ?? const Color(0xFF4A4A4A);
    final paint = Paint()
      ..color = color.withOpacity(progress * 0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(rimPath, paint);
    
    // Add salt crystal texture with custom color
    _paintSaltCrystals(canvas, size, rimPath, color.withOpacity(0.6));
  }

  /// Paint custom spice rim
  void _paintCustomSpiceRim(Canvas canvas, Size size, Path rimPath) {
    final color = customColor ?? const Color(0xFF8B4513);
    final paint = Paint()
      ..color = color.withOpacity(progress * 0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(rimPath, paint);
    
    // Add spice texture (coarser than salt)
    _paintSpiceTexture(canvas, size, rimPath, color);
  }

  /// Paint salt crystal texture
  void _paintSaltCrystals(Canvas canvas, Size size, Path rimPath, Color crystalColor) {
    final random = math.Random(42); // Fixed seed for consistent pattern
    final paint = Paint()
      ..color = crystalColor
      ..style = PaintingStyle.fill;
    
    // Create clip path for rim area
    canvas.save();
    canvas.clipPath(rimPath);
    
    // Generate salt crystals
    final bounds = rimPath.getBounds();
    final crystalCount = (bounds.width * bounds.height * 0.01 * progress).round();
    
    for (int i = 0; i < crystalCount; i++) {
      final x = bounds.left + random.nextDouble() * bounds.width;
      final y = bounds.top + random.nextDouble() * bounds.height;
      final size = random.nextDouble() * 2 + 0.5;
      
      // Draw small rectangular crystals
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: size,
          height: size * 0.8,
        ),
        paint,
      );
    }
    
    canvas.restore();
  }

  /// Paint sugar crystal texture
  void _paintSugarCrystals(Canvas canvas, Size size, Path rimPath) {
    final random = math.Random(24); // Fixed seed for consistent pattern
    final lightPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = const Color(0xFFE8E8E8).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    canvas.save();
    canvas.clipPath(rimPath);
    
    final bounds = rimPath.getBounds();
    final crystalCount = (bounds.width * bounds.height * 0.008 * progress).round();
    
    for (int i = 0; i < crystalCount; i++) {
      final x = bounds.left + random.nextDouble() * bounds.width;
      final y = bounds.top + random.nextDouble() * bounds.height;
      final size = random.nextDouble() * 3 + 1;
      
      // Draw shadow first
      canvas.drawCircle(
        Offset(x + 0.5, y + 0.5),
        size * 0.8,
        shadowPaint,
      );
      
      // Draw crystal
      canvas.drawCircle(
        Offset(x, y),
        size,
        lightPaint,
      );
    }
    
    canvas.restore();
  }

  /// Paint sparkle effect for sugar
  void _paintSparkles(Canvas canvas, Size size, Path rimPath) {
    final random = math.Random(123); // Fixed seed
    final paint = Paint()
      ..color = Colors.white.withOpacity(sparkleIntensity * 0.9)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.save();
    canvas.clipPath(rimPath);
    
    final bounds = rimPath.getBounds();
    final sparkleCount = (bounds.width * bounds.height * 0.003 * sparkleIntensity).round();
    
    for (int i = 0; i < sparkleCount; i++) {
      final x = bounds.left + random.nextDouble() * bounds.width;
      final y = bounds.top + random.nextDouble() * bounds.height;
      
      // Create animated sparkle
      final phase = (sparklePhase + (i / sparkleCount)) % 1.0;
      final opacity = (math.sin(phase * math.pi * 2) + 1) / 2;
      
      if (opacity > 0.3) {
        paint.color = Colors.white.withOpacity(opacity * sparkleIntensity);
        
        // Draw 4-pointed star
        final sparkleSize = 3.0 + (opacity * 2);
        _drawSparkle(canvas, Offset(x, y), sparkleSize, paint);
      }
    }
    
    canvas.restore();
  }

  /// Paint spice texture (coarser than salt)
  void _paintSpiceTexture(Canvas canvas, Size size, Path rimPath, Color spiceColor) {
    final random = math.Random(78); // Fixed seed
    final paint = Paint()
      ..color = spiceColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.save();
    canvas.clipPath(rimPath);
    
    final bounds = rimPath.getBounds();
    final particleCount = (bounds.width * bounds.height * 0.005 * progress).round();
    
    for (int i = 0; i < particleCount; i++) {
      final x = bounds.left + random.nextDouble() * bounds.width;
      final y = bounds.top + random.nextDouble() * bounds.height;
      final size = random.nextDouble() * 4 + 1;
      
      // Draw irregular spice particles
      final particlePath = Path();
      particlePath.addOval(Rect.fromCenter(
        center: Offset(x, y),
        width: size,
        height: size * (0.5 + random.nextDouble() * 0.5),
      ));
      
      canvas.drawPath(particlePath, paint);
    }
    
    canvas.restore();
  }

  /// Draw a 4-pointed sparkle
  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // Horizontal line
    path.moveTo(center.dx - size, center.dy);
    path.lineTo(center.dx + size, center.dy);
    
    // Vertical line
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx, center.dy + size);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RimPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.sparklePhase != sparklePhase ||
           oldDelegate.rimType != rimType;
  }
}

/// Helper extension for rim decorations
extension RimDecorationHelpers on RimType {
  /// Get the default color for this rim type
  Color get defaultColor {
    switch (this) {
      case RimType.none:
        return Colors.transparent;
      case RimType.salt:
        return const Color(0xFFF5F5F5);
      case RimType.sugar:
        return const Color(0xFFFAFAFA);
      case RimType.coloredSalt:
        return const Color(0xFF4A4A4A); // Default to black salt
      case RimType.customSpice:
        return const Color(0xFF8B4513); // Default to cinnamon color
    }
  }

  /// Whether this rim type should have sparkle effects
  bool get hasSparkles => this == RimType.sugar;

  /// Get animation duration for appearance
  Duration get animationDuration {
    switch (this) {
      case RimType.none:
        return Duration.zero;
      case RimType.salt:
      case RimType.coloredSalt:
        return const Duration(milliseconds: 600);
      case RimType.sugar:
        return const Duration(milliseconds: 800);
      case RimType.customSpice:
        return const Duration(milliseconds: 700);
    }
  }
}