import 'package:flutter/material.dart';

/// Provides a single ticker for all flow related animations.
class FlowAnimationController {
  FlowAnimationController(this.vsync)
      : controller = AnimationController.unbounded(vsync: vsync);

  final TickerProvider vsync;
  final AnimationController controller;

  /// Helper to stagger animations.
  Duration stagger(int milliseconds) => Duration(milliseconds: milliseconds);

  void dispose() {
    controller.dispose();
  }
}
