import 'package:flutter_test/flutter_test.dart';
import 'package:random_kit_app/dice_logic.dart';

void main() {
  group('DiceLogic', () {
    test('rollD6 always returns a number between 1 and 6 inclusive', () {
      // Test the function 100 times to ensure the range is correct
      for (int i = 0; i < 100; i++) {
        final roll = DiceLogic.rollD6();

        // Assertions:
        expect(roll, greaterThanOrEqualTo(1));
        expect(roll, lessThanOrEqualTo(6));
      }
    });
  });
}
