import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'glass_shape.dart';

/// Types of garnish animations
enum GarnishType {
  none,
  limeWheel,
  lemonWheel,
  orangeWheel,
  cherry,
  mintSprig,
  olives,
  cocktailUmbrella,
  celeryStalk,
  pickledOnion,
}

/// Widget for displaying animated garnishes on glasses
class GarnishAnimator extends StatefulWidget {
  const GarnishAnimator({
    super.key,
    required this.glassShape,
    required this.garnishType,
    required this.progress,
    this.size = const Size(120, 120),
    this.customColor,
  });

  /// The glass shape to add garnish to
  final GlassShape glassShape;
  
  /// Type of garnish to animate
  final GarnishType garnishType;
  
  /// Animation progress (0.0 to 1.0)
  final double progress;
  
  /// Size of the glass widget
  final Size size;
  
  /// Custom color for garnish (overrides default)
  final Color? customColor;

  @override
  State<GarnishAnimator> createState() => _GarnishAnimatorState();
}

class _GarnishAnimatorState extends State<GarnishAnimator>
    with TickerProviderStateMixin {
  late AnimationController _dropController;
  late AnimationController _settleController;
  late AnimationController _floatController;
  
  late Animation<double> _dropAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _settleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    
    _dropController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _settleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _dropAnimation = Tween<double>(
      begin: -0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dropController,
      curve: Curves.bounceOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: math.pi * 2 * 3, // 3 full rotations during drop
    ).animate(CurvedAnimation(
      parent: _dropController,
      curve: Curves.easeOut,
    ));
    
    _settleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _settleController,
      curve: Curves.elasticOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(GarnishAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.progress != widget.progress && widget.progress > 0) {
      _startGarnishAnimation();
    }
    
    if (widget.progress == 0) {
      _resetAnimations();
    }
  }

  void _startGarnishAnimation() {
    _dropController.forward().then((_) {
      _settleController.forward().then((_) {
        if (widget.garnishType.hasFloatEffect) {
          _floatController.repeat(reverse: true);
        }
      });
    });
  }

  void _resetAnimations() {
    _dropController.reset();
    _settleController.reset();
    _floatController.reset();
  }

  @override
  void dispose() {
    _dropController.dispose();
    _settleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.garnishType == GarnishType.none || widget.progress <= 0) {
      return SizedBox.fromSize(size: widget.size);
    }

    return SizedBox.fromSize(
      size: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _dropAnimation,
          _rotationAnimation,
          _settleAnimation,
          _floatAnimation,
        ]),
        builder: (context, child) {
          return CustomPaint(
            painter: _GarnishPainter(
              glassShape: widget.glassShape,
              garnishType: widget.garnishType,
              dropProgress: _dropAnimation.value,
              rotation: _rotationAnimation.value,
              settleProgress: _settleAnimation.value,
              floatProgress: _floatAnimation.value,
              customColor: widget.customColor,
            ),
            size: widget.size,
          );
        },
      ),
    );
  }
}

/// Custom painter for garnish animations
class _GarnishPainter extends CustomPainter {
  const _GarnishPainter({
    required this.glassShape,
    required this.garnishType,
    required this.dropProgress,
    required this.rotation,
    required this.settleProgress,
    required this.floatProgress,
    this.customColor,
  });

  final GlassShape glassShape;
  final GarnishType garnishType;
  final double dropProgress;
  final double rotation;
  final double settleProgress;
  final double floatProgress;
  final Color? customColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (dropProgress < 0) return;

    final garnishPosition = glassShape.getGarnishPosition(size);
    final animatedPosition = _calculateAnimatedPosition(garnishPosition, size);
    
    canvas.save();
    canvas.translate(animatedPosition.dx, animatedPosition.dy);
    
    if (garnishType.shouldRotate) {
      canvas.rotate(rotation * settleProgress);
    }
    
    _paintGarnish(canvas, size);
    
    canvas.restore();
  }

  /// Calculate the animated position based on drop and settle progress
  Offset _calculateAnimatedPosition(Offset finalPosition, Size size) {
    if (dropProgress <= 0) {
      return Offset(finalPosition.dx, -size.height * 0.2);
    }
    
    // Drop animation: start above glass, drop to position
    final dropY = finalPosition.dy * dropProgress - (size.height * 0.2 * (1 - dropProgress));
    
    // Add settle bounce
    final settleOffset = math.sin(settleProgress * math.pi) * 5 * (1 - settleProgress);
    
    // Add float effect for certain garnishes
    final floatOffset = garnishType.hasFloatEffect 
        ? math.sin(floatProgress * math.pi * 2) * 2 
        : 0.0;
    
    return Offset(
      finalPosition.dx,
      dropY - settleOffset + floatOffset,
    );
  }

  /// Paint the specific garnish type
  void _paintGarnish(Canvas canvas, Size size) {
    switch (garnishType) {
      case GarnishType.none:
        return;
      case GarnishType.limeWheel:
        _paintCitrusWheel(canvas, const Color(0xFF32CD32), const Color(0xFF228B22));
        break;
      case GarnishType.lemonWheel:
        _paintCitrusWheel(canvas, const Color(0xFFFFFF00), const Color(0xFFDAA520));
        break;
      case GarnishType.orangeWheel:
        _paintCitrusWheel(canvas, const Color(0xFFFFA500), const Color(0xFFFF8C00));
        break;
      case GarnishType.cherry:
        _paintCherry(canvas);
        break;
      case GarnishType.mintSprig:
        _paintMintSprig(canvas);
        break;
      case GarnishType.olives:
        _paintOlives(canvas);
        break;
      case GarnishType.cocktailUmbrella:
        _paintCocktailUmbrella(canvas);
        break;
      case GarnishType.celeryStalk:
        _paintCeleryStalk(canvas);
        break;
      case GarnishType.pickledOnion:
        _paintPickledOnion(canvas);
        break;
    }
  }

  /// Paint citrus wheel (lime, lemon, orange)
  void _paintCitrusWheel(Canvas canvas, Color primaryColor, Color secondaryColor) {
    final radius = 12.0;
    final center = Offset.zero;
    
    // Outer peel
    final peelPaint = Paint()
      ..color = (customColor ?? primaryColor).withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, peelPaint);
    
    // Inner segments
    final segmentPaint = Paint()
      ..color = (customColor ?? secondaryColor).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final segmentPath = Path();
      segmentPath.moveTo(center.dx, center.dy);
      segmentPath.arcTo(
        Rect.fromCircle(center: center, radius: radius * 0.8),
        angle,
        math.pi / 4,
        false,
      );
      segmentPath.close();
      
      if (i % 2 == 0) {
        canvas.drawPath(segmentPath, segmentPaint);
      }
    }
    
    // Center dot
    canvas.drawCircle(center, 2, Paint()..color = Colors.white.withOpacity(0.8));
    
    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx - 4, center.dy - 4),
      3,
      highlightPaint,
    );
  }

  /// Paint cherry
  void _paintCherry(Canvas canvas) {
    final cherryColor = customColor ?? const Color(0xFFDC143C);
    
    // Cherry body
    final cherryPaint = Paint()
      ..color = cherryColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, 8, cherryPaint);
    
    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(-3, -3), 2.5, highlightPaint);
    
    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF228B22)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      const Offset(0, -8),
      const Offset(-2, -15),
      stemPaint,
    );
  }

  /// Paint mint sprig
  void _paintMintSprig(Canvas canvas) {
    final mintGreen = customColor ?? const Color(0xFF90EE90);
    final leafPaint = Paint()
      ..color = mintGreen
      ..style = PaintingStyle.fill;
    
    // Main stem
    final stemPaint = Paint()
      ..color = const Color(0xFF228B22)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      const Offset(0, 0),
      const Offset(0, -20),
      stemPaint,
    );
    
    // Leaves
    final leaves = [
      Offset(-8, -5),
      Offset(8, -8),
      Offset(-6, -12),
      Offset(7, -15),
    ];
    
    for (final leafPos in leaves) {
      final leafPath = Path();
      leafPath.addOval(Rect.fromCenter(
        center: leafPos,
        width: 8,
        height: 12,
      ));
      canvas.drawPath(leafPath, leafPaint);
      
      // Leaf veins
      final veinPaint = Paint()
        ..color = const Color(0xFF228B22)
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(
        Offset(leafPos.dx, leafPos.dy - 4),
        Offset(leafPos.dx, leafPos.dy + 4),
        veinPaint,
      );
    }
    
    // Add flutter effect with floatProgress
    if (floatProgress > 0) {
      final flutter = math.sin(floatProgress * math.pi * 4) * 2;
      canvas.translate(flutter, 0);
    }
  }

  /// Paint olives (usually 2-3 olives on a pick)
  void _paintOlives(Canvas canvas) {
    final oliveColor = customColor ?? const Color(0xFF6B8E23);
    final olivePaint = Paint()
      ..color = oliveColor
      ..style = PaintingStyle.fill;
    
    // Toothpick
    final pickPaint = Paint()
      ..color = const Color(0xFFDEB887)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      const Offset(0, -15),
      const Offset(0, 15),
      pickPaint,
    );
    
    // Olives
    final olivePositions = [
      const Offset(0, -8),
      const Offset(0, 0),
      const Offset(0, 8),
    ];
    
    for (final pos in olivePositions) {
      // Olive body
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 8, height: 12),
        olivePaint,
      );
      
      // Pimento (red center)
      canvas.drawCircle(
        pos,
        2,
        Paint()..color = const Color(0xFFDC143C),
      );
    }
  }

  /// Paint cocktail umbrella
  void _paintCocktailUmbrella(Canvas canvas) {
    final umbrellaColor = customColor ?? const Color(0xFFFF69B4);
    
    // Handle
    final handlePaint = Paint()
      ..color = const Color(0xFFDEB887)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      const Offset(0, 0),
      const Offset(5, 15),
      handlePaint,
    );
    
    // Umbrella canopy
    final canopyPaint = Paint()
      ..color = umbrellaColor
      ..style = PaintingStyle.fill;
    
    final canopyPath = Path();
    canopyPath.moveTo(-12, -5);
    
    // Scalloped edge
    for (int i = 0; i < 6; i++) {
      final x = -12 + (i * 4);
      canopyPath.quadraticBezierTo(x + 2, -8, x + 4, -5);
    }
    
    canopyPath.lineTo(0, 0);
    canopyPath.close();
    
    canvas.drawPath(canopyPath, canopyPaint);
    
    // Umbrella ribs
    final ribPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 7; i++) {
      final angle = (i * math.pi) / 6 - math.pi / 2;
      final endX = math.cos(angle) * 12;
      final endY = math.sin(angle) * 12 - 5;
      
      canvas.drawLine(
        const Offset(0, 0),
        Offset(endX, endY),
        ribPaint,
      );
    }
  }

  /// Paint celery stalk
  void _paintCeleryStalk(Canvas canvas) {
    final celeryColor = customColor ?? const Color(0xFF9ACD32);
    
    // Main stalk
    final stalkPaint = Paint()
      ..color = celeryColor
      ..style = PaintingStyle.fill;
    
    final stalkPath = Path();
    stalkPath.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(-3, -20, 6, 25),
      const Radius.circular(3),
    ));
    
    canvas.drawPath(stalkPath, stalkPaint);
    
    // Celery ridges
    final ridgePaint = Paint()
      ..color = const Color(0xFF7CFC00)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 5; i++) {
      final y = -18 + (i * 4);
      canvas.drawLine(
        Offset(-2, y.toDouble()),
        Offset(2, y.toDouble()),
        ridgePaint,
      );
    }
    
    // Leaves at top
    final leafPaint = Paint()
      ..color = const Color(0xFF228B22)
      ..style = PaintingStyle.fill;
    
    final leaves = [
      const Offset(-4, -22),
      const Offset(0, -25),
      const Offset(4, -22),
    ];
    
    for (final leafPos in leaves) {
      canvas.drawOval(
        Rect.fromCenter(center: leafPos, width: 4, height: 6),
        leafPaint,
      );
    }
  }

  /// Paint pickled onion
  void _paintPickledOnion(Canvas canvas) {
    final onionColor = customColor ?? const Color(0xFFF5F5DC);
    
    // Onion body
    final onionPaint = Paint()
      ..color = onionColor
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 12, height: 10),
      onionPaint,
    );
    
    // Onion layers
    final layerPaint = Paint()
      ..color = const Color(0xFFE6E6FA).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 8, height: 6),
      layerPaint,
    );
    
    // Toothpick
    final pickPaint = Paint()
      ..color = const Color(0xFFDEB887)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      const Offset(0, -8),
      const Offset(0, -15),
      pickPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GarnishPainter oldDelegate) {
    return oldDelegate.dropProgress != dropProgress ||
           oldDelegate.rotation != rotation ||
           oldDelegate.settleProgress != settleProgress ||
           oldDelegate.floatProgress != floatProgress ||
           oldDelegate.garnishType != garnishType;
  }
}

/// Extension for garnish type properties
extension GarnishTypeProperties on GarnishType {
  /// Whether this garnish should rotate during drop animation
  bool get shouldRotate {
    switch (this) {
      case GarnishType.limeWheel:
      case GarnishType.lemonWheel:
      case GarnishType.orangeWheel:
      case GarnishType.cherry:
        return true;
      default:
        return false;
    }
  }

  /// Whether this garnish should have a floating effect
  bool get hasFloatEffect {
    switch (this) {
      case GarnishType.mintSprig:
      case GarnishType.cocktailUmbrella:
      case GarnishType.celeryStalk:
        return true;
      default:
        return false;
    }
  }

  /// Default color for this garnish type
  Color get defaultColor {
    switch (this) {
      case GarnishType.none:
        return Colors.transparent;
      case GarnishType.limeWheel:
        return const Color(0xFF32CD32);
      case GarnishType.lemonWheel:
        return const Color(0xFFFFFF00);
      case GarnishType.orangeWheel:
        return const Color(0xFFFFA500);
      case GarnishType.cherry:
        return const Color(0xFFDC143C);
      case GarnishType.mintSprig:
        return const Color(0xFF90EE90);
      case GarnishType.olives:
        return const Color(0xFF6B8E23);
      case GarnishType.cocktailUmbrella:
        return const Color(0xFFFF69B4);
      case GarnishType.celeryStalk:
        return const Color(0xFF9ACD32);
      case GarnishType.pickledOnion:
        return const Color(0xFFF5F5DC);
    }
  }
}