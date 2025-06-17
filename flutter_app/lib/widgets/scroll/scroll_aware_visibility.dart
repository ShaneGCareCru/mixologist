import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

/// Scroll-aware visibility widget that tracks scroll position and fades elements
/// based on visibility with RepaintBoundary optimization and parallax options
class ScrollAwareVisibility extends StatefulWidget {
  final Widget child;
  final double visibilityThreshold;
  final bool enableParallax;
  final double parallaxFactor;
  final bool optimizeWithRepaintBoundary;
  final Duration fadeDuration;
  final Curve fadeCurve;
  final ScrollDirection? trackDirection;
  final VoidCallback? onVisibilityChanged;
  final bool startVisible;
  
  const ScrollAwareVisibility({
    super.key,
    required this.child,
    this.visibilityThreshold = 0.5,
    this.enableParallax = false,
    this.parallaxFactor = 0.3,
    this.optimizeWithRepaintBoundary = true,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.fadeCurve = Curves.easeInOut,
    this.trackDirection,
    this.onVisibilityChanged,
    this.startVisible = true,
  });

  @override
  State<ScrollAwareVisibility> createState() => _ScrollAwareVisibilityState();
}

class _ScrollAwareVisibilityState extends State<ScrollAwareVisibility>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  ScrollController? _scrollController;
  double _visibilityRatio = 0.0;
  double _scrollOffset = 0.0;
  bool _isVisible = false;
  bool _lastVisibility = false;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: widget.fadeDuration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: widget.fadeCurve,
    ));
    
    _isVisible = widget.startVisible;
    if (_isVisible) {
      _fadeController.value = 1.0;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findScrollController();
    });
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController?.removeListener(_handleScroll);
    super.dispose();
  }
  
  void _findScrollController() {
    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState != null) {
      _scrollController = scrollableState.widget.controller ?? 
                        PrimaryScrollController.maybeOf(context);
      _scrollController?.addListener(_handleScroll);
      _updateVisibility();
    }
  }
  
  void _handleScroll() {
    if (_scrollController != null) {
      _scrollOffset = _scrollController!.offset;
      _updateVisibility();
    }
  }
  
  void _updateVisibility() {
    if (!mounted) return;
    
    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;
    
    final renderBox = renderObject as RenderBox;
    final scrollableRenderObject = _scrollController?.position.context.storageContext.findRenderObject();
    
    if (scrollableRenderObject == null) return;
    
    final scrollableRenderBox = scrollableRenderObject as RenderBox;
    
    // Get the position of this widget relative to the scrollable
    final offset = renderBox.localToGlobal(Offset.zero, ancestor: scrollableRenderBox);
    final childRect = offset & renderBox.size;
    
    final scrollableRect = Offset.zero & scrollableRenderBox.size;
    
    // Calculate visibility ratio
    final intersection = childRect.intersect(scrollableRect);
    final childArea = childRect.width * childRect.height;
    
    if (childArea > 0) {
      final intersectionArea = intersection.width * intersection.height;
      _visibilityRatio = intersectionArea / childArea;
    } else {
      _visibilityRatio = 0.0;
    }
    
    // Check if direction matters
    bool shouldBeVisible = _visibilityRatio >= widget.visibilityThreshold;
    
    if (widget.trackDirection != null) {
      final scrollDirection = _scrollController!.position.userScrollDirection;
      if (widget.trackDirection == ScrollDirection.forward && 
          scrollDirection == ScrollDirection.reverse) {
        shouldBeVisible = false;
      } else if (widget.trackDirection == ScrollDirection.reverse && 
                 scrollDirection == ScrollDirection.forward) {
        shouldBeVisible = false;
      }
    }
    
    if (_isVisible != shouldBeVisible) {
      setState(() {
        _isVisible = shouldBeVisible;
      });
      
      if (_isVisible) {
        _fadeController.forward();
      } else {
        _fadeController.reverse();
      }
      
      // Notify visibility change
      if (_lastVisibility != _isVisible) {
        _lastVisibility = _isVisible;
        widget.onVisibilityChanged?.call();
      }
    }
  }
  
  Widget _buildParallaxChild() {
    if (!widget.enableParallax) {
      return widget.child;
    }
    
    // Calculate parallax offset based on scroll position
    final parallaxOffset = _scrollOffset * widget.parallaxFactor;
    
    return Transform.translate(
      offset: Offset(0, parallaxOffset),
      child: widget.child,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: _buildParallaxChild(),
        );
      },
    );
    
    if (widget.optimizeWithRepaintBoundary) {
      child = RepaintBoundary(child: child);
    }
    
    return child;
  }
}

/// Scroll-aware container that provides additional scroll information
class ScrollAwareContainer extends StatefulWidget {
  final Widget child;
  final ValueChanged<ScrollInfo>? onScrollChanged;
  final double parallaxStrength;
  final bool enableBlur;
  final double maxBlurRadius;
  
  const ScrollAwareContainer({
    super.key,
    required this.child,
    this.onScrollChanged,
    this.parallaxStrength = 0.5,
    this.enableBlur = false,
    this.maxBlurRadius = 10.0,
  });

  @override
  State<ScrollAwareContainer> createState() => _ScrollAwareContainerState();
}

class _ScrollAwareContainerState extends State<ScrollAwareContainer> {
  ScrollController? _scrollController;
  ScrollInfo _scrollInfo = ScrollInfo.initial();
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findScrollController();
    });
  }
  
  @override
  void dispose() {
    _scrollController?.removeListener(_handleScroll);
    super.dispose();
  }
  
  void _findScrollController() {
    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState != null) {
      _scrollController = scrollableState.widget.controller ?? 
                        PrimaryScrollController.maybeOf(context);
      _scrollController?.addListener(_handleScroll);
    }
  }
  
  void _handleScroll() {
    if (_scrollController == null || !mounted) return;
    
    final position = _scrollController!.position;
    final newScrollInfo = ScrollInfo(
      offset: position.pixels,
      maxScrollExtent: position.maxScrollExtent,
      scrollDirection: position.userScrollDirection,
      velocity: position.activity?.velocity ?? 0.0,
      progress: position.maxScrollExtent > 0 
          ? (position.pixels / position.maxScrollExtent).clamp(0.0, 1.0)
          : 0.0,
    );
    
    setState(() {
      _scrollInfo = newScrollInfo;
    });
    
    widget.onScrollChanged?.call(_scrollInfo);
  }
  
  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    
    // Apply parallax effect
    if (widget.parallaxStrength > 0) {
      final parallaxOffset = _scrollInfo.offset * widget.parallaxStrength;
      child = Transform.translate(
        offset: Offset(0, -parallaxOffset),
        child: child,
      );
    }
    
    // Apply blur effect based on scroll velocity
    if (widget.enableBlur && _scrollInfo.velocity.abs() > 100) {
      final blurRadius = ((_scrollInfo.velocity.abs() / 1000) * widget.maxBlurRadius)
          .clamp(0.0, widget.maxBlurRadius);
      
      // Note: In a real app, you'd use ImageFilter.blur here
      child = Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(blurRadius / widget.maxBlurRadius * 0.1),
        ),
        child: child,
      );
    }
    
    return child;
  }
}

/// Data model for scroll information
class ScrollInfo {
  final double offset;
  final double maxScrollExtent;
  final ScrollDirection scrollDirection;
  final double velocity;
  final double progress;
  
  const ScrollInfo({
    required this.offset,
    required this.maxScrollExtent,
    required this.scrollDirection,
    required this.velocity,
    required this.progress,
  });
  
  factory ScrollInfo.initial() {
    return const ScrollInfo(
      offset: 0.0,
      maxScrollExtent: 0.0,
      scrollDirection: ScrollDirection.idle,
      velocity: 0.0,
      progress: 0.0,
    );
  }
  
  bool get isScrollingUp => scrollDirection == ScrollDirection.forward;
  bool get isScrollingDown => ScrollDirection.reverse == scrollDirection;
  bool get isIdle => scrollDirection == ScrollDirection.idle;
  bool get isFastScrolling => velocity.abs() > 500;
}

/// Widget that becomes sticky when scrolled past a certain point
class StickyScrollWidget extends StatefulWidget {
  final Widget child;
  final double stickyOffset;
  final bool enableShadow;
  final Color? backgroundColor;
  final Duration animationDuration;
  
  const StickyScrollWidget({
    super.key,
    required this.child,
    this.stickyOffset = 100.0,
    this.enableShadow = true,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<StickyScrollWidget> createState() => _StickyScrollWidgetState();
}

class _StickyScrollWidgetState extends State<StickyScrollWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shadowAnimation;
  
  ScrollController? _scrollController;
  bool _isSticky = false;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _shadowAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findScrollController();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _scrollController?.removeListener(_handleScroll);
    super.dispose();
  }
  
  void _findScrollController() {
    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState != null) {
      _scrollController = scrollableState.widget.controller ?? 
                        PrimaryScrollController.maybeOf(context);
      _scrollController?.addListener(_handleScroll);
    }
  }
  
  void _handleScroll() {
    if (_scrollController == null || !mounted) return;
    
    final shouldBeSticky = _scrollController!.offset >= widget.stickyOffset;
    
    if (_isSticky != shouldBeSticky) {
      setState(() {
        _isSticky = shouldBeSticky;
      });
      
      if (_isSticky) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shadowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
            boxShadow: widget.enableShadow && _isSticky
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: _shadowAnimation.value,
                      offset: Offset(0, _shadowAnimation.value / 2),
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Scroll-triggered animation widget
class ScrollTriggeredAnimation extends StatefulWidget {
  final Widget child;
  final double triggerOffset;
  final Duration animationDuration;
  final Curve animationCurve;
  final AnimationType animationType;
  final Offset? slideOffset;
  final double? scaleFrom;
  final double? rotateDegrees;
  
  const ScrollTriggeredAnimation({
    super.key,
    required this.child,
    this.triggerOffset = 100.0,
    this.animationDuration = const Duration(milliseconds: 600),
    this.animationCurve = Curves.easeOut,
    this.animationType = AnimationType.fadeIn,
    this.slideOffset,
    this.scaleFrom,
    this.rotateDegrees,
  });

  @override
  State<ScrollTriggeredAnimation> createState() => _ScrollTriggeredAnimationState();
}

class _ScrollTriggeredAnimationState extends State<ScrollTriggeredAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  ScrollController? _scrollController;
  bool _hasTriggered = false;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findScrollController();
      _checkTrigger();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _scrollController?.removeListener(_handleScroll);
    super.dispose();
  }
  
  void _findScrollController() {
    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState != null) {
      _scrollController = scrollableState.widget.controller ?? 
                        PrimaryScrollController.maybeOf(context);
      _scrollController?.addListener(_handleScroll);
    }
  }
  
  void _handleScroll() {
    _checkTrigger();
  }
  
  void _checkTrigger() {
    if (_hasTriggered || _scrollController == null || !mounted) return;
    
    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;
    
    final renderBox = renderObject as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Trigger when widget comes into view
    if (position.dy <= screenHeight - widget.triggerOffset) {
      setState(() {
        _hasTriggered = true;
      });
      _controller.forward();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        Widget animatedChild = widget.child;
        
        switch (widget.animationType) {
          case AnimationType.fadeIn:
            animatedChild = Opacity(
              opacity: _animation.value,
              child: animatedChild,
            );
            break;
            
          case AnimationType.slideIn:
            final offset = widget.slideOffset ?? const Offset(0, 50);
            animatedChild = Transform.translate(
              offset: Offset(
                offset.dx * (1 - _animation.value),
                offset.dy * (1 - _animation.value),
              ),
              child: animatedChild,
            );
            break;
            
          case AnimationType.scaleIn:
            final scale = widget.scaleFrom ?? 0.0;
            animatedChild = Transform.scale(
              scale: scale + (1.0 - scale) * _animation.value,
              child: animatedChild,
            );
            break;
            
          case AnimationType.rotateIn:
            final degrees = widget.rotateDegrees ?? 180.0;
            animatedChild = Transform.rotate(
              angle: (degrees * (1 - _animation.value)) * pi / 180,
              child: animatedChild,
            );
            break;
            
          case AnimationType.slideAndFade:
            final offset = widget.slideOffset ?? const Offset(0, 30);
            animatedChild = Opacity(
              opacity: _animation.value,
              child: Transform.translate(
                offset: Offset(
                  offset.dx * (1 - _animation.value),
                  offset.dy * (1 - _animation.value),
                ),
                child: animatedChild,
              ),
            );
            break;
        }
        
        return animatedChild;
      },
    );
  }
}

/// Animation types for scroll-triggered animations
enum AnimationType {
  fadeIn,
  slideIn,
  scaleIn,
  rotateIn,
  slideAndFade,
}

/// Extension methods for easy scroll-aware widgets
extension ScrollAwareExtensions on Widget {
  /// Make widget scroll-aware with visibility tracking
  Widget scrollAware({
    double visibilityThreshold = 0.5,
    bool enableParallax = false,
    double parallaxFactor = 0.3,
    VoidCallback? onVisibilityChanged,
  }) {
    return ScrollAwareVisibility(
      visibilityThreshold: visibilityThreshold,
      enableParallax: enableParallax,
      parallaxFactor: parallaxFactor,
      onVisibilityChanged: onVisibilityChanged,
      child: this,
    );
  }
  
  /// Make widget sticky on scroll
  Widget sticky({
    double stickyOffset = 100.0,
    bool enableShadow = true,
    Color? backgroundColor,
  }) {
    return StickyScrollWidget(
      stickyOffset: stickyOffset,
      enableShadow: enableShadow,
      backgroundColor: backgroundColor,
      child: this,
    );
  }
  
  /// Add scroll-triggered animation
  Widget animateOnScroll({
    double triggerOffset = 100.0,
    Duration animationDuration = const Duration(milliseconds: 600),
    AnimationType animationType = AnimationType.fadeIn,
    Offset? slideOffset,
    double? scaleFrom,
    double? rotateDegrees,
  }) {
    return ScrollTriggeredAnimation(
      triggerOffset: triggerOffset,
      animationDuration: animationDuration,
      animationType: animationType,
      slideOffset: slideOffset,
      scaleFrom: scaleFrom,
      rotateDegrees: rotateDegrees,
      child: this,
    );
  }
}