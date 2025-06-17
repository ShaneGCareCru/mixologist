import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

/// Simple helper that wraps any widget in a glassmorphic container.
Widget frostedCard(Widget child) => GlassmorphicContainer(
      width: double.infinity,
      borderRadius: 24,
      blur: 20,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(.70), Colors.white10],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: 0.6,
      child: child,
    );
