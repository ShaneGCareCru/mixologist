import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'ambient_animation_controller.dart';

/// Widget for creating subtle rotating garnish animations
class RotatingGarnish extends StatefulWidget {
  const RotatingGarnish({
    super.key,
    required this.child,
    this.maxRotation = 3.0,
    this.duration = const Duration(seconds: 4),
    this.curve = Curves.easeInOut,
    this.randomVariation = true,
    this.hoverSensitive = true,
    this.enabled = true,
  });

  /// The garnish widget to rotate
  final Widget child;
  
  /// Maximum rotation in degrees (±)
  final double maxRotation;
  
  /// Duration of one complete rotation cycle
  final Duration duration;
  
  /// Animation curve for rotation
  final Curve curve;
  
  /// Whether to add random variation to timing
  final bool randomVariation;
  
  /// Whether to respond to hover interactions
  final bool hoverSensitive;
  
  /// Whether rotation is enabled
  final bool enabled;

  @override
  State<RotatingGarnish> createState() => _RotatingGarnishState();
}

class _RotatingGarnishState extends State<RotatingGarnish>
    with TickerProviderStateMixin, AmbientAnimationMixin<RotatingGarnish> {
  
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  
  bool _isHovering = false;
  double _randomOffset = 0.0;
  
  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    // Add random variation to duration if enabled
    Duration effectiveDuration = widget.duration;
    if (widget.randomVariation) {
      final random = math.Random();
      _randomOffset = random.nextDouble() * 2.0 - 1.0; // -1.0 to 1.0
      final variation = (widget.duration.inMilliseconds * 0.2).round();
      effectiveDuration = Duration(
        milliseconds: widget.duration.inMilliseconds + 
                     (random.nextInt(variation * 2) - variation),
      );
    }
    
    _rotationController = createAmbientController(
      duration: effectiveDuration,
      debugLabel: 'RotatingGarnish',
    );
    
    _rotationAnimation = Tween<double>(
      begin: -widget.maxRotation,
      end: widget.maxRotation,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: widget.curve,
    ));
    
    // Start with random phase offset
    if (widget.randomVariation) {
      final random = math.Random();
      _rotationController.value = random.nextDouble();
    }
  }

  @override
  void didUpdateWidget(RotatingGarnish oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.maxRotation != widget.maxRotation ||
        oldWidget.duration != widget.duration ||
        oldWidget.curve != widget.curve) {
      _setupAnimation();
    }
  }

  void _onHoverChange(bool hovering) {
    if (!widget.hoverSensitive) return;
    
    setState(() {
      _isHovering = hovering;
    });
    
    if (hovering) {
      // Slightly speed up rotation on hover
      _rotationController.duration = Duration(
        milliseconds: (widget.duration.inMilliseconds * 0.7).round(),
      );
    } else {
      // Return to normal speed
      _rotationController.duration = widget.duration;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return MouseRegion(
      onEnter: (_) => _onHoverChange(true),
      onExit: (_) => _onHoverChange(false),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          double rotation = _rotationAnimation.value;
          
          // Add random offset for variation
          if (widget.randomVariation) {
            rotation += _randomOffset * (widget.maxRotation * 0.3);
          }
          
          // Add hover amplification
          if (_isHovering && widget.hoverSensitive) {
            rotation *= 1.5;
          }
          
          // Convert degrees to radians
          final radians = rotation * (math.pi / 180);
          
          return Transform.rotate(
            angle: radians,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Preset configurations for different garnish types
class GarnishRotationPresets {
  /// Subtle rotation for lime/lemon wheels
  static const citrusWheels = GarnishRotationConfig(
    maxRotation: 3.0,
    duration: Duration(seconds: 4),
    curve: Curves.easeInOut,
  );
  
  /// Gentle rotation for cherries
  static const cherries = GarnishRotationConfig(
    maxRotation: 2.0,
    duration: Duration(seconds: 5),
    curve: Curves.easeInOutSine,
  );
  
  /// Minimal rotation for olives
  static const olives = GarnishRotationConfig(
    maxRotation: 1.5,
    duration: Duration(seconds: 6),
    curve: Curves.easeInOut,
  );
  
  /// Faster rotation for cocktail umbrellas
  static const umbrellas = GarnishRotationConfig(
    maxRotation: 5.0,
    duration: Duration(seconds: 3),
    curve: Curves.easeInOutCubic,
  );
}

/// Configuration for garnish rotation
class GarnishRotationConfig {
  const GarnishRotationConfig({
    required this.maxRotation,
    required this.duration,
    required this.curve,
  });

  final double maxRotation;
  final Duration duration;
  final Curve curve;
}

/// Extension to provide rotation configs for garnish types
extension GarnishRotationExtension on String {
  /// Get appropriate rotation configuration for garnish name
  GarnishRotationConfig get rotationConfig {
    final lowerName = toLowerCase();
    
    if (lowerName.contains('lime') || 
        lowerName.contains('lemon') || 
        lowerName.contains('orange')) {
      return GarnishRotationPresets.citrusWheels;
    }
    
    if (lowerName.contains('cherry')) {
      return GarnishRotationPresets.cherries;
    }
    
    if (lowerName.contains('olive')) {
      return GarnishRotationPresets.olives;
    }
    
    if (lowerName.contains('umbrella')) {
      return GarnishRotationPresets.umbrellas;
    }
    
    // Default gentle rotation
    return GarnishRotationPresets.citrusWheels;
  }
  
  /// Whether this garnish should have rotation animation
  bool get shouldRotate {
    final lowerName = toLowerCase();
    
    // Items that benefit from rotation
    return lowerName.contains('lime') ||
           lowerName.contains('lemon') ||
           lowerName.contains('orange') ||
           lowerName.contains('cherry') ||
           lowerName.contains('olive') ||
           lowerName.contains('umbrella') ||
           lowerName.contains('wheel') ||
           lowerName.contains('slice');
  }
}

/// Auto-rotating garnish that applies rotation based on content
class AutoRotatingGarnish extends StatelessWidget {
  const AutoRotatingGarnish({
    super.key,
    required this.child,
    required this.garnishName,
    this.customConfig,
    this.enabled = true,
  });

  final Widget child;
  final String garnishName;
  final GarnishRotationConfig? customConfig;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled || !garnishName.shouldRotate) {
      return child;
    }

    final config = customConfig ?? garnishName.rotationConfig;
    
    return RotatingGarnish(
      maxRotation: config.maxRotation,
      duration: config.duration,
      curve: config.curve,
      child: child,
    );
  }
}

/// Multi-garnish coordinator for synchronized rotations
class SynchronizedGarnishRotation extends StatefulWidget {
  const SynchronizedGarnishRotation({
    super.key,
    required this.children,
    this.phaseOffset = 0.0,
    this.duration = const Duration(seconds: 4),
  });

  final List<Widget> children;
  final double phaseOffset; // 0.0 to 1.0
  final Duration duration;

  @override
  State<SynchronizedGarnishRotation> createState() => 
      _SynchronizedGarnishRotationState();
}

class _SynchronizedGarnishRotationState extends State<SynchronizedGarnishRotation>
    with TickerProviderStateMixin, AmbientAnimationMixin<SynchronizedGarnishRotation> {
  
  late AnimationController _masterController;
  
  @override
  void initState() {
    super.initState();
    
    _masterController = createAmbientController(
      duration: widget.duration,
      debugLabel: 'SynchronizedGarnishRotation',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _masterController,
      builder: (context, child) {
        return Column(
          children: widget.children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            
            // Calculate phase offset for this child
            final phaseShift = (index * widget.phaseOffset) % 1.0;
            final effectiveValue = (_masterController.value + phaseShift) % 1.0;
            
            // Convert to rotation angle
            final rotation = math.sin(effectiveValue * 2 * math.pi) * 3.0;
            final radians = rotation * (math.pi / 180);
            
            return Transform.rotate(
              angle: radians,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}