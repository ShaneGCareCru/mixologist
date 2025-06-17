import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/haptic_service.dart';

/// Custom painter that creates morphing animation between heart and cocktail glass shapes
class MorphingIconPainter extends CustomPainter {
  final double morphProgress;
  final Color color;
  final double strokeWidth;
  
  MorphingIconPainter({
    required this.morphProgress,
    required this.color,
    this.strokeWidth = 2.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth;
    
    // Create the morphing path
    final morphPath = _createMorphingPath(center, radius, morphProgress);
    
    // Draw filled background
    canvas.drawPath(morphPath, fillPaint);
    
    // Draw the outline
    canvas.drawPath(morphPath, paint);
  }
  
  /// Create a path that morphs from heart to cocktail glass
  Path _createMorphingPath(Offset center, double radius, double progress) {
    final path = Path();
    
    if (progress <= 0.0) {
      // Pure heart shape
      return _createHeartPath(center, radius);
    } else if (progress >= 1.0) {
      // Pure cocktail glass shape
      return _createCocktailGlassPath(center, radius);
    } else {
      // Morphing between shapes
      return _createMorphedPath(center, radius, progress);
    }
  }
  
  /// Create heart shape path
  Path _createHeartPath(Offset center, double radius) {
    final path = Path();
    final heartSize = radius * 0.8;
    
    // Heart shape using cubic bezier curves
    final x = center.dx;
    final y = center.dy;
    
    path.moveTo(x, y + heartSize * 0.3);
    
    // Left side of heart
    path.cubicTo(
      x - heartSize * 0.5, y - heartSize * 0.3,
      x - heartSize, y + heartSize * 0.1,
      x, y + heartSize * 0.7,
    );
    
    // Right side of heart
    path.cubicTo(
      x + heartSize, y + heartSize * 0.1,
      x + heartSize * 0.5, y - heartSize * 0.3,
      x, y + heartSize * 0.3,
    );
    
    path.close();
    return path;
  }
  
  /// Create cocktail glass shape path
  Path _createCocktailGlassPath(Offset center, double radius) {
    final path = Path();
    final glassSize = radius * 0.9;
    
    final x = center.dx;
    final y = center.dy;
    
    // Glass bowl (triangle-like shape)
    path.moveTo(x - glassSize * 0.7, y - glassSize * 0.4);
    path.lineTo(x + glassSize * 0.7, y - glassSize * 0.4);
    path.lineTo(x, y + glassSize * 0.2);
    path.close();
    
    // Glass stem
    path.moveTo(x, y + glassSize * 0.2);
    path.lineTo(x, y + glassSize * 0.6);
    
    // Glass base
    path.moveTo(x - glassSize * 0.3, y + glassSize * 0.6);
    path.lineTo(x + glassSize * 0.3, y + glassSize * 0.6);
    
    return path;
  }
  
  /// Create morphed path between heart and glass
  Path _createMorphedPath(Offset center, double radius, double progress) {
    final path = Path();
    
    // Interpolate between heart and glass control points
    final heartPoints = _getHeartControlPoints(center, radius);
    final glassPoints = _getGlassControlPoints(center, radius);
    
    // Create morphed points by interpolating
    final morphedPoints = <Offset>[];
    for (int i = 0; i < heartPoints.length && i < glassPoints.length; i++) {
      morphedPoints.add(Offset.lerp(heartPoints[i], glassPoints[i], progress)!);
    }
    
    // Build path from morphed points
    if (morphedPoints.isNotEmpty) {
      path.moveTo(morphedPoints[0].dx, morphedPoints[0].dy);
      
      for (int i = 1; i < morphedPoints.length - 2; i += 3) {
        if (i + 2 < morphedPoints.length) {
          path.cubicTo(
            morphedPoints[i].dx, morphedPoints[i].dy,
            morphedPoints[i + 1].dx, morphedPoints[i + 1].dy,
            morphedPoints[i + 2].dx, morphedPoints[i + 2].dy,
          );
        }
      }
      
      path.close();
    }
    
    return path;
  }
  
  /// Get control points for heart shape
  List<Offset> _getHeartControlPoints(Offset center, double radius) {
    final heartSize = radius * 0.8;
    final x = center.dx;
    final y = center.dy;
    
    return [
      Offset(x, y + heartSize * 0.3),                    // Start point
      Offset(x - heartSize * 0.5, y - heartSize * 0.3),  // Control 1
      Offset(x - heartSize, y + heartSize * 0.1),        // Control 2
      Offset(x, y + heartSize * 0.7),                    // End point left
      Offset(x + heartSize, y + heartSize * 0.1),        // Control 3
      Offset(x + heartSize * 0.5, y - heartSize * 0.3),  // Control 4
      Offset(x, y + heartSize * 0.3),                    // End point right
    ];
  }
  
  /// Get control points for glass shape
  List<Offset> _getGlassControlPoints(Offset center, double radius) {
    final glassSize = radius * 0.9;
    final x = center.dx;
    final y = center.dy;
    
    return [
      Offset(x - glassSize * 0.7, y - glassSize * 0.4),  // Top left
      Offset(x - glassSize * 0.3, y - glassSize * 0.2),  // Control 1
      Offset(x - glassSize * 0.1, y),                    // Control 2
      Offset(x, y + glassSize * 0.2),                    // Bottom point
      Offset(x + glassSize * 0.1, y),                    // Control 3
      Offset(x + glassSize * 0.3, y - glassSize * 0.2),  // Control 4
      Offset(x + glassSize * 0.7, y - glassSize * 0.4),  // Top right
    ];
  }
  
  @override
  bool shouldRepaint(MorphingIconPainter oldDelegate) {
    return oldDelegate.morphProgress != morphProgress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Morphing favorite icon widget that transitions from heart to cocktail glass
class MorphingFavoriteIcon extends StatefulWidget {
  final bool isFavorited;
  final double size;
  final Color favoriteColor;
  final Color unfavoriteColor;
  final Duration animationDuration;
  final VoidCallback? onToggle;
  final bool enableHaptics;
  final bool showParticleBurst;
  
  const MorphingFavoriteIcon({
    super.key,
    required this.isFavorited,
    this.size = 32.0,
    this.favoriteColor = const Color(0xFFB8860B), // Amber from design philosophy
    this.unfavoriteColor = const Color(0xFF666666),
    this.animationDuration = const Duration(milliseconds: 600),
    this.onToggle,
    this.enableHaptics = true,
    this.showParticleBurst = true,
  });

  @override
  State<MorphingFavoriteIcon> createState() => _MorphingFavoriteIconState();
}

class _MorphingFavoriteIconState extends State<MorphingFavoriteIcon>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _scaleController;
  late AnimationController _particleController;
  
  late Animation<double> _morphAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _particleAnimation;
  
  bool _showParticles = false;
  
  @override
  void initState() {
    super.initState();
    
    // Main morphing animation controller
    _morphController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    // Scale bounce animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Particle burst animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Morphing animation (0 = heart, 1 = cocktail glass)
    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOut,
    );
    
    // Scale bounce animation
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Particle animation
    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    );
    
    // Set initial state
    if (widget.isFavorited) {
      _morphController.value = 1.0;
    }
    
    // Listen for particle animation completion
    _particleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showParticles = false;
        });
        _particleController.reset();
      }
    });
  }
  
  @override
  void didUpdateWidget(MorphingFavoriteIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.isFavorited != widget.isFavorited) {
      _animateToState(widget.isFavorited);
    }
  }
  
  void _animateToState(bool isFavorited) {
    if (isFavorited) {
      _morphController.forward();
      _triggerBounceEffect();
      if (widget.showParticleBurst) {
        _triggerParticleBurst();
      }
    } else {
      _morphController.reverse();
    }
    
    if (widget.enableHaptics) {
      if (isFavorited) {
        HapticService.instance.heavyImpact();
      } else {
        HapticService.instance.selection();
      }
    }
  }
  
  void _triggerBounceEffect() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
  }
  
  void _triggerParticleBurst() {
    setState(() {
      _showParticles = true;
    });
    _particleController.forward();
  }
  
  void _handleTap() {
    widget.onToggle?.call();
  }
  
  @override
  void dispose() {
    _morphController.dispose();
    _scaleController.dispose();
    _particleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _morphController,
          _scaleController,
          _particleController,
        ]),
        builder: (context, child) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Particle burst effect
                if (_showParticles)
                  ..._buildParticles(),
                
                // Main morphing icon
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: MorphingIconPainter(
                      morphProgress: _morphAnimation.value,
                      color: Color.lerp(
                        widget.unfavoriteColor,
                        widget.favoriteColor,
                        _morphAnimation.value,
                      )!,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  /// Build particle burst effect
  List<Widget> _buildParticles() {
    return List.generate(12, (index) {
      final angle = (index / 12) * 2 * pi;
      final distance = 20 + (_particleAnimation.value * 30);
      final opacity = 1.0 - _particleAnimation.value;
      final scale = 0.5 + (_particleAnimation.value * 0.5);
      
      final x = cos(angle) * distance;
      final y = sin(angle) * distance;
      
      return Positioned(
        left: widget.size / 2 + x - 2,
        top: widget.size / 2 + y - 2,
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: widget.favoriteColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Interactive favorite button with cocktail-themed styling
class CocktailFavoriteButton extends StatefulWidget {
  final bool isFavorited;
  final ValueChanged<bool>? onChanged;
  final String? tooltip;
  final double size;
  
  const CocktailFavoriteButton({
    super.key,
    required this.isFavorited,
    this.onChanged,
    this.tooltip,
    this.size = 40.0,
  });

  @override
  State<CocktailFavoriteButton> createState() => _CocktailFavoriteButtonState();
}

class _CocktailFavoriteButtonState extends State<CocktailFavoriteButton> {
  bool _isFavorited = false;
  
  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorited;
  }
  
  @override
  void didUpdateWidget(CocktailFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorited != widget.isFavorited) {
      setState(() {
        _isFavorited = widget.isFavorited;
      });
    }
  }
  
  void _toggle() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    
    widget.onChanged?.call(_isFavorited);
  }
  
  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isFavorited 
            ? const Color(0xFFB8860B).withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: _isFavorited 
              ? const Color(0xFFB8860B).withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: MorphingFavoriteIcon(
          isFavorited: _isFavorited,
          size: widget.size * 0.6,
          onToggle: _toggle,
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