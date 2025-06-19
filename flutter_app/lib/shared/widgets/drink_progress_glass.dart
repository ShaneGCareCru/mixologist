import 'package:flutter/material.dart';
import 'dart:math' as math;

enum DrinkProgress {
  emptyGlass(0),
  ingredientsAdded(1), 
  mixed(2),
  garnished(3),
  complete(4);

  const DrinkProgress(this.level);
  final int level;
}

class DrinkProgressGlass extends StatefulWidget {
  final DrinkProgress progress;
  final List<Color> liquidColors;
  final double height;
  final double width;

  const DrinkProgressGlass({
    super.key,
    required this.progress,
    this.liquidColors = const [Color(0xFF4CAF50), Color(0xFF2196F3)],
    this.height = 120,
    this.width = 60,
  });

  @override
  State<DrinkProgressGlass> createState() => _DrinkProgressGlassState();
}

class _DrinkProgressGlassState extends State<DrinkProgressGlass>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.level / 4.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(DrinkProgressGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _fillAnimation = Tween<double>(
        begin: _fillAnimation.value,
        end: widget.progress.level / 4.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _fillAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _GlassPainter(
              fillLevel: _fillAnimation.value,
              liquidColors: widget.liquidColors,
              progress: widget.progress,
            ),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

class _GlassPainter extends CustomPainter {
  final double fillLevel;
  final List<Color> liquidColors;
  final DrinkProgress progress;

  _GlassPainter({
    required this.fillLevel,
    required this.liquidColors,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final glassPath = Path();
    final glassWidth = size.width * 0.8;
    final glassHeight = size.height * 0.9;
    final centerX = size.width / 2;
    final startY = size.height * 0.1;

    // Draw glass outline (slightly tapered)
    glassPath.moveTo(centerX - glassWidth / 2, startY);
    glassPath.lineTo(centerX - glassWidth / 2 + 5, startY + glassHeight);
    glassPath.lineTo(centerX + glassWidth / 2 - 5, startY + glassHeight);
    glassPath.lineTo(centerX + glassWidth / 2, startY);
    glassPath.close();

    // Draw glass stroke
    final glassPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(glassPath, glassPaint);

    // Draw liquid fill
    if (fillLevel > 0) {
      final liquidHeight = glassHeight * fillLevel;
      final liquidPath = Path();
      
      final bottomY = startY + glassHeight;
      final topY = bottomY - liquidHeight;
      
      // Calculate liquid width at different heights (tapered)
      final bottomWidth = glassWidth - 10;
      final topWidth = glassWidth - (5 * (1 - fillLevel));
      
      liquidPath.moveTo(centerX - bottomWidth / 2, bottomY);
      liquidPath.lineTo(centerX - topWidth / 2, topY);
      liquidPath.lineTo(centerX + topWidth / 2, topY);
      liquidPath.lineTo(centerX + bottomWidth / 2, bottomY);
      liquidPath.close();

      // Choose liquid color based on progress
      Color liquidColor = liquidColors[0];
      if (progress.level >= 2) {
        // Mixed state - blend colors
        liquidColor = Color.lerp(liquidColors[0], liquidColors[1], 0.5)!;
      }
      if (progress.level >= 3) {
        // Garnished state - add some transparency/sparkle effect
        liquidColor = liquidColor.withOpacity(0.9);
      }

      final liquidPaint = Paint()
        ..color = liquidColor
        ..style = PaintingStyle.fill;
      
      canvas.drawPath(liquidPath, liquidPaint);

      // Add surface shine effect
      if (fillLevel > 0.1) {
        final shinePath = Path();
        shinePath.moveTo(centerX - topWidth / 2, topY);
        shinePath.lineTo(centerX + topWidth / 2, topY);
        
        final shinePaint = Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        
        canvas.drawPath(shinePath, shinePaint);
      }
    }

    // Add garnish indicator for completed state
    if (progress == DrinkProgress.garnished || progress == DrinkProgress.complete) {
      final garnishPaint = Paint()
        ..color = Colors.green[400]!
        ..style = PaintingStyle.fill;
      
      // Enhanced lime wheel garnish on rim - proportional to larger glass
      final garnishCenter = Offset(centerX + glassWidth / 3, startY);
      final garnishRadius = 18.0; // Increased from 12.0 to be more proportional
      
      // Draw outer lime wheel (green rim)
      canvas.drawCircle(garnishCenter, garnishRadius, garnishPaint);
      
      // Draw inner lighter green center
      final innerPaint = Paint()
        ..color = Colors.green[200]!
        ..style = PaintingStyle.fill;
      canvas.drawCircle(garnishCenter, garnishRadius * 0.7, innerPaint);
      
      // Draw lime wheel segments (spokes)
      final spokePaint = Paint()
        ..color = Colors.green[600]!
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      
      for (int i = 0; i < 8; i++) {
        final angle = (i * 45) * (3.14159 / 180); // Convert degrees to radians
        final startX = garnishCenter.dx + (garnishRadius * 0.3) * math.cos(angle);
        final startY = garnishCenter.dy + (garnishRadius * 0.3) * math.sin(angle);
        final endX = garnishCenter.dx + (garnishRadius * 0.9) * math.cos(angle);
        final endY = garnishCenter.dy + (garnishRadius * 0.9) * math.sin(angle);
        
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), spokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GlassPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel || 
           oldDelegate.progress != progress;
  }
}