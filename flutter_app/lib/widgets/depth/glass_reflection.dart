import 'package:flutter/material.dart';

/// Adds a subtle white gradient reflection over glassware widgets.
class GlassReflection extends StatelessWidget {
  const GlassReflection({required this.child, super.key});

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
