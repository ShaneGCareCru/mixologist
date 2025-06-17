import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'ambient_animation_controller.dart';

/// Widget for creating wind-like flutter effects on mint leaves and similar garnishes
class FlutteringLeaf extends StatefulWidget {
  const FlutteringLeaf({
    super.key,
    required this.leafAssetPath,
    this.size = const Size(20, 28),
    this.maxRotation = 8.0,
    this.maxTranslation = 3.0,
    this.windIntensity = 1.0,
    this.duration = const Duration(seconds: 3),
    this.shadowColor = const Color(0x33000000),
    this.enabled = true,
  });

  /// Path to the leaf asset or null for custom painted leaf
  final String? leafAssetPath;
  
  /// Size of the leaf
  final Size size;
  
  /// Maximum rotation in degrees
  final double maxRotation;
  
  /// Maximum translation in pixels
  final double maxTranslation;
  
  /// Wind intensity (0.0 to 2.0)
  final double windIntensity;
  
  /// Duration of one complete flutter cycle
  final Duration duration;
  
  /// Shadow color for depth
  final Color shadowColor;
  
  /// Whether flutter effect is enabled
  final bool enabled;

  @override
  State<FlutteringLeaf> createState() => _FlutteringLeafState();
}

class _FlutteringLeafState extends State<FlutteringLeaf>
    with AmbientAnimationMixin<FlutteringLeaf> {
  
  late AnimationController _flutterController;
  late Animation<double> _primaryWave;
  late Animation<double> _secondaryWave;
  late Animation<double> _rotationWave;
  
  double _randomPhase = 0.0;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    final random = math.Random();
    _randomPhase = random.nextDouble() * 2 * math.pi;
    
    _flutterController = createAmbientController(
      duration: widget.duration,
      debugLabel: 'FlutteringLeaf',
    );
    
    // Primary wave for main flutter movement
    _primaryWave = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _flutterController,
      curve: Curves.easeInOut,
    ));
    
    // Secondary wave for complex movement
    _secondaryWave = Tween<double>(
      begin: 0.0,
      end: 3 * math.pi,
    ).animate(CurvedAnimation(
      parent: _flutterController,
      curve: Curves.easeInOutSine,
    ));
    
    // Rotation wave for twisting effect
    _rotationWave = Tween<double>(
      begin: 0.0,
      end: 4 * math.pi,
    ).animate(CurvedAnimation(
      parent: _flutterController,
      curve: Curves.easeInOutCubic,
    ));
  }

  /// Calculate flutter transformation values
  FlutterTransform _calculateFlutterTransform() {
    final primaryValue = _primaryWave.value + _randomPhase;
    final secondaryValue = _secondaryWave.value + _randomPhase * 0.7;
    final rotationValue = _rotationWave.value + _randomPhase * 0.5;
    
    // Calculate translation components
    final xTranslation = math.sin(primaryValue) * widget.maxTranslation * widget.windIntensity;
    final yTranslation = math.sin(secondaryValue * 0.8) * widget.maxTranslation * 0.5 * widget.windIntensity;
    
    // Calculate rotation
    final rotation = math.sin(rotationValue * 0.6) * widget.maxRotation * widget.windIntensity;
    
    // Calculate shadow offset based on movement
    final shadowOffsetX = xTranslation * 0.3;
    final shadowOffsetY = math.abs(yTranslation) * 0.5 + 2;
    
    // Calculate scale variation for breathing effect
    final scale = 1.0 + (math.sin(primaryValue * 1.5) * 0.05 * widget.windIntensity);
    
    return FlutterTransform(
      translation: Offset(xTranslation, yTranslation),
      rotation: rotation * (math.pi / 180), // Convert to radians
      scale: scale,
      shadowOffset: Offset(shadowOffsetX, shadowOffsetY),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return _buildLeaf();
    }

    return AnimatedBuilder(
      animation: _flutterController,
      builder: (context, child) {
        final transform = _calculateFlutterTransform();
        
        return Transform.translate(
          offset: transform.translation,
          child: Transform.rotate(
            angle: transform.rotation,
            child: Transform.scale(
              scale: transform.scale,
              child: Stack(
                children: [
                  // Shadow
                  Transform.translate(
                    offset: transform.shadowOffset,
                    child: _buildLeafShadow(),
                  ),
                  // Main leaf
                  _buildLeaf(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build the main leaf widget
  Widget _buildLeaf() {
    if (widget.leafAssetPath != null) {
      return Image.asset(
        widget.leafAssetPath!,
        width: widget.size.width,
        height: widget.size.height,
        fit: BoxFit.contain,
      );
    } else {
      return CustomPaint(
        painter: _MintLeafPainter(),
        size: widget.size,
      );
    }
  }

  /// Build the leaf shadow
  Widget _buildLeafShadow() {
    return Opacity(
      opacity: 0.3,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          widget.shadowColor,
          BlendMode.srcIn,
        ),
        child: _buildLeaf(),
      ),
    );
  }
}

/// Transform values for flutter animation
class FlutterTransform {
  const FlutterTransform({
    required this.translation,
    required this.rotation,
    required this.scale,
    required this.shadowOffset,
  });

  final Offset translation;
  final double rotation;
  final double scale;
  final Offset shadowOffset;
}

/// Custom painter for drawing mint leaves when no asset is provided
class _MintLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = const Color(0xFF90EE90)
      ..style = PaintingStyle.fill;
    
    final stemPaint = Paint()
      ..color = const Color(0xFF228B22)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final veinPaint = Paint()
      ..color = const Color(0xFF228B22)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Draw stem
    canvas.drawLine(
      Offset(size.width * 0.5, size.height),
      Offset(size.width * 0.5, size.height * 0.7),
      stemPaint,
    );
    
    // Draw leaf shape (oval with pointed end)
    final leafPath = Path();
    final centerX = size.width * 0.5;
    final topY = size.height * 0.1;
    final bottomY = size.height * 0.7;
    final width = size.width * 0.8;
    
    leafPath.moveTo(centerX, topY);
    leafPath.quadraticBezierTo(
      centerX + width * 0.5, topY + (bottomY - topY) * 0.3,
      centerX + width * 0.3, bottomY,
    );
    leafPath.quadraticBezierTo(
      centerX, bottomY + 5,
      centerX - width * 0.3, bottomY,
    );
    leafPath.quadraticBezierTo(
      centerX - width * 0.5, topY + (bottomY - topY) * 0.3,
      centerX, topY,
    );
    
    canvas.drawPath(leafPath, leafPaint);
    
    // Draw main vein
    canvas.drawLine(
      Offset(centerX, topY + 5),
      Offset(centerX, bottomY - 5),
      veinPaint,
    );
    
    // Draw side veins
    for (int i = 1; i <= 3; i++) {
      final y = topY + (bottomY - topY) * (i / 4);
      final veinLength = width * 0.2 * (1 - i * 0.15);
      
      canvas.drawLine(
        Offset(centerX, y),
        Offset(centerX - veinLength, y + veinLength * 0.5),
        veinPaint,
      );
      
      canvas.drawLine(
        Offset(centerX, y),
        Offset(centerX + veinLength, y + veinLength * 0.5),
        veinPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Multi-leaf flutter effect for sprigs with multiple leaves
class FlutteringSprig extends StatefulWidget {
  const FlutteringSprig({
    super.key,
    required this.leafCount,
    this.leafSize = const Size(16, 22),
    this.spacing = 8.0,
    this.synchronization = 0.3,
    this.windIntensity = 1.0,
    this.enabled = true,
  });

  final int leafCount;
  final Size leafSize;
  final double spacing;
  final double synchronization; // 0.0 = independent, 1.0 = synchronized
  final double windIntensity;
  final bool enabled;

  @override
  State<FlutteringSprig> createState() => _FlutteringSprigState();
}

class _FlutteringSprigState extends State<FlutteringSprig>
    with AmbientAnimationMixin<FlutteringSprig> {
  
  late AnimationController _windController;
  final List<double> _leafPhases = [];
  
  @override
  void initState() {
    super.initState();
    
    _windController = createAmbientController(
      duration: const Duration(milliseconds: 2500),
      debugLabel: 'FlutteringSprig',
    );
    
    // Generate random phases for each leaf
    final random = math.Random();
    for (int i = 0; i < widget.leafCount; i++) {
      _leafPhases.add(random.nextDouble() * 2 * math.pi);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _windController,
      builder: (context, child) {
        return Column(
          children: List.generate(widget.leafCount, (index) {
            // Calculate phase for this leaf
            final basePhase = _leafPhases[index];
            final syncPhase = _windController.value * 2 * math.pi;
            final leafPhase = (basePhase * (1 - widget.synchronization)) + 
                             (syncPhase * widget.synchronization);
            
            // Calculate individual leaf transform
            final xOffset = math.sin(leafPhase) * 2 * widget.windIntensity;
            final rotation = math.sin(leafPhase * 1.3) * 5 * widget.windIntensity;
            
            return Padding(
              padding: EdgeInsets.only(bottom: widget.spacing),
              child: Transform.translate(
                offset: Offset(xOffset, 0),
                child: Transform.rotate(
                  angle: rotation * (math.pi / 180),
                  child: FlutteringLeaf(
                    leafAssetPath: null,
                    size: widget.leafSize,
                    windIntensity: widget.windIntensity * 0.7, // Reduce individual intensity
                    enabled: widget.enabled,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Preset configurations for different leaf types
class LeafFlutterPresets {
  /// Gentle flutter for mint leaves
  static const mint = LeafFlutterConfig(
    maxRotation: 6.0,
    maxTranslation: 2.5,
    duration: Duration(milliseconds: 2800),
    windIntensity: 0.8,
  );
  
  /// More active flutter for basil
  static const basil = LeafFlutterConfig(
    maxRotation: 8.0,
    maxTranslation: 3.5,
    duration: Duration(milliseconds: 2200),
    windIntensity: 1.2,
  );
  
  /// Delicate flutter for garnish herbs
  static const delicate = LeafFlutterConfig(
    maxRotation: 4.0,
    maxTranslation: 1.8,
    duration: Duration(milliseconds: 3500),
    windIntensity: 0.6,
  );
  
  /// Strong flutter for larger leaves
  static const strong = LeafFlutterConfig(
    maxRotation: 12.0,
    maxTranslation: 5.0,
    duration: Duration(milliseconds: 1800),
    windIntensity: 1.5,
  );
}

/// Configuration for leaf flutter effects
class LeafFlutterConfig {
  const LeafFlutterConfig({
    required this.maxRotation,
    required this.maxTranslation,
    required this.duration,
    required this.windIntensity,
  });

  final double maxRotation;
  final double maxTranslation;
  final Duration duration;
  final double windIntensity;
}

/// Auto-fluttering leaf that applies flutter based on leaf type
class AutoFlutteringLeaf extends StatelessWidget {
  const AutoFlutteringLeaf({
    super.key,
    required this.leafType,
    this.customConfig,
    this.enabled = true,
  });

  final String leafType;
  final LeafFlutterConfig? customConfig;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final config = customConfig ?? _getConfigForType(leafType);
    
    return FlutteringLeaf(
      leafAssetPath: null,
      maxRotation: config.maxRotation,
      maxTranslation: config.maxTranslation,
      duration: config.duration,
      windIntensity: config.windIntensity,
      enabled: enabled,
    );
  }

  LeafFlutterConfig _getConfigForType(String type) {
    final lowerType = type.toLowerCase();
    
    if (lowerType.contains('mint')) {
      return LeafFlutterPresets.mint;
    } else if (lowerType.contains('basil')) {
      return LeafFlutterPresets.basil;
    } else if (lowerType.contains('delicate') || lowerType.contains('small')) {
      return LeafFlutterPresets.delicate;
    } else if (lowerType.contains('large') || lowerType.contains('strong')) {
      return LeafFlutterPresets.strong;
    }
    
    return LeafFlutterPresets.mint; // Default
  }
}