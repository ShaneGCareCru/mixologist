import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

/// Collection of Material Motion transition widgets for the Mixologist app.
/// 
/// These transitions follow Material Design guidelines and provide:
/// - Container Transform: for expanding/shrinking content
/// - Shared Axis: for sequential content changes
/// - Fade Through: for replacing content at the same level
/// - Fade: for simple content changes

class MotionTransitions {
  /// Container transform animation for expanding cards to full screen
  static Widget containerTransform({
    required Widget closedChild,
    required Widget Function(BuildContext) openBuilder,
    Color? closedColor,
    Color? openColor,
    double? borderRadius,
    VoidCallback? onClosed,
  }) {
    return OpenContainer(
      closedBuilder: (context, action) => closedChild,
      openBuilder: (context, action) => openBuilder(context),
      closedColor: closedColor ?? Colors.transparent,
      openColor: openColor ?? Colors.white,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
      ),
      closedElevation: 0,
      openElevation: 0,
      onClosed: onClosed != null ? (data) => onClosed() : null,
      transitionDuration: const Duration(milliseconds: 300),
      transitionType: ContainerTransitionType.fade,
    );
  }

  /// Shared axis transition for page navigation
  static Widget sharedAxisTransition({
    required Widget child,
    required SharedAxisTransitionType transitionType,
    bool reverse = false,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageTransitionSwitcher(
      duration: duration,
      reverse: reverse,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Fade through transition for content replacement
  static Widget fadeThrough({
    required Widget child,
    Duration duration = const Duration(milliseconds: 210),
  }) {
    return PageTransitionSwitcher(
      duration: duration,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Simple fade transition
  static Widget fade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 150),
  }) {
    return PageTransitionSwitcher(
      duration: duration,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeTransition(
          opacity: primaryAnimation,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Custom page route with shared axis transition
  static PageRouteBuilder sharedAxisPageRoute({
    required Widget page,
    SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
    Duration duration = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
    );
  }

  /// Custom page route with fade through transition
  static PageRouteBuilder fadeThroughPageRoute({
    required Widget page,
    Duration duration = const Duration(milliseconds: 210),
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }
}

/// Hero widget wrapper for cocktail recipe cards
class CocktailHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final Widget Function(BuildContext)? destinationBuilder;

  const CocktailHero({
    super.key,
    required this.tag,
    required this.child,
    this.destinationBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (destinationBuilder != null) {
      return MotionTransitions.containerTransform(
        closedChild: Hero(
          tag: tag,
          child: child,
        ),
        openBuilder: destinationBuilder!,
      );
    }

    return Hero(
      tag: tag,
      child: child,
    );
  }
}

/// Animated floating action button with motion transitions
class MotionFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const MotionFAB({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        child: icon,
      ),
    );
  }
}