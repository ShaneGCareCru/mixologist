import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'ambient_animation_controller.dart';

/// DISABLED: Static garnish widget without rotation to prevent curve errors
class RotatingGarnish extends StatefulWidget {
  const RotatingGarnish({
    super.key,
    required this.child,
    this.maxRotation = 3.0,
    this.duration = const Duration(seconds: 4),
    this.curve = Curves.easeInOut,
    this.randomVariation = true,
    this.hoverSensitive = true,
    this.enabled = true,
  });

  /// The garnish widget to rotate
  final Widget child;
  
  /// Maximum rotation in degrees (±)
  final double maxRotation;
  
  /// Duration of one complete rotation cycle
  final Duration duration;
  
  /// Animation curve for rotation
  final Curve curve;
  
  /// Whether to add random variation to timing
  final bool randomVariation;
  
  /// Whether to respond to hover interactions
  final bool hoverSensitive;
  
  /// Whether rotation is enabled
  final bool enabled;

  @override
  State<RotatingGarnish> createState() => _RotatingGarnishState();
}

class _RotatingGarnishState extends State<RotatingGarnish> {
  // DISABLED: No animation controllers to prevent curve errors
  
  @override
  Widget build(BuildContext context) {
    // DISABLED: Static garnish without rotation
    return widget.child;
  }
}

/// DISABLED: Multi-garnish widget without coordinated rotation
class RotatingGarnishGroup extends StatefulWidget {
  const RotatingGarnishGroup({
    super.key,
    required this.children,
    this.synchronization = 0.5,
    this.maxRotation = 2.0,
    this.staggerDelay = const Duration(milliseconds: 200),
    this.enabled = true,
  });

  final List<Widget> children;
  final double synchronization; // 0.0 = independent, 1.0 = synchronized
  final double maxRotation;
  final Duration staggerDelay;
  final bool enabled;

  @override
  State<RotatingGarnishGroup> createState() => _RotatingGarnishGroupState();
}

class _RotatingGarnishGroupState extends State<RotatingGarnishGroup> {
  @override
  Widget build(BuildContext context) {
    // DISABLED: Static garnish group without coordinated rotation
    return Column(
      children: widget.children.map((child) => 
        RotatingGarnish(
          child: child,
          enabled: false, // All disabled
        )
      ).toList(),
    );
  }
}

/// DISABLED: Smart garnish widget without adaptive rotation
class SmartRotatingGarnish extends StatefulWidget {
  const SmartRotatingGarnish({
    super.key,
    required this.child,
    this.intensity = 1.0,
    this.enabled = true,
  });

  final Widget child;
  final double intensity; // 0.0 to 2.0
  final bool enabled;

  @override
  State<SmartRotatingGarnish> createState() => _SmartRotatingGarnishState();
}

class _SmartRotatingGarnishState extends State<SmartRotatingGarnish> {
  @override
  Widget build(BuildContext context) {
    // DISABLED: Static smart garnish without adaptive rotation
    return widget.child;
  }
}