import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  success,
  error,
}

enum TipCategory {
  technique(Icons.touch_app, 'Technique'),
  timing(Icons.timer, 'Timing'),
  ingredient(Icons.local_grocery_store, 'Ingredient'),
  equipment(Icons.kitchen, 'Equipment'),
  presentation(Icons.palette, 'Presentation'),
  safety(Icons.warning, 'Safety');

  const TipCategory(this.icon, this.label);
  final IconData icon;
  final String label;
}

class MethodCardData {
  final int stepNumber;
  final String title;
  final String description;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final bool isGenerating;
  final String imageAlt;
  final bool isCompleted;
  final String duration;
  final String difficulty;
  final String? proTip;
  final TipCategory? tipCategory;

  const MethodCardData({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.imageUrl,
    this.imageBytes,
    this.isGenerating = false,
    required this.imageAlt,
    required this.isCompleted,
    required this.duration,
    required this.difficulty,
    this.proTip,
    this.tipCategory,
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
  final ValueChanged<bool>? onCheckboxChanged;

  const MethodCard({
    super.key,
    required this.data,
    this.state = MethodCardState.defaultState,
    this.initiallyExpanded = false,
    this.onCompleted,
    this.onPrevious,
    this.enableSwipeGestures = true,
    this.enableKeyboardNavigation = true,
    this.onCheckboxChanged,
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
    _triggerHapticFeedback(HapticFeedbackType.selection);
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _handleSwipeRight() {
    if (widget.onCompleted != null && !_isSwipeInProgress) {
      _triggerHapticFeedback(HapticFeedbackType.success);
      _animateSwipeComplete();
    }
  }

  void _handleSwipeLeft() {
    if (widget.onPrevious != null && !_isSwipeInProgress) {
      _triggerHapticFeedback(HapticFeedbackType.medium);
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

  void _triggerHapticFeedback([HapticFeedbackType type = HapticFeedbackType.light]) async {
    if (kIsWeb) return;
    
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.success:
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(pattern: [0, 100, 50, 100], intensities: [0, 128, 0, 255]);
        } else {
          HapticFeedback.heavyImpact();
        }
        break;
      case HapticFeedbackType.error:
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200], intensities: [0, 255, 0, 255, 0, 255]);
        } else {
          HapticFeedback.heavyImpact();
        }
        break;
    }
  }



  void _handleKeyPress(KeyEvent event) {
    if (!widget.enableKeyboardNavigation) return;
    
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        _triggerHapticFeedback(HapticFeedbackType.success);
        widget.onCompleted?.call();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                 event.logicalKey == LogicalKeyboardKey.backspace) {
        _triggerHapticFeedback(HapticFeedbackType.selection);
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

  Widget _buildImageWidget(ThemeData theme) {
    // Show loading state
    if (widget.data.isGenerating) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Generating image...'),
            ],
          ),
        ),
      );
    }

    // Show generated image from bytes
    if (widget.data.imageBytes != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Image.memory(
          widget.data.imageBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    // Show cached network image from URL
    if (widget.data.imageUrl != null && widget.data.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.data.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholderWidget(theme),
        memCacheWidth: 400,
        memCacheHeight: 225,
        maxWidthDiskCache: 800,
        maxHeightDiskCache: 450,
      );
    }

    // Show placeholder
    return _buildPlaceholderWidget(theme);
  }

  Widget _buildPlaceholderWidget(ThemeData theme) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, 
                 size: 32, 
                 color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              widget.data.imageAlt,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "Generate Visuals" to create image',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.state == MethodCardState.loading) {
      return _buildLoadingSkeleton(theme);
    }

    Widget cardContent = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.brightness == Brightness.dark
              ? [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.06),
                ]
              : [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.15),
                ],
        ),
        border: Border.all(
          color: _borderColor(theme).withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.6)
                : _borderColor(theme).withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: theme.brightness == Brightness.dark
              ? Colors.black.withOpacity(0.25)
              : Colors.white.withOpacity(0.15),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 2.0, // Wide aspect ratio for action images
            child: _buildImageWidget(theme),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${widget.data.stepNumber}',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    widget.data.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.data.tipCategory != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          widget.data.tipCategory!.icon,
                                          size: 16,
                                          color: theme.colorScheme.onPrimaryContainer,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.data.tipCategory!.label,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    widget.data.proTip!,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
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
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                if (widget.onCheckboxChanged != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Checkbox(
                      value: widget.data.isCompleted,
                      onChanged: (value) {
                        if (widget.onCheckboxChanged != null) {
                          widget.onCheckboxChanged!(value ?? false);
                        }
                      },
                      activeColor: theme.colorScheme.secondary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
              ),
            ),
          ),
          ],
        ),
        ),
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
        child: interactiveCard,
      );
    }

    return interactiveCard;
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.brightness == Brightness.dark
              ? [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.04),
                ]
              : [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
        ),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: theme.brightness == Brightness.dark
              ? Colors.black.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(color: theme.disabledColor.withOpacity(0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  color: theme.disabledColor.withOpacity(0.1),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: double.infinity,
                  color: theme.disabledColor.withOpacity(0.1),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      height: 12,
                      width: 60,
                      color: theme.disabledColor.withOpacity(0.1),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 12,
                      width: 60,
                      color: theme.disabledColor.withOpacity(0.1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ],
        ),
        ),
      ),
    );
  }
}

