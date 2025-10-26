import 'dart:math';

class DiceLogic {
  // Generates a random integer between 1 and 6, simulating a standard die roll
  static int rollD6() {
    final random = Random();
    // nextInt(6) return 0-5. Add 1 to get the 1-6.
    return random.nextInt(6) + 1;
  }
}
