import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spring/spring.dart';
import '../../theme/ios_theme.dart';

/// Spring-animated button component with iOS-style physics
class SpringButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool enabled;
  final double scaleOnPress;
  final Duration springDuration;
  
  const SpringButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.enabled = true,
    this.scaleOnPress = 0.95,
    this.springDuration = const Duration(milliseconds: 150),
  });

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.springDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleOnPress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.onPressed == null) return;
    
    setState(() {
      _isPressed = true;
    });
    
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (!_isPressed) return;
    
    setState(() {
      _isPressed = false;
    });
    
    _animationController.reverse();
    
    // Call onPressed after a short delay to feel natural
    if (widget.onPressed != null) {
      Future.delayed(const Duration(milliseconds: 50), () {
        widget.onPressed?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? 
        iOSTheme.adaptiveColor(
          context,
          CupertinoColors.systemBlue,
          iOSTheme.whiskey,
        );
    
    final borderRadius = widget.borderRadius ?? 
        BorderRadius.circular(iOSTheme.mediumRadius);
    
    final padding = widget.padding ?? 
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: widget.enabled 
                    ? backgroundColor 
                    : backgroundColor.withOpacity(0.5),
                borderRadius: borderRadius,
                boxShadow: widget.enabled && !_isPressed
                    ? [
                        BoxShadow(
                          color: backgroundColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: widget.enabled
                      ? CupertinoColors.white
                      : CupertinoColors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Cocktail-themed spring button with whiskey color
class CocktailButton extends SpringButton {
  const CocktailButton({
    super.key,
    required super.child,
    super.onPressed,
    super.padding,
    super.borderRadius,
    super.enabled,
  }) : super(
          backgroundColor: iOSTheme.whiskey,
          scaleOnPress: 0.92,
          springDuration: const Duration(milliseconds: 200),
        );
}

/// Subtle spring button for secondary actions
class SubtleSpringButton extends SpringButton {
  SubtleSpringButton({
    super.key,
    required super.child,
    super.onPressed,
    super.padding,
    super.borderRadius,
    super.enabled,
    required BuildContext context,
  }) : super(
          backgroundColor: iOSTheme.adaptiveColor(
            context,
            CupertinoColors.tertiarySystemFill,
            iOSTheme.darkTertiaryBackground,
          ),
          scaleOnPress: 0.96,
          springDuration: const Duration(milliseconds: 120),
        );
}

/// Spring animation for bottle cards and inventory items
class BottleSpringCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  
  const BottleSpringCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
  });

  @override
  State<BottleSpringCard> createState() => _BottleSpringCardState();
}

class _BottleSpringCardState extends State<BottleSpringCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    
    setState(() {
      _isPressed = true;
    });
    
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (!_isPressed) return;
    
    setState(() {
      _isPressed = false;
    });
    
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}