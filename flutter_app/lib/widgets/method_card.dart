import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class MethodCardData {
  final int stepNumber;
  final String title;
  final String description;
  final String imageUrl;
  final String imageAlt;
  final bool isCompleted;
  final String duration;
  final String difficulty;
  final String? proTip;

  const MethodCardData({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.imageAlt,
    required this.isCompleted,
    required this.duration,
    required this.difficulty,
    this.proTip,
  });
}

enum MethodCardState { defaultState, active, completed, loading }

class MethodCard extends StatefulWidget {
  final MethodCardData data;
  final MethodCardState state;
  final bool initiallyExpanded;
  final VoidCallback? onCompleted;
  final VoidCallback? onPrevious;
  final bool enableSwipeGestures;
  final bool enableKeyboardNavigation;

  const MethodCard({
    super.key,
    required this.data,
    this.state = MethodCardState.defaultState,
    this.initiallyExpanded = false,
    this.onCompleted,
    this.onPrevious,
    this.enableSwipeGestures = true,
    this.enableKeyboardNavigation = true,
  });

  @override
  State<MethodCard> createState() => _MethodCardState();
}

class _MethodCardState extends State<MethodCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  final FocusNode _focusNode = FocusNode();
  late AnimationController _swipeAnimationController;
  late Animation<Offset> _swipeAnimation;
  bool _isSwipeInProgress = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _swipeAnimationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _handleSwipeRight() {
    if (widget.onCompleted != null && !_isSwipeInProgress) {
      _triggerHapticFeedback();
      _animateSwipeComplete();
    }
  }

  void _handleSwipeLeft() {
    if (widget.onPrevious != null && !_isSwipeInProgress) {
      _triggerHapticFeedback();
      widget.onPrevious!();
    }
  }

  void _animateSwipeComplete() {
    setState(() {
      _isSwipeInProgress = true;
    });
    
    _swipeAnimationController.forward().then((_) {
      widget.onCompleted?.call();
      _swipeAnimationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isSwipeInProgress = false;
          });
        }
      });
    });
  }

  void _triggerHapticFeedback() {
    if (!kIsWeb) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleKeyPress(KeyEvent event) {
    if (!widget.enableKeyboardNavigation) return;
    
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        _triggerHapticFeedback();
        widget.onCompleted?.call();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                 event.logicalKey == LogicalKeyboardKey.backspace) {
        _triggerHapticFeedback();
        widget.onPrevious?.call();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _focusNode.unfocus();
      }
    }
  }

  Color _borderColor(ThemeData theme) {
    switch (widget.state) {
      case MethodCardState.active:
        return theme.colorScheme.primary;
      case MethodCardState.completed:
        return theme.colorScheme.secondary;
      default:
        return theme.dividerColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.state == MethodCardState.loading) {
      return _buildLoadingSkeleton(theme);
    }

    Widget cardContent = Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: _borderColor(theme), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              widget.data.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text(widget.data.imageAlt),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${widget.data.stepNumber}: ${widget.data.title}',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(widget.data.description,
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: theme.hintColor),
                    const SizedBox(width: 4),
                    Text(widget.data.duration,
                        style: theme.textTheme.bodySmall),
                    const SizedBox(width: 12),
                    Icon(Icons.speed, size: 16, color: theme.hintColor),
                    const SizedBox(width: 4),
                    Text(widget.data.difficulty,
                        style: theme.textTheme.bodySmall),
                    const Spacer(),
                    if (widget.data.proTip != null)
                      IconButton(
                        icon: Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        onPressed: _toggleExpanded,
                      ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: ConstrainedBox(
                    constraints: _expanded
                        ? const BoxConstraints()
                        : const BoxConstraints(maxHeight: 0),
                    child: widget.data.proTip != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Pro Tip: ${widget.data.proTip!}',
                              style: theme.textTheme.bodySmall,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                // Keyboard shortcuts hint
                if (widget.enableKeyboardNavigation)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Shortcuts: Space/Enter to complete, ← to go back, Esc to unfocus',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    // Wrap with gesture detection and keyboard handling
    Widget interactiveCard = cardContent;
    
    if (widget.enableSwipeGestures) {
      interactiveCard = GestureDetector(
        onPanEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 300) {
            _handleSwipeRight();
          } else if (details.velocity.pixelsPerSecond.dx < -300) {
            _handleSwipeLeft();
          }
        },
        child: AnimatedBuilder(
          animation: _swipeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: _swipeAnimation.value * MediaQuery.of(context).size.width,
              child: cardContent,
            );
          },
        ),
      );
    }

    if (widget.enableKeyboardNavigation) {
      interactiveCard = KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyPress,
        child: Focus(
          focusNode: _focusNode,
          child: interactiveCard,
        ),
      );
    }

    return interactiveCard;
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.dividerColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(color: theme.disabledColor.withValues(alpha: 0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  color: theme.disabledColor.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: double.infinity,
                  color: theme.disabledColor.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      height: 12,
                      width: 60,
                      color: theme.disabledColor.withValues(alpha: 0.1),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 12,
                      width: 60,
                      color: theme.disabledColor.withValues(alpha: 0.1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

