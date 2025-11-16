// test/number_generator_logic_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:random_kit_app/number_generator_logic.dart';

void main() {
  group('NumberGeneratorLogic', () {
    test('generateNumber generates within a custom range (10-20)', () {
      const int min = 10;
      const int max = 20;
      for (int i = 0; i < 100; i++) {
        final number = NumberGeneratorLogic.generateNumber(min, max);
        expect(number, greaterThanOrEqualTo(min));
        expect(number, lessThanOrEqualTo(max));
      }
    });

    test('generateNumber handles min >= max case', () {
      expect(NumberGeneratorLogic.generateNumber(5, 5), equals(5));
      expect(NumberGeneratorLogic.generateNumber(10, 8), equals(10));
    });
  });
}
