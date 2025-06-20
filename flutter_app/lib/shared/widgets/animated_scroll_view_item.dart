import 'package:flutter/material.dart';

/// A widget that animates its child based on scroll position visibility.
/// Based on the technique shown in Roaa's Flutter animation tip.
/// 
/// This creates smooth scale and fade animations as items scroll into view,
/// making any ListView, GridView, or horizontal scroll view come to life.
class AnimatedScrollViewItem extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double scaleFrom;
  final double scaleTo;

  const AnimatedScrollViewItem({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.elasticOut,
    this.scaleFrom = 0.0,
    this.scaleTo = 1.0,
  });

  @override
  State<AnimatedScrollViewItem> createState() => _AnimatedScrollViewItemState();
}

class _AnimatedScrollViewItemState extends State<AnimatedScrollViewItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.scaleFrom,
      end: widget.scaleTo,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _scaleAnimation,
          child: widget.child,
          builder: (context, child) {
            return ClipRect(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _scaleAnimation.value,
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Triggers the animation when the item becomes visible
  void animateIn() {
    if (!_animationController.isAnimating) {
      print('🎯 ANIMATING IN: Scale ${widget.scaleFrom} → ${widget.scaleTo}');
      _animationController.forward();
    }
  }

  /// Resets the animation when the item goes out of view
  void animateOut() {
    if (!_animationController.isAnimating) {
      _animationController.reverse();
    }
  }
}

/// A ListView that automatically animates its children as they scroll into view
class AnimatedListView extends StatefulWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double itemExtent;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedListView({
    super.key,
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.itemExtent = 100.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOut,
  });

  @override
  State<AnimatedListView> createState() => _AnimatedListViewState();
}

class _AnimatedListViewState extends State<AnimatedListView> {
  late ScrollController _scrollController;
  final List<GlobalKey<_AnimatedScrollViewItemState>> _itemKeys = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Create keys for each child
    for (int i = 0; i < widget.children.length; i++) {
      _itemKeys.add(GlobalKey<_AnimatedScrollViewItemState>());
    }

    // Trigger initial animations after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;

    final scrollOffset = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;
    
    for (int i = 0; i < _itemKeys.length; i++) {
      final key = _itemKeys[i];
      final RenderBox? renderBox = 
          key.currentContext?.findRenderObject() as RenderBox?;
      
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final itemTop = widget.scrollDirection == Axis.vertical 
            ? position.dy 
            : position.dx;
        final itemBottom = itemTop + (widget.scrollDirection == Axis.vertical 
            ? renderBox.size.height 
            : renderBox.size.width);
        
        // Check if item is visible in viewport
        final isVisible = itemBottom > 0 && itemTop < viewportHeight;
        
        if (isVisible) {
          key.currentState?.animateIn();
        } else {
          key.currentState?.animateOut();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: widget.children.length,
      itemExtent: widget.scrollDirection == Axis.horizontal ? widget.itemExtent : null,
      itemBuilder: (context, index) {
        return AnimatedScrollViewItem(
          key: _itemKeys[index],
          duration: widget.animationDuration,
          curve: widget.animationCurve,
          child: widget.children[index],
        );
      },
    );
  }
}

/// A horizontal scroll view with automatic animations for inventory items
class HorizontalInventoryScroll extends StatefulWidget {
  final List<Widget> items;
  final double itemWidth;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;
  final Duration animationDuration;

  const HorizontalInventoryScroll({
    super.key,
    required this.items,
    this.itemWidth = 140.0,
    this.itemHeight = 200.0,
    this.padding,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  State<HorizontalInventoryScroll> createState() => _HorizontalInventoryScrollState();
}

class _HorizontalInventoryScrollState extends State<HorizontalInventoryScroll> {
  late ScrollController _scrollController;
  final List<GlobalKey<_AnimatedScrollViewItemState>> _itemKeys = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Create keys for each item
    for (int i = 0; i < widget.items.length; i++) {
      _itemKeys.add(GlobalKey<_AnimatedScrollViewItemState>());
    }

    // Trigger initial animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;

    final scrollOffset = _scrollController.offset;
    final viewportWidth = _scrollController.position.viewportDimension;
    
    for (int i = 0; i < _itemKeys.length; i++) {
      final key = _itemKeys[i];
      final RenderBox? renderBox = 
          key.currentContext?.findRenderObject() as RenderBox?;
      
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final itemLeft = position.dx;
        final itemRight = itemLeft + renderBox.size.width;
        
        // Check if item is visible in viewport with large margin for early animation
        final margin = widget.itemWidth * 0.8; // 80% margin for much earlier animation trigger
        final isVisible = itemRight > -margin && itemLeft < viewportWidth + margin;
        
        if (isVisible) {
          key.currentState?.animateIn();
        } else {
          key.currentState?.animateOut();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemHeight,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return Container(
            width: widget.itemWidth,
            margin: const EdgeInsets.only(right: 12),
            child: AnimatedScrollViewItem(
              key: _itemKeys[index],
              duration: widget.animationDuration,
              curve: Curves.elasticOut,
              scaleFrom: 0.0,
              scaleTo: 1.0,
              child: widget.items[index],
            ),
          );
        },
      ),
    );
  }
}