import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Centralized controller for managing all ambient animations in the app
class AmbientAnimationController with ChangeNotifier {
  static AmbientAnimationController? _instance;
  
  /// Singleton instance
  static AmbientAnimationController get instance {
    _instance ??= AmbientAnimationController._internal();
    return _instance!;
  }

  AmbientAnimationController._internal() {
    _initializeController();
  }

  /// List of all animation controllers managed by this system
  final List<AnimationController> _controllers = [];
  
  /// Whether ambient animations are currently active
  bool _isActive = true;
  
  /// Whether animations are paused for battery saving
  bool _isPaused = false;
  
  /// Whether animations are reduced for accessibility
  bool _isReducedMotion = false;
  
  /// Performance metrics
  int _frameCount = 0;
  DateTime _lastFrameTime = DateTime.now();
  double _currentFPS = 60.0;
  
  /// Timer for performance monitoring
  Timer? _performanceTimer;
  
  /// Listeners for animation lifecycle events
  final List<VoidCallback> _startListeners = [];
  final List<VoidCallback> _pauseListeners = [];
  final List<VoidCallback> _resumeListeners = [];

  /// Current state getters
  bool get isActive => _isActive && !_isPaused;
  bool get isPaused => _isPaused;
  bool get isReducedMotion => _isReducedMotion;
  double get currentFPS => _currentFPS;
  int get controllerCount => _controllers.length;

  /// Initialize the controller and set up performance monitoring
  void _initializeController() {
    // Start performance monitoring
    _startPerformanceMonitoring();
    
    // Listen for app lifecycle changes
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(this));
  }

  /// Register an animation controller with the ambient system
  void registerController(AnimationController controller) {
    if (!_controllers.contains(controller)) {
      _controllers.add(controller);
      
      // Add frame counting listener
      controller.addListener(_onAnimationFrame);
      
      // Start the controller if ambient animations are active
      if (isActive) {
        controller.repeat();
      }
      
      notifyListeners();
    }
  }

  /// Unregister an animation controller
  void unregisterController(AnimationController controller) {
    if (_controllers.contains(controller)) {
      controller.removeListener(_onAnimationFrame);
      _controllers.remove(controller);
      notifyListeners();
    }
  }

  /// Start all registered animations
  void startAll() {
    if (_isPaused || !_isActive) return;
    
    for (final controller in _controllers) {
      if (!controller.isAnimating) {
        controller.repeat();
      }
    }
    
    // Notify listeners
    for (final listener in _startListeners) {
      listener();
    }
    
    notifyListeners();
  }

  /// Pause all animations (for battery saving or background)
  void pauseAll() {
    _isPaused = true;
    
    for (final controller in _controllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
    }
    
    // Notify listeners
    for (final listener in _pauseListeners) {
      listener();
    }
    
    notifyListeners();
  }

  /// Resume all animations
  void resumeAll() {
    _isPaused = false;
    
    if (_isActive) {
      startAll();
    }
    
    // Notify listeners
    for (final listener in _resumeListeners) {
      listener();
    }
    
    notifyListeners();
  }

  /// Enable or disable ambient animations
  void setActive(bool active) {
    _isActive = active;
    
    if (active && !_isPaused) {
      startAll();
    } else {
      for (final controller in _controllers) {
        controller.stop();
      }
    }
    
    notifyListeners();
  }

  /// Set reduced motion mode for accessibility
  void setReducedMotion(bool reduced) {
    _isReducedMotion = reduced;
    
    if (reduced) {
      // Pause complex animations but allow simple fades
      pauseAll();
    } else {
      resumeAll();
    }
    
    notifyListeners();
  }

  /// Add a listener for when animations start
  void addStartListener(VoidCallback listener) {
    _startListeners.add(listener);
  }

  /// Add a listener for when animations pause
  void addPauseListener(VoidCallback listener) {
    _pauseListeners.add(listener);
  }

  /// Add a listener for when animations resume
  void addResumeListener(VoidCallback listener) {
    _resumeListeners.add(listener);
  }

  /// Remove listeners
  void removeStartListener(VoidCallback listener) {
    _startListeners.remove(listener);
  }

  void removePauseListener(VoidCallback listener) {
    _pauseListeners.remove(listener);
  }

  void removeResumeListener(VoidCallback listener) {
    _resumeListeners.remove(listener);
  }

  /// Called on each animation frame to track performance
  void _onAnimationFrame() {
    _frameCount++;
    final now = DateTime.now();
    final timeDiff = now.difference(_lastFrameTime).inMilliseconds;
    
    if (timeDiff > 0) {
      _currentFPS = 1000.0 / timeDiff;
      _lastFrameTime = now;
    }
  }

  /// Start performance monitoring timer
  void _startPerformanceMonitoring() {
    _performanceTimer?.cancel();
    _performanceTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkPerformance();
    });
  }

  /// Check performance and adjust animations if needed
  void _checkPerformance() {
    // If FPS drops below 30, consider pausing some animations
    if (_currentFPS < 30.0 && _isActive && !_isPaused) {
      debugPrint('AmbientAnimationController: Low FPS detected ($_currentFPS), consider reducing animations');
      
      // Could implement automatic reduction here
      // For now, just log the performance issue
    }
    
    // Reset frame counter
    _frameCount = 0;
  }

  /// Handle app going to background
  void _onAppPaused() {
    pauseAll();
  }

  /// Handle app returning to foreground
  void _onAppResumed() {
    // Only resume if animations were active before pausing
    if (_isActive) {
      resumeAll();
    }
  }

  /// Dispose all resources
  @override
  void dispose() {
    _performanceTimer?.cancel();
    
    // Stop all controllers but don't dispose them (they're managed elsewhere)
    for (final controller in _controllers) {
      controller.removeListener(_onAnimationFrame);
      controller.stop();
    }
    
    _controllers.clear();
    _startListeners.clear();
    _pauseListeners.clear();
    _resumeListeners.clear();
    
    super.dispose();
  }
}

/// App lifecycle observer for ambient animations
class _AppLifecycleObserver with WidgetsBindingObserver {
  final AmbientAnimationController controller;
  
  _AppLifecycleObserver(this.controller);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        controller._onAppPaused();
        break;
      case AppLifecycleState.resumed:
        controller._onAppResumed();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }
}

/// Mixin for widgets that use ambient animations
mixin AmbientAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  final List<AnimationController> _ambientControllers = [];
  
  /// Create an ambient animation controller with the specified duration
  AnimationController createAmbientController({
    required Duration duration,
    String? debugLabel,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: this,
      debugLabel: debugLabel,
    );
    
    _ambientControllers.add(controller);
    AmbientAnimationController.instance.registerController(controller);
    
    return controller;
  }

  @override
  void dispose() {
    // Unregister and dispose all ambient controllers
    for (final controller in _ambientControllers) {
      AmbientAnimationController.instance.unregisterController(controller);
      controller.dispose();
    }
    _ambientControllers.clear();
    
    super.dispose();
  }
}

/// Widget that provides ambient animation control to its children
class AmbientAnimationProvider extends StatelessWidget {
  const AmbientAnimationProvider({
    super.key,
    required this.child,
    this.reducedMotion = false,
  });

  final Widget child;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    // Set reduced motion based on system accessibility settings
    final mediaQuery = MediaQuery.of(context);
    final systemReducedMotion = mediaQuery.disableAnimations;
    
    // Update controller with accessibility settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmbientAnimationController.instance.setReducedMotion(
        reducedMotion || systemReducedMotion,
      );
    });

    return ListenableBuilder(
      listenable: AmbientAnimationController.instance,
      builder: (context, child) {
        return this.child;
      },
    );
  }
}