import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

/// Teardrop shaped liquid progress indicator used in the ingredient flow UI.
class LiquidDrop extends StatelessWidget {
  const LiquidDrop({
    super.key,
    required this.value,
    required this.color,
  });

  /// Fill percentage from 0-1.
  final double value;

  /// Primary color of the drop.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TeardropClipper(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Faint inner shadow for depth
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: LiquidCircularProgressIndicator(
          value: value,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          backgroundColor: color.withOpacity(0.15),
          direction: Axis.vertical,
        ),
      ),
    );
  }
}

/// Simple teardrop clip path used to clip the progress indicator.
class _TeardropClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.6);
    path.arcToPoint(
      Offset(0, size.height * 0.6),
      radius: Radius.circular(size.width / 2),
      clockwise: false,
    );
    path.quadraticBezierTo(0, 0, size.width / 2, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
