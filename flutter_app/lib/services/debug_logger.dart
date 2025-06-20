import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Comprehensive debug logging service for tracking all user actions and state changes
class DebugLogger {
  static DebugLogger? _instance;
  static DebugLogger get instance => _instance ??= DebugLogger._internal();
  DebugLogger._internal();

  static const String _prefix = '🔍 DEBUG';
  static const String _stepPrefix = '🎯 STEP';
  static const String _guiPrefix = '🖥️ GUI';
  static const String _animationPrefix = '🎬 ANIMATION';
  static const String _statePrefix = '📊 STATE';
  static const String _errorPrefix = '❌ ERROR';
  static const String _performancePrefix = '⚡ PERFORMANCE';
  static const String _userPrefix = '👤 USER';
  static const String _systemPrefix = '⚙️ SYSTEM';

  bool _isEnabled = true;
  int _actionCounter = 0;

  void enable() => _isEnabled = true;
  void disable() => _isEnabled = false;
  bool get isEnabled => _isEnabled;

  /// Log user actions like taps, swipes, etc.
  void logUserAction(String action, {Map<String, dynamic>? details}) {
    if (!_isEnabled) return;
    _actionCounter++;
    final timestamp = DateTime.now().toIso8601String();
    final detailsStr = details != null ? ' | ${_formatDetails(details)}' : '';
    _log('$_userPrefix #$_actionCounter', '[$timestamp] $action$detailsStr');
  }

  /// Log step-related actions
  void logStepAction(String action, {
    int? stepNumber,
    String? stepText,
    bool? completed,
    double? progress,
    Map<String, dynamic>? details,
  }) {
    if (!_isEnabled) return;
    _actionCounter++;
    final timestamp = DateTime.now().toIso8601String();
    final stepInfo = stepNumber != null ? ' Step $stepNumber' : '';
    final completedInfo = completed != null ? ' (${completed ? "✅" : "⏳"})' : '';
    final progressInfo = progress != null ? ' Progress: ${(progress * 100).toStringAsFixed(1)}%' : '';
    final textInfo = stepText != null ? ' | "$stepText"' : '';
    final detailsStr = details != null ? ' | ${_formatDetails(details)}' : '';
    
    _log('$_stepPrefix #$_actionCounter', 
         '[$timestamp]$stepInfo$completedInfo$progressInfo | $action$textInfo$detailsStr');
  }

  /// Log GUI state changes
  void logGuiState(String component, String state, {
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
    Map<String, dynamic>? details,
  }) {
    if (!_isEnabled) return;
    _actionCounter++;
    final timestamp = DateTime.now().toIso8601String();
    final beforeStr = before != null ? ' | Before: ${_formatDetails(before)}' : '';
    final afterStr = after != null ? ' | After: ${_formatDetails(after)}' : '';
    final detailsStr = details != null ? ' | ${_formatDetails(details)}' : '';
    
    _log('$_guiPrefix #$_actionCounter', 
         '[$timestamp] $component → $state$beforeStr$afterStr$detailsStr');
  }

  /// Log animation events
  void logAnimation(String animationType, String event, {
    String? target,
    double? value,
    Duration? duration,
    String? curve,
    Map<String, dynamic>? details,
  }) {
    if (!_isEnabled) return;
    _actionCounter++;
    final timestamp = DateTime.now().toIso8601String();
    final targetInfo = target != null ? ' Target: $target' : '';
    final valueInfo = value != null ? ' Value: $value' : '';
    final durationInfo = duration != null ? ' Duration: ${duration.inMilliseconds}ms' : '';
    final curveInfo = curve != null ? ' Curve: $curve' : '';
    final detailsStr = details != null ? ' | ${_formatDetails(details)}' : '';
    
    _log('$_animationPrefix #$_actionCounter', 
         '[$timestamp] $animationType → $event$targetInfo$valueInfo$durationInfo$curveInfo$detailsStr');
  }

  /// Log state changes
  void logStateChange(String stateName, dynamic oldValue, dynamic newValue, {
    String? component,
    Map<String, dynamic>? details,
  }) {
    if (!_isEnabled) return;
    _actionCounter++;
    final timestamp = DateTime.now().toIso8601String();
    final componentInfo = component != null ? ' [$component]' : '';
    final detailsStr = details != null ? ' | ${_formatDetails(details)}' : '';
    
    _log('$_statePrefix #$_actionCounter', 
         '[$timestamp]$componentInfo $stateName: $oldValue → $newValue$detailsStr');
  }

  /// Log errors with stack trace context
  void logError(String error, {
    String? component,
    StackTrace? stackTrace,
    Map<String, dynamic>? details,
  }) {
    if (!_isEnabled) return;
    _actionCounter++;
    final timestamp = DateTime.now().toIso8601String();
    final componentInfo = component != null ? ' [$component]' : '';
    final detailsStr = details != null ? ' | ${_formatDetails(details)}' : '';
    final stackInfo = stackTrace != null ? '\nStack: ${stackTrace.toString().split('\n').take(5).join('\n')}' : '';
    
    _log('$_errorPrefix #$_actionCounter', 
         '[$timestamp]$componentInfo $error$detailsStr$stackInfo');
  }

  /// Log performance metrics
  void logPerformance(String metric, double value, {
    String? unit,
    String? component,
    Map<String, dynamic>? details,
  }) {
    if (!_isEnabled) return;
    _actionCounter++;
    final timestamp = DateTime.now().toIso8601String();
    final componentInfo = component != null ? ' [$component]' : '';
    final unitInfo = unit != null ? unit : '';
    final detailsStr = details != null ? ' | ${_formatDetails(details)}' : '';
    
    _log('$_performancePrefix #$_actionCounter', 
         '[$timestamp]$componentInfo $metric: $value$unitInfo$detailsStr');
  }

  /// Log system events
  void logSystem(String event, {
    Map<String, dynamic>? details,
  }) {
    if (!_isEnabled) return;
    _actionCounter++;
    final timestamp = DateTime.now().toIso8601String();
    final detailsStr = details != null ? ' | ${_formatDetails(details)}' : '';
    
    _log('$_systemPrefix #$_actionCounter', '[$timestamp] $event$detailsStr');
  }

  /// Log widget lifecycle events
  void logWidgetLifecycle(String widget, String event, {
    Map<String, dynamic>? details,
  }) {
    if (!_isEnabled) return;
    _actionCounter++;
    final timestamp = DateTime.now().toIso8601String();
    final detailsStr = details != null ? ' | ${_formatDetails(details)}' : '';
    
    _log('$_guiPrefix #$_actionCounter', '[$timestamp] $widget.$event$detailsStr');
  }

  /// Create a scoped logger for tracking a specific operation
  ScopedLogger createScopedLogger(String scope) {
    return ScopedLogger._(this, scope);
  }

  /// Format details map into readable string
  String _formatDetails(Map<String, dynamic> details) {
    return details.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
  }

  /// Internal logging method
  void _log(String prefix, String message) {
    if (!_isEnabled) return;
    
    final fullMessage = '$prefix $message';
    
    // Force output to debugPrint so it appears in Flutter console
    debugPrint(fullMessage);
    
    // Also use developer.log for DevTools integration
    if (kDebugMode) {
      developer.log(fullMessage, name: 'MixologistDebug');
    }
  }

  /// Reset action counter (useful for testing)
  void resetCounter() {
    _actionCounter = 0;
  }

  /// Get current action count
  int get actionCount => _actionCounter;
}

/// Scoped logger for tracking operations with automatic completion logging
class ScopedLogger {
  final DebugLogger _logger;
  final String _scope;
  final DateTime _startTime;
  final Map<String, dynamic> _context = {};

  ScopedLogger._(this._logger, this._scope) : _startTime = DateTime.now() {
    _logger.logSystem('Started: $_scope');
  }

  /// Add context to this scoped operation
  void addContext(String key, dynamic value) {
    _context[key] = value;
  }

  /// Log a step within this scope
  void step(String step, {Map<String, dynamic>? details}) {
    final combinedDetails = {..._context, if (details != null) ...details};
    _logger.logSystem('$_scope | $step', details: combinedDetails);
  }

  /// Log completion of this scope
  void complete({String? result, Map<String, dynamic>? details}) {
    final duration = DateTime.now().difference(_startTime);
    final combinedDetails = {
      ..._context, 
      'duration_ms': duration.inMilliseconds,
      if (details != null) ...details
    };
    _logger.logSystem('Completed: $_scope${result != null ? " | Result: $result" : ""}', 
                     details: combinedDetails);
  }

  /// Log an error within this scope
  void error(String error, {StackTrace? stackTrace}) {
    final duration = DateTime.now().difference(_startTime);
    _logger.logError('$_scope | $error', 
                    details: {..._context, 'duration_ms': duration.inMilliseconds},
                    stackTrace: stackTrace);
  }
}

/// Extension methods for easy logging integration
extension WidgetDebugLogging on State {
  void logLifecycle(String event, {Map<String, dynamic>? details}) {
    DebugLogger.instance.logWidgetLifecycle(
      widget.runtimeType.toString(), 
      event, 
      details: details
    );
  }

  void logStateChange(String stateName, dynamic oldValue, dynamic newValue, {Map<String, dynamic>? details}) {
    DebugLogger.instance.logStateChange(
      stateName, 
      oldValue, 
      newValue, 
      component: widget.runtimeType.toString(),
      details: details
    );
  }

  void logUserAction(String action, {Map<String, dynamic>? details}) {
    DebugLogger.instance.logUserAction(action, details: {
      'widget': widget.runtimeType.toString(),
      if (details != null) ...details,
    });
  }
}