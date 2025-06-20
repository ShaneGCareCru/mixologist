import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'ambient_animation_controller.dart';

/// DISABLED: Static leaf widget without flutter animations
/// Previously caused curve and performance issues
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

class _FlutteringLeafState extends State<FlutteringLeaf> {
  @override
  void initState() {
    super.initState();
    // DISABLED: No animation setup to prevent curve errors
  }

  @override
  Widget build(BuildContext context) {
    // DISABLED: Static leaf without animations
    return _buildLeaf();
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

class _FlutteringSprigState extends State<FlutteringSprig> {
  @override
  Widget build(BuildContext context) {
    // DISABLED: Static sprig without animations
    return Column(
      children: List.generate(widget.leafCount, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: widget.spacing),
          child: FlutteringLeaf(
            leafAssetPath: null,
            size: widget.leafSize,
            windIntensity: 0.0, // No wind
            enabled: false, // Disabled
          ),
        );
      }),
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