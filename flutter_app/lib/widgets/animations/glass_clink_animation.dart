import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/haptic_service.dart';

/// Custom painter for drawing cocktail glass shapes
class CocktailGlassPainter extends CustomPainter {
  final Color glassColor;
  final Color liquidColor;
  final double fillLevel;
  final bool showGarnish;
  final double rotation;
  
  CocktailGlassPainter({
    required this.glassColor,
    required this.liquidColor,
    this.fillLevel = 0.6,
    this.showGarnish = true,
    this.rotation = 0.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = glassColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final liquidPaint = Paint()
      ..color = liquidColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    
    _drawGlass(canvas, size, paint, liquidPaint);
    
    if (showGarnish) {
      _drawGarnish(canvas, size);
    }
    
    canvas.restore();
  }
  
  void _drawGlass(Canvas canvas, Size size, Paint paint, Paint liquidPaint) {
    final center = Offset(size.width / 2, size.height / 2);
    final glassWidth = size.width * 0.6;
    final glassHeight = size.height * 0.8;
    
    // Glass bowl (martini style)
    final path = Path();
    path.moveTo(center.dx - glassWidth / 2, center.dy - glassHeight / 3);
    path.lineTo(center.dx + glassWidth / 2, center.dy - glassHeight / 3);
    path.lineTo(center.dx, center.dy + glassHeight / 6);
    path.close();
    
    // Draw liquid first (behind glass)
    if (fillLevel > 0) {
      final liquidPath = Path();
      final liquidHeight = (glassHeight / 2) * fillLevel;
      final liquidWidth = glassWidth * (1 - fillLevel * 0.3);
      
      liquidPath.moveTo(center.dx - liquidWidth / 2, center.dy - glassHeight / 3 + liquidHeight);
      liquidPath.lineTo(center.dx + liquidWidth / 2, center.dy - glassHeight / 3 + liquidHeight);
      liquidPath.lineTo(center.dx, center.dy + glassHeight / 6);
      liquidPath.close();
      
      canvas.drawPath(liquidPath, liquidPaint);
    }
    
    // Draw glass outline
    canvas.drawPath(path, paint);
    
    // Glass stem
    canvas.drawLine(
      Offset(center.dx, center.dy + glassHeight / 6),
      Offset(center.dx, center.dy + glassHeight / 2),
      paint,
    );
    
    // Glass base
    canvas.drawLine(
      Offset(center.dx - glassWidth / 4, center.dy + glassHeight / 2),
      Offset(center.dx + glassWidth / 4, center.dy + glassHeight / 2),
      paint,
    );
  }
  
  void _drawGarnish(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final garnishPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;
    
    // Draw a small olive or cherry
    canvas.drawCircle(
      Offset(center.dx + 8, center.dy - size.height * 0.2),
      3,
      garnishPaint,
    );
    
    // Draw a small stick/toothpick
    final stickPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(center.dx + 5, center.dy - size.height * 0.2),
      Offset(center.dx + 15, center.dy - size.height * 0.25),
      stickPaint,
    );
  }
  
  @override
  bool shouldRepaint(CocktailGlassPainter oldDelegate) {
    return oldDelegate.glassColor != glassColor ||
           oldDelegate.liquidColor != liquidColor ||
           oldDelegate.fillLevel != fillLevel ||
           oldDelegate.showGarnish != showGarnish ||
           oldDelegate.rotation != rotation;
  }
}

/// Animation widget showing two glasses meeting and clinking
class GlassClinkAnimation extends StatefulWidget {
  final VoidCallback? onShareComplete;
  final bool enableHaptics;
  final bool enableSoundEffects;
  final Duration animationDuration;
  final Color glassColor;
  final Color liquidColor;
  
  const GlassClinkAnimation({
    super.key,
    this.onShareComplete,
    this.enableHaptics = true,
    this.enableSoundEffects = false,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.glassColor = const Color(0xFF87A96B), // Sage from design philosophy
    this.liquidColor = const Color(0xFFB8860B), // Amber from design philosophy
  });

  @override
  State<GlassClinkAnimation> createState() => _GlassClinkAnimationState();
}

class _GlassClinkAnimationState extends State<GlassClinkAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _flashController;
  late AnimationController _bubbleController;
  
  late Animation<double> _leftGlassSlide;
  late Animation<double> _rightGlassSlide;
  late Animation<double> _leftGlassRotation;
  late Animation<double> _rightGlassRotation;
  late Animation<double> _flashOpacity;
  late Animation<double> _bubbleScale;
  late Animation<double> _bubbleOpacity;
  
  bool _showFlash = false;
  bool _showBubbles = false;
  
  @override
  void initState() {
    super.initState();
    
    // Main animation controller
    _mainController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    // Flash effect controller
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Bubble effect controller
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Left glass sliding in from left
    _leftGlassSlide = Tween<double>(
      begin: -1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    // Right glass sliding in from right
    _rightGlassSlide = Tween<double>(
      begin: 1.0,
      end: -0.3,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    // Left glass tilting towards right
    _leftGlassRotation = Tween<double>(
      begin: 0.0,
      end: 0.2,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
    ));
    
    // Right glass tilting towards left
    _rightGlassRotation = Tween<double>(
      begin: 0.0,
      end: -0.2,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
    ));
    
    // Flash effect
    _flashOpacity = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOut,
    ));
    
    // Bubble effects
    _bubbleScale = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOut,
    ));
    
    _bubbleOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOut,
    ));
    
    // Listen for clink moment
    _mainController.addListener(_checkForClink);
    
    // Listen for animation completion
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onAnimationComplete();
      }
    });
    
    // Start the animation
    _startAnimation();
  }
  
  void _checkForClink() {
    // Trigger clink effects when glasses meet (around 60% progress)
    if (_mainController.value >= 0.6 && !_showFlash) {
      _triggerClinkEffects();
    }
  }
  
  void _triggerClinkEffects() {
    setState(() {
      _showFlash = true;
      _showBubbles = true;
    });
    
    // Flash effect
    _flashController.forward().then((_) {
      _flashController.reverse();
    });
    
    // Bubble effect
    _bubbleController.forward();
    
    // Haptic feedback
    if (widget.enableHaptics) {
      HapticService.instance.glassClink();
    }
    
    // Optional system sound (iOS only)
    if (widget.enableSoundEffects) {
      // Use haptic for sound effect since SystemSound.click doesn't exist
      await HapticService.instance.selection();
    }
  }
  
  void _startAnimation() {
    _mainController.forward();
  }
  
  void _onAnimationComplete() {
    // Small delay before calling completion callback
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onShareComplete?.call();
    });
  }
  
  @override
  void dispose() {
    _mainController.dispose();
    _flashController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainController,
        _flashController,
        _bubbleController,
      ]),
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 120,
          child: Stack(
            children: [
              // Flash effect overlay
              if (_showFlash)
                Positioned.fill(
                  child: Opacity(
                    opacity: _flashOpacity.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              
              // Left glass
              Positioned(
                left: 50 + (_leftGlassSlide.value * 100),
                top: 20,
                child: SizedBox(
                  width: 60,
                  height: 80,
                  child: CustomPaint(
                    painter: CocktailGlassPainter(
                      glassColor: widget.glassColor,
                      liquidColor: widget.liquidColor,
                      rotation: _leftGlassRotation.value,
                    ),
                  ),
                ),
              ),
              
              // Right glass
              Positioned(
                left: 90 + (_rightGlassSlide.value * 100),
                top: 20,
                child: SizedBox(
                  width: 60,
                  height: 80,
                  child: CustomPaint(
                    painter: CocktailGlassPainter(
                      glassColor: widget.glassColor,
                      liquidColor: widget.liquidColor,
                      rotation: _rightGlassRotation.value,
                    ),
                  ),
                ),
              ),
              
              // Bubble effects
              if (_showBubbles)
                ..._buildBubbles(),
            ],
          ),
        );
      },
    );
  }
  
  /// Build celebratory bubbles
  List<Widget> _buildBubbles() {
    return List.generate(8, (index) {
      final random = Random(index);
      final angle = random.nextDouble() * 2 * pi;
      final distance = 20 + (_bubbleScale.value * 40);
      final x = cos(angle) * distance;
      final y = sin(angle) * distance;
      
      return Positioned(
        left: 100 + x - 3,
        top: 40 + y - 3,
        child: Transform.scale(
          scale: 0.5 + (_bubbleScale.value * 0.5),
          child: Opacity(
            opacity: _bubbleOpacity.value,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: widget.liquidColor.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.liquidColor.withOpacity(0.3),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Interactive share button with glass clink animation
class CocktailShareButton extends StatefulWidget {
  final VoidCallback? onShare;
  final String? tooltip;
  final double size;
  final Widget? child;
  
  const CocktailShareButton({
    super.key,
    this.onShare,
    this.tooltip,
    this.size = 48.0,
    this.child,
  });

  @override
  State<CocktailShareButton> createState() => _CocktailShareButtonState();
}

class _CocktailShareButtonState extends State<CocktailShareButton> {
  bool _isAnimating = false;
  
  void _handleTap() async {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
    });
    
    // Show overlay with clink animation
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: GlassClinkAnimation(
              onShareComplete: () {
                overlayEntry.remove();
                setState(() {
                  _isAnimating = false;
                });
                
                // Trigger share after animation
                widget.onShare?.call();
              },
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF87A96B).withOpacity(0.1), // Sage
        border: Border.all(
          color: const Color(0xFF87A96B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.size / 2),
        onTap: _isAnimating ? null : _handleTap,
        child: Center(
          child: widget.child ?? 
              Icon(
                Icons.share,
                size: widget.size * 0.5,
                color: const Color(0xFF87A96B),
              ),
        ),
      ),
    );
    
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}

/// Full-screen glass clink overlay for dramatic effect
class GlassClinkOverlay extends StatelessWidget {
  final VoidCallback? onComplete;
  final Color backgroundColor;
  
  const GlassClinkOverlay({
    super.key,
    this.onComplete,
    this.backgroundColor = const Color(0x80000000),
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassClinkAnimation(
              onShareComplete: onComplete,
            ),
            const SizedBox(height: 24),
            Text(
              'Cheers!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Preparing to share...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}