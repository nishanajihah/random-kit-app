// lib/coin_flipper_logic.dart

import 'dart:math';

class CoinFlipperLogic {
  // Simulates a coin flip and return 'Heads' or 'Tails'
  static String flip() {
    final random = Random();
    // nextInt(2) return 0 or 1
    return random.nextInt(2) == 0 ? 'Heads' : 'Tails';
  }
}
