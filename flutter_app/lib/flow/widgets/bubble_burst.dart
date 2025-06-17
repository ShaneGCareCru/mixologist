import 'package:flutter/material.dart';
import 'package:particles_flutter/particles_flutter.dart';

/// Simple bubble burst particle effect used when an ingredient is checked.
class BubbleBurst extends StatelessWidget {
  final Color color;
  const BubbleBurst(this.color, {Key? key}) : super(key: key);

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
