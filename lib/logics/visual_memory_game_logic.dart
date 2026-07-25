// lib/logics/visual_memory_game_logic.dart

import 'dart:ui';
import '../models/game_item.dart';

// Logic for Visual Memory Game - generates sequences of colors and creates ColorGameItems
class VisualMemoryGameLogic {
  // 9 Vibrant Color palette for progressive levels (2x2 grid for levels 1-2, 3x2 grid for levels 3-4, 3x3 grid for levels 5+)
  static final List<GameColor> _allGameColors = [
    GameColor(id: 'red', name: '🔴 Red', color: const Color(0xFFE74C3C)),
    GameColor(id: 'blue', name: '🔵 Blue', color: const Color(0xFF3498DB)),
    GameColor(id: 'green', name: '🟢 Green', color: const Color(0xFF2ECC71)),
    GameColor(id: 'yellow', name: '🟡 Yellow', color: const Color(0xFFF1C40F)),
    GameColor(id: 'purple', name: '🟣 Purple', color: const Color(0xFF9B59B6)),
    GameColor(id: 'orange', name: '🟠 Orange', color: const Color(0xFFE67E22)),
    GameColor(id: 'teal', name: '🩵 Teal', color: const Color(0xFF1ABC9C)),
    GameColor(id: 'pink', name: '🩷 Pink', color: const Color(0xFFE91E63)),
    GameColor(id: 'amber', name: '🟤 Amber', color: const Color(0xFFD35400)),
  ];

  /// Get active color items based on current level:
  /// - Level 1-2: 4 colors (2x2 grid)
  /// - Level 3-4: 6 colors (3x2 grid)
  /// - Level 5+: 9 colors (3x3 grid)
  static List<ColorGameItem> getAvailableItemsForLevel(int level) {
    int count = 4;
    if (level >= 5) {
      count = 9;
    } else if (level >= 3) {
      count = 6;
    }

    return _allGameColors
        .take(count)
        .map(
          (gc) => ColorGameItem(
            id: gc.id,
            displayName: gc.name,
            colorValue: gc.color.toARGB32(),
            durationMs: 800,
          ),
        )
        .toList();
  }

  /// Get all 9 available items (default fallback)
  static List<ColorGameItem> getAvailableItems() {
    return getAvailableItemsForLevel(5);
  }

  /// Get a specific color by ID
  static GameColor? getColorById(String id) {
    try {
      return _allGameColors.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static int getTotalColorsCount() => _allGameColors.length;
}

// Helper class to store color information
class GameColor {
  final String id;
  final String name;
  final Color color;

  GameColor({required this.id, required this.name, required this.color});
}
