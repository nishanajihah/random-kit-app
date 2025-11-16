// lib/number_generator_logic.dart

import 'dart:math';

class NumberGeneratorLogic {
  // Generates a random integer between min and max (inclusive)
  static int generateNumber(int min, int max) {
    if (min >= max) {
      // Safety check: return min if min >= max
      return min;
    }
    final random = Random();
    return random.nextInt(max - min + 1) + min;
  }
}
