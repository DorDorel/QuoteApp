import 'dart:developer' as devtools show log;
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Logger {
  // Singleton instance
  static final Logger _instance = Logger._internal();

  // Firebase Analytics instance
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Factory constructor
  factory Logger() => _instance;

  // Internal constructor
  Logger._internal();

  // Log levels
  static const String _INFO = "INFO";
  static const String _WARNING = "WARNING";
  static const String _ERROR = "ERROR";

  // Colors for console output (ANSI escape codes)
  static const String _RESET = "\x1B[0m";
  static const String _GREEN = "\x1B[32m";
  static const String _YELLOW = "\x1B[33m";
  static const String _RED = "\x1B[31m";

  // Firebase Analytics event names (keep under 40 characters per Firebase requirements)
  static const String _EVENT_INFO = "log_info";
  static const String _EVENT_WARNING = "log_warning";
  static const String _EVENT_ERROR = "log_error";
  static const String _EVENT_EXCEPTION = "log_exception";

  // Get Firebase Analytics instance for direct access if needed
  FirebaseAnalytics get analytics => _analytics;

  // Info level logging
  void info(String message, {String? tag}) {
    _log(_INFO, message, tag: tag, color: _GREEN);
    _logAnalyticsEvent(_EVENT_INFO, {
      'message': message,
      'tag': tag ?? 'untagged',
    });
  }

  // Warning level logging
  void warning(String message, {String? tag}) {
    _log(_WARNING, message, tag: tag, color: _YELLOW);
    _logAnalyticsEvent(_EVENT_WARNING, {
      'message': message,
      'tag': tag ?? 'untagged',
    });
  }

  // Error level logging
  void error(String message,
      {String? tag, Object? exception, StackTrace? stackTrace}) {
    _log(_ERROR, message,
        tag: tag, color: _RED, exception: exception, stackTrace: stackTrace);

    final Map<String, dynamic> params = {
      'message': message,
      'tag': tag ?? 'untagged',
    };

    if (exception != null) {
      params['exception'] = exception.toString();
    }

    _logAnalyticsEvent(_EVENT_ERROR, params);

    // Log as a Firebase Analytics error event for better tracking
    _analytics.logEvent(
      name: _EVENT_EXCEPTION,
      parameters: {
        'fatal': true,
        'message': message,
        'exception': exception?.toString() ?? 'unknown',
      },
    );
  }

  // Track user actions and screens
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
    info('Screen view: $screenName', tag: 'Navigation');
  }

  // Track user interactions (clicks, selections, etc.)
  Future<void> logUserAction(String action, Map<String, Object> map,
      {Map<String, dynamic>? parameters}) async {
    await _logAnalyticsEvent(action, parameters);
    info('User action: $action', tag: 'Interaction');
  }

  // Track business events (bid created, product added, etc.)
  Future<void> logBusinessEvent(String event, Map<String, String?> map,
      {Map<String, dynamic>? parameters}) async {
    await _logAnalyticsEvent(event, parameters);
    info('Business event: $event', tag: 'Business');
  }

  // Internal logging method
  void _log(String level, String message,
      {String? tag,
      String color = "",
      Object? exception,
      StackTrace? stackTrace}) {
    if (kDebugMode) {
      final now = DateTime.now();
      final timeString =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      final tagString = tag != null ? "[$tag]" : "";

      devtools.log("$color$timeString [$level]$tagString: $message$_RESET");

      if (exception != null) {
        devtools.log("$color$timeString [$level] Exception: $exception$_RESET");
      }

      if (stackTrace != null) {
        devtools
            .log("$color$timeString [$level] StackTrace: $stackTrace$_RESET");
      }
    }
  }

  // Log to Firebase Analytics
  Future<void> _logAnalyticsEvent(
      String eventName, Map<String, dynamic>? parameters) async {
    try {
      // Trim event name to fit Firebase's requirements (max 40 characters)
      final String safeEventName =
          eventName.length > 40 ? eventName.substring(0, 40) : eventName;

      // Firebase has limits on parameter values (string: 100 chars)
      final Map<String, dynamic> safeParams = {};

      if (parameters != null) {
        parameters.forEach((key, value) {
          if (value is String && value.length > 100) {
            safeParams[key] = value.substring(0, 100);
          } else {
            safeParams[key] = value;
          }
        });
      }

      await _analytics.logEvent(
        name: safeEventName,
        parameters: safeParams.cast<String, Object>(),
      );
    } catch (e) {
      if (kDebugMode) {
        devtools.log("${_RED}Failed to log analytics event: $e$_RESET");
      }
    }
  }

  // Set user properties for segmentation
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}

// Extension method for backward compatibility
extension Log on Object {
  void log() => devtools.log(toString());
}
