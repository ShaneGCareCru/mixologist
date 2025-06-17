import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'glass_shape.dart';

/// Individual bubble in the carbonation effect
class Bubble {
  Bubble({
    required this.startPosition,
    required this.size,
    required this.speed,
    required this.wobbleFreq,
    required this.wobbleAmount,
    this.opacity = 0.8,
  }) : currentPosition = startPosition,
       _time = 0.0;

  /// Starting position of the bubble
  final Offset startPosition;
  
  /// Current animated position
  Offset currentPosition;
  
  /// Size of the bubble (radius)
  final double size;
  
  /// Upward movement speed
  final double speed;
  
  /// Frequency of horizontal wobble
  final double wobbleFreq;
  
  /// Amount of horizontal wobble
  final double wobbleAmount;
  
  /// Opacity of the bubble
  final double opacity;
  
  /// Internal time tracker for animation
  double _time;

  /// Update bubble position based on elapsed time
  void update(double deltaTime, double glassHeight) {
    _time += deltaTime;
    
    // Move upward
    final newY = startPosition.dy - (speed * _time);
    
    // Add horizontal wobble
    final wobbleX = math.sin(_time * wobbleFreq) * wobbleAmount;
    
    currentPosition = Offset(
      startPosition.dx + wobbleX,
      newY,
    );
  }

  /// Check if bubble has reached the top and should be reset
  bool shouldReset(double glassHeight) {
    return currentPosition.dy < -size * 2;
  }

  /// Reset bubble to bottom of glass
  void reset(Offset newStartPosition) {
    currentPosition = newStartPosition;
    startPosition = newStartPosition;
    _time = 0.0;
  }

  /// Check if bubble is visible within the glass bounds
  bool isVisible(Size glassSize) {
    return currentPosition.dx >= -size &&
           currentPosition.dx <= glassSize.width + size &&
           currentPosition.dy >= -size &&
           currentPosition.dy <= glassSize.height + size;
  }
}

/// Widget for displaying animated carbonation bubbles in glasses
class BubbleStream extends StatefulWidget {
  const BubbleStream({
    super.key,
    required this.glassShape,
    required this.isActive,
    this.size = const Size(120, 120),
    this.bubbleCount = 12,
    this.fillLevel = 0.7,
    this.intensity = 1.0,
    this.bubbleColor = const Color(0xFFE6F3FF),
  });

  /// The glass shape containing the bubbles
  final GlassShape glassShape;
  
  /// Whether bubbles should be actively animated
  final bool isActive;
  
  /// Size of the glass widget
  final Size size;
  
  /// Number of bubbles to display
  final int bubbleCount;
  
  /// Fill level of the liquid (0.0 to 1.0)
  final double fillLevel;
  
  /// Intensity of bubble generation (0.0 to 2.0)
  final double intensity;
  
  /// Color of the bubbles
  final Color bubbleColor;

  @override
  State<BubbleStream> createState() => _BubbleStreamState();
}

class _BubbleStreamState extends State<BubbleStream>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Bubble> _bubbles;
  double _lastTime = 0.0;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _bubbles = [];
    _initializeBubbles();
    
    if (widget.isActive) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(BubbleStream oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
    
    if (widget.bubbleCount != oldWidget.bubbleCount ||
        widget.fillLevel != oldWidget.fillLevel ||
        widget.intensity != oldWidget.intensity) {
      _initializeBubbles();
    }
  }

  void _startAnimation() {
    _animationController.repeat();
    _lastTime = 0.0;
  }

  void _stopAnimation() {
    _animationController.stop();
  }

  /// Initialize bubbles with random properties
  void _initializeBubbles() {
    final random = math.Random();
    _bubbles.clear();
    
    final effectiveBubbleCount = (widget.bubbleCount * widget.intensity).round();
    
    for (int i = 0; i < effectiveBubbleCount; i++) {
      final startPosition = _generateBubbleStartPosition(random);
      
      _bubbles.add(Bubble(
        startPosition: startPosition,
        size: _generateBubbleSize(random),
        speed: _generateBubbleSpeed(random),
        wobbleFreq: _generateWobbleFreq(random),
        wobbleAmount: _generateWobbleAmount(random),
        opacity: _generateBubbleOpacity(random),
      ));
    }
  }

  /// Generate random start position for a bubble
  Offset _generateBubbleStartPosition(math.Random random) {
    // Get the liquid area bounds
    final liquidPath = widget.glassShape.getLiquidPath(widget.size, widget.fillLevel);
    final bounds = liquidPath.getBounds();
    
    // Generate position within the bottom portion of the liquid
    final x = bounds.left + (random.nextDouble() * bounds.width);
    final y = bounds.bottom - (random.nextDouble() * bounds.height * 0.2);
    
    return Offset(x, y);
  }

  /// Generate random bubble size
  double _generateBubbleSize(math.Random random) {
    return 1.0 + (random.nextDouble() * 4.0); // 1-5 pixels radius
  }

  /// Generate random bubble speed
  double _generateBubbleSpeed(math.Random random) {
    final baseSpeed = 30.0; // pixels per second
    return baseSpeed + (random.nextDouble() * 20.0);
  }

  /// Generate random wobble frequency
  double _generateWobbleFreq(math.Random random) {
    return 2.0 + (random.nextDouble() * 4.0); // 2-6 Hz
  }

  /// Generate random wobble amount
  double _generateWobbleAmount(math.Random random) {
    return 2.0 + (random.nextDouble() * 6.0); // 2-8 pixels
  }

  /// Generate random bubble opacity
  double _generateBubbleOpacity(math.Random random) {
    return 0.3 + (random.nextDouble() * 0.5); // 0.3-0.8
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive || widget.fillLevel <= 0) {
      return SizedBox.fromSize(size: widget.size);
    }

    return SizedBox.fromSize(
      size: widget.size,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          _updateBubbles();
          return CustomPaint(
            painter: _BubblePainter(
              glassShape: widget.glassShape,
              bubbles: _bubbles,
              fillLevel: widget.fillLevel,
              bubbleColor: widget.bubbleColor,
            ),
            size: widget.size,
          );
        },
      ),
    );
  }

  /// Update all bubble positions
  void _updateBubbles() {
    final currentTime = _animationController.value;
    final deltaTime = currentTime - _lastTime;
    _lastTime = currentTime;
    
    final random = math.Random();
    
    for (final bubble in _bubbles) {
      bubble.update(deltaTime, widget.size.height);
      
      if (bubble.shouldReset(widget.size.height)) {
        final newStartPosition = _generateBubbleStartPosition(random);
        bubble.reset(newStartPosition);
      }
    }
  }
}

/// Custom painter for bubble effects
class _BubblePainter extends CustomPainter {
  const _BubblePainter({
    required this.glassShape,
    required this.bubbles,
    required this.fillLevel,
    required this.bubbleColor,
  });

  final GlassShape glassShape;
  final List<Bubble> bubbles;
  final double fillLevel;
  final Color bubbleColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (bubbles.isEmpty || fillLevel <= 0) return;

    // Create clipping path for liquid area
    final liquidPath = glassShape.getLiquidPath(size, fillLevel);
    canvas.save();
    canvas.clipPath(liquidPath);
    
    // Paint each bubble
    for (final bubble in bubbles) {
      if (bubble.isVisible(size)) {
        _paintBubble(canvas, bubble);
      }
    }
    
    canvas.restore();
  }

  /// Paint an individual bubble
  void _paintBubble(Canvas canvas, Bubble bubble) {
    final center = bubble.currentPosition;
    final radius = bubble.size;
    
    // Bubble body
    final bubblePaint = Paint()
      ..color = bubbleColor.withOpacity(bubble.opacity * 0.6)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, bubblePaint);
    
    // Bubble highlight (makes it look more 3D)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(bubble.opacity * 0.8)
      ..style = PaintingStyle.fill;
    
    final highlightCenter = Offset(
      center.dx - radius * 0.3,
      center.dy - radius * 0.3,
    );
    
    canvas.drawCircle(highlightCenter, radius * 0.4, highlightPaint);
    
    // Bubble rim (subtle outline)
    final rimPaint = Paint()
      ..color = bubbleColor.withOpacity(bubble.opacity * 0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) {
    return oldDelegate.bubbles.length != bubbles.length ||
           oldDelegate.fillLevel != fillLevel ||
           _bubblesChanged(oldDelegate.bubbles);
  }

  /// Check if any bubble positions have changed
  bool _bubblesChanged(List<Bubble> oldBubbles) {
    if (oldBubbles.length != bubbles.length) return true;
    
    for (int i = 0; i < bubbles.length; i++) {
      if (oldBubbles[i].currentPosition != bubbles[i].currentPosition) {
        return true;
      }
    }
    
    return false;
  }
}

/// Preset configurations for different drink types
class BubblePresets {
  /// Light carbonation (e.g., champagne, prosecco)
  static const light = BubbleConfig(
    bubbleCount: 8,
    intensity: 0.7,
    bubbleColor: Color(0xFFF5F5DC),
  );
  
  /// Medium carbonation (e.g., beer, soda)
  static const medium = BubbleConfig(
    bubbleCount: 15,
    intensity: 1.0,
    bubbleColor: Color(0xFFE6F3FF),
  );
  
  /// Heavy carbonation (e.g., soda water, tonic)
  static const heavy = BubbleConfig(
    bubbleCount: 25,
    intensity: 1.5,
    bubbleColor: Color(0xFFFFFFFF),
  );
  
  /// Beer bubbles (specific color and behavior)
  static const beer = BubbleConfig(
    bubbleCount: 20,
    intensity: 1.2,
    bubbleColor: Color(0xFFFFF8DC),
  );
}

/// Configuration for bubble effects
class BubbleConfig {
  const BubbleConfig({
    required this.bubbleCount,
    required this.intensity,
    required this.bubbleColor,
  });

  final int bubbleCount;
  final double intensity;
  final Color bubbleColor;
}

/// Helper extension for drink-specific bubble effects
extension DrinkBubbles on String {
  /// Get appropriate bubble configuration for drink type
  BubbleConfig get bubbleConfig {
    final lowerName = toLowerCase();
    
    if (lowerName.contains('champagne') || 
        lowerName.contains('prosecco') || 
        lowerName.contains('cava')) {
      return BubblePresets.light;
    }
    
    if (lowerName.contains('beer') || 
        lowerName.contains('ale') || 
        lowerName.contains('lager')) {
      return BubblePresets.beer;
    }
    
    if (lowerName.contains('soda') || 
        lowerName.contains('cola') || 
        lowerName.contains('sprite') || 
        lowerName.contains('tonic')) {
      return BubblePresets.heavy;
    }
    
    if (lowerName.contains('sparkling') || 
        lowerName.contains('fizzy') || 
        lowerName.contains('carbonated')) {
      return BubblePresets.medium;
    }
    
    // Default to no bubbles
    return const BubbleConfig(
      bubbleCount: 0,
      intensity: 0.0,
      bubbleColor: Colors.transparent,
    );
  }
  
  /// Whether this drink should have bubble effects
  bool get hasBubbles => bubbleConfig.bubbleCount > 0;
}