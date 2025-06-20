import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'dart:collection';
import 'ambient_animation_controller.dart';

/// DISABLED: Performance monitoring disabled to prevent performance overhead

/// Performance metrics data structure
class PerformanceMetrics {
  const PerformanceMetrics({
    required this.averageFPS,
    required this.minFPS,
    required this.maxFPS,
    required this.frameDropCount,
    required this.memoryUsage,
    required this.activeAnimations,
    required this.timestamp,
  });

  final double averageFPS;
  final double minFPS;
  final double maxFPS;
  final int frameDropCount;
  final double memoryUsage; // MB
  final int activeAnimations;
  final DateTime timestamp;

  @override
  String toString() {
    return 'PerformanceMetrics(avgFPS: ${averageFPS.toStringAsFixed(1)}, '
           'minFPS: ${minFPS.toStringAsFixed(1)}, '
           'maxFPS: ${maxFPS.toStringAsFixed(1)}, '
           'drops: $frameDropCount, '
           'memory: ${memoryUsage.toStringAsFixed(1)}MB, '
           'animations: $activeAnimations)';
  }
}

/// Performance monitoring system for ambient animations
class AnimationPerformanceMonitor with ChangeNotifier {
  static AnimationPerformanceMonitor? _instance;
  
  /// Singleton instance
  static AnimationPerformanceMonitor get instance {
    _instance ??= AnimationPerformanceMonitor._internal();
    return _instance!;
  }

  AnimationPerformanceMonitor._internal() {
    _initialize();
  }

  // Configuration
  static const int _maxMetricsHistory = 100;
  static const Duration _monitoringInterval = Duration(seconds: 2);
  static const double _fpsThresholdCritical = 25.0;
  static const double _fpsThresholdWarning = 45.0;
  static const int _frameDropThreshold = 5;

  // Monitoring state
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  
  // Frame tracking
  final Queue<double> _frameTimes = Queue<double>();
  final Queue<Duration> _frameIntervals = Queue<Duration>();
  DateTime _lastFrameTime = DateTime.now();
  int _frameDropCount = 0;
  
  // Performance history
  final Queue<PerformanceMetrics> _metricsHistory = Queue<PerformanceMetrics>();
  
  // Current metrics
  PerformanceMetrics? _currentMetrics;
  
  // Performance state
  PerformanceLevel _currentPerformanceLevel = PerformanceLevel.optimal;
  bool _automaticOptimization = true;
  
  // Callbacks
  final List<VoidCallback> _performanceWarningCallbacks = [];
  final List<VoidCallback> _performanceCriticalCallbacks = [];

  /// Current performance metrics
  PerformanceMetrics? get currentMetrics => _currentMetrics;
  
  /// Performance level
  PerformanceLevel get performanceLevel => _currentPerformanceLevel;
  
  /// Whether automatic optimization is enabled
  bool get automaticOptimization => _automaticOptimization;
  
  /// Whether monitoring is active
  bool get isMonitoring => _isMonitoring;
  
  /// Metrics history (last 100 measurements)
  List<PerformanceMetrics> get metricsHistory => _metricsHistory.toList();

  /// Initialize the performance monitor
  void _initialize() {
    // Add frame callback for continuous monitoring
    if (kDebugMode) {
      SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
    }
  }

  /// Start performance monitoring
  void startMonitoring() {
    // DISABLED: Performance monitoring disabled to prevent overhead
    debugPrint('🚫 AnimationPerformanceMonitor: monitoring disabled');
  }

  /// DISABLED: Stop performance monitoring
  void stopMonitoring() {
    // DISABLED: No monitoring to stop
    debugPrint('🚫 AnimationPerformanceMonitor: stop monitoring disabled');
  }

  /// Enable or disable automatic optimization
  void setAutomaticOptimization(bool enabled) {
    _automaticOptimization = enabled;
    debugPrint('AnimationPerformanceMonitor: Automatic optimization ${enabled ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  /// Force disable animations if performance is critical
  void disableIfLowPerformance() {
    if (_currentPerformanceLevel == PerformanceLevel.critical) {
      AmbientAnimationController.instance.pauseAll();
      debugPrint('AnimationPerformanceMonitor: Disabled animations due to critical performance');
    }
  }

  /// Track frame rate
  void trackFrameRate() {
    // This is automatically called by _onFrame when monitoring is active
  }

  /// Add callback for performance warnings
  void addPerformanceWarningCallback(VoidCallback callback) {
    _performanceWarningCallbacks.add(callback);
  }

  /// Add callback for critical performance issues
  void addPerformanceCriticalCallback(VoidCallback callback) {
    _performanceCriticalCallbacks.add(callback);
  }

  /// Remove callbacks
  void removePerformanceWarningCallback(VoidCallback callback) {
    _performanceWarningCallbacks.remove(callback);
  }

  void removePerformanceCriticalCallback(VoidCallback callback) {
    _performanceCriticalCallbacks.remove(callback);
  }

  /// Log performance metrics
  void logPerformanceMetrics() {
    if (_currentMetrics != null) {
      debugPrint('Performance: $_currentMetrics');
    }
  }

  /// Frame callback for tracking frame times
  void _onFrame(Duration timestamp) {
    if (!_isMonitoring) return;
    
    final now = DateTime.now();
    final interval = now.difference(_lastFrameTime);
    
    // Track frame intervals
    _frameIntervals.addLast(interval);
    if (_frameIntervals.length > 60) { // Keep last 60 frames (1 second at 60fps)
      _frameIntervals.removeFirst();
    }
    
    // Calculate current FPS
    final fps = 1000.0 / interval.inMilliseconds;
    _frameTimes.addLast(fps);
    if (_frameTimes.length > 60) {
      _frameTimes.removeFirst();
    }
    
    // Track frame drops (intervals > 20ms indicate dropped frames)
    if (interval.inMilliseconds > 20) {
      _frameDropCount++;
    }
    
    _lastFrameTime = now;
  }

  /// Calculate performance metrics
  void _calculateMetrics() {
    if (_frameTimes.isEmpty) return;
    
    // Calculate FPS statistics
    final frameTimesList = _frameTimes.toList();
    final averageFPS = frameTimesList.reduce((a, b) => a + b) / frameTimesList.length;
    final minFPS = frameTimesList.reduce((a, b) => a < b ? a : b);
    final maxFPS = frameTimesList.reduce((a, b) => a > b ? a : b);
    
    // Get memory usage (simplified estimate)
    final memoryUsage = _estimateMemoryUsage();
    
    // Get active animation count
    final activeAnimations = AmbientAnimationController.instance.controllerCount;
    
    // Create metrics
    final metrics = PerformanceMetrics(
      averageFPS: averageFPS,
      minFPS: minFPS,
      maxFPS: maxFPS,
      frameDropCount: _frameDropCount,
      memoryUsage: memoryUsage,
      activeAnimations: activeAnimations,
      timestamp: DateTime.now(),
    );
    
    _currentMetrics = metrics;
    
    // Add to history
    _metricsHistory.addLast(metrics);
    if (_metricsHistory.length > _maxMetricsHistory) {
      _metricsHistory.removeFirst();
    }
    
    // Update performance level
    _updatePerformanceLevel(metrics);
    
    // Apply automatic optimizations if enabled
    if (_automaticOptimization) {
      _applyAutomaticOptimizations();
    }
    
    // Reset frame drop counter
    _frameDropCount = 0;
    
    notifyListeners();
  }

  /// Estimate memory usage (simplified)
  double _estimateMemoryUsage() {
    // This is a simplified estimate
    // In a real implementation, you might use platform-specific APIs
    final activeAnimations = AmbientAnimationController.instance.controllerCount;
    final baseMemory = 10.0; // Base app memory in MB
    final animationMemory = activeAnimations * 0.5; // 0.5MB per animation estimate
    
    return baseMemory + animationMemory;
  }

  /// Update performance level based on metrics
  void _updatePerformanceLevel(PerformanceMetrics metrics) {
    final previousLevel = _currentPerformanceLevel;
    
    if (metrics.averageFPS < _fpsThresholdCritical || 
        metrics.frameDropCount > _frameDropThreshold * 2) {
      _currentPerformanceLevel = PerformanceLevel.critical;
    } else if (metrics.averageFPS < _fpsThresholdWarning || 
               metrics.frameDropCount > _frameDropThreshold) {
      _currentPerformanceLevel = PerformanceLevel.warning;
    } else {
      _currentPerformanceLevel = PerformanceLevel.optimal;
    }
    
    // Trigger callbacks if level changed
    if (previousLevel != _currentPerformanceLevel) {
      _onPerformanceLevelChanged(previousLevel, _currentPerformanceLevel);
    }
  }

  /// Handle performance level changes
  void _onPerformanceLevelChanged(PerformanceLevel from, PerformanceLevel to) {
    debugPrint('AnimationPerformanceMonitor: Performance level changed from $from to $to');
    
    switch (to) {
      case PerformanceLevel.warning:
        for (final callback in _performanceWarningCallbacks) {
          callback();
        }
        break;
      case PerformanceLevel.critical:
        for (final callback in _performanceCriticalCallbacks) {
          callback();
        }
        break;
      case PerformanceLevel.optimal:
        // Performance improved
        break;
    }
  }

  /// Apply automatic performance optimizations
  void _applyAutomaticOptimizations() {
    final controller = AmbientAnimationController.instance;
    
    switch (_currentPerformanceLevel) {
      case PerformanceLevel.optimal:
        // Ensure animations are running if they should be
        if (!controller.isActive) {
          controller.setActive(true);
        }
        break;
        
      case PerformanceLevel.warning:
        // Reduce animation intensity but keep running
        debugPrint('AnimationPerformanceMonitor: Performance warning - consider reducing animation complexity');
        break;
        
      case PerformanceLevel.critical:
        // Pause animations to improve performance
        if (controller.isActive) {
          controller.pauseAll();
          debugPrint('AnimationPerformanceMonitor: Critical performance - paused animations');
        }
        break;
    }
  }

  /// Get performance summary for the last period
  PerformanceSummary getPerformanceSummary({Duration? period}) {
    period ??= const Duration(minutes: 5);
    
    final cutoffTime = DateTime.now().subtract(period);
    final recentMetrics = _metricsHistory
        .where((m) => m.timestamp.isAfter(cutoffTime))
        .toList();
    
    if (recentMetrics.isEmpty) {
      return PerformanceSummary.empty();
    }
    
    final avgFPS = recentMetrics
        .map((m) => m.averageFPS)
        .reduce((a, b) => a + b) / recentMetrics.length;
    
    final totalFrameDrops = recentMetrics
        .map((m) => m.frameDropCount)
        .reduce((a, b) => a + b);
    
    final maxMemory = recentMetrics
        .map((m) => m.memoryUsage)
        .reduce((a, b) => a > b ? a : b);
    
    final warningCount = recentMetrics
        .where((m) => m.averageFPS < _fpsThresholdWarning)
        .length;
    
    final criticalCount = recentMetrics
        .where((m) => m.averageFPS < _fpsThresholdCritical)
        .length;
    
    return PerformanceSummary(
      period: period,
      averageFPS: avgFPS,
      totalFrameDrops: totalFrameDrops,
      maxMemoryUsage: maxMemory,
      warningPeriods: warningCount,
      criticalPeriods: criticalCount,
      sampleCount: recentMetrics.length,
    );
  }

  @override
  void dispose() {
    stopMonitoring();
    _performanceWarningCallbacks.clear();
    _performanceCriticalCallbacks.clear();
    super.dispose();
  }
}

/// Performance level indicators
enum PerformanceLevel {
  optimal,
  warning,
  critical,
}

/// Performance summary for a period
class PerformanceSummary {
  const PerformanceSummary({
    required this.period,
    required this.averageFPS,
    required this.totalFrameDrops,
    required this.maxMemoryUsage,
    required this.warningPeriods,
    required this.criticalPeriods,
    required this.sampleCount,
  });

  final Duration period;
  final double averageFPS;
  final int totalFrameDrops;
  final double maxMemoryUsage;
  final int warningPeriods;
  final int criticalPeriods;
  final int sampleCount;

  factory PerformanceSummary.empty() {
    return const PerformanceSummary(
      period: Duration.zero,
      averageFPS: 0.0,
      totalFrameDrops: 0,
      maxMemoryUsage: 0.0,
      warningPeriods: 0,
      criticalPeriods: 0,
      sampleCount: 0,
    );
  }

  @override
  String toString() {
    return 'PerformanceSummary(${period.inMinutes}m: '
           'avgFPS: ${averageFPS.toStringAsFixed(1)}, '
           'drops: $totalFrameDrops, '
           'memory: ${maxMemoryUsage.toStringAsFixed(1)}MB, '
           'warnings: $warningPeriods, '
           'critical: $criticalPeriods)';
  }
}

/// Widget that displays performance metrics in debug mode
class PerformanceOverlay extends StatelessWidget {
  const PerformanceOverlay({
    super.key,
    required this.child,
    this.showInRelease = false,
  });

  final Widget child;
  final bool showInRelease;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode && !showInRelease) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          top: 50,
          right: 10,
          child: _PerformanceDisplay(),
        ),
      ],
    );
  }
}

class _PerformanceDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnimationPerformanceMonitor.instance,
      builder: (context, child) {
        final monitor = AnimationPerformanceMonitor.instance;
        final metrics = monitor.currentMetrics;
        
        if (metrics == null || !monitor.isMonitoring) {
          return const SizedBox.shrink();
        }

        Color backgroundColor;
        switch (monitor.performanceLevel) {
          case PerformanceLevel.optimal:
            backgroundColor = Colors.green.withOpacity(0.8);
            break;
          case PerformanceLevel.warning:
            backgroundColor = Colors.orange.withOpacity(0.8);
            break;
          case PerformanceLevel.critical:
            backgroundColor = Colors.red.withOpacity(0.8);
            break;
        }

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FPS: ${metrics.averageFPS.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                'Drops: ${metrics.frameDropCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
              Text(
                'Anims: ${metrics.activeAnimations}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Mixin for widgets that want to react to performance changes
mixin PerformanceAware<T extends StatefulWidget> on State<T> {
  bool _performanceCallbacksAdded = false;
  
  @override
  void initState() {
    super.initState();
    _addPerformanceCallbacks();
  }
  
  void _addPerformanceCallbacks() {
    if (!_performanceCallbacksAdded) {
      AnimationPerformanceMonitor.instance.addPerformanceWarningCallback(_onPerformanceWarning);
      AnimationPerformanceMonitor.instance.addPerformanceCriticalCallback(_onPerformanceCritical);
      _performanceCallbacksAdded = true;
    }
  }
  
  @override
  void dispose() {
    if (_performanceCallbacksAdded) {
      AnimationPerformanceMonitor.instance.removePerformanceWarningCallback(_onPerformanceWarning);
      AnimationPerformanceMonitor.instance.removePerformanceCriticalCallback(_onPerformanceCritical);
    }
    super.dispose();
  }
  
  /// Called when performance warning threshold is reached
  void _onPerformanceWarning() {
    onPerformanceWarning();
  }
  
  /// Called when performance critical threshold is reached
  void _onPerformanceCritical() {
    onPerformanceCritical();
  }
  
  /// Override this to handle performance warnings
  void onPerformanceWarning() {}
  
  /// Override this to handle critical performance issues
  void onPerformanceCritical() {}
}