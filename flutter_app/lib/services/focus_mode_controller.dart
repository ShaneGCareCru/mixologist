import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/interaction_feedback.dart';

/// Focus mode controller that manages distraction-free cooking experience
/// by hiding tier 3 elements and providing gesture-based toggle
class FocusModeController extends ChangeNotifier {
  static FocusModeController? _instance;
  static FocusModeController get instance => _instance ??= FocusModeController._();
  
  FocusModeController._();
  
  bool _isFocusMode = false;
  bool _showTutorial = true;
  bool _isInitialized = false;
  DateTime? _lastToggleTime;
  
  static const String _focusModeKey = 'focus_mode_enabled';
  static const String _tutorialShownKey = 'focus_mode_tutorial_shown';
  static const Duration _toggleCooldown = Duration(milliseconds: 500);
  
  /// Whether focus mode is currently active
  bool get isFocusMode => _isFocusMode;
  
  /// Whether to show the tutorial
  bool get showTutorial => _showTutorial;
  
  /// Whether the controller is initialized
  bool get isInitialized => _isInitialized;
  
  /// Initialize the focus mode controller
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _isFocusMode = prefs.getBool(_focusModeKey) ?? false;
      _showTutorial = !(prefs.getBool(_tutorialShownKey) ?? false);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('FocusModeController: Failed to initialize: $e');
      _isInitialized = true;
    }
  }
  
  /// Enter focus mode - hide tier 3 elements
  Future<void> enterFocusMode({bool withFeedback = true}) async {
    if (_isFocusMode || _isInCooldown()) return;
    
    _lastToggleTime = DateTime.now();
    _isFocusMode = true;
    
    if (withFeedback) {
      HapticFeedback.mediumImpact();
    }
    
    await _saveState();
    notifyListeners();
  }
  
  /// Exit focus mode - show all tiers
  Future<void> exitFocusMode({bool withFeedback = true}) async {
    if (!_isFocusMode || _isInCooldown()) return;
    
    _lastToggleTime = DateTime.now();
    _isFocusMode = false;
    
    if (withFeedback) {
      HapticFeedback.lightImpact();
    }
    
    await _saveState();
    notifyListeners();
  }
  
  /// Toggle focus mode state
  Future<void> toggleFocusMode({bool withFeedback = true}) async {
    if (_isInCooldown()) return;
    
    if (_isFocusMode) {
      await exitFocusMode(withFeedback: withFeedback);
    } else {
      await enterFocusMode(withFeedback: withFeedback);
    }
  }
  
  /// Dismiss the tutorial
  Future<void> dismissTutorial() async {
    _showTutorial = false;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_tutorialShownKey, true);
    } catch (e) {
      debugPrint('FocusModeController: Failed to save tutorial state: $e');
    }
    
    notifyListeners();
  }
  
  /// Reset tutorial (for testing or re-onboarding)
  Future<void> resetTutorial() async {
    _showTutorial = true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_tutorialShownKey, false);
    } catch (e) {
      debugPrint('FocusModeController: Failed to reset tutorial: $e');
    }
    
    notifyListeners();
  }
  
  /// Check if we're in cooldown period to prevent rapid toggling
  bool _isInCooldown() {
    if (_lastToggleTime == null) return false;
    return DateTime.now().difference(_lastToggleTime!) < _toggleCooldown;
  }
  
  /// Save current state to preferences
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_focusModeKey, _isFocusMode);
    } catch (e) {
      debugPrint('FocusModeController: Failed to save state: $e');
    }
  }
}

/// Widget that provides focus mode toggle functionality
class FocusModeToggle extends StatefulWidget {
  final Widget? child;
  final EdgeInsets padding;
  final bool showLabel;
  final bool enableGestures;
  final VoidCallback? onToggle;
  final FocusToggleStyle style;
  
  const FocusModeToggle({
    super.key,
    this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.showLabel = true,
    this.enableGestures = true,
    this.onToggle,
    this.style = FocusToggleStyle.button,
  });

  @override
  State<FocusModeToggle> createState() => _FocusModeToggleState();
}

class _FocusModeToggleState extends State<FocusModeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: const Color(0xFF87A96B), // Sage
      end: const Color(0xFFB8860B), // Amber
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Listen to focus mode changes
    FocusModeController.instance.addListener(_updateAnimation);
    _updateAnimation();
  }
  
  @override
  void dispose() {
    FocusModeController.instance.removeListener(_updateAnimation);
    _animationController.dispose();
    super.dispose();
  }
  
  void _updateAnimation() {
    if (FocusModeController.instance.isFocusMode) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
  
  void _handleTap() async {
    await FocusModeController.instance.toggleFocusMode();
    widget.onToggle?.call();
  }
  
  void _handleLongPress() async {
    // Long press exits focus mode regardless of current state
    if (FocusModeController.instance.isFocusMode) {
      await FocusModeController.instance.exitFocusMode();
    }
    widget.onToggle?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FocusModeController.instance,
      builder: (context, child) {
        switch (widget.style) {
          case FocusToggleStyle.button:
            return _buildButton();
          case FocusToggleStyle.fab:
            return _buildFab();
          case FocusToggleStyle.switchStyle:
            return _buildSwitch();
          case FocusToggleStyle.icon:
            return _buildIcon();
        }
      },
    );
  }
  
  Widget _buildButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _handleTap,
            onLongPress: widget.enableGestures ? _handleLongPress : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: widget.padding,
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FocusModeController.instance.isFocusMode 
                        ? Icons.visibility_off 
                        : Icons.center_focus_strong,
                    color: Colors.white,
                    size: 16,
                  ),
                  if (widget.showLabel) ...[
                    const SizedBox(width: 8),
                    Text(
                      FocusModeController.instance.isFocusMode 
                          ? 'Exit Focus' 
                          : 'Focus Mode',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildFab() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FloatingActionButton(
          onPressed: _handleTap,
          backgroundColor: _colorAnimation.value,
          child: Icon(
            FocusModeController.instance.isFocusMode 
                ? Icons.visibility_off 
                : Icons.center_focus_strong,
            color: Colors.white,
          ),
        );
      },
    );
  }
  
  Widget _buildSwitch() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabel) ...[
          Text(
            'Focus Mode',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Switch(
          value: FocusModeController.instance.isFocusMode,
          onChanged: (_) => _handleTap(),
          activeColor: const Color(0xFFB8860B), // Amber
          inactiveThumbColor: const Color(0xFF87A96B), // Sage
        ),
      ],
    );
  }
  
  Widget _buildIcon() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return IconButton(
          onPressed: _handleTap,
          icon: Icon(
            FocusModeController.instance.isFocusMode 
                ? Icons.visibility_off 
                : Icons.center_focus_strong,
            color: _colorAnimation.value,
          ),
        );
      },
    );
  }
}

/// Focus mode gesture detector for swipe-based toggling
class FocusModeGestureDetector extends StatefulWidget {
  final Widget child;
  final bool enableSwipeGestures;
  final bool enableDoubleTap;
  final SwipeDirection swipeDirection;
  final double swipeThreshold;
  
  const FocusModeGestureDetector({
    super.key,
    required this.child,
    this.enableSwipeGestures = true,
    this.enableDoubleTap = true,
    this.swipeDirection = SwipeDirection.vertical,
    this.swipeThreshold = 100.0,
  });

  @override
  State<FocusModeGestureDetector> createState() => _FocusModeGestureDetectorState();
}

class _FocusModeGestureDetectorState extends State<FocusModeGestureDetector> {
  DateTime? _lastTapTime;
  
  void _handleDoubleTap() async {
    if (!widget.enableDoubleTap) return;
    
    final now = DateTime.now();
    if (_lastTapTime != null && 
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      // Double tap detected
      await FocusModeController.instance.toggleFocusMode();
    }
    _lastTapTime = now;
  }
  
  void _handleSwipe(DragEndDetails details) async {
    if (!widget.enableSwipeGestures) return;
    
    final velocity = details.velocity.pixelsPerSecond;
    
    bool shouldToggle = false;
    
    switch (widget.swipeDirection) {
      case SwipeDirection.vertical:
        shouldToggle = velocity.dy.abs() > widget.swipeThreshold;
        break;
      case SwipeDirection.horizontal:
        shouldToggle = velocity.dx.abs() > widget.swipeThreshold;
        break;
      case SwipeDirection.diagonal:
        shouldToggle = (velocity.dx.abs() + velocity.dy.abs()) > widget.swipeThreshold;
        break;
    }
    
    if (shouldToggle) {
      await FocusModeController.instance.toggleFocusMode();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enableDoubleTap ? _handleDoubleTap : null,
      onPanEnd: widget.enableSwipeGestures ? _handleSwipe : null,
      child: widget.child,
    );
  }
}

/// Focus mode tutorial overlay
class FocusModeTutorial extends StatefulWidget {
  final VoidCallback? onDismiss;
  
  const FocusModeTutorial({
    super.key,
    this.onDismiss,
  });

  @override
  State<FocusModeTutorial> createState() => _FocusModeTutorialState();
}

class _FocusModeTutorialState extends State<FocusModeTutorial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _dismiss() async {
    await _controller.reverse();
    await FocusModeController.instance.dismissTutorial();
    widget.onDismiss?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8860B).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.center_focus_strong,
                          size: 30,
                          color: Color(0xFFB8860B),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Title
                      Text(
                        'Focus Mode',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB8860B),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Description
                      Text(
                        'Hide distractions and focus on your cocktail making. '
                        'Tap the focus button or double-tap anywhere to toggle.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Gesture indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildGestureIndicator(
                            icon: Icons.touch_app,
                            label: 'Double Tap',
                          ),
                          _buildGestureIndicator(
                            icon: Icons.swipe_vertical,
                            label: 'Swipe',
                          ),
                          _buildGestureIndicator(
                            icon: Icons.radio_button_checked,
                            label: 'Button',
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _dismiss,
                              child: Text(
                                'Got it',
                                style: TextStyle(
                                  color: const Color(0xFFB8860B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await FocusModeController.instance.enterFocusMode();
                                _dismiss();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB8860B),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Try Now'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildGestureIndicator({
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: const Color(0xFF87A96B),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Styles for focus mode toggle
enum FocusToggleStyle {
  button,
  fab,
  switchStyle,
  icon,
}

/// Swipe directions for gesture detection
enum SwipeDirection {
  vertical,
  horizontal,
  diagonal,
}

/// Extension methods for focus mode functionality
extension FocusModeExtensions on Widget {
  /// Wrap widget with focus mode gesture detection
  Widget withFocusGestures({
    bool enableSwipeGestures = true,
    bool enableDoubleTap = true,
    SwipeDirection swipeDirection = SwipeDirection.vertical,
  }) {
    return FocusModeGestureDetector(
      enableSwipeGestures: enableSwipeGestures,
      enableDoubleTap: enableDoubleTap,
      swipeDirection: swipeDirection,
      child: this,
    );
  }
}

/// Focus mode aware widget that automatically hides/shows based on focus state
class FocusModeAware extends StatelessWidget {
  final Widget child;
  final bool hideInFocusMode;
  final Duration animationDuration;
  final Widget? focusReplacement;
  
  const FocusModeAware({
    super.key,
    required this.child,
    this.hideInFocusMode = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.focusReplacement,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FocusModeController.instance,
      builder: (context, _) {
        final shouldHide = hideInFocusMode && FocusModeController.instance.isFocusMode;
        
        return AnimatedSwitcher(
          duration: animationDuration,
          child: shouldHide 
              ? (focusReplacement ?? const SizedBox.shrink())
              : child,
        );
      },
    );
  }
}