import 'dart:developer' as developer;
import 'dart:convert';

/// Centralized logging utility for the Mixologist Flutter app.
/// Provides structured logging with user context and operation tracking.
class MixologistLogger {
  static const String _name = 'MixologistApp';

  /// Log levels matching backend logging
  static const int _debug = 0;
  static const int _info = 1;
  static const int _warning = 2;
  static const int _error = 3;

  /// Log a debug message
  static void debug(String message, {Map<String, dynamic>? extra}) {
    _log(_debug, '🔍 DEBUG', message, extra: extra);
  }

  /// Log an info message
  static void info(String message, {Map<String, dynamic>? extra}) {
    _log(_info, 'ℹ️ INFO', message, extra: extra);
  }

  /// Log a warning message
  static void warning(String message, {Map<String, dynamic>? extra}) {
    _log(_warning, '⚠️ WARNING', message, extra: extra);
  }

  /// Log an error message
  static void error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    final errorExtra = Map<String, dynamic>.from(extra ?? {});
    if (error != null) {
      errorExtra['error'] = error.toString();
    }
    if (stackTrace != null) {
      errorExtra['stack_trace'] = stackTrace.toString();
    }
    _log(_error, '❌ ERROR', message, extra: errorExtra);
  }

  /// Log user authentication events
  static void logAuth(String event, {
    String? userId,
    String? userEmail,
    bool success = true,
    Map<String, dynamic>? extra,
  }) {
    final authExtra = Map<String, dynamic>.from(extra ?? {});
    authExtra['operation'] = 'auth_$event';
    authExtra['success'] = success;
    if (userId != null) authExtra['user_id'] = userId;
    if (userEmail != null) authExtra['user_email'] = userEmail;

    final emoji = success ? '🔐' : '❌';
    final status = success ? 'successful' : 'failed';
    info('$emoji Auth ${_capitalize(event)}: $status', extra: authExtra);
  }

  /// Log user actions
  static void logUserAction(String userId, String action, {
    String? userEmail,
    Map<String, dynamic>? details,
  }) {
    final actionExtra = Map<String, dynamic>.from(details ?? {});
    actionExtra['user_id'] = userId;
    actionExtra['operation'] = action;
    if (userEmail != null) actionExtra['user_email'] = userEmail;

    info('👤 User Action: $action', extra: actionExtra);
  }

  /// Log inventory operations
  static void logInventoryOperation(String userId, String operation, {
    String? itemId,
    String? itemName,
    int? itemCount,
    Map<String, dynamic>? extra,
  }) {
    final inventoryExtra = Map<String, dynamic>.from(extra ?? {});
    inventoryExtra['user_id'] = userId;
    inventoryExtra['operation'] = 'inventory_$operation';
    if (itemId != null) inventoryExtra['item_id'] = itemId;
    if (itemName != null) inventoryExtra['item_name'] = itemName;
    if (itemCount != null) inventoryExtra['item_count'] = itemCount;

    info('📦 Inventory ${_capitalize(operation)}: ${itemName ?? itemId ?? 'bulk'}', 
         extra: inventoryExtra);
  }

  /// Log HTTP requests
  static void logHttpRequest(String method, String endpoint, {
    String? userId,
    int? statusCode,
    int? responseTimeMs,
    Map<String, dynamic>? extra,
  }) {
    final httpExtra = Map<String, dynamic>.from(extra ?? {});
    httpExtra['operation'] = 'http_request';
    httpExtra['method'] = method;
    httpExtra['endpoint'] = endpoint;
    if (userId != null) httpExtra['user_id'] = userId;
    if (statusCode != null) httpExtra['status_code'] = statusCode;
    if (responseTimeMs != null) httpExtra['response_time_ms'] = responseTimeMs;

    final emoji = _getHttpEmoji(statusCode);
    final timing = responseTimeMs != null ? ' (${responseTimeMs}ms)' : '';
    info('$emoji HTTP $method $endpoint$timing', extra: httpExtra);
  }

  /// Log app lifecycle events
  static void logAppEvent(String event, {Map<String, dynamic>? extra}) {
    final appExtra = Map<String, dynamic>.from(extra ?? {});
    appExtra['operation'] = 'app_$event';
    info('📱 App ${_capitalize(event)}', extra: appExtra);
  }

  /// Log navigation events
  static void logNavigation(String from, String to, {
    String? userId,
    Map<String, dynamic>? extra,
  }) {
    final navExtra = Map<String, dynamic>.from(extra ?? {});
    navExtra['operation'] = 'navigation';
    navExtra['from_screen'] = from;
    navExtra['to_screen'] = to;
    if (userId != null) navExtra['user_id'] = userId;

    info('📍 Navigation: $from → $to', extra: navExtra);
  }

  /// Internal logging method
  static void _log(int level, String levelName, String message, {Map<String, dynamic>? extra}) {
    final now = DateTime.now().toUtc();
    
    // Create structured log entry similar to backend
    final Map<String, dynamic> logEntry = {
      'timestamp': now.toIso8601String(),
      'level': levelName.replaceAll(RegExp(r'[^\w]'), ''),
      'logger': _name,
      'message': message,
      'platform': 'flutter',
    };

    // Add extra context if provided
    if (extra != null) {
      logEntry.addAll(extra);
    }

    // Convert to JSON for structured logging
    final jsonLog = json.encode(logEntry);

    // Use developer.log for better debugging in development
    developer.log(
      jsonLog,
      name: _name,
      level: level,
      time: now,
    );

    // Also print to console for easier reading during development
    print('[$levelName] [$_name] $message ${extra != null ? extra.toString() : ''}');
  }

  /// Helper methods
  static String _capitalize(String text) {
    return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
  }

  static String _getHttpEmoji(int? statusCode) {
    if (statusCode == null) return '🌐';
    if (statusCode >= 200 && statusCode < 300) return '✅';
    if (statusCode >= 400 && statusCode < 500) return '⚠️';
    if (statusCode >= 500) return '❌';
    return '🌐';
  }
}

/// Extension for easy logging on any object
extension LoggingExtension on Object {
  void logDebug(String message, {Map<String, dynamic>? extra}) {
    MixologistLogger.debug('[$runtimeType] $message', extra: extra);
  }

  void logInfo(String message, {Map<String, dynamic>? extra}) {
    MixologistLogger.info('[$runtimeType] $message', extra: extra);
  }

  void logWarning(String message, {Map<String, dynamic>? extra}) {
    MixologistLogger.warning('[$runtimeType] $message', extra: extra);
  }

  void logError(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    MixologistLogger.error('[$runtimeType] $message', 
        error: error, stackTrace: stackTrace, extra: extra);
  }
}