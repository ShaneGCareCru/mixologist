/// Ambient Animation System
/// 
/// This library provides a comprehensive ambient animation system for cocktail apps
/// with subtle, life-like movements that enhance the user experience without being distracting.
/// 
/// ## Core Components:
/// 
/// - [AmbientAnimationController]: Centralized animation management and lifecycle control
/// - [RotatingGarnish]: Subtle rotation animations for garnishes like lime wheels and cherries
/// - [LiquidSwirlEffect]: Natural liquid movement with sine wave distortions
/// - [FlutteringLeaf]: Wind-like flutter effects for mint leaves and herbs
/// - [GlintingIce]: Sparkle and glint effects for ice cubes
/// - [AnimationPerformanceMonitor]: Performance monitoring and automatic optimization
/// 
/// ## Usage:
/// 
/// ```dart
/// // Wrap your app with the ambient animation provider
/// AmbientAnimationProvider(
///   child: MaterialApp(
///     home: Scaffold(
///       body: Stack(
///         children: [
///           // Your cocktail glass
///           GlassVisualization(...),
///           
///           // Add ambient animations
///           RotatingGarnish(
///             child: LimeWheelWidget(),
///             maxRotation: 3.0,
///           ),
///           
///           LiquidSwirlEffect(
///             glassShape: glassShape,
///             fillLevel: 0.7,
///           ),
///           
///           FlutteringLeaf(
///             leafAssetPath: 'assets/mint_leaf.png',
///           ),
///           
///           GlintingIce(
///             sparklePoints: iceSparklePoints,
///           ),
///         ],
///       ),
///     ),
///   ),
/// )
/// 
/// // Enable performance monitoring in debug builds
/// AnimationPerformanceMonitor.instance.startMonitoring();
/// ```
/// 
/// ## Performance Considerations:
/// 
/// - All animations automatically pause when the app goes to background
/// - Performance monitoring can automatically disable animations on low-end devices
/// - Respects system accessibility settings for reduced motion
/// - Uses efficient CustomPainter implementations for complex effects
/// - Shared animation controllers minimize resource usage
/// 
/// ## Accessibility:
/// 
/// - Automatically disables complex animations when `MediaQuery.disableAnimations` is true
/// - Provides simple fade alternatives for users with motion sensitivity
/// - Includes proper semantic labels for screen readers

library ambient_animations;

// Core animation system
export 'ambient_animation_controller.dart';
export 'animation_performance_monitor.dart';

// Individual animation components
export 'rotating_garnish.dart';
export 'liquid_swirl_painter.dart';
export 'fluttering_leaf.dart';
export 'glinting_ice.dart';

// Re-export commonly used Flutter types
export 'package:flutter/material.dart' show 
    Widget, 
    StatefulWidget, 
    StatelessWidget,
    AnimationController,
    Animation,
    Curve,
    Curves,
    Duration,
    Size,
    Offset,
    Color,
    Colors;