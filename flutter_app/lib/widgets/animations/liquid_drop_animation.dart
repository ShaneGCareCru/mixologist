import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/haptic_service.dart';

/// DISABLED: Static liquid drop that immediately triggers callbacks without animation
/// Previously caused "Invalid curve endpoint at 0" errors
class LiquidDropAnimation extends StatefulWidget {
  final Offset startPosition;
  final Offset glassPosition;
  final Color liquidColor;
  final double dropSize;
  final Duration duration;
  final VoidCallback? onDropLanded;
  final VoidCallback? onAnimationComplete;
  
  const LiquidDropAnimation({
    super.key,
    required this.startPosition,
    required this.glassPosition,
    this.liquidColor = const Color(0xFFB8860B), // Amber from design philosophy
    this.dropSize = 12.0,
    this.duration = const Duration(milliseconds: 800),
    this.onDropLanded,
    this.onAnimationComplete,
  });

  @override
  State<LiquidDropAnimation> createState() => _LiquidDropAnimationState();
}

class _LiquidDropAnimationState extends State<LiquidDropAnimation> {
  @override
  void initState() {
    super.initState();
    
    // DISABLED: Immediately trigger callbacks without animation
    // This eliminates the bezier curve calculations that caused errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerCallbacks();
    });
  }
  
  void _triggerCallbacks() async {
    // Trigger haptic feedback
    await HapticService.instance.ingredientCheck();
    
    // Call the callbacks immediately
    widget.onDropLanded?.call();
    widget.onAnimationComplete?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    // DISABLED: Return empty container - all animation removed
    return const SizedBox.shrink();
  }
}

/// Widget that wraps a child and provides liquid drop animation on tap
class LiquidDropWrapper extends StatefulWidget {
  final Widget child;
  final Color liquidColor;
  final VoidCallback? onTap;
  final VoidCallback? onDropComplete;
  
  const LiquidDropWrapper({
    super.key,
    required this.child,
    this.liquidColor = const Color(0xFFB8860B),
    this.onTap,
    this.onDropComplete,
  });

  @override
  State<LiquidDropWrapper> createState() => _LiquidDropWrapperState();
}

class _LiquidDropWrapperState extends State<LiquidDropWrapper> {
  void _handleTap() async {
    // DISABLED: Simply trigger haptic and callbacks without animation
    await HapticService.instance.ingredientCheck();
    widget.onTap?.call();
    widget.onDropComplete?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: widget.child,
    );
  }
}