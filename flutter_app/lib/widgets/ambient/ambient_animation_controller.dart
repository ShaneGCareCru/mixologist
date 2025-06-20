import 'package:flutter/material.dart';
import 'dart:async';
import 'animation_performance_monitor.dart';

/// DISABLED: Centralized controller that does nothing to prevent performance issues
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
  
  /// Shared controllers for common animation types
  final Map<String, AnimationController> _sharedControllers = {};
  
  /// Maximum number of controllers allowed to run simultaneously
  static const int _maxConcurrentControllers = 15;
  
  /// Whether ambient animations are currently active
  bool _isActive = true;
  
  /// Whether animations are paused for battery saving
  bool _isPaused = false;
  
  /// Whether animations are reduced for accessibility
  bool _isReducedMotion = false;
  
  /// Performance metrics - optimized for better tracking
  final List<double> _fpsHistory = [];
  DateTime _lastPerformanceCheck = DateTime.now();
  double _currentFPS = 60.0;
  double _averageFPS = 60.0;
  int _lowFPSCount = 0;
  
  /// Timer for performance monitoring
  Timer? _performanceTimer;
  
  /// Performance thresholds
  static const double _fpsWarningThreshold = 30.0;
  static const double _fpsCriticalThreshold = 20.0;
  
  /// Listeners for animation lifecycle events
  final List<VoidCallback> _startListeners = [];
  final List<VoidCallback> _pauseListeners = [];
  final List<VoidCallback> _resumeListeners = [];

  /// Current state getters
  bool get isActive => _isActive && !_isPaused;
  bool get isPaused => _isPaused;
  bool get isReducedMotion => _isReducedMotion;
  double get currentFPS => _currentFPS;
  double get averageFPS => _averageFPS;
  int get controllerCount => _controllers.length;
  bool get isPerformanceDegraded => _averageFPS < _fpsWarningThreshold;

  /// Initialize the controller and set up performance monitoring
  void _initializeController() {
    // Start performance monitoring
    _startPerformanceMonitoring();
    
    // Initialize and start the advanced performance monitor
    AnimationPerformanceMonitor.instance.startMonitoring();
    AnimationPerformanceMonitor.instance.setAutomaticOptimization(true);
    
    // Add performance callbacks
    AnimationPerformanceMonitor.instance.addPerformanceWarningCallback(_onPerformanceWarning);
    AnimationPerformanceMonitor.instance.addPerformanceCriticalCallback(_onPerformanceCritical);
    
    // Listen for app lifecycle changes
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(this));
  }

  /// Register an animation controller with the ambient system
  void registerController(AnimationController controller) {
    if (!_controllers.contains(controller)) {
      // Check if we've reached the maximum number of controllers
      if (_controllers.length >= _maxConcurrentControllers) {
        debugPrint('AmbientAnimationController: Maximum controllers reached, queuing animation');
        // For now, just skip registration. Could implement queuing later.
        return;
      }
      
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
    // DISABLED: No animation starting to prevent performance issues
    debugPrint('🚫 AmbientAnimationController: startAll() disabled');
  }

  /// DISABLED: Pause all animations 
  void pauseAll() {
    // DISABLED: No animations to pause
    debugPrint('🚫 AmbientAnimationController: pauseAll() disabled');
  }

  /// DISABLED: Resume all animations
  void resumeAll() {
    // DISABLED: No animations to resume
    debugPrint('🚫 AmbientAnimationController: resumeAll() disabled');
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

  /// Called on each animation frame to track performance - optimized
  void _onAnimationFrame() {
    final now = DateTime.now();
    final timeDiff = now.difference(_lastPerformanceCheck).inMilliseconds;
    
    // Only update FPS calculation every 500ms to reduce overhead
    if (timeDiff >= 500) {
      final instantFPS = 1000.0 / timeDiff;
      
      // Add to rolling window (keep last 10 measurements)
      _fpsHistory.add(instantFPS);
      if (_fpsHistory.length > 10) {
        _fpsHistory.removeAt(0);
      }
      
      // Calculate average FPS from history
      _averageFPS = _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
      _currentFPS = instantFPS;
      _lastPerformanceCheck = now;
      
      // Track low FPS occurrences
      if (_averageFPS < _fpsWarningThreshold) {
        _lowFPSCount++;
      } else {
        _lowFPSCount = 0;
      }
    }
  }

  /// Start performance monitoring timer
  void _startPerformanceMonitoring() {
    _performanceTimer?.cancel();
    _performanceTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkPerformance();
    });
  }

  /// Check performance and adjust animations if needed - optimized
  void _checkPerformance() {
    // Only act on sustained low performance (not brief dips)
    if (_lowFPSCount >= 3 && _isActive && !_isPaused) {
      if (_averageFPS < _fpsCriticalThreshold) {
        // Critical: pause all animations
        debugPrint('🚨 AmbientAnimationController: Critical FPS ($_averageFPS), pausing all animations');
        pauseAll();
        
        // Resume after longer delay for critical issues
        Future.delayed(const Duration(seconds: 8), () {
          if (_averageFPS >= 35.0) {
            debugPrint('✅ AmbientAnimationController: Performance recovered, resuming');
            resumeAll();
          }
        });
      } else if (_averageFPS < _fpsWarningThreshold) {
        // Warning: reduce animation count by pausing 30% of controllers
        final controllersToReduce = (_controllers.length * 0.3).round();
        debugPrint('⚠️ AmbientAnimationController: Low FPS ($_averageFPS), reducing $controllersToReduce controllers');
        
        for (int i = 0; i < controllersToReduce && i < _controllers.length; i++) {
          _controllers[i].stop();
        }
        
        // Auto-resume when performance improves
        Future.delayed(const Duration(seconds: 5), () {
          if (_averageFPS >= 40.0) {
            debugPrint('✅ AmbientAnimationController: Performance improved, resuming reduced animations');
            startAll();
          }
        });
      }
    }
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

  /// Handle performance warning from the performance monitor
  void _onPerformanceWarning() {
    debugPrint('AmbientAnimationController: Performance warning - reducing animation intensity');
    
    // Reduce the number of active controllers by pausing some
    final controllersToReduce = (_controllers.length * 0.3).round();
    for (int i = 0; i < controllersToReduce && i < _controllers.length; i++) {
      if (_controllers[i].isAnimating) {
        _controllers[i].stop();
      }
    }
  }

  /// Handle critical performance issues from the performance monitor
  void _onPerformanceCritical() {
    debugPrint('AmbientAnimationController: Critical performance issue - pausing all animations');
    pauseAll();
  }

  /// Dispose all resources
  /// Get or create a shared controller for common animation types
  AnimationController? getSharedController(String type, Duration duration, TickerProvider vsync) {
    final key = '${type}_${duration.inMilliseconds}';
    
    if (_sharedControllers.containsKey(key)) {
      return _sharedControllers[key];
    }
    
    // Create shared controller if we haven't reached the limit
    if (_controllers.length + _sharedControllers.length < _maxConcurrentControllers) {
      final controller = AnimationController(
        duration: duration,
        vsync: vsync,
        debugLabel: 'Shared_$key',
      );
      
      _sharedControllers[key] = controller;
      registerController(controller);
      
      return controller;
    }
    
    return null; // No shared controller available
  }

  @override
  void dispose() {
    _performanceTimer?.cancel();
    
    // Stop advanced performance monitoring
    AnimationPerformanceMonitor.instance.removePerformanceWarningCallback(_onPerformanceWarning);
    AnimationPerformanceMonitor.instance.removePerformanceCriticalCallback(_onPerformanceCritical);
    AnimationPerformanceMonitor.instance.stopMonitoring();
    
    // Dispose shared controllers
    for (final controller in _sharedControllers.values) {
      controller.dispose();
    }
    _sharedControllers.clear();
    
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
      case AppLifecycleState.hidden:
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
    bool tryShared = false,
  }) {
    // Try to use shared controller for common animation types
    if (tryShared && debugLabel != null) {
      final shared = AmbientAnimationController.instance.getSharedController(
        debugLabel, 
        duration, 
        this,
      );
      if (shared != null) {
        return shared;
      }
    }
    
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