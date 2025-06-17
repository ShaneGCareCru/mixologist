import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:perlin_noise_dart/perlin_noise_dart.dart';
import 'package:shadows/shadows.dart';
import 'package:parallax_animation/parallax_animation.dart';

/// Wood grain background painter using Perlin noise.
class WoodGrainPainter extends CustomPainter {
  WoodGrainPainter({this.opacity = .03});
  final double opacity;

  @override
  void paint(Canvas c, Size s) {
    final noise = PerlinNoise();
    final paint = Paint();
    for (int y = 0; y < s.height; y++) {
      final t = y / s.height;
      paint.color = Color.lerp(
              const Color(0xFFCFB995), const Color(0xFFF5F5DC), t)!
          .withOpacity(opacity + noise.noise2D(0, y * .02) * .01);
      c.drawLine(Offset(0, y.toDouble()), Offset(s.width, y.toDouble()), paint);
    }
  }

  @override
  bool shouldRepaint(covariant WoodGrainPainter old) => false;
}

/// Elevation wrapper that applies material shadows from the [shadows] package.
class ElevatedCard extends StatelessWidget {
  const ElevatedCard({super.key, required this.level, required this.child});

  final int level; // 0–5
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          boxShadow: Shadows.material(level.toDouble()),
        ),
        child: child,
      );
}

/// Widget that adds a subtle reflection overlay to its child.
class GlassReflection extends StatelessWidget {
  const GlassReflection({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(children: [
        child,
        IgnorePointer(
          child: Transform(
            alignment: Alignment.topCenter,
            transform: Matrix4.identity()
              ..setEntry(3, 2, .001)
              ..rotateX(.35),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white60, Colors.white10],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ]);
}

/// Glassmorphic frosted card helper.
Widget frostedCard(Widget child) => GlassmorphicContainer(
      width: double.infinity,
      height: 220,
      borderRadius: 24,
      blur: 20,
      border: 0.6,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(.70), Colors.white10],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: const LinearGradient(
        colors: [Colors.white24, Colors.white24],
      ),
      child: child,
    );

/// Extension for layering widgets with wood background and glass effect.
extension DepthDecorations on Widget {
  Widget layerBack() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F5DC), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomPaint(painter: WoodGrainPainter(opacity: .03), child: this),
      );

  Widget glassify() => GlassmorphicContainer(
        blur: 20,
        borderRadius: 16,
        border: 0.6,
        linearGradient: LinearGradient(
          colors: [Colors.white.withOpacity(.70), Colors.white10],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: this,
      );
}

/// Controls depth-related animations such as parallax and shadow intensity.
class DepthController extends ChangeNotifier {
  DepthController({this.disableMotion = false});

  bool disableMotion;
  double scrollOffset = 0.0;

  void updateScroll(double offset) {
    scrollOffset = offset;
    if (!disableMotion) notifyListeners();
  }
}

final depthControllerProvider = ChangeNotifierProvider<DepthController>((ref) {
  return DepthController();
});
