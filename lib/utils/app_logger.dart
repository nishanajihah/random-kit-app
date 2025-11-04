// lib/utils/app_logger.dart

import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  static final Logger _logger = Logger(
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
    level: kDebugMode ? Level.debug : Level.warning,
  );

  // Debug level - Only shows in development
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  // Info level - Shows in development
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  // Warning level - Shows in dev and production
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  // Error level - Shows in dev and production
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // Fatal level - Critical errors only
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
