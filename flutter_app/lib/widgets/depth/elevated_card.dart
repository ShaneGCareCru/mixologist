import 'package:flutter/widgets.dart';
import 'package:shadows/shadows.dart';

/// Card container with soft elevation based on material shadow levels.
class ElevatedCard extends StatelessWidget {
  const ElevatedCard({
    super.key,
    required this.level,
    required this.child,
  });

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
