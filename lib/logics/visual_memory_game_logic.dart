// ib/logics/visual_memory_game_logic.dart

import 'dart:ui';
import '../models/game_item.dart';

// Logic for Visual Memory Game - generates sequences of colors and checks player input
// Defines available colors and creates ColorGameItems
class VisualMemoryGameLogic {
  // Color palette for the game
  static final List<GameColor> _gameColors = [
    GameColor(id: 'red', name: '🔴 Red', color: const Color(0xFFE74C3C)),
    GameColor(id: 'blue', name: '🔵 Blue', color: const Color(0xFF3498DB)),
    GameColor(id: 'green', name: '🟢 Green', color: const Color(0xFF2ECC71)),
    GameColor(id: 'yellow', name: '🟡 Yellow', color: const Color(0xFFF1C40F)),
    GameColor(id: 'purple', name: '🟣 Purple', color: const Color(0xFF9B59B6)),
    GameColor(id: 'orange', name: '🟠 Orange', color: const Color(0xFFE67E22)),
  ];

  // Get allll available color game items
  static List<ColorGameItem> getAvailableItems() {
    return _gameColors
        .map(
          (gc) => ColorGameItem(
            id: gc.id,
            displayName: gc.name,
            colorValue: gc.color.toARGB32(),
            durationMs: 800, //show each color for 800ms
          ),
        )
        .toList();
  }

  /// Get a specific color by ID
  static GameColor? getColorById(String id) {
    try {
      return _gameColors.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get totall number of colors
  static int getTotalColorsCount() => _gameColors.length;
}

// Helper class to store color information
class GameColor {
  final String id;
  final String name;
  final Color color;

  GameColor({required this.id, required this.name, required this.color});
}
