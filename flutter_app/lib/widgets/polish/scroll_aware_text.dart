import 'package:flutter/material.dart';
import 'dart:math';

/// Text widget that responds to scroll position with variable font weights
/// Font weight increases/decreases based on scroll proximity and direction
class ScrollAwareText extends StatefulWidget {
  final String text;
  final double minWeight; // 300 (light)
  final double maxWeight; // 700 (bold)
  final TextStyle? baseStyle;
  final ScrollController? scrollController;
  final double sensitivity;
  final bool inverseWeight; // Heavier when further from scroll center
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double scrollThreshold; // Distance from center to start effect
  final Curve weightCurve;
  
  const ScrollAwareText(
    this.text, {
    super.key,
    this.minWeight = 300,
    this.maxWeight = 700,
    this.baseStyle,
    this.scrollController,
    this.sensitivity = 1.0,
    this.inverseWeight = false,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.scrollThreshold = 200.0,
    this.weightCurve = Curves.easeInOut,
  });

  @override
  State<ScrollAwareText> createState() => _ScrollAwareTextState();
}

class _ScrollAwareTextState extends State<ScrollAwareText>
    with SingleTickerProviderStateMixin {
  late AnimationController _weightController;
  late Animation<double> _weightAnimation;
  
  ScrollController? _scrollController;
  double _currentWeight = 400; // Normal weight
  bool _isDisposed = false;
  
  @override
  void initState() {
    super.initState();
    
    _weightController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _weightAnimation = Tween<double>(
      begin: widget.minWeight,
      end: widget.maxWeight,
    ).animate(CurvedAnimation(
      parent: _weightController,
      curve: widget.weightCurve,
    ));
    
    _currentWeight = (widget.minWeight + widget.maxWeight) / 2;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollListener();
    });
  }
  
  void _setupScrollListener() {
    _scrollController = widget.scrollController ?? 
                      PrimaryScrollController.maybeOf(context);
    
    if (_scrollController != null) {
      _scrollController!.addListener(_onScroll);
      _updateWeight();
    }
  }
  
  @override
  void didUpdateWidget(ScrollAwareText oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.scrollController != widget.scrollController) {
      _scrollController?.removeListener(_onScroll);
      _setupScrollListener();
    }
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    _scrollController?.removeListener(_onScroll);
    _weightController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_isDisposed) return;
    _updateWeight();
  }
  
  void _updateWeight() {
    if (_scrollController == null || !mounted) return;
    
    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;
    
    final renderBox = renderObject as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    final screenHeight = MediaQuery.of(context).size.height;
    final elementCenter = position.dy + size.height / 2;
    final screenCenter = screenHeight / 2;
    
    // Calculate distance from screen center
    final distanceFromCenter = (elementCenter - screenCenter).abs();
    
    // Normalize distance (0.0 at center, 1.0 at threshold)
    final normalizedDistance = min(distanceFromCenter / widget.scrollThreshold, 1.0);
    
    // Calculate weight factor (0.0 to 1.0)
    double weightFactor;
    if (widget.inverseWeight) {
      // Heavier when further from center
      weightFactor = normalizedDistance * widget.sensitivity;
    } else {
      // Lighter when further from center
      weightFactor = (1.0 - normalizedDistance) * widget.sensitivity;
    }
    
    weightFactor = weightFactor.clamp(0.0, 1.0);
    
    final targetWeight = widget.minWeight + 
                        (widget.maxWeight - widget.minWeight) * weightFactor;
    
    if ((targetWeight - _currentWeight).abs() > 10) {
      _currentWeight = targetWeight;
      _weightController.animateTo(weightFactor);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _weightAnimation,
      builder: (context, child) {
        final currentWeight = widget.minWeight + 
                             (widget.maxWeight - widget.minWeight) * 
                             _weightController.value;
        
        return Text(
          widget.text,
          style: (widget.baseStyle ?? Theme.of(context).textTheme.bodyLarge!)
              .copyWith(
            fontWeight: FontWeight.values[_getClosestFontWeightIndex(currentWeight)],
            // Use fontVariations for more precise control if available
            fontVariations: [
              FontVariation('wght', currentWeight),
            ],
          ),
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
        );
      },
    );
  }
  
  int _getClosestFontWeightIndex(double weight) {
    const weights = [100, 200, 300, 400, 500, 600, 700, 800, 900];
    int closestIndex = 3; // FontWeight.w400 as default
    double minDifference = double.infinity;
    
    for (int i = 0; i < weights.length; i++) {
      final difference = (weights[i] - weight).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestIndex = i;
      }
    }
    
    return closestIndex;
  }
}

/// Enhanced text widget with scroll-aware typography effects
class ResponsiveText extends StatefulWidget {
  final String text;
  final TextStyle? baseStyle;
  final ScrollController? scrollController;
  final bool enableWeightVariation;
  final bool enableSizeVariation;
  final bool enableSpacingVariation;
  final double minSize;
  final double maxSize;
  final double minSpacing;
  final double maxSpacing;
  final TextAlign textAlign;
  
  const ResponsiveText(
    this.text, {
    super.key,
    this.baseStyle,
    this.scrollController,
    this.enableWeightVariation = true,
    this.enableSizeVariation = false,
    this.enableSpacingVariation = false,
    this.minSize = 14.0,
    this.maxSize = 18.0,
    this.minSpacing = 0.0,
    this.maxSpacing = 1.2,
    this.textAlign = TextAlign.start,
  });

  @override
  State<ResponsiveText> createState() => _ResponsiveTextState();
}

class _ResponsiveTextState extends State<ResponsiveText>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _spacingAnimation;
  
  ScrollController? _scrollController;
  double _scrollProgress = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _sizeAnimation = Tween<double>(
      begin: widget.minSize,
      end: widget.maxSize,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));
    
    _spacingAnimation = Tween<double>(
      begin: widget.minSpacing,
      end: widget.maxSpacing,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollListener();
    });
  }
  
  void _setupScrollListener() {
    _scrollController = widget.scrollController ?? 
                      PrimaryScrollController.maybeOf(context);
    
    if (_scrollController != null) {
      _scrollController!.addListener(_onScroll);
    }
  }
  
  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _textController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (!mounted) return;
    
    final renderObject = context.findRenderObject();
    if (renderObject == null) return;
    
    final renderBox = renderObject as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate visibility progress (0.0 = off-screen, 1.0 = fully visible)
    final visibilityProgress = 1.0 - (position.dy / screenHeight).clamp(0.0, 1.0);
    
    if ((visibilityProgress - _scrollProgress).abs() > 0.05) {
      _scrollProgress = visibilityProgress;
      _textController.animateTo(visibilityProgress);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.enableSizeVariation && !widget.enableSpacingVariation) {
      return widget.enableWeightVariation
          ? ScrollAwareText(
              widget.text,
              baseStyle: widget.baseStyle,
              scrollController: widget.scrollController,
              textAlign: widget.textAlign,
            )
          : Text(
              widget.text,
              style: widget.baseStyle,
              textAlign: widget.textAlign,
            );
    }
    
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Text(
          widget.text,
          style: (widget.baseStyle ?? Theme.of(context).textTheme.bodyLarge!)
              .copyWith(
            fontSize: widget.enableSizeVariation ? _sizeAnimation.value : null,
            letterSpacing: widget.enableSpacingVariation ? _spacingAnimation.value : null,
          ),
          textAlign: widget.textAlign,
        );
      },
    );
  }
}

/// Scroll-aware headline that becomes bolder as it approaches center
class ScrollHeadline extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final ScrollController? scrollController;
  final bool centerFocus;
  
  const ScrollHeadline(
    this.text, {
    super.key,
    this.style,
    this.scrollController,
    this.centerFocus = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return ScrollAwareText(
      text,
      minWeight: 400,
      maxWeight: 700,
      baseStyle: style ?? Theme.of(context).textTheme.headlineMedium,
      scrollController: scrollController,
      inverseWeight: !centerFocus,
      sensitivity: 1.2,
      scrollThreshold: 150.0,
    );
  }
}

/// Scroll-aware body text that lightens when far from focus
class ScrollBodyText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final ScrollController? scrollController;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const ScrollBodyText(
    this.text, {
    super.key,
    this.style,
    this.scrollController,
    this.maxLines,
    this.overflow,
  });
  
  @override
  Widget build(BuildContext context) {
    return ScrollAwareText(
      text,
      minWeight: 300,
      maxWeight: 500,
      baseStyle: style ?? Theme.of(context).textTheme.bodyMedium,
      scrollController: scrollController,
      sensitivity: 0.8,
      scrollThreshold: 200.0,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Typography system optimized for variable fonts
class VariableFontTypography {
  /// Get optimized text style for variable font rendering
  static TextStyle variable({
    required double fontSize,
    required double fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFamily: fontFamily,
      fontVariations: [
        FontVariation('wght', fontWeight),
      ],
    );
  }
  
  /// Create a smooth font weight transition
  static TextStyle lerpWeight(
    TextStyle baseStyle,
    double fromWeight,
    double toWeight,
    double t,
  ) {
    final weight = fromWeight + (toWeight - fromWeight) * t;
    return baseStyle.copyWith(
      fontVariations: [
        FontVariation('wght', weight),
      ],
    );
  }
  
  /// Get cocktail-themed font weights
  static Map<String, double> get cocktailWeights => {
    'light': 300.0,      // Ingredients, descriptions
    'regular': 400.0,    // Body text
    'medium': 500.0,     // Subheadings
    'semiBold': 600.0,   // Active elements
    'bold': 700.0,       // Headlines, emphasis
    'extraBold': 800.0,  // Brand, hero text
  };
}

/// Extension methods for easy scroll-aware text usage
extension ScrollAwareTextExtensions on String {
  /// Convert string to scroll-aware text widget
  Widget toScrollAwareText({
    TextStyle? style,
    ScrollController? scrollController,
    double minWeight = 300,
    double maxWeight = 700,
    TextAlign textAlign = TextAlign.start,
  }) {
    return ScrollAwareText(
      this,
      baseStyle: style,
      scrollController: scrollController,
      minWeight: minWeight,
      maxWeight: maxWeight,
      textAlign: textAlign,
    );
  }
  
  /// Convert string to scroll-aware headline
  Widget toScrollHeadline({
    TextStyle? style,
    ScrollController? scrollController,
  }) {
    return ScrollHeadline(
      this,
      style: style,
      scrollController: scrollController,
    );
  }
  
  /// Convert string to scroll-aware body text
  Widget toScrollBodyText({
    TextStyle? style,
    ScrollController? scrollController,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return ScrollBodyText(
      this,
      style: style,
      scrollController: scrollController,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}