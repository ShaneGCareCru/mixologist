import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'ambient_animation_controller.dart';

/// Individual sparkle point for ice glint effects
class SparklePoint {
  SparklePoint({
    required this.position,
    required this.intensity,
    required this.size,
    required this.phase,
    required this.duration,
    this.color = Colors.white,
  }) : _time = 0.0;

  /// Position of the sparkle on the ice cube
  final Offset position;
  
  /// Brightness intensity (0.0 to 1.0)
  final double intensity;
  
  /// Size of the sparkle
  final double size;
  
  /// Phase offset for timing variation
  final double phase;
  
  /// Duration of one sparkle cycle
  final Duration duration;
  
  /// Color of the sparkle
  final Color color;
  
  /// Internal time tracker
  double _time;
  
  /// Current opacity based on animation
  double get currentOpacity {
    final cycleProgress = (_time + phase) % duration.inMilliseconds / duration.inMilliseconds;
    
    // Create sparkle pattern: quick flash, longer fade
    if (cycleProgress < 0.1) {
      // Flash phase
      return intensity * (cycleProgress / 0.1);
    } else if (cycleProgress < 0.3) {
      // Peak phase
      return intensity;
    } else if (cycleProgress < 0.8) {
      // Fade phase
      return intensity * (1.0 - (cycleProgress - 0.3) / 0.5);
    } else {
      // Dark phase
      return 0.0;
    }
  }
  
  /// Update sparkle animation
  void update(double deltaTime) {
    _time += deltaTime;
  }
  
  /// Reset sparkle timing
  void reset() {
    _time = 0.0;
  }
}

/// Widget for displaying animated ice cube glints and sparkles
class GlintingIce extends StatefulWidget {
  const GlintingIce({
    super.key,
    required this.sparklePoints,
    this.size = const Size(40, 40),
    this.glintIntensity = 1.0,
    this.sparkleColor = Colors.white,
    this.enableRandomGlints = true,
    this.averageGlintInterval = const Duration(seconds: 3),
    this.enabled = true,
  });

  /// Predefined sparkle points on the ice cube
  final List<Offset> sparklePoints;
  
  /// Size of the ice cube
  final Size size;
  
  /// Overall intensity of glint effects
  final double glintIntensity;
  
  /// Base color for sparkles
  final Color sparkleColor;
  
  /// Whether to enable random sparkle timing
  final bool enableRandomGlints;
  
  /// Average interval between random glints
  final Duration averageGlintInterval;
  
  /// Whether glinting is enabled
  final bool enabled;

  @override
  State<GlintingIce> createState() => _GlintingIceState();
}

class _GlintingIceState extends State<GlintingIce>
    with AmbientAnimationMixin<GlintingIce> {
  
  late AnimationController _masterController;
  final List<SparklePoint> _sparkles = [];
  final math.Random _random = math.Random();
  
  @override
  void initState() {
    super.initState();
    _setupSparkles();
    _setupAnimation();
  }

  void _setupAnimation() {
    _masterController = createAmbientController(
      duration: const Duration(milliseconds: 100), // High frequency for smooth updates
      debugLabel: 'GlintingIce',
    );
  }

  void _setupSparkles() {
    _sparkles.clear();
    
    for (final point in widget.sparklePoints) {
      _sparkles.add(SparklePoint(
        position: Offset(
          point.dx * widget.size.width,
          point.dy * widget.size.height,
        ),
        intensity: 0.7 + (_random.nextDouble() * 0.3), // 0.7 to 1.0
        size: 2.0 + (_random.nextDouble() * 3.0), // 2 to 5 pixels
        phase: _random.nextDouble() * 2000, // Random phase offset
        duration: Duration(
          milliseconds: 1500 + _random.nextInt(1000), // 1.5 to 2.5 seconds
        ),
        color: widget.sparkleColor,
      ));
    }
    
    // Add some random sparkle points if enabled
    if (widget.enableRandomGlints) {
      _addRandomSparkles();
    }
  }

  void _addRandomSparkles() {
    final randomCount = 3 + _random.nextInt(4); // 3 to 6 random sparkles
    
    for (int i = 0; i < randomCount; i++) {
      _sparkles.add(SparklePoint(
        position: Offset(
          _random.nextDouble() * widget.size.width,
          _random.nextDouble() * widget.size.height,
        ),
        intensity: 0.3 + (_random.nextDouble() * 0.4), // Dimmer for random ones
        size: 1.0 + (_random.nextDouble() * 2.0),
        phase: _random.nextDouble() * widget.averageGlintInterval.inMilliseconds.toDouble(),
        duration: Duration(
          milliseconds: widget.averageGlintInterval.inMilliseconds + 
                      _random.nextInt(2000) - 1000, // ±1 second variation
        ),
        color: widget.sparkleColor,
      ));
    }
  }

  @override
  void didUpdateWidget(GlintingIce oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.sparklePoints.length != widget.sparklePoints.length ||
        oldWidget.size != widget.size) {
      _setupSparkles();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return SizedBox.fromSize(size: widget.size);
    }

    return SizedBox.fromSize(
      size: widget.size,
      child: AnimatedBuilder(
        animation: _masterController,
        builder: (context, child) {
          _updateSparkles();
          return CustomPaint(
            painter: _IceGlintPainter(
              sparkles: _sparkles,
              intensity: widget.glintIntensity,
            ),
            size: widget.size,
          );
        },
      ),
    );
  }

  void _updateSparkles() {
    const deltaTime = 100.0; // 100ms updates
    
    for (final sparkle in _sparkles) {
      sparkle.update(deltaTime);
    }
  }
}

/// Custom painter for ice glint effects
class _IceGlintPainter extends CustomPainter {
  const _IceGlintPainter({
    required this.sparkles,
    required this.intensity,
  });

  final List<SparklePoint> sparkles;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in sparkles) {
      final opacity = sparkle.currentOpacity * intensity;
      
      if (opacity > 0.01) {
        _paintSparkle(canvas, sparkle, opacity);
      }
    }
  }

  void _paintSparkle(Canvas canvas, SparklePoint sparkle, double opacity) {
    final center = sparkle.position;
    final size = sparkle.size;
    
    // Main sparkle body
    final sparkleBody = Paint()
      ..color = sparkle.color.withOpacity(opacity * 0.9)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.5);
    
    canvas.drawCircle(center, size, sparkleBody);
    
    // Bright center
    final sparkleCenter = Paint()
      ..color = sparkle.color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, size * 0.3, sparkleCenter);
    
    // Sparkle rays (4-pointed star effect)
    _paintSparkleRays(canvas, center, size, sparkle.color, opacity);
    
    // Optional: add prismatic effect for larger sparkles
    if (size > 3.0 && opacity > 0.7) {
      _paintPrismaticEffect(canvas, center, size, opacity);
    }
  }

  void _paintSparkleRays(Canvas canvas, Offset center, double size, Color color, double opacity) {
    final rayPaint = Paint()
      ..color = color.withOpacity(opacity * 0.8)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.5);
    
    final rayLength = size * 2.5;
    
    // Draw 4 rays at 45-degree intervals
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + (math.pi / 4);
      final endX = center.dx + math.cos(angle) * rayLength;
      final endY = center.dy + math.sin(angle) * rayLength;
      
      canvas.drawLine(
        center,
        Offset(endX, endY),
        rayPaint,
      );
    }
  }

  void _paintPrismaticEffect(Canvas canvas, Offset center, double size, double opacity) {
    // Add subtle color variations for prismatic effect
    final colors = [
      Colors.lightBlue.withOpacity(opacity * 0.3),
      Colors.lightGreen.withOpacity(opacity * 0.2),
      Colors.pink.withOpacity(opacity * 0.2),
    ];
    
    for (int i = 0; i < colors.length; i++) {
      final offset = Offset(
        center.dx + (i - 1) * 0.5,
        center.dy + (i - 1) * 0.3,
      );
      
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.3);
      
      canvas.drawCircle(offset, size * 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _IceGlintPainter oldDelegate) {
    return oldDelegate.intensity != intensity ||
           _sparklesChanged(oldDelegate.sparkles);
  }

  bool _sparklesChanged(List<SparklePoint> oldSparkles) {
    if (oldSparkles.length != sparkles.length) return true;
    
    for (int i = 0; i < sparkles.length; i++) {
      if (oldSparkles[i].currentOpacity != sparkles[i].currentOpacity) {
        return true;
      }
    }
    
    return false;
  }
}

/// Ice cube shape with predefined sparkle points
class IceCubeWithGlints extends StatelessWidget {
  const IceCubeWithGlints({
    super.key,
    this.size = const Size(40, 40),
    this.iceColor = const Color(0xFFE6F3FF),
    this.glintIntensity = 1.0,
    this.shape = IceCubeShape.cube,
    this.enabled = true,
  });

  final Size size;
  final Color iceColor;
  final double glintIntensity;
  final IceCubeShape shape;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ice cube base
        Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: iceColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        // Glint overlay
        GlintingIce(
          sparklePoints: shape.sparklePoints,
          size: size,
          glintIntensity: glintIntensity,
          enabled: enabled,
        ),
      ],
    );
  }
}

/// Different ice cube shapes with predefined sparkle patterns
enum IceCubeShape {
  cube,
  crushed,
  sphere,
  cylinder,
}

extension IceCubeShapeExtension on IceCubeShape {
  /// Get sparkle points for this ice shape
  List<Offset> get sparklePoints {
    switch (this) {
      case IceCubeShape.cube:
        return [
          const Offset(0.2, 0.2), // Top-left corner
          const Offset(0.8, 0.3), // Top-right corner
          const Offset(0.3, 0.7), // Bottom-left
          const Offset(0.7, 0.8), // Bottom-right
          const Offset(0.5, 0.1), // Top center
          const Offset(0.1, 0.6), // Left edge
        ];
      
      case IceCubeShape.crushed:
        return [
          const Offset(0.15, 0.25),
          const Offset(0.35, 0.15),
          const Offset(0.65, 0.3),
          const Offset(0.85, 0.45),
          const Offset(0.25, 0.6),
          const Offset(0.45, 0.75),
          const Offset(0.75, 0.7),
          const Offset(0.1, 0.8),
        ];
      
      case IceCubeShape.sphere:
        return [
          const Offset(0.3, 0.2),
          const Offset(0.7, 0.25),
          const Offset(0.2, 0.5),
          const Offset(0.8, 0.6),
          const Offset(0.5, 0.1),
          const Offset(0.4, 0.8),
        ];
      
      case IceCubeShape.cylinder:
        return [
          const Offset(0.2, 0.15),
          const Offset(0.8, 0.2),
          const Offset(0.1, 0.4),
          const Offset(0.9, 0.45),
          const Offset(0.3, 0.7),
          const Offset(0.7, 0.75),
          const Offset(0.5, 0.9),
        ];
    }
  }
}

/// Multiple ice cubes with synchronized glinting
class IceCubeCluster extends StatefulWidget {
  const IceCubeCluster({
    super.key,
    required this.cubeCount,
    this.cubeSize = const Size(30, 30),
    this.spacing = 8.0,
    this.glintSynchronization = 0.3,
    this.enabled = true,
  });

  final int cubeCount;
  final Size cubeSize;
  final double spacing;
  final double glintSynchronization; // 0.0 = independent, 1.0 = synchronized
  final bool enabled;

  @override
  State<IceCubeCluster> createState() => _IceCubeClusterState();
}

class _IceCubeClusterState extends State<IceCubeCluster>
    with AmbientAnimationMixin<IceCubeCluster> {
  
  late AnimationController _clusterController;
  final List<double> _cubePhases = [];
  
  @override
  void initState() {
    super.initState();
    
    _clusterController = createAmbientController(
      duration: const Duration(seconds: 4),
      debugLabel: 'IceCubeCluster',
    );
    
    // Generate random phases for each cube
    final random = math.Random();
    for (int i = 0; i < widget.cubeCount; i++) {
      _cubePhases.add(random.nextDouble());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.spacing,
      children: List.generate(widget.cubeCount, (index) {
        // Calculate synchronized intensity
        final phase = _cubePhases[index];
        final syncValue = math.sin(_clusterController.value * 2 * math.pi + phase);
        final intensity = 0.7 + (syncValue * 0.3 * widget.glintSynchronization);
        
        return IceCubeWithGlints(
          size: widget.cubeSize,
          glintIntensity: intensity,
          shape: IceCubeShape.values[index % IceCubeShape.values.length],
          enabled: widget.enabled,
        );
      }),
    );
  }
}