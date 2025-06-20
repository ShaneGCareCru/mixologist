import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../glass/glass_shape.dart';
import 'ambient_animation_controller.dart';

/// DISABLED: Static liquid painter without curve-based swirl effects
/// Previously caused "Invalid curve endpoint at 0" errors
class LiquidSwirlPainter extends CustomPainter {
  const LiquidSwirlPainter({
    required this.glassShape,
    required this.fillLevel,
    required this.animationValue,
    this.primaryColor = const Color(0xFF4CAF50),
    this.intensity = 0.3,
    this.waveCount = 3,
    this.showMeniscus = true,
  });
  
  // Cache for expensive path calculations
  static Path? _cachedBasePath;
  static double? _cachedFillLevel;
  static Size? _cachedSize;

  /// The glass shape containing the liquid
  final GlassShape glassShape;
  
  /// Fill level of the liquid (0.0 to 1.0)
  final double fillLevel;
  
  /// Animation progress (0.0 to 1.0)
  final double animationValue;
  
  /// Primary color of the liquid
  final Color primaryColor;
  
  /// Intensity of the swirl effect (0.0 to 1.0)
  final double intensity;
  
  /// Number of wave patterns
  final int waveCount;
  
  /// Whether to show the meniscus movement
  final bool showMeniscus;

  @override
  void paint(Canvas canvas, Size size) {
    if (fillLevel <= 0) return;

    // DISABLED: Simple static liquid without curves or swirls
    final liquidPath = glassShape.getLiquidPath(size, fillLevel);
    
    // Simple fill without effects
    final liquidPaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(liquidPath, liquidPaint);
  }

  /// Create a path with swirl distortion applied
  Path _createSwirlPath(Size size, Path basePath) {
    final bounds = basePath.getBounds();
    if (bounds.isEmpty) return basePath;
    
    final distortedPath = Path();
    final pathMetrics = basePath.computeMetrics();
    
    for (final metric in pathMetrics) {
      final points = <Offset>[];
      
      // Sample points along the path (reduced sampling for performance)
      for (double t = 0.0; t <= 1.0; t += 0.05) {
        final distance = t * metric.length;
        final tangent = metric.getTangentForOffset(distance);
        
        if (tangent != null) {
          final originalPoint = tangent.position;
          final distortedPoint = _applySwirl(originalPoint, bounds, size);
          points.add(distortedPoint);
        }
      }
      
      // Build smooth path from distorted points
      if (points.isNotEmpty) {
        distortedPath.moveTo(points.first.dx, points.first.dy);
        
        for (int i = 1; i < points.length - 1; i++) {
          final current = points[i];
          final next = points[i + 1];
          final controlPoint = Offset(
            (current.dx + next.dx) / 2,
            (current.dy + next.dy) / 2,
          );
          
          distortedPath.quadraticBezierTo(
            current.dx, current.dy,
            controlPoint.dx, controlPoint.dy,
          );
        }
        
        if (points.length > 1) {
          distortedPath.lineTo(points.last.dx, points.last.dy);
        }
        
        distortedPath.close();
      }
    }
    
    return distortedPath;
  }

  /// Apply swirl distortion to a point
  Offset _applySwirl(Offset point, Rect bounds, Size size) {
    // Convert to normalized coordinates
    final normalizedX = (point.dx - bounds.left) / bounds.width;
    final normalizedY = (point.dy - bounds.top) / bounds.height;
    
    // Calculate swirl parameters
    final centerX = 0.5;
    final centerY = 0.7; // Swirl center slightly below middle
    
    final dx = normalizedX - centerX;
    final dy = normalizedY - centerY;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    // Create swirl effect using sine waves
    final angle = math.atan2(dy, dx);
    final swirl = math.sin(animationValue * 2 * math.pi + angle * waveCount) * 
                  intensity * 
                  math.exp(-distance * 3); // Decay with distance from center
    
    // Apply time-based rotation
    final timeRotation = animationValue * 0.5; // Slow rotation
    final rotatedAngle = angle + timeRotation;
    
    // Calculate distorted position
    final distortedX = centerX + (distance * math.cos(rotatedAngle + swirl));
    final distortedY = centerY + (distance * math.sin(rotatedAngle + swirl));
    
    // Convert back to canvas coordinates
    return Offset(
      bounds.left + distortedX * bounds.width,
      bounds.top + distortedY * bounds.height,
    );
  }

  /// Paint the liquid with swirl effect
  void _paintLiquidWithSwirl(Canvas canvas, Size size, Path swirlPath) {
    // Base liquid color
    final basePaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(swirlPath, basePaint);
    
    // Add swirl highlights
    _paintSwirlHighlights(canvas, size, swirlPath);
    
    // Add subtle gradient overlay
    _paintGradientOverlay(canvas, size, swirlPath);
  }

  /// Paint swirl highlight effects
  void _paintSwirlHighlights(Canvas canvas, Size size, Path liquidPath) {
    final bounds = liquidPath.getBounds();
    if (bounds.isEmpty) return;
    
    // Create highlight streaks that follow the swirl pattern
    for (int i = 0; i < waveCount; i++) {
      final streak = _createSwirlStreak(bounds, i);
      
      final streakPaint = Paint()
        ..color = Colors.white.withOpacity(0.2 * intensity)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      canvas.save();
      canvas.clipPath(liquidPath);
      canvas.drawPath(streak, streakPaint);
      canvas.restore();
    }
  }

  /// Create a swirl streak path
  Path _createSwirlStreak(Rect bounds, int index) {
    final streak = Path();
    final centerX = bounds.center.dx;
    final centerY = bounds.center.dy + bounds.height * 0.2;
    
    final startAngle = (index * 2 * math.pi / waveCount) + (animationValue * 2 * math.pi);
    final radius = bounds.width * 0.3;
    
    final points = <Offset>[];
    
    for (double t = 0; t < 1; t += 0.1) {
      final angle = startAngle + t * math.pi;
      final currentRadius = radius * (1 - t * 0.5);
      
      final x = centerX + currentRadius * math.cos(angle);
      final y = centerY + currentRadius * math.sin(angle) * 0.5; // Flatten vertically
      
      points.add(Offset(x, y));
    }
    
    if (points.isNotEmpty) {
      streak.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        streak.lineTo(points[i].dx, points[i].dy);
      }
    }
    
    return streak;
  }

  /// Paint gradient overlay for depth
  void _paintGradientOverlay(Canvas canvas, Size size, Path liquidPath) {
    final bounds = liquidPath.getBounds();
    
    final gradient = RadialGradient(
      center: const Alignment(0.3, -0.3), // Off-center for more natural look
      radius: 1.2,
      colors: [
        Colors.white.withOpacity(0.1),
        primaryColor.withOpacity(0.05),
        primaryColor.withOpacity(0.2),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(bounds)
      ..blendMode = BlendMode.overlay;
    
    canvas.save();
    canvas.clipPath(liquidPath);
    canvas.drawRect(bounds, paint);
    canvas.restore();
  }

  /// Paint surface distortion effects
  void _paintSurfaceDistortion(Canvas canvas, Size size) {
    final liquidPath = glassShape.getLiquidPath(size, fillLevel);
    final pathMetrics = liquidPath.computeMetrics();
    
    if (pathMetrics.isEmpty) return;
    
    // Find surface points
    final surfacePoints = <Offset>[];
    final metric = pathMetrics.first;
    
    for (double t = 0.1; t <= 0.9; t += 0.1) {
      final distance = t * metric.length;
      final tangent = metric.getTangentForOffset(distance);
      
      if (tangent != null) {
        final point = tangent.position;
        // Only include points near the surface (top of liquid)
        if (point.dy <= size.height * (1 - fillLevel) + 10) {
          surfacePoints.add(point);
        }
      }
    }
    
    // Draw surface ripples
    for (int i = 0; i < surfacePoints.length - 1; i++) {
      final start = surfacePoints[i];
      final end = surfacePoints[i + 1];
      
      // Calculate ripple offset
      final rippleOffset = math.sin(animationValue * 4 * math.pi + i * 0.5) * 
                          intensity * 3;
      
      final ripplePoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2 + rippleOffset,
      );
      
      final ripplePath = Path();
      ripplePath.moveTo(start.dx, start.dy);
      ripplePath.quadraticBezierTo(
        ripplePoint.dx, ripplePoint.dy,
        end.dx, end.dy,
      );
      
      final ripplePaint = Paint()
        ..color = Colors.white.withOpacity(0.3 * intensity)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      canvas.drawPath(ripplePath, ripplePaint);
    }
  }

  /// Paint animated meniscus
  void _paintAnimatedMeniscus(Canvas canvas, Size size) {
    final liquidPath = glassShape.getLiquidPath(size, fillLevel);
    final pathMetrics = liquidPath.computeMetrics();
    
    if (pathMetrics.isEmpty) return;
    
    final metric = pathMetrics.first;
    final meniscusPoints = <Offset>[];
    
    // Sample points along the liquid surface
    for (double t = 0.2; t <= 0.8; t += 0.1) {
      final distance = t * metric.length;
      final tangent = metric.getTangentForOffset(distance);
      
      if (tangent != null) {
        final point = tangent.position;
        
        // Add animation to meniscus curvature
        final waveOffset = math.sin(animationValue * 3 * math.pi + t * 10) * 
                          intensity * 2;
        
        meniscusPoints.add(Offset(point.dx, point.dy + waveOffset));
      }
    }
    
    if (meniscusPoints.length < 2) return;
    
    // Draw smooth meniscus curve
    final meniscusPath = Path();
    meniscusPath.moveTo(meniscusPoints.first.dx, meniscusPoints.first.dy);
    
    for (int i = 1; i < meniscusPoints.length - 1; i++) {
      final current = meniscusPoints[i];
      final next = meniscusPoints[i + 1];
      final controlPoint = Offset(
        (current.dx + next.dx) / 2,
        math.min(current.dy, next.dy) - 1,
      );
      
      meniscusPath.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy,
        next.dx, next.dy,
      );
    }
    
    final meniscusPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(meniscusPath, meniscusPaint);
  }

  @override
  bool shouldRepaint(covariant LiquidSwirlPainter oldDelegate) {
    // Only repaint if there are significant changes to reduce unnecessary repaints
    const animationThreshold = 0.02; // 2% change threshold
    const intensityThreshold = 0.05; // 5% change threshold
    
    return oldDelegate.fillLevel != fillLevel ||
           (oldDelegate.animationValue - animationValue).abs() > animationThreshold ||
           (oldDelegate.intensity - intensity).abs() > intensityThreshold ||
           oldDelegate.primaryColor != primaryColor ||
           oldDelegate.waveCount != waveCount ||
           oldDelegate.showMeniscus != showMeniscus;
  }
}

/// Widget that provides liquid swirl animation
class LiquidSwirlEffect extends StatefulWidget {
  const LiquidSwirlEffect({
    super.key,
    required this.glassShape,
    required this.fillLevel,
    required this.size,
    this.liquidColor = const Color(0xFF4CAF50),
    this.intensity = 0.3,
    this.duration = const Duration(seconds: 8),
    this.enabled = true,
  });

  final GlassShape glassShape;
  final double fillLevel;
  final Size size;
  final Color liquidColor;
  final double intensity;
  final Duration duration;
  final bool enabled;

  @override
  State<LiquidSwirlEffect> createState() => _LiquidSwirlEffectState();
}

class _LiquidSwirlEffectState extends State<LiquidSwirlEffect> {
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || widget.fillLevel <= 0) {
      return SizedBox.fromSize(size: widget.size);
    }

    // DISABLED: Static painter without animation
    return SizedBox.fromSize(
      size: widget.size,
      child: CustomPaint(
        painter: LiquidSwirlPainter(
          glassShape: widget.glassShape,
          fillLevel: widget.fillLevel,
          animationValue: 0.0, // Static value
          primaryColor: widget.liquidColor,
          intensity: 0.0, // No intensity
        ),
        size: widget.size,
      ),
    );
  }
}

/// Preset swirl configurations for different drink types
class LiquidSwirlPresets {
  /// Gentle swirl for spirits
  static const spirits = LiquidSwirlConfig(
    intensity: 0.2,
    duration: Duration(seconds: 10),
    waveCount: 2,
  );
  
  /// Medium swirl for mixed drinks
  static const mixedDrinks = LiquidSwirlConfig(
    intensity: 0.3,
    duration: Duration(seconds: 8),
    waveCount: 3,
  );
  
  /// Active swirl for layered cocktails
  static const layeredCocktails = LiquidSwirlConfig(
    intensity: 0.4,
    duration: Duration(seconds: 6),
    waveCount: 4,
  );
  
  /// Minimal swirl for wine
  static const wine = LiquidSwirlConfig(
    intensity: 0.15,
    duration: Duration(seconds: 12),
    waveCount: 2,
  );
}

/// Configuration for liquid swirl effects
class LiquidSwirlConfig {
  const LiquidSwirlConfig({
    required this.intensity,
    required this.duration,
    required this.waveCount,
  });

  final double intensity;
  final Duration duration;
  final int waveCount;
}