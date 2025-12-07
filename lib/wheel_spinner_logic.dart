// lib/wheel_spinner_logic.dart

import 'dart:math';

class WheelSpinnerLogic {
  static const int maxOptions = 10;
  static const int minOptions = 2;

  /// Selects a random index from the given list of options
  /// Returns 0 if the list is empty
  static int selectRandomIndex(List<String> options) {
    if (options.isEmpty) {
      return 0;
    }
    final random = Random();
    return random.nextInt(options.length);
  }

  /// Validates and cleans user input
  /// Returns a list of non-empty trimmed strings
  static List<String> parseOptions(String input) {
    return input
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Checks if there are enough options to spin
  static bool hasMinimumOptions(List<String> options) {
    return options.length >= minOptions;
  }

  /// Checks if options count is within the allowed maximum
  static bool isWithinMaxOptions(List<String> options) {
    return options.length <= maxOptions;
  }
}
