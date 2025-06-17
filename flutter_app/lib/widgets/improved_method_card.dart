import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'mixologist_image.dart';

/// Enhanced method card data model with safe defaults
/// Implements graceful data handling from our design philosophy
class SafeMethodCardData {
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

  const SafeMethodCardData({
    required this.stepNumber,
    this.title = '',
    required this.description,
    this.imageUrl,
    this.imageBytes,
    this.isGenerating = false,
    String? imageAlt,
    this.isCompleted = false,
    this.duration = 'Variable',
    this.difficulty = 'Standard',
    this.proTip,
    this.tipCategory,
  }) : imageAlt = imageAlt ?? 'Step $stepNumber technique illustration';

  /// Factory method to create from potentially unsafe data
  factory SafeMethodCardData.fromMap(
      Map<String, dynamic>? data, int stepNumber) {
    if (data == null) {
      return SafeMethodCardData(
        stepNumber: stepNumber,
        description: 'Step information will be available soon.',
        imageAlt: 'Step $stepNumber illustration',
      );
    }

    return SafeMethodCardData(
      stepNumber: stepNumber,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ??
          data['instruction']?.toString() ??
          'Step information will be available soon.',
      imageUrl: data['imageUrl']?.toString(),
      imageBytes: data['imageBytes'] as Uint8List?,
      isGenerating: data['isGenerating'] as bool? ?? false,
      imageAlt: data['imageAlt']?.toString() ?? 'Step $stepNumber illustration',
      isCompleted: data['isCompleted'] as bool? ?? false,
      duration: data['duration']?.toString() ??
          _estimateDuration(data['description']?.toString() ?? ''),
      difficulty: data['difficulty']?.toString() ??
          _estimateDifficulty(data['description']?.toString() ?? ''),
      proTip: data['proTip']?.toString(),
      tipCategory: data['tipCategory'] as TipCategory?,
    );
  }

  /// Create from simple string step (most common case)
  factory SafeMethodCardData.fromString(String stepText, int stepNumber) {
    return SafeMethodCardData(
      stepNumber: stepNumber,
      description: stepText.isNotEmpty
          ? stepText
          : 'Step information will be available soon.',
      duration: _estimateDuration(stepText),
      difficulty: _estimateDifficulty(stepText),
      proTip: _generateProTip(stepText),
      tipCategory: _determineTipCategory(stepText),
    );
  }

  static String _estimateDuration(String stepText) {
    final text = stepText.toLowerCase();
    if (text.contains('shake')) return '15 seconds';
    if (text.contains('stir')) return '30 seconds';
    if (text.contains('muddle')) return '20 seconds';
    if (text.contains('strain')) return '10 seconds';
    if (text.contains('garnish')) return '15 seconds';
    if (text.contains('chill') || text.contains('freeze')) return '2-5 minutes';
    return '30 seconds';
  }

  static String _estimateDifficulty(String stepText) {
    final text = stepText.toLowerCase();
    if (text.contains('muddle') ||
        text.contains('flame') ||
        text.contains('layer')) {
      return 'Advanced';
    }
    if (text.contains('shake') ||
        text.contains('double strain') ||
        text.contains('express')) {
      return 'Intermediate';
    }
    return 'Basic';
  }

  static String? _generateProTip(String stepText) {
    final text = stepText.toLowerCase();
    if (text.contains('shake')) {
      return 'Shake vigorously for 10-15 seconds to properly chill and dilute the drink.';
    }
    if (text.contains('stir')) {
      return 'Stir gently for 20-30 seconds to avoid over-dilution while chilling.';
    }
    if (text.contains('strain')) {
      return 'Double strain through a fine mesh strainer for the smoothest texture.';
    }
    if (text.contains('garnish')) {
      return 'Express citrus oils over the drink by gently twisting the peel.';
    }
    if (text.contains('muddle')) {
      return 'Muddle gently to release oils without creating bitter flavors from over-crushing.';
    }
    return null;
  }

  static TipCategory? _determineTipCategory(String stepText) {
    final text = stepText.toLowerCase();
    if (text.contains('shake') ||
        text.contains('stir') ||
        text.contains('muddle')) {
      return TipCategory.technique;
    }
    if (text.contains('strain')) {
      return TipCategory.equipment;
    }
    if (text.contains('garnish') || text.contains('serve')) {
      return TipCategory.presentation;
    }
    if (text.contains('chill') || text.contains('temperature')) {
      return TipCategory.timing;
    }
    if (text.contains('fresh') || text.contains('quality')) {
      return TipCategory.ingredient;
    }
    return null;
  }
}

/// Tip categories for organizing pro tips
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

/// Haptic feedback types for better user experience
enum HapticFeedbackType { light, medium, heavy, selection, success, error }

/// Method card states for visual feedback
enum MethodCardState { defaultState, active, completed, loading }

/// Improved Method Card implementing our design philosophy
/// Features: graceful data handling, consistent styling, unified image system
class ImprovedMethodCard extends StatefulWidget {
  final SafeMethodCardData data;
  final MethodCardState state;
  final bool initiallyExpanded;
  final VoidCallback? onCompleted;
  final VoidCallback? onPrevious;
  final VoidCallback? onGenerateImage;
  final bool enableSwipeGestures;
  final bool enableKeyboardNavigation;
  final ValueChanged<bool?>? onCheckboxChanged;

  const ImprovedMethodCard({
    super.key,
    required this.data,
    this.state = MethodCardState.defaultState,
    this.initiallyExpanded = false,
    this.onCompleted,
    this.onPrevious,
    this.onGenerateImage,
    this.enableSwipeGestures = true,
    this.enableKeyboardNavigation = true,
    this.onCheckboxChanged,
  });

  @override
  State<ImprovedMethodCard> createState() => _ImprovedMethodCardState();
}

class _ImprovedMethodCardState extends State<ImprovedMethodCard>
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

  void _triggerHapticFeedback(
      [HapticFeedbackType type = HapticFeedbackType.light]) async {
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
          Vibration.vibrate(
              pattern: [0, 100, 50, 100], intensities: [0, 128, 0, 255]);
        } else {
          HapticFeedback.heavyImpact();
        }
        break;
      case HapticFeedbackType.error:
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(
              pattern: [0, 200, 100, 200, 100, 200],
              intensities: [0, 255, 0, 255, 0, 255]);
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

  Color _getBorderColor(ThemeData theme) {
    switch (widget.state) {
      case MethodCardState.active:
        return const Color(0xFFB8860B); // Amber from design philosophy
      case MethodCardState.completed:
        return const Color(0xFF87A96B); // Sage from design philosophy
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

    Widget cardContent = Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(16), // Slightly smaller for modern look
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.brightness == Brightness.dark
              ? [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.04),
                ]
              : [
                  const Color(0xFFF5F5DC)
                      .withOpacity(0.4), // Cream from design philosophy
                  const Color(0xFFF5F5DC).withOpacity(0.2),
                ],
        ),
        border: Border.all(
          color: _getBorderColor(theme).withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : _getBorderColor(theme).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Consistent image using MixologistImage
            MixologistImage.methodStep(
              imageUrl: widget.data.imageUrl,
              imageBytes: widget.data.imageBytes,
              altText: widget.data.imageAlt,
              isGenerating: widget.data.isGenerating,
              onGenerateRequest: widget.onGenerateImage,
              onTap: widget.onCompleted,
            ),
            // Step number overlay
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8860B).withOpacity(0.9), // Amber
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Step ${widget.data.stepNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Content section with improved spacing
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description with better typography
                  Text(
                    widget.data.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Metadata row with improved icons
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        widget.data.duration,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.bar_chart, size: 16, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        widget.data.difficulty,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      // Completion checkbox
                      if (widget.onCheckboxChanged != null)
                        Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: widget.data.isCompleted,
                            onChanged: widget.onCheckboxChanged,
                            activeColor: const Color(0xFF87A96B), // Sage
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      // Pro tip toggle
                      if (widget.data.proTip != null)
                        IconButton(
                          icon: Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.lightbulb_outline,
                            color: const Color(0xFFB8860B), // Amber
                          ),
                          onPressed: _toggleExpanded,
                        ),
                    ],
                  ),
                  // Animated pro tip section
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _expanded && widget.data.proTip != null
                        ? _buildProTipSection(theme)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Add gesture and keyboard handling
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

  Widget _buildProTipSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF87A96B).withOpacity(0.1), // Sage background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF87A96B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.data.tipCategory != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF87A96B), // Sage
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.data.tipCategory!.icon,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.data.tipCategory!.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image skeleton
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: theme.disabledColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
          ),
          // Content skeleton
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.disabledColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: double.infinity * 0.7,
                  decoration: BoxDecoration(
                    color: theme.disabledColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      height: 12,
                      width: 60,
                      decoration: BoxDecoration(
                        color: theme.disabledColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      height: 12,
                      width: 60,
                      decoration: BoxDecoration(
                        color: theme.disabledColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
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
