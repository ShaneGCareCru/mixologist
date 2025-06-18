import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

/// Progressive blur widget that increases blur intensity based on scroll depth
/// Creates depth perception and focus hierarchy during scrolling
class ProgressiveBlur extends StatefulWidget {
  final Widget child;
  final double maxBlur; // Maximum blur radius in pixels
  final ScrollController? controller;
  final double blurStart; // Scroll position where blur starts
  final double blurEnd; // Scroll position where max blur is reached
  final Curve blurCurve;
  final bool enablePerformanceMode;
  final BlurDirection direction;
  final bool clipBehavior;
  final Color? overlayColor;
  final double overlayOpacity;
  
  const ProgressiveBlur({
    super.key,
    required this.child,
    this.maxBlur = 10.0,
    this.controller,
    this.blurStart = 0.0,
    this.blurEnd = 200.0,
    this.blurCurve = Curves.easeOut,
    this.enablePerformanceMode = false,
    this.direction = BlurDirection.both,
    this.clipBehavior = true,
    this.overlayColor,
    this.overlayOpacity = 0.1,
  });

  @override
  State<ProgressiveBlur> createState() => _ProgressiveBlurState();
}

class _ProgressiveBlurState extends State<ProgressiveBlur> {
  ScrollController? _controller;
  double _currentBlur = 0.0;
  bool _isDisposed = false;
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollListener();
    });
  }
  
  void _setupScrollListener() {
    _controller = widget.controller ?? PrimaryScrollController.maybeOf(context);
    
    if (_controller != null) {
      _controller!.addListener(_updateBlur);
      _updateBlur();
    }
  }
  
  @override
  void didUpdateWidget(ProgressiveBlur oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.controller != widget.controller) {
      _controller?.removeListener(_updateBlur);
      _setupScrollListener();
    }
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    _controller?.removeListener(_updateBlur);
    super.dispose();
  }
  
  void _updateBlur() {
    if (_isDisposed || !mounted || _controller == null) return;
    
    final scrollPosition = _controller!.offset;
    
    // Calculate blur progress (0.0 to 1.0)
    double blurProgress = 0.0;
    
    if (scrollPosition > widget.blurStart) {
      final blurRange = widget.blurEnd - widget.blurStart;
      if (blurRange > 0) {
        blurProgress = ((scrollPosition - widget.blurStart) / blurRange).clamp(0.0, 1.0);
      }
    }
    
    // Apply curve to blur progress
    final curvedProgress = widget.blurCurve.transform(blurProgress);
    final newBlur = widget.maxBlur * curvedProgress;
    
    // Only update if blur changed significantly
    if ((newBlur - _currentBlur).abs() > 0.1) {
      setState(() {
        _currentBlur = newBlur;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_currentBlur <= 0.1) {
      return widget.child;
    }
    
    Widget blurredChild = widget.child;
    
    // Apply blur effect
    if (widget.enablePerformanceMode) {
      // Performance mode: simplified blur
      blurredChild = _buildPerformanceBlur(blurredChild);
    } else {
      // Standard mode: high-quality blur
      blurredChild = _buildStandardBlur(blurredChild);
    }
    
    // Apply overlay if specified
    if (widget.overlayColor != null) {
      blurredChild = _buildWithOverlay(blurredChild);
    }
    
    return blurredChild;
  }
  
  Widget _buildStandardBlur(Widget child) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: widget.direction == BlurDirection.vertical ? 0 : _currentBlur,
        sigmaY: widget.direction == BlurDirection.horizontal ? 0 : _currentBlur,
      ),
      child: widget.clipBehavior
          ? ClipRect(child: child)
          : child,
    );
  }
  
  Widget _buildPerformanceBlur(Widget child) {
    // Use opacity-based "blur" for better performance
    final opacity = (1.0 - (_currentBlur / widget.maxBlur * 0.5)).clamp(0.3, 1.0);
    
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: 1.0 + (_currentBlur / widget.maxBlur * 0.02),
        child: child,
      ),
    );
  }
  
  Widget _buildWithOverlay(Widget child) {
    final overlayOpacity = widget.overlayOpacity * (_currentBlur / widget.maxBlur);
    
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Container(
            color: widget.overlayColor!.withOpacity(overlayOpacity),
          ),
        ),
      ],
    );
  }
}

/// Direction for blur application
enum BlurDirection {
  horizontal,
  vertical,
  both,
}

/// Smart blur container that adapts blur based on element visibility
class SmartBlurContainer extends StatefulWidget {
  final Widget child;
  final double maxBlur;
  final ScrollController? controller;
  final bool blurWhenOffscreen;
  final bool blurWhenInBackground;
  final double visibilityThreshold;
  final Duration animationDuration;
  
  const SmartBlurContainer({
    super.key,
    required this.child,
    this.maxBlur = 8.0,
    this.controller,
    this.blurWhenOffscreen = true,
    this.blurWhenInBackground = false,
    this.visibilityThreshold = 0.5,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<SmartBlurContainer> createState() => _SmartBlurContainerState();
}

class _SmartBlurContainerState extends State<SmartBlurContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _blurAnimation;
  
  ScrollController? _controller;
  double _visibility = 1.0;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: widget.maxBlur,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollListener();
    });
  }
  
  void _setupScrollListener() {
    _controller = widget.controller ?? PrimaryScrollController.maybeOf(context);
    
    if (_controller != null) {
      _controller!.addListener(_updateVisibility);
      _updateVisibility();
    }
  }
  
  @override
  void dispose() {
    _controller?.removeListener(_updateVisibility);
    _animationController.dispose();
    super.dispose();
  }
  
  void _updateVisibility() {
    if (!mounted) return;
    
    final renderObject = context.findRenderObject();
    if (renderObject == null) return;
    
    final renderBox = renderObject as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    final screenHeight = MediaQuery.of(context).size.height;
    final elementTop = position.dy;
    final elementBottom = position.dy + size.height;
    
    // Calculate visibility (0.0 = not visible, 1.0 = fully visible)
    double newVisibility = 0.0;
    
    if (elementBottom > 0 && elementTop < screenHeight) {
      final visibleTop = max(0.0, elementTop);
      final visibleBottom = min(screenHeight, elementBottom);
      final visibleHeight = visibleBottom - visibleTop;
      newVisibility = visibleHeight / size.height;
    }
    
    if ((newVisibility - _visibility).abs() > 0.1) {
      _visibility = newVisibility;
      
      bool shouldBlur = false;
      if (widget.blurWhenOffscreen && _visibility < widget.visibilityThreshold) {
        shouldBlur = true;
      }
      if (widget.blurWhenInBackground && _visibility < 1.0) {
        shouldBlur = true;
      }
      
      if (shouldBlur) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blurAnimation,
      builder: (context, child) {
        if (_blurAnimation.value <= 0.1) {
          return widget.child;
        }
        
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _blurAnimation.value,
            sigmaY: _blurAnimation.value,
          ),
          child: ClipRect(child: widget.child),
        );
      },
    );
  }
}

/// Depth-based blur for layered content
class DepthBlur extends StatelessWidget {
  final Widget child;
  final int depth; // 0 = foreground, higher = background
  final double maxDepth;
  final double blurPerDepth;
  final Color? tintColor;
  final double tintOpacity;
  
  const DepthBlur({
    super.key,
    required this.child,
    required this.depth,
    this.maxDepth = 5.0,
    this.blurPerDepth = 2.0,
    this.tintColor,
    this.tintOpacity = 0.1,
  });
  
  @override
  Widget build(BuildContext context) {
    final blurAmount = (depth / maxDepth * blurPerDepth).clamp(0.0, 20.0);
    
    if (blurAmount <= 0.1) {
      return child;
    }
    
    Widget blurredChild = BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: blurAmount,
        sigmaY: blurAmount,
      ),
      child: ClipRect(child: child),
    );
    
    // Apply depth tint
    if (tintColor != null && depth > 0) {
      final opacity = (depth / maxDepth * tintOpacity).clamp(0.0, 0.5);
      blurredChild = Stack(
        children: [
          blurredChild,
          Positioned.fill(
            child: Container(
              color: tintColor!.withOpacity(opacity),
            ),
          ),
        ],
      );
    }
    
    return blurredChild;
  }
}

/// Scroll-based focus blur that highlights the current item
class FocusBlur extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final double itemHeight;
  final double focusBlur;
  final double backgroundBlur;
  final int focusIndex;
  final ValueChanged<int>? onFocusChanged;
  
  const FocusBlur({
    super.key,
    required this.children,
    this.controller,
    required this.itemHeight,
    this.focusBlur = 0.0,
    this.backgroundBlur = 5.0,
    this.focusIndex = 0,
    this.onFocusChanged,
  });

  @override
  State<FocusBlur> createState() => _FocusBlurState();
}

class _FocusBlurState extends State<FocusBlur> {
  ScrollController? _controller;
  int _currentFocus = 0;
  
  @override
  void initState() {
    super.initState();
    _currentFocus = widget.focusIndex;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollListener();
    });
  }
  
  void _setupScrollListener() {
    _controller = widget.controller ?? PrimaryScrollController.maybeOf(context);
    
    if (_controller != null) {
      _controller!.addListener(_updateFocus);
    }
  }
  
  @override
  void dispose() {
    _controller?.removeListener(_updateFocus);
    super.dispose();
  }
  
  void _updateFocus() {
    if (!mounted || _controller == null) return;
    
    final scrollPosition = _controller!.offset;
    final newFocus = (scrollPosition / widget.itemHeight).round();
    final clampedFocus = newFocus.clamp(0, widget.children.length - 1);
    
    if (clampedFocus != _currentFocus) {
      setState(() {
        _currentFocus = clampedFocus;
      });
      widget.onFocusChanged?.call(_currentFocus);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final isFocused = index == _currentFocus;
        
        return SizedBox(
          height: widget.itemHeight,
          child: ProgressiveBlur(
            controller: _controller,
            maxBlur: isFocused ? widget.focusBlur : widget.backgroundBlur,
            blurStart: index * widget.itemHeight - widget.itemHeight / 2,
            blurEnd: index * widget.itemHeight + widget.itemHeight / 2,
            child: child,
          ),
        );
      }).toList(),
    );
  }
}

/// Performance monitoring for blur effects
class BlurPerformanceMonitor {
  static bool _performanceModeEnabled = false;
  static int _frameDrops = 0;
  static DateTime? _lastCheck;
  
  /// Enable performance monitoring
  static void enable() {
    _performanceModeEnabled = true;
  }
  
  /// Check if performance mode should be used
  static bool shouldUsePerformanceMode() {
    return _performanceModeEnabled && _frameDrops > 3;
  }
  
  /// Record performance metrics
  static void recordFrame(Duration frameDuration) {
    if (frameDuration.inMilliseconds > 16) { // >60fps
      _frameDrops++;
    } else if (_frameDrops > 0) {
      _frameDrops--;
    }
    
    _lastCheck = DateTime.now();
  }
  
  /// Reset performance counters
  static void reset() {
    _frameDrops = 0;
    _lastCheck = null;
  }
}

/// Utility class for blur presets
class BlurPresets {
  /// Subtle blur for slight depth
  static const double subtle = 2.0;
  
  /// Light blur for background elements
  static const double light = 5.0;
  
  /// Medium blur for out-of-focus content
  static const double medium = 10.0;
  
  /// Heavy blur for hidden content
  static const double heavy = 15.0;
  
  /// Maximum blur for completely obscured content
  static const double maximum = 25.0;
  
  /// Create cocktail-themed blur settings
  static ProgressiveBlur cocktailBackground({
    required Widget child,
    ScrollController? controller,
  }) {
    return ProgressiveBlur(
      child: child,
      controller: controller,
      maxBlur: medium,
      blurStart: 50,
      blurEnd: 200,
      overlayColor: const Color(0xFFB8860B),
      overlayOpacity: 0.05,
    );
  }
  
  /// Create ingredient focus blur
  static ProgressiveBlur ingredientFocus({
    required Widget child,
    ScrollController? controller,
    bool isActive = false,
  }) {
    return ProgressiveBlur(
      child: child,
      controller: controller,
      maxBlur: isActive ? 0 : light,
      blurCurve: Curves.easeInOut,
    );
  }
  
  /// Create method step blur
  static ProgressiveBlur methodStep({
    required Widget child,
    ScrollController? controller,
    bool isCurrentStep = false,
  }) {
    return ProgressiveBlur(
      child: child,
      controller: controller,
      maxBlur: isCurrentStep ? 0 : medium,
      overlayColor: isCurrentStep ? null : Colors.grey,
      overlayOpacity: 0.1,
    );
  }
}

/// Extension methods for easy blur integration
extension BlurExtensions on Widget {
  /// Add progressive blur to any widget
  Widget withProgressiveBlur({
    ScrollController? controller,
    double maxBlur = 10.0,
    double blurStart = 0.0,
    double blurEnd = 200.0,
  }) {
    return ProgressiveBlur(
      controller: controller,
      maxBlur: maxBlur,
      blurStart: blurStart,
      blurEnd: blurEnd,
      child: this,
    );
  }
  
  /// Add depth-based blur
  Widget withDepthBlur({
    required int depth,
    double maxDepth = 5.0,
    double blurPerDepth = 2.0,
  }) {
    return DepthBlur(
      depth: depth,
      maxDepth: maxDepth,
      blurPerDepth: blurPerDepth,
      child: this,
    );
  }
  
  /// Add smart visibility-based blur
  Widget withSmartBlur({
    ScrollController? controller,
    double maxBlur = 8.0,
    bool blurWhenOffscreen = true,
  }) {
    return SmartBlurContainer(
      controller: controller,
      maxBlur: maxBlur,
      blurWhenOffscreen: blurWhenOffscreen,
      child: this,
    );
  }
}