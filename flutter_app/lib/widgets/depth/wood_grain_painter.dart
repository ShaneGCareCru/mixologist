import 'package:flutter/material.dart';
import 'package:fast_noise/fast_noise.dart';

/// Painter that renders a subtle wood grain texture using fast Perlin noise.
/// Wrap in a [RepaintBoundary] and cache to an image for smooth scrolling.
class WoodGrainPainter extends CustomPainter {
  WoodGrainPainter({this.opacity = .03});

  final double opacity;
  final _noise = PerlinNoise(frequency: .015, seed: 1337);

  @override
  void paint(Canvas c, Size s) {
    final paint = Paint();
    for (int y = 0; y < s.height; y++) {
      final t = y / s.height;
      final base = Color.lerp(
        const Color(0xFFCFB995),
        const Color(0xFFF5F5DC),
        t,
      )!;
      final grain = (_noise.getNoise2(0, y.toDouble()) + 1) * .5;
      paint.color = base.withOpacity(opacity + grain * .02);
      c.drawLine(Offset(0, y.toDouble()), Offset(s.width, y.toDouble()), paint);
    }
  }

  @override
  bool shouldRepaint(covariant WoodGrainPainter old) => old.opacity != opacity;
}
