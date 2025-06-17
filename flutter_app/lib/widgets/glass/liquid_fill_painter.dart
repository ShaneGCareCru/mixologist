import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'glass_shape.dart';

/// Represents a layer of liquid in the glass
class LiquidLayer {
  const LiquidLayer({
    required this.color,
    required this.thickness,
    this.opacity = 1.0,
    this.isTranslucent = false,
  });

  /// The color of this liquid layer
  final Color color;
  
  /// Relative thickness of this layer (0.0 to 1.0)
  final double thickness;
  
  /// Opacity of the layer (0.0 to 1.0)
  final double opacity;
  
  /// Whether this layer should blend with layers below
  final bool isTranslucent;
}

/// Custom painter for rendering layered liquid fills in glasses
class LiquidFillPainter extends CustomPainter {
  const LiquidFillPainter({
    required this.glassShape,
    required this.layers,
    required this.totalFillLevel,
    this.showMeniscus = true,
    this.animationValue = 0.0,
  });

  /// The glass shape to fill
  final GlassShape glassShape;
  
  /// List of liquid layers from bottom to top
  final List<LiquidLayer> layers;
  
  /// Total fill level (0.0 to 1.0)
  final double totalFillLevel;
  
  /// Whether to show the meniscus curve at the top
  final bool showMeniscus;
  
  /// Animation value for dynamic effects (0.0 to 1.0)
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    if (totalFillLevel <= 0 || layers.isEmpty) return;

    // Calculate layer positions
    final layerPositions = _calculateLayerPositions();
    
    // Draw each layer from bottom to top
    for (int i = 0; i < layers.length; i++) {
      final layer = layers[i];
      final position = layerPositions[i];
      
      if (position.fillLevel <= 0) continue;
      
      _drawLiquidLayer(canvas, size, layer, position);
    }
    
    // Draw meniscus if enabled
    if (showMeniscus && totalFillLevel > 0.05) {
      _drawMeniscus(canvas, size);
    }
  }

  /// Calculate the fill level and position for each layer
  List<LayerPosition> _calculateLayerPositions() {
    final positions = <LayerPosition>[];
    double currentBottom = 0.0;
    
    for (final layer in layers) {
      final layerHeight = layer.thickness * totalFillLevel;
      final layerTop = math.min(currentBottom + layerHeight, totalFillLevel);
      
      positions.add(LayerPosition(
        fillLevel: layerTop - currentBottom,
        bottomOffset: currentBottom,
        topOffset: layerTop,
      ));
      
      currentBottom = layerTop;
      if (currentBottom >= totalFillLevel) break;
    }
    
    return positions;
  }

  /// Draw a single liquid layer
  void _drawLiquidLayer(Canvas canvas, Size size, LiquidLayer layer, LayerPosition position) {
    final paint = Paint()
      ..color = layer.color.withOpacity(layer.opacity)
      ..style = PaintingStyle.fill;

    // Apply blending mode for translucent layers
    if (layer.isTranslucent) {
      paint.blendMode = BlendMode.multiply;
    }

    // Create clipping path for this layer
    final clipPath = _createLayerClipPath(size, position);
    
    canvas.save();
    canvas.clipPath(clipPath);
    
    // Fill the layer area
    final fillPath = glassShape.getLiquidPath(size, position.topOffset);
    canvas.drawPath(fillPath, paint);
    
    // Add subtle gradient for depth
    _drawLayerGradient(canvas, size, layer, position);
    
    canvas.restore();
  }

  /// Create a clipping path for a specific layer
  Path _createLayerClipPath(Size size, LayerPosition position) {
    final path = Path();
    
    // Get the glass outline
    final glassPath = glassShape.getLiquidPath(size, position.topOffset);
    
    // Create bottom boundary if not the bottom layer
    if (position.bottomOffset > 0) {
      final bottomPath = glassShape.getLiquidPath(size, position.bottomOffset);
      
      // Subtract bottom path from top path
      path.addPath(glassPath, Offset.zero);
      path.addPath(bottomPath, Offset.zero, PathOperation.difference);
    } else {
      path.addPath(glassPath, Offset.zero);
    }
    
    return path;
  }

  /// Draw gradient overlay for layer depth
  void _drawLayerGradient(Canvas canvas, Size size, LiquidLayer layer, LayerPosition position) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        layer.color.withOpacity(0.1),
        layer.color.withOpacity(0.3),
      ],
      stops: const [0.0, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..blendMode = BlendMode.overlay;
    
    canvas.drawRect(rect, paint);
  }

  /// Draw the meniscus curve at the liquid surface
  void _drawMeniscus(Canvas canvas, Size size) {
    final liquidPath = glassShape.getLiquidPath(size, totalFillLevel);
    final pathMetrics = liquidPath.computeMetrics();
    
    if (pathMetrics.isEmpty) return;
    
    // Find the top edge of the liquid
    final metric = pathMetrics.first;
    final topPoints = <Offset>[];
    
    // Sample points along the top edge
    for (double t = 0.2; t <= 0.8; t += 0.1) {
      final tangent = metric.getTangentForOffset(metric.length * t);
      if (tangent != null) {
        topPoints.add(tangent.position);
      }
    }
    
    if (topPoints.length < 2) return;
    
    // Draw meniscus curve
    final meniscusPath = Path();
    meniscusPath.moveTo(topPoints.first.dx, topPoints.first.dy);
    
    for (int i = 1; i < topPoints.length; i++) {
      final point = topPoints[i];
      final prevPoint = topPoints[i - 1];
      
      // Create slight curve for meniscus effect
      final controlPoint = Offset(
        (prevPoint.dx + point.dx) / 2,
        math.min(prevPoint.dy, point.dy) - 2,
      );
      
      meniscusPath.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        point.dx,
        point.dy,
      );
    }
    
    final meniscusPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(meniscusPath, meniscusPaint);
  }

  @override
  bool shouldRepaint(covariant LiquidFillPainter oldDelegate) {
    return oldDelegate.totalFillLevel != totalFillLevel ||
           oldDelegate.layers.length != layers.length ||
           oldDelegate.animationValue != animationValue ||
           _layersChanged(oldDelegate.layers);
  }

  /// Check if layers have changed
  bool _layersChanged(List<LiquidLayer> oldLayers) {
    if (oldLayers.length != layers.length) return true;
    
    for (int i = 0; i < layers.length; i++) {
      final oldLayer = oldLayers[i];
      final newLayer = layers[i];
      
      if (oldLayer.color != newLayer.color ||
          oldLayer.thickness != newLayer.thickness ||
          oldLayer.opacity != newLayer.opacity ||
          oldLayer.isTranslucent != newLayer.isTranslucent) {
        return true;
      }
    }
    
    return false;
  }
}

/// Position information for a liquid layer
class LayerPosition {
  const LayerPosition({
    required this.fillLevel,
    required this.bottomOffset,
    required this.topOffset,
  });

  /// Fill level for this layer (0.0 to 1.0)
  final double fillLevel;
  
  /// Bottom offset from glass bottom (0.0 to 1.0)
  final double bottomOffset;
  
  /// Top offset from glass bottom (0.0 to 1.0)
  final double topOffset;
}

/// Predefined liquid layer combinations for common cocktails
class LiquidPresets {
  static const margarita = [
    LiquidLayer(
      color: Color(0xFFE6F3FF), // Clear tequila
      thickness: 0.6,
      opacity: 0.8,
      isTranslucent: true,
    ),
    LiquidLayer(
      color: Color(0xFF90EE90), // Lime juice
      thickness: 0.25,
      opacity: 0.9,
    ),
    LiquidLayer(
      color: Color(0xFFFFB347), // Triple sec
      thickness: 0.15,
      opacity: 0.7,
      isTranslucent: true,
    ),
  ];

  static const oldFashioned = [
    LiquidLayer(
      color: Color(0xFFD4A574), // Whiskey
      thickness: 0.85,
      opacity: 0.9,
    ),
    LiquidLayer(
      color: Color(0xFF8B4513), // Bitters
      thickness: 0.15,
      opacity: 0.6,
      isTranslucent: true,
    ),
  ];

  static const mojito = [
    LiquidLayer(
      color: Color(0xFFE6F3FF), // White rum
      thickness: 0.5,
      opacity: 0.8,
      isTranslucent: true,
    ),
    LiquidLayer(
      color: Color(0xFF90EE90), // Lime juice
      thickness: 0.2,
      opacity: 0.9,
    ),
    LiquidLayer(
      color: Color(0xFFE0FFE0), // Soda water
      thickness: 0.3,
      opacity: 0.5,
      isTranslucent: true,
    ),
  ];

  static const cosmopolitan = [
    LiquidLayer(
      color: Color(0xFFE6F3FF), // Vodka
      thickness: 0.4,
      opacity: 0.8,
      isTranslucent: true,
    ),
    LiquidLayer(
      color: Color(0xFFFFB6C1), // Cranberry juice
      thickness: 0.35,
      opacity: 0.9,
    ),
    LiquidLayer(
      color: Color(0xFF90EE90), // Lime juice
      thickness: 0.15,
      opacity: 0.8,
    ),
    LiquidLayer(
      color: Color(0xFFFFB347), // Triple sec
      thickness: 0.1,
      opacity: 0.7,
      isTranslucent: true,
    ),
  ];
}