import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/debug_logger.dart';

enum DrinkProgress {
  emptyGlass(0),
  ingredientsAdded(1), 
  mixed(2),
  garnished(3),
  complete(4);

  const DrinkProgress(this.level);
  final int level;
}

class DrinkProgressGlass extends StatelessWidget {
  final DrinkProgress progress;
  final double fillPercentage; // 0.0 to 1.0 based on step completion
  final List<Color> liquidColors;
  final double height;
  final double width;
  final bool showIce;

  const DrinkProgressGlass({
    super.key,
    required this.progress,
    this.fillPercentage = 0.0,
    this.liquidColors = const [Color(0xFF4CAF50), Color(0xFF2196F3)],
    this.height = 120,
    this.width = 60,
    this.showIce = true,
  });

  @override
  Widget build(BuildContext context) {
    final logger = DebugLogger.instance;
    
    // Log every build with current state
    logger.logGuiState(
      'DrinkProgressGlass',
      'Build Triggered',
      details: {
        'fillPercentage': fillPercentage,
        'progress': progress.toString(),
        'progressLevel': progress.level,
        'liquidColors': liquidColors.map((c) => c.value.toRadixString(16)).toList(),
        'dimensions': '${width}x${height}',
        'showIce': showIce,
      }
    );

    // Log if there's a significant state change
    if (fillPercentage > 0) {
      logger.logAnimation(
        'GlassFill',
        'Rendering',
        target: 'DrinkProgressGlass',
        value: fillPercentage,
        details: {
          'progress': progress.toString(),
          'showIce': showIce,
        }
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _GlassPainter(
          fillLevel: fillPercentage,
          liquidColors: liquidColors,
          progress: progress,
          showIce: showIce,
        ),
        size: Size(width, height),
      ),
    );
  }
}

class _GlassPainter extends CustomPainter {
  final double fillLevel;
  final List<Color> liquidColors;
  final DrinkProgress progress;
  final bool showIce;

  _GlassPainter({
    required this.fillLevel,
    required this.liquidColors,
    required this.progress,
    required this.showIce,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final logger = DebugLogger.instance;
    
    // Log paint method execution
    logger.logAnimation(
      'GlassPainter',
      'Paint Method Called',
      target: 'CustomPaint',
      value: fillLevel,
      details: {
        'canvasSize': '${size.width}x${size.height}',
        'fillLevel': fillLevel,
        'progress': progress.toString(),
        'showIce': showIce,
        'liquidColors': liquidColors.length,
      }
    );

    final glassWidth = size.width * 0.8;
    final glassHeight = size.height * 0.9;
    final centerX = size.width / 2;
    final startY = size.height * 0.1;

    // Draw glass outline (simple rectangle)
    final glassRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX - glassWidth / 2, 
        startY, 
        glassWidth, 
        glassHeight
      ),
      const Radius.circular(4),
    );

    // Draw glass stroke
    final glassPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(glassRect, glassPaint);

    // Draw ice cubes first (so liquid appears above them)
    if (showIce) {
      _drawIceCubes(canvas, size, centerX, startY, glassWidth, glassHeight);
    }

    // Draw simple liquid fill based on fillPercentage
    if (fillLevel > 0) {
      final liquidHeight = glassHeight * fillLevel;
      
      final liquidRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - glassWidth / 2 + 2, 
          startY + glassHeight - liquidHeight, 
          glassWidth - 4, 
          liquidHeight
        ),
        const Radius.circular(2),
      );

      // Simple color progression
      Color liquidColor = liquidColors[0]; // Green for early stages
      if (progress.level >= 2) {
        liquidColor = liquidColors[1]; // Blue for mixed
      }

      final liquidPaint = Paint()
        ..color = liquidColor.withOpacity(0.8) // Slightly transparent to show ice
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(liquidRect, liquidPaint);
    }

    // Simple lime wheel for garnished/complete states
    if (progress == DrinkProgress.garnished || progress == DrinkProgress.complete) {
      final garnishCenter = Offset(centerX + glassWidth / 3, startY);
      final garnishRadius = 18.0;
      
      // Simple lime wheel - just green circle with segments
      final garnishPaint = Paint()
        ..color = Colors.green[400]!
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(garnishCenter, garnishRadius, garnishPaint);
      
      // Inner circle
      final innerPaint = Paint()
        ..color = Colors.green[200]!
        ..style = PaintingStyle.fill;
      canvas.drawCircle(garnishCenter, garnishRadius * 0.7, innerPaint);
      
      // Simple spokes
      final spokePaint = Paint()
        ..color = Colors.green[600]!
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      
      for (int i = 0; i < 6; i++) {
        final angle = (i * 60) * (3.14159 / 180);
        final startX = garnishCenter.dx + (garnishRadius * 0.3) * math.cos(angle);
        final startY = garnishCenter.dy + (garnishRadius * 0.3) * math.sin(angle);
        final endX = garnishCenter.dx + (garnishRadius * 0.9) * math.cos(angle);
        final endY = garnishCenter.dy + (garnishRadius * 0.9) * math.sin(angle);
        
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), spokePaint);
      }
    }
  }

  void _drawIceCubes(Canvas canvas, Size size, double centerX, double startY, double glassWidth, double glassHeight) {
    final bottomY = startY + glassHeight;
    
    // Draw multiple ice cubes with varied sizes and positions for realism
    _drawRealisticIceCube(canvas, centerX - 15, bottomY - 14, 12, 10, 0.1); // Left cube
    _drawRealisticIceCube(canvas, centerX + 8, bottomY - 12, 10, 11, -0.05); // Right cube  
    _drawRealisticIceCube(canvas, centerX - 2, bottomY - 22, 11, 9, 0.08); // Center cube (higher)
    _drawRealisticIceCube(canvas, centerX - 20, bottomY - 8, 8, 8, -0.03); // Small left
    _drawRealisticIceCube(canvas, centerX + 12, bottomY - 6, 7, 9, 0.06); // Small right
  }
  
  void _drawRealisticIceCube(Canvas canvas, double x, double y, double width, double height, double tilt) {
    canvas.save();
    
    // Apply slight tilt for natural randomness
    canvas.translate(x + width/2, y + height/2);
    canvas.rotate(tilt);
    canvas.translate(-width/2, -height/2);
    
    // Main ice body - translucent white/blue
    final icePath = Path();
    icePath.moveTo(0, 2); // Slightly irregular top
    icePath.lineTo(width - 1, 0);
    icePath.lineTo(width, height - 1);
    icePath.lineTo(1, height);
    icePath.close();
    
    final iceGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFF0F8FF).withOpacity(0.9), // Very light blue
        const Color(0xFFE6F3FF).withOpacity(0.8), // Light blue
        const Color(0xFFCCE7FF).withOpacity(0.7), // Slightly darker
      ],
    );
    
    final icePaint = Paint()
      ..shader = iceGradient.createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(icePath, icePaint);
    
    // Ice highlights (light reflections)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Top-left highlight
    canvas.drawLine(
      Offset(1, 2), 
      Offset(width * 0.6, 1), 
      highlightPaint
    );
    
    // Vertical highlight
    canvas.drawLine(
      Offset(2, 1), 
      Offset(1.5, height * 0.4), 
      highlightPaint
    );
    
    // Ice shadows/depth
    final shadowPaint = Paint()
      ..color = const Color(0xFFB8D4F0).withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Bottom-right shadow
    canvas.drawLine(
      Offset(width * 0.3, height - 1), 
      Offset(width - 1, height - 1), 
      shadowPaint
    );
    
    // Right edge shadow
    canvas.drawLine(
      Offset(width - 1, height * 0.6), 
      Offset(width - 1, height - 1), 
      shadowPaint
    );
    
    // Subtle internal crack/texture
    final crackPaint = Paint()
      ..color = const Color(0xFFDDE9F7).withOpacity(0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(width * 0.2, height * 0.3), 
      Offset(width * 0.7, height * 0.8), 
      crackPaint
    );
    
    // Outer edge (subtle border)
    final borderPaint = Paint()
      ..color = const Color(0xFFB8D4F0).withOpacity(0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    canvas.drawPath(icePath, borderPaint);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GlassPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.fillLevel != fillLevel;
  }
}