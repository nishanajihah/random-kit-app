// test/decision_wheel_logic_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:random_kit_app/wheel_spinner_logic.dart';

void main() {
  group('WheelSpinnerLogic', () {
    final testOptions = ['Option A', 'Option B', 'Option C', 'Option D'];

    test('selectRandomIndex returns a valid index within the list bounds', () {
      for (int i = 0; i < 100; i++) {
        final resultIndex = WheelSpinnerLogic.selectRandomIndex(testOptions);

        // Assert the result is >= 0
        expect(resultIndex, greaterThanOrEqualTo(0));

        // Assert the result is < list length
        expect(resultIndex, lessThan(testOptions.length));
      }
    });

    test('selectRandomIndex returns 0 for an empty list', () {
      final resultIndex = WheelSpinnerLogic.selectRandomIndex([]);
      expect(resultIndex, equals(0));
    });
  });
}
