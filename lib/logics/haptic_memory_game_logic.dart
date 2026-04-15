// lib/logics/haptic_memory_game_logic.dart

import '../models/game_item.dart';

/// Logic for the Haptic Memory Game
/// Defines available vibration patterns and creates HapticGameItems
class HapticMemoryGameLogic {
  // Vibration patterns for the game
  static final List<GamePattern> _gamePatterns = [
    GamePattern(id: 'short', name: '⚡ Short', pattern: [0, 100]),
    GamePattern(id: 'double', name: '👆 Double', pattern: [0, 100, 100, 100]),
    GamePattern(id: 'long', name: '➖ Long', pattern: [0, 300]),
    GamePattern(
      id: 'pulse',
      name: '💓 Pulse',
      pattern: [0, 100, 100, 100, 100, 100],
    ),
    GamePattern(
      id: 'wave',
      name: '🌊 Wave',
      pattern: [0, 150, 50, 200, 50, 150],
    ),
  ];

  /// Get all available haptic game items
  static List<HapticGameItem> getAvailableItems() {
    return _gamePatterns
        .map(
          (gp) => HapticGameItem(
            id: gp.id,
            displayName: gp.name,
            vibrationPattern: gp.pattern,
          ),
        )
        .toList();
  }

  /// Get a specific pattern by ID
  static GamePattern? getPatternById(String id) {
    try {
      return _gamePatterns.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get total number of patterns
  static int getTotalPatternsCount() => _gamePatterns.length;
}

/// Helper class to store pattern information
class GamePattern {
  final String id;
  final String name;
  final List<int> pattern;

  GamePattern({required this.id, required this.name, required this.pattern});
}
