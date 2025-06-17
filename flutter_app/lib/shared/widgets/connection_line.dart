import 'package:flutter/material.dart';

class ConnectionLine extends StatelessWidget {
  final GlobalKey from;
  final List<GlobalKey> to;
  final bool active;

  const ConnectionLine({
    super.key,
    required this.from,
    required this.to,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    if (!active) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ConnectionPainter(from, to,
              Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }
}

class _ConnectionPainter extends CustomPainter {
  final GlobalKey from;
  final List<GlobalKey> to;
  final Color color;

  _ConnectionPainter(this.from, this.to, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final fromBox = from.currentContext?.findRenderObject() as RenderBox?;
    if (fromBox == null) return;
    final fromPos = fromBox.localToGlobal(
        fromBox.size.center(Offset.zero));
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final key in to) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final toPos = box.localToGlobal(
          box.size.center(Offset.zero));
      final path = Path();
      path.moveTo(fromPos.dx, fromPos.dy);
      final midX = (fromPos.dx + toPos.dx) / 2;
      path.cubicTo(midX, fromPos.dy, midX, toPos.dy, toPos.dx, toPos.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) => true;
}
