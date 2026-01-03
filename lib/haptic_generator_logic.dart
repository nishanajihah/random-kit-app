// lib/haptic_generator_logic.dart

import 'dart:math';

class HapticPattern {
  final String name;
  final String description;
  final List<int> pattern; // [pause, vibrate, pause, vibrate, ...]

  HapticPattern({
    required this.name,
    required this.description,
    required this.pattern,
  });
}

class HapticGeneratorLogic {
  static final List<HapticPattern> _patterns = [
    HapticPattern(
      name: '💓 Heartbeat',
      description: 'Thump-thump rhythm',
      pattern: [0, 100, 100, 100],
    ),
    HapticPattern(
      name: '⚡ Quick Pulse',
      description: 'Fast buzzing',
      pattern: [0, 50, 50, 50, 50, 50],
    ),
    HapticPattern(
      name: '👆 Triple Tap',
      description: 'Three short taps',
      pattern: [0, 50, 100, 50, 100, 50],
    ),
    HapticPattern(
      name: '🌊 Wave',
      description: 'Rising and falling',
      pattern: [0, 200, 100, 300, 100, 200],
    ),
    HapticPattern(
      name: '🔫 Rapid Fire',
      description: 'Machine gun style',
      pattern: [0, 30, 30, 30, 30, 30, 30, 30, 30, 30],
    ),
    HapticPattern(
      name: '⏰ Alarm',
      description: 'Urgent buzzing',
      pattern: [0, 200, 100, 200, 100, 200],
    ),
    HapticPattern(
      name: '🆘 SOS Morse',
      description: '... --- ...',
      pattern: [
        0, 100, 100, 100, 100, 100, // S
        200, 300, 100, 300, 100, 300, // O
        200, 100, 100, 100, 100, 100, // S
      ],
    ),
    HapticPattern(
      name: '🎵 Melody',
      description: 'Musical rhythm',
      pattern: [0, 150, 50, 100, 50, 150, 100, 200],
    ),
    HapticPattern(
      name: '💨 Swoosh',
      description: 'Quick sweep',
      pattern: [0, 300],
    ),
    HapticPattern(
      name: '🎲 Random Chaos',
      description: 'Unpredictable!',
      pattern: [0, 80, 120, 60, 90, 150, 40, 110],
    ),
  ];

  static HapticPattern getRandomPattern() {
    return _patterns[Random().nextInt(_patterns.length)];
  }

  static int getTotalPatternsCount() => _patterns.length;
}
