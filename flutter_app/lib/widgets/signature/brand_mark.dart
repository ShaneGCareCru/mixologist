import 'package:flutter/material.dart';
import 'dart:math';

/// Brand mark styles for different contexts
enum BrandStyle {
  full,        // Full logo with text
  icon,        // Icon only
  minimal,     // Simplified version
  watermark,   // Subtle background mark
  monogram,    // Initials only
}

/// Context-aware brand mark that adapts to different usage scenarios
class BrandMark extends StatefulWidget {
  final BrandStyle style;
  final Size size;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool adaptive;
  final bool animated;
  final Duration animationDuration;
  final VoidCallback? onTap;
  final String? customText;
  final bool darkMode;
  final EdgeInsets padding;
  
  const BrandMark({
    super.key,
    this.style = BrandStyle.full,
    this.size = const Size(120, 40),
    this.primaryColor,
    this.secondaryColor,
    this.adaptive = true,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 600),
    this.onTap,
    this.customText,
    this.darkMode = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<BrandMark> createState() => _BrandMarkState();
}

class _BrandMarkState extends State<BrandMark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ));
    
    if (widget.animated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Color get _primaryColor {
    if (widget.primaryColor != null) return widget.primaryColor!;
    
    if (widget.adaptive) {
      return widget.darkMode 
          ? const Color(0xFFB8860B) // Amber for dark mode
          : const Color(0xFF87A96B); // Sage for light mode
    }
    
    return const Color(0xFFB8860B); // Default amber
  }
  
  Color get _secondaryColor {
    if (widget.secondaryColor != null) return widget.secondaryColor!;
    
    if (widget.adaptive) {
      return widget.darkMode 
          ? const Color(0xFFF5F5DC) // Cream for dark mode
          : const Color(0xFF36454F); // Charcoal for light mode
    }
    
    return const Color(0xFFF5F5DC); // Default cream
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = widget.darkMode || 
                  (widget.adaptive && Theme.of(context).brightness == Brightness.dark);
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: widget.padding,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: SizedBox(
                    width: widget.size.width,
                    height: widget.size.height,
                    child: CustomPaint(
                      painter: _BrandMarkPainter(
                        style: widget.style,
                        primaryColor: _primaryColor,
                        secondaryColor: _secondaryColor,
                        customText: widget.customText,
                        isDarkMode: isDark,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for the brand mark
class _BrandMarkPainter extends CustomPainter {
  final BrandStyle style;
  final Color primaryColor;
  final Color secondaryColor;
  final String? customText;
  final bool isDarkMode;
  
  _BrandMarkPainter({
    required this.style,
    required this.primaryColor,
    required this.secondaryColor,
    this.customText,
    required this.isDarkMode,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case BrandStyle.full:
        _drawFullLogo(canvas, size);
        break;
      case BrandStyle.icon:
        _drawIconOnly(canvas, size);
        break;
      case BrandStyle.minimal:
        _drawMinimal(canvas, size);
        break;
      case BrandStyle.watermark:
        _drawWatermark(canvas, size);
        break;
      case BrandStyle.monogram:
        _drawMonogram(canvas, size);
        break;
    }
  }
  
  void _drawFullLogo(Canvas canvas, Size size) {
    final iconSize = size.height * 0.8;
    final iconRect = Rect.fromLTWH(
      8, 
      (size.height - iconSize) / 2, 
      iconSize, 
      iconSize,
    );
    
    // Draw cocktail icon
    _drawCocktailIcon(canvas, iconRect);
    
    // Draw brand text
    final textPainter = TextPainter(
      text: TextSpan(
        text: customText ?? 'MIXOLOGIST',
        style: TextStyle(
          color: primaryColor,
          fontSize: size.height * 0.35,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontFamily: 'Roboto', // Modern, readable font
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        iconSize + 16,
        (size.height - textPainter.height) / 2,
      ),
    );
  }
  
  void _drawIconOnly(Canvas canvas, Size size) {
    final iconRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.8,
    );
    
    _drawCocktailIcon(canvas, iconRect);
  }
  
  void _drawMinimal(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.8;
    
    // Simple circular mark with cocktail symbol
    final circlePaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawCircle(center, radius, circlePaint);
    
    // Simple cocktail glass in center
    final glassPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final glassPath = Path();
    glassPath.moveTo(center.dx - radius * 0.4, center.dy - radius * 0.2);
    glassPath.lineTo(center.dx + radius * 0.4, center.dy - radius * 0.2);
    glassPath.lineTo(center.dx, center.dy + radius * 0.3);
    glassPath.close();
    
    canvas.drawPath(glassPath, glassPaint);
    
    // Glass stem
    canvas.drawLine(
      Offset(center.dx, center.dy + radius * 0.3),
      Offset(center.dx, center.dy + radius * 0.5),
      glassPaint,
    );
  }
  
  void _drawWatermark(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final iconSize = min(size.width, size.height) * 0.6;
    
    final watermarkPaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    // Large, subtle cocktail outline
    final glassPath = Path();
    glassPath.moveTo(center.dx - iconSize * 0.3, center.dy - iconSize * 0.2);
    glassPath.lineTo(center.dx + iconSize * 0.3, center.dy - iconSize * 0.2);
    glassPath.lineTo(center.dx, center.dy + iconSize * 0.3);
    glassPath.close();
    
    canvas.drawPath(glassPath, watermarkPaint);
    
    // Stem
    final stemRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + iconSize * 0.4),
      width: iconSize * 0.05,
      height: iconSize * 0.2,
    );
    canvas.drawRect(stemRect, watermarkPaint);
  }
  
  void _drawMonogram(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Background circle
    final bgPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, min(size.width, size.height) / 2 * 0.9, bgPaint);
    
    // Monogram letters
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'M',
        style: TextStyle(
          color: secondaryColor,
          fontSize: size.height * 0.6,
          fontWeight: FontWeight.bold,
          fontFamily: 'Serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }
  
  void _drawCocktailIcon(Canvas canvas, Rect rect) {
    final center = rect.center;
    final iconPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final fillPaint = Paint()
      ..color = primaryColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    // Martini glass bowl
    final glassPath = Path();
    glassPath.moveTo(center.dx - rect.width * 0.25, center.dy - rect.height * 0.1);
    glassPath.lineTo(center.dx + rect.width * 0.25, center.dy - rect.height * 0.1);
    glassPath.lineTo(center.dx, center.dy + rect.height * 0.2);
    glassPath.close();
    
    canvas.drawPath(glassPath, fillPaint);
    canvas.drawPath(glassPath, iconPaint);
    
    // Glass stem
    canvas.drawLine(
      Offset(center.dx, center.dy + rect.height * 0.2),
      Offset(center.dx, center.dy + rect.height * 0.35),
      iconPaint,
    );
    
    // Glass base
    canvas.drawLine(
      Offset(center.dx - rect.width * 0.12, center.dy + rect.height * 0.35),
      Offset(center.dx + rect.width * 0.12, center.dy + rect.height * 0.35),
      iconPaint,
    );
    
    // Olive/garnish
    final garnishPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx, center.dy + rect.height * 0.05),
      3,
      garnishPaint,
    );
    
    // Cocktail liquid surface (animated ripple effect)
    final liquidPaint = Paint()
      ..color = primaryColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final liquidY = center.dy - rect.height * 0.05;
    canvas.drawLine(
      Offset(center.dx - rect.width * 0.15, liquidY),
      Offset(center.dx + rect.width * 0.15, liquidY),
      liquidPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant _BrandMarkPainter oldDelegate) {
    return oldDelegate.style != style ||
           oldDelegate.primaryColor != primaryColor ||
           oldDelegate.secondaryColor != secondaryColor ||
           oldDelegate.isDarkMode != isDarkMode;
  }
}

/// Animated brand reveal widget
class BrandReveal extends StatefulWidget {
  final Widget child;
  final Duration revealDuration;
  final Curve revealCurve;
  final BrandStyle brandStyle;
  final Size brandSize;
  
  const BrandReveal({
    super.key,
    required this.child,
    this.revealDuration = const Duration(milliseconds: 1500),
    this.revealCurve = Curves.easeOutCubic,
    this.brandStyle = BrandStyle.icon,
    this.brandSize = const Size(80, 80),
  });

  @override
  State<BrandReveal> createState() => _BrandRevealState();
}

class _BrandRevealState extends State<BrandReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _brandScale;
  late Animation<double> _brandFade;
  late Animation<double> _contentFade;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.revealDuration,
      vsync: this,
    );
    
    _brandScale = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _brandFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));
    
    _contentFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    ));
    
    _startReveal();
  }
  
  void _startReveal() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _controller.forward();
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
        return Stack(
          children: [
            // Main content
            Opacity(
              opacity: _contentFade.value,
              child: widget.child,
            ),
            
            // Brand overlay
            if (_brandFade.value > 0)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.95),
                  child: Center(
                    child: Transform.scale(
                      scale: _brandScale.value,
                      child: Opacity(
                        opacity: _brandFade.value,
                        child: BrandMark(
                          style: widget.brandStyle,
                          size: widget.brandSize,
                          animated: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Context-aware brand placement
class BrandContext {
  /// Get appropriate brand style for app bar
  static BrandStyle appBar({bool isMain = false}) {
    return isMain ? BrandStyle.full : BrandStyle.icon;
  }
  
  /// Get appropriate brand style for loading screens
  static BrandStyle loading() => BrandStyle.icon;
  
  /// Get appropriate brand style for onboarding
  static BrandStyle onboarding() => BrandStyle.full;
  
  /// Get appropriate brand style for background watermarks
  static BrandStyle watermark() => BrandStyle.watermark;
  
  /// Get appropriate brand style for navigation
  static BrandStyle navigation() => BrandStyle.minimal;
  
  /// Get appropriate brand style for splash screen
  static BrandStyle splash() => BrandStyle.full;
}

/// Responsive brand mark that adapts to screen size
class ResponsiveBrandMark extends StatelessWidget {
  final BrandStyle? overrideStyle;
  final bool showInAppBar;
  final VoidCallback? onTap;
  
  const ResponsiveBrandMark({
    super.key,
    this.overrideStyle,
    this.showInAppBar = false,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isMobile = screenWidth < 400;
    
    BrandStyle style;
    Size size;
    
    if (overrideStyle != null) {
      style = overrideStyle!;
    } else if (showInAppBar) {
      style = isMobile ? BrandStyle.icon : BrandStyle.full;
    } else {
      style = BrandStyle.full;
    }
    
    if (showInAppBar) {
      size = isMobile 
          ? const Size(32, 32)
          : const Size(120, 32);
    } else {
      size = isTablet 
          ? const Size(200, 60)
          : const Size(150, 45);
    }
    
    return BrandMark(
      style: style,
      size: size,
      adaptive: true,
      onTap: onTap,
    );
  }
}

/// Extension methods for easy brand mark usage
extension BrandMarkExtensions on Widget {
  /// Wrap widget with brand reveal animation
  Widget withBrandReveal({
    Duration duration = const Duration(milliseconds: 1500),
    BrandStyle brandStyle = BrandStyle.icon,
  }) {
    return BrandReveal(
      revealDuration: duration,
      brandStyle: brandStyle,
      child: this,
    );
  }
}