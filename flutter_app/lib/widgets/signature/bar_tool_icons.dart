import 'package:flutter/material.dart';
import 'dart:math';

/// Available bar tools for navigation icons
enum BarTool {
  shaker,
  strainer,
  jigger,
  muddle,
  barSpoon,
  peeler,
  glass,
  bottle,
}

/// Signature bar tool navigation icon with fill animation
/// Active state: tool "fills" with cocktail color
class BarToolIcon extends StatefulWidget {
  final BarTool tool;
  final bool isActive;
  final Color fillColor;
  final Color inactiveColor;
  final double size;
  final Duration animationDuration;
  final VoidCallback? onTap;
  final String? label;
  final bool showLabel;
  final EdgeInsets padding;
  
  const BarToolIcon({
    super.key,
    required this.tool,
    this.isActive = false,
    this.fillColor = const Color(0xFFB8860B), // Amber
    this.inactiveColor = const Color(0xFF87A96B), // Sage
    this.size = 32.0,
    this.animationDuration = const Duration(milliseconds: 400),
    this.onTap,
    this.label,
    this.showLabel = true,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  State<BarToolIcon> createState() => _BarToolIconState();
}

class _BarToolIconState extends State<BarToolIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.bounceOut),
    ));
    
    if (widget.isActive) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(BarToolIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: widget.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value * _bounceAnimation.value,
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CustomPaint(
                      painter: _BarToolPainter(
                        tool: widget.tool,
                        fillProgress: _fillAnimation.value,
                        fillColor: widget.fillColor,
                        inactiveColor: widget.inactiveColor,
                        isActive: widget.isActive,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (widget.showLabel && widget.label != null) ...[
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: widget.animationDuration,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: widget.isActive ? widget.fillColor : widget.inactiveColor,
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                child: Text(
                  widget.label!,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Custom painter for bar tool icons with fill animation
class _BarToolPainter extends CustomPainter {
  final BarTool tool;
  final double fillProgress;
  final Color fillColor;
  final Color inactiveColor;
  final bool isActive;
  
  _BarToolPainter({
    required this.tool,
    required this.fillProgress,
    required this.fillColor,
    required this.inactiveColor,
    required this.isActive,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    switch (tool) {
      case BarTool.shaker:
        _drawShaker(canvas, size, center);
        break;
      case BarTool.strainer:
        _drawStrainer(canvas, size, center);
        break;
      case BarTool.jigger:
        _drawJigger(canvas, size, center);
        break;
      case BarTool.muddle:
        _drawMuddle(canvas, size, center);
        break;
      case BarTool.barSpoon:
        _drawBarSpoon(canvas, size, center);
        break;
      case BarTool.peeler:
        _drawPeeler(canvas, size, center);
        break;
      case BarTool.glass:
        _drawGlass(canvas, size, center);
        break;
      case BarTool.bottle:
        _drawBottle(canvas, size, center);
        break;
    }
  }
  
  void _drawShaker(Canvas canvas, Size size, Offset center) {
    final outlinePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    
    // Shaker body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.6,
        height: size.height * 0.8,
      ),
      const Radius.circular(4),
    );
    
    // Draw outline
    canvas.drawRRect(bodyRect, outlinePaint);
    
    // Draw fill based on progress
    if (fillProgress > 0) {
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + (1 - fillProgress) * size.height * 0.3),
          width: size.width * 0.6 - 4,
          height: size.height * 0.8 * fillProgress,
        ),
        const Radius.circular(2),
      );
      
      canvas.drawRRect(fillRect, fillPaint);
    }
    
    // Shaker cap
    final capRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - size.height * 0.35),
      width: size.width * 0.4,
      height: size.height * 0.15,
    );
    canvas.drawRect(capRect, outlinePaint);
  }
  
  void _drawStrainer(Canvas canvas, Size size, Offset center) {
    final outlinePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    
    // Strainer bowl
    final bowlRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.7,
      height: size.height * 0.5,
    );
    
    canvas.drawOval(bowlRect, outlinePaint);
    
    // Draw fill
    if (fillProgress > 0) {
      final fillRect = Rect.fromCenter(
        center: center,
        width: (size.width * 0.7 - 4) * fillProgress,
        height: (size.height * 0.5 - 4) * fillProgress,
      );
      canvas.drawOval(fillRect, fillPaint);
    }
    
    // Strainer holes
    final holePaint = Paint()
      ..color = isActive ? fillColor : inactiveColor
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 9; i++) {
      final angle = (i / 9) * 2 * pi;
      final holeCenter = Offset(
        center.dx + cos(angle) * size.width * 0.15,
        center.dy + sin(angle) * size.height * 0.12,
      );
      canvas.drawCircle(holeCenter, 1.5, holePaint);
    }
    
    // Handle
    final handlePath = Path();
    handlePath.moveTo(center.dx + size.width * 0.35, center.dy);
    handlePath.lineTo(center.dx + size.width * 0.45, center.dy - size.height * 0.1);
    handlePath.lineTo(center.dx + size.width * 0.45, center.dy + size.height * 0.1);
    canvas.drawPath(handlePath, outlinePaint);
  }
  
  void _drawJigger(Canvas canvas, Size size, Offset center) {
    final outlinePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    
    // Large cup (1 oz)
    final largeCupPath = Path();
    largeCupPath.moveTo(center.dx - size.width * 0.15, center.dy - size.height * 0.1);
    largeCupPath.lineTo(center.dx - size.width * 0.25, center.dy - size.height * 0.4);
    largeCupPath.lineTo(center.dx + size.width * 0.25, center.dy - size.height * 0.4);
    largeCupPath.lineTo(center.dx + size.width * 0.15, center.dy - size.height * 0.1);
    largeCupPath.close();
    
    canvas.drawPath(largeCupPath, outlinePaint);
    
    // Small cup (0.5 oz)
    final smallCupPath = Path();
    smallCupPath.moveTo(center.dx - size.width * 0.1, center.dy + size.height * 0.1);
    smallCupPath.lineTo(center.dx - size.width * 0.15, center.dy + size.height * 0.35);
    smallCupPath.lineTo(center.dx + size.width * 0.15, center.dy + size.height * 0.35);
    smallCupPath.lineTo(center.dx + size.width * 0.1, center.dy + size.height * 0.1);
    smallCupPath.close();
    
    canvas.drawPath(smallCupPath, outlinePaint);
    
    // Connection
    canvas.drawLine(
      Offset(center.dx - size.width * 0.08, center.dy - size.height * 0.1),
      Offset(center.dx + size.width * 0.08, center.dy + size.height * 0.1),
      outlinePaint,
    );
    
    // Fill animation
    if (fillProgress > 0) {
      final fillHeight = fillProgress * size.height * 0.25;
      final fillRect = Rect.fromLTWH(
        center.dx - size.width * 0.22,
        center.dy - size.height * 0.38,
        size.width * 0.44,
        fillHeight,
      );
      canvas.drawRect(fillRect, fillPaint);
    }
  }
  
  void _drawMuddle(Canvas canvas, Size size, Offset center) {
    final outlinePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0 * fillProgress
      ..strokeCap = StrokeCap.round;
    
    // Handle
    canvas.drawLine(
      Offset(center.dx, center.dy - size.height * 0.4),
      Offset(center.dx, center.dy + size.height * 0.2),
      outlinePaint,
    );
    
    // Fill animation for handle
    if (fillProgress > 0) {
      canvas.drawLine(
        Offset(center.dx, center.dy - size.height * 0.4),
        Offset(center.dx, center.dy + size.height * 0.2),
        fillPaint,
      );
    }
    
    // Muddling head
    final headRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + size.height * 0.3),
      width: size.width * 0.3,
      height: size.height * 0.2,
    );
    canvas.drawRect(headRect, outlinePaint);
    
    if (fillProgress > 0) {
      final fillRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.3),
        width: (size.width * 0.3 - 4) * fillProgress,
        height: (size.height * 0.2 - 4) * fillProgress,
      );
      canvas.drawRect(fillRect, Paint()..color = fillColor..style = PaintingStyle.fill);
    }
  }
  
  void _drawBarSpoon(Canvas canvas, Size size, Offset center) {
    final outlinePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 * fillProgress
      ..strokeCap = StrokeCap.round;
    
    // Spoon handle (twisted)
    final handlePath = Path();
    for (double i = 0; i <= 1; i += 0.1) {
      final y = center.dy - size.height * 0.4 + i * size.height * 0.6;
      final x = center.dx + sin(i * pi * 4) * size.width * 0.05;
      if (i == 0) {
        handlePath.moveTo(x, y);
      } else {
        handlePath.lineTo(x, y);
      }
    }
    
    canvas.drawPath(handlePath, outlinePaint);
    
    if (fillProgress > 0) {
      canvas.drawPath(handlePath, fillPaint);
    }
    
    // Spoon bowl
    final bowlRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + size.height * 0.3),
      width: size.width * 0.25,
      height: size.height * 0.4,
    );
    canvas.drawOval(bowlRect, outlinePaint);
    
    if (fillProgress > 0) {
      final fillRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.3),
        width: (size.width * 0.25 - 4) * fillProgress,
        height: (size.height * 0.4 - 4) * fillProgress,
      );
      canvas.drawOval(fillRect, Paint()..color = fillColor..style = PaintingStyle.fill);
    }
  }
  
  void _drawPeeler(Canvas canvas, Size size, Offset center) {
    final outlinePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    
    // Handle
    canvas.drawLine(
      Offset(center.dx, center.dy - size.height * 0.4),
      Offset(center.dx, center.dy + size.height * 0.1),
      outlinePaint,
    );
    
    // Peeler head
    final peelerRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + size.height * 0.25),
      width: size.width * 0.4,
      height: size.height * 0.3,
    );
    canvas.drawRect(peelerRect, outlinePaint);
    
    // Fill animation
    if (fillProgress > 0) {
      final fillRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.25),
        width: (size.width * 0.4 - 4) * fillProgress,
        height: (size.height * 0.3 - 4) * fillProgress,
      );
      canvas.drawRect(fillRect, fillPaint);
    }
    
    // Blade
    canvas.drawLine(
      Offset(center.dx - size.width * 0.15, center.dy + size.height * 0.25),
      Offset(center.dx + size.width * 0.15, center.dy + size.height * 0.25),
      Paint()
        ..color = isActive ? fillColor : inactiveColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }
  
  void _drawGlass(Canvas canvas, Size size, Offset center) {
    final outlinePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    
    // Glass bowl
    final glassPath = Path();
    glassPath.moveTo(center.dx - size.width * 0.3, center.dy + size.height * 0.4);
    glassPath.lineTo(center.dx - size.width * 0.2, center.dy - size.height * 0.3);
    glassPath.lineTo(center.dx + size.width * 0.2, center.dy - size.height * 0.3);
    glassPath.lineTo(center.dx + size.width * 0.3, center.dy + size.height * 0.4);
    glassPath.close();
    
    canvas.drawPath(glassPath, outlinePaint);
    
    // Fill animation
    if (fillProgress > 0) {
      final fillHeight = fillProgress * size.height * 0.6;
      final fillPath = Path();
      fillPath.moveTo(center.dx - size.width * 0.28, center.dy + size.height * 0.38);
      fillPath.lineTo(center.dx - size.width * 0.28 + (1 - fillProgress) * size.width * 0.08, 
                     center.dy + size.height * 0.38 - fillHeight);
      fillPath.lineTo(center.dx + size.width * 0.28 - (1 - fillProgress) * size.width * 0.08, 
                     center.dy + size.height * 0.38 - fillHeight);
      fillPath.lineTo(center.dx + size.width * 0.28, center.dy + size.height * 0.38);
      fillPath.close();
      
      canvas.drawPath(fillPath, fillPaint);
    }
    
    // Glass stem
    canvas.drawLine(
      Offset(center.dx, center.dy + size.height * 0.4),
      Offset(center.dx, center.dy + size.height * 0.45),
      outlinePaint,
    );
  }
  
  void _drawBottle(Canvas canvas, Size size, Offset center) {
    final outlinePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    
    // Bottle body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.1),
        width: size.width * 0.5,
        height: size.height * 0.6,
      ),
      const Radius.circular(8),
    );
    
    canvas.drawRRect(bodyRect, outlinePaint);
    
    // Fill animation
    if (fillProgress > 0) {
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + size.height * 0.1 + (1 - fillProgress) * size.height * 0.2),
          width: size.width * 0.5 - 4,
          height: size.height * 0.6 * fillProgress,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(fillRect, fillPaint);
    }
    
    // Bottle neck
    final neckRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - size.height * 0.25),
      width: size.width * 0.2,
      height: size.height * 0.3,
    );
    canvas.drawRect(neckRect, outlinePaint);
    
    // Bottle cap
    final capRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - size.height * 0.42),
      width: size.width * 0.25,
      height: size.height * 0.1,
    );
    canvas.drawRect(capRect, outlinePaint);
  }
  
  @override
  bool shouldRepaint(covariant _BarToolPainter oldDelegate) {
    return oldDelegate.fillProgress != fillProgress ||
           oldDelegate.isActive != isActive ||
           oldDelegate.tool != tool;
  }
}

/// Navigation bar with bar tool icons
class BarToolNavigation extends StatefulWidget {
  final List<BarToolTab> tabs;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final double iconSize;
  final EdgeInsets padding;
  
  const BarToolNavigation({
    super.key,
    required this.tabs,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.iconSize = 28.0,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
  });

  @override
  State<BarToolNavigation> createState() => _BarToolNavigationState();
}

class _BarToolNavigationState extends State<BarToolNavigation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widget.tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isActive = index == widget.currentIndex;
            
            return Expanded(
              child: BarToolIcon(
                tool: tab.tool,
                isActive: isActive,
                fillColor: tab.activeColor ?? const Color(0xFFB8860B),
                inactiveColor: tab.inactiveColor ?? const Color(0xFF87A96B),
                size: widget.iconSize,
                label: tab.label,
                showLabel: tab.showLabel,
                onTap: () => widget.onTap?.call(index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Data model for bar tool navigation tabs
class BarToolTab {
  final BarTool tool;
  final String label;
  final bool showLabel;
  final Color? activeColor;
  final Color? inactiveColor;
  
  const BarToolTab({
    required this.tool,
    required this.label,
    this.showLabel = true,
    this.activeColor,
    this.inactiveColor,
  });
}

/// Extension methods for easy bar tool icon usage
extension BarToolExtensions on BarTool {
  /// Get the display name for this bar tool
  String get displayName {
    switch (this) {
      case BarTool.shaker:
        return 'Shaker';
      case BarTool.strainer:
        return 'Strainer';
      case BarTool.jigger:
        return 'Jigger';
      case BarTool.muddle:
        return 'Muddle';
      case BarTool.barSpoon:
        return 'Bar Spoon';
      case BarTool.peeler:
        return 'Peeler';
      case BarTool.glass:
        return 'Glass';
      case BarTool.bottle:
        return 'Bottle';
    }
  }
  
  /// Get the appropriate icon for this bar tool
  IconData get iconData {
    switch (this) {
      case BarTool.shaker:
        return Icons.sports_bar;
      case BarTool.strainer:
        return Icons.filter_alt;
      case BarTool.jigger:
        return Icons.straighten;
      case BarTool.muddle:
        return Icons.construction;
      case BarTool.barSpoon:
        return Icons.restaurant;
      case BarTool.peeler:
        return Icons.cut;
      case BarTool.glass:
        return Icons.wine_bar;
      case BarTool.bottle:
        return Icons.local_bar;
    }
  }
}