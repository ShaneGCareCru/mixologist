import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

/// A teardrop shaped liquid progress indicator used to visualize ingredient
/// completion. The fill level rises from bottom to top and the color can be
/// customized per ingredient category.
class LiquidDrop extends StatelessWidget {
  const LiquidDrop({Key? key, required this.value, required this.color}) : super(key: key);

  /// Fill value from 0 to 1.
  final double value;

  /// Color of the liquid.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TeardropClipper(),
      child: Container(
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(0, 1),
          )
        ]),
        child: LiquidCircularProgressIndicator(
          value: value.clamp(0.0, 1.0),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          backgroundColor: color.withOpacity(0.15),
          direction: Axis.vertical,
        ),
      ),
    );
  }
}

/// Simple teardrop clipper used to shape the progress indicator.
class _TeardropClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.6);
    path.arcToPoint(
      Offset(0, size.height * 0.6),
      radius: Radius.circular(size.width),
      clockwise: false,
    );
    path.quadraticBezierTo(0, 0, size.width / 2, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant _TeardropClipper oldClipper) => false;
}
