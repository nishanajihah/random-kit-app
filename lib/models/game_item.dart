// lib/models/game_item.dart

// Abtract class representing an item in the memory game
// Can be a color, haptic pattern, sound, or any other sensory output
abstract class GameItem {
  // Unique identifier for this item
  String get id;

  // Display name (for UI)
  String get displayName;

  // Execute the sensory feedback for this item
  // (e.g show color, play sound, trigger vibration)
  Future<void> play();

  // Duration in millliseconds this item shoud be displayed/played
  int get durationMs;
}

// Concrete implrementation for Color-based items
class ColorGameItem implements GameItem {
  @override
  final String id;

  @override
  final String displayName;

  final int colorValue;

  @override
  final int durationMs;

  ColorGameItem({
    required this.id,
    required this.displayName,
    required this.colorValue,
    this.durationMs = 800,
  });

  @override
  Future<void> play() async {
    // This will be implemented in the screen
    // The screen will handle showing the color
    await Future.delayed(Duration(milliseconds: durationMs));
  }
}

// Concret implementation for Haptic-based items
class HapticGameItem implements GameItem {
  @override
  final String id;

  @override
  final String displayName;

  final List<int> vibrationPattern; // Vibration pattern in milliseconds

  @override
  final int durationMs;

  HapticGameItem({
    required this.id,
    required this.displayName,
    required this.vibrationPattern,
    int? durationMs,
  }) : durationMs = durationMs ?? vibrationPattern.reduce((a, b) => a + b);

  @override
  Future<void> play() async {
    // This will be implemented in the screen
    // The screen will handle triggering vibration
    await Future.delayed(Duration(milliseconds: durationMs));
  }
}
