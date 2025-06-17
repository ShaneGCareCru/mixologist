import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated connector used between liquid drops.
class TubeConnector extends StatelessWidget {
  const TubeConnector({
    super.key,
    required this.l,
    required this.r,
  });

  final Color l;
  final Color r;

  @override
  Widget build(BuildContext context) {
    return Animate(
      onPlay: (controller) => controller.repeat(),
      effects: [MoveEffect(duration: 1.5.seconds, curve: Curves.easeInOut)],
      child: CustomPaint(
        painter: _TubePainter(shader: _tubeShader(l, r)),
        size: const Size(double.infinity, 16),
      ),
    );
  }
}

Shader _tubeShader(Color left, Color right) {
  return LinearGradient(colors: [left, right]).createShader(
    const Rect.fromLTWH(0, 0, 200, 16),
  );
}

class _TubePainter extends CustomPainter {
  final Shader shader;

  _TubePainter({required this.shader});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TubePainter oldDelegate) => oldDelegate.shader != shader;
}
