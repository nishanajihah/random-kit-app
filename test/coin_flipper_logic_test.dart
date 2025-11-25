// test/coin_flipper_logic_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:random_kit_app/coin_flipper_logic.dart';

void main() {
  group('CoinFlipperLogic', () {
    test('flip always returns "Heads" or "Tails"', () {
      const validOutcomes = ['Heads', 'Tails'];

      // Test the function 100 times
      for (int i = 0; i < 100; i++) {
        final result = CoinFlipperLogic.flip();
        expect(validOutcomes, contains(result));
      }
    });
  });
}
