import 'package:flutter/material.dart';
import 'package:particles_flutter/particles_flutter.dart';

/// Simple particle effect shown when an ingredient is checked.
class BubbleBurst extends StatelessWidget {
  final Color color;
  const BubbleBurst(this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return CircularParticle(
      numberOfParticles: 5,
      particleColor: color,
      awayRadius: 80,
      maxParticleSize: 4,
      isRandSize: true,
      awayAnimationDuration: 600,
    );
  }
}
