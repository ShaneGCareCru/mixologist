import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/haptic_service.dart';

/// Animated liquid drop that follows a bezier curve path from start to glass position
/// with gravity acceleration and splash effect on landing
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

class _LiquidDropAnimationState extends State<LiquidDropAnimation>
    with TickerProviderStateMixin {
  late AnimationController _dropController;
  late AnimationController _splashController;
  late Animation<double> _dropProgress;
  late Animation<double> _splashScale;
  late Animation<double> _splashOpacity;
  
  bool _dropLanded = false;
  bool _showSplash = false;
  
  @override
  void initState() {
    super.initState();
    
    // Main drop animation controller
    _dropController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    // Splash animation controller
    _splashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Drop progress with easing that simulates gravity
    _dropProgress = CurvedAnimation(
      parent: _dropController,
      curve: Curves.easeIn, // Gravity acceleration
    );
    
    // Splash scale animation
    _splashScale = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _splashController,
      curve: Curves.easeOut,
    ));
    
    // Splash opacity animation
    _splashOpacity = Tween<double>(
      begin: 0.8,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _splashController,
      curve: Curves.easeOut,
    ));
    
    // Listen for drop completion
    _dropController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_dropLanded) {
        _onDropLanded();
      }
    });
    
    // Listen for splash completion
    _splashController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onAnimationComplete();
      }
    });
    
    // Start the animation
    _startAnimation();
  }
  
  void _startAnimation() {
    _dropController.forward();
  }
  
  void _onDropLanded() async {
    if (_dropLanded) return;
    
    setState(() {
      _dropLanded = true;
      _showSplash = true;
    });
    
    // Trigger haptic feedback
    await HapticService.instance.ingredientCheck();
    
    // Call the callback
    widget.onDropLanded?.call();
    
    // Start splash animation
    _splashController.forward();
  }
  
  void _onAnimationComplete() {
    widget.onAnimationComplete?.call();
  }
  
  @override
  void dispose() {
    _dropController.dispose();
    _splashController.dispose();
    super.dispose();
  }
  
  /// Calculate the bezier curve position for the drop
  Offset _calculateDropPosition(double t) {
    // Control point for the bezier curve (creates arc)
    final controlPoint = Offset(
      (widget.startPosition.dx + widget.glassPosition.dx) / 2,
      min(widget.startPosition.dy, widget.glassPosition.dy) - 50,
    );
    
    // Quadratic bezier curve calculation
    final x = pow(1 - t, 2) * widget.startPosition.dx +
        2 * (1 - t) * t * controlPoint.dx +
        pow(t, 2) * widget.glassPosition.dx;
    
    final y = pow(1 - t, 2) * widget.startPosition.dy +
        2 * (1 - t) * t * controlPoint.dy +
        pow(t, 2) * widget.glassPosition.dy;
    
    return Offset(x, y);
  }
  
  /// Calculate drop scale based on progress (gets slightly larger as it falls)
  double _calculateDropScale(double t) {
    return 1.0 + (t * 0.2); // Grows 20% during fall
  }
  
  /// Calculate drop opacity (fades slightly as it approaches glass)
  double _calculateDropOpacity(double t) {
    return 1.0 - (t * 0.1); // Slight fade
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_dropController, _splashController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Main liquid drop
            if (!_dropLanded)
              Positioned(
                left: _calculateDropPosition(_dropProgress.value).dx - widget.dropSize / 2,
                top: _calculateDropPosition(_dropProgress.value).dy - widget.dropSize / 2,
                child: Transform.scale(
                  scale: _calculateDropScale(_dropProgress.value),
                  child: Opacity(
                    opacity: _calculateDropOpacity(_dropProgress.value),
                    child: Container(
                      width: widget.dropSize,
                      height: widget.dropSize,
                      decoration: BoxDecoration(
                        color: widget.liquidColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.liquidColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Highlight to make it look more liquid-like
                          Positioned(
                            top: 2,
                            left: 3,
                            child: Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            
            // Splash effect
            if (_showSplash)
              Positioned(
                left: widget.glassPosition.dx - (widget.dropSize * _splashScale.value) / 2,
                top: widget.glassPosition.dy - (widget.dropSize * _splashScale.value) / 2,
                child: Transform.scale(
                  scale: _splashScale.value,
                  child: Opacity(
                    opacity: _splashOpacity.value,
                    child: Container(
                      width: widget.dropSize,
                      height: widget.dropSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.liquidColor.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Additional splash ripples
            if (_showSplash)
              ...List.generate(3, (index) {
                final delay = index * 0.1;
                final adjustedProgress = (_splashController.value - delay).clamp(0.0, 1.0);
                
                return Positioned(
                  left: widget.glassPosition.dx - (widget.dropSize * (1 + adjustedProgress * 2)) / 2,
                  top: widget.glassPosition.dy - (widget.dropSize * (1 + adjustedProgress * 2)) / 2,
                  child: Transform.scale(
                    scale: 1 + adjustedProgress * 2,
                    child: Opacity(
                      opacity: (1 - adjustedProgress) * 0.3,
                      child: Container(
                        width: widget.dropSize,
                        height: widget.dropSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.liquidColor.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
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
  final GlobalKey _childKey = GlobalKey();
  bool _isAnimating = false;
  
  void _handleTap(TapDownDetails details) async {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
    });
    
    // Get the position of the tap
    final RenderBox? renderBox = _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final localPosition = details.localPosition;
    final globalPosition = renderBox.localToGlobal(localPosition);
    
    // Calculate glass position (bottom center of the widget)
    final glassPosition = renderBox.localToGlobal(
      Offset(renderBox.size.width / 2, renderBox.size.height * 0.8),
    );
    
    // Show overlay with drop animation
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => LiquidDropAnimation(
        startPosition: globalPosition,
        glassPosition: glassPosition,
        liquidColor: widget.liquidColor,
        onAnimationComplete: () {
          overlayEntry.remove();
          setState(() {
            _isAnimating = false;
          });
          widget.onDropComplete?.call();
        },
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Call the tap callback
    widget.onTap?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _childKey,
      onTapDown: _handleTap,
      child: widget.child,
    );
  }
}