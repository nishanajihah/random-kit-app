// lib/services/high_score_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Service to persist and retrieve high scores using SharedPreferences
class HighScoreService {
  static const String _colorMemoryHighScoreKey = 'color_memory_high_score';

  /// Save high score if it beats the current stored score
  static Future<int> saveColorMemoryHighScore(int newScore) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentHigh = prefs.getInt(_colorMemoryHighScoreKey) ?? 0;
      if (newScore > currentHigh) {
        await prefs.setInt(_colorMemoryHighScoreKey, newScore);
        AppLogger.info('🏆 New persistent High Score saved: $newScore');
        return newScore;
      }
      return currentHigh;
    } catch (e) {
      AppLogger.error('Failed to save high score: $e');
      return newScore;
    }
  }

  /// Get stored high score
  static Future<int> getColorMemoryHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_colorMemoryHighScoreKey) ?? 0;
    } catch (e) {
      AppLogger.error('Failed to load high score: $e');
      return 0;
    }
  }
}
