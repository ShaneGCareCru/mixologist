import 'package:flutter/material.dart';
import 'package:parallax_animation/parallax_animation.dart';

/// Wrapper around [ParallaxArea] that respects disabled animations.
class DepthArea extends StatelessWidget {
  const DepthArea({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final disable = MediaQuery.of(context).disableAnimations;
    if (disable) return child;
    return ParallaxArea(child: child);
  }
}

/// Layer that applies parallax and shadow based on its z factor.
class DepthLayer extends StatelessWidget {
  const DepthLayer({required this.z, required this.child, super.key});

  final double z; // 0.0 – 1.0
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final disable = MediaQuery.of(context).disableAnimations;
    final opacity = (0.20 + z * 0.10).clamp(0.0, 0.35);
    final content = Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(opacity),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (disable) return content;
    return ParallaxWidget(
      child: content,
      position: z,
    );
  }
}
