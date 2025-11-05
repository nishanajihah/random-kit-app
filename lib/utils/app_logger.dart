// lib/utils/app_logger.dart

import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  static late Logger _logger;
  static bool _initialized = false;

  // Initialize logger with environment
  static void initialize(String environment) {
    // Always show info in both environments
    final logLevel = Level.info;

    _logger = Logger(
      printer: PrettyPrinter(
        // Hide method call stack
        methodCount: 0,
        // Show 5 methods for errors
        errorMethodCount: 5,
        // Libe width
        lineLength: 80,
        // Colorful logs
        colors: true,
        // Print emojis
        printEmojis: true,
        // Print timestamp
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      // Debug in dev, warning only in production
      // level: kDebugMode ? Level.debug : Level.warning,
      level: logLevel,
    );

    _initialized = true;
  }

  // Debug level - Only shows in development
  // static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
  //   _logger.d(message, error: error, stackTrace: stackTrace);
  // }

  // Debug level - if development show debug
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) {
      // Keep this check to ensure debug logs only show in development
      if (kDebugMode) {
        _logger.d(message, error: error, stackTrace: stackTrace);
      }
    }
  }

  // Info level - Shows in development
  // static void info(String message, [dynamic error, StackTrace? stackTrace]) {
  //   _logger.i(message, error: error, stackTrace: stackTrace);
  // }

  // Info level - Shows in both dev and production
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  // Warning level - Shows in dev and production
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  // Error level - Shows in dev and production
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  // Fatal level - Critical errors only
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) {
      _logger.f(message, error: error, stackTrace: stackTrace);
    }
  }
}
