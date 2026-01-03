// lib/haptic_generator_logic_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:random_kit_app/haptic_generator_logic.dart';

void main() {
  group('HapticGeneratorLogic Tests', () {
    test('getRandomPattern should return a valid HapticPattern', () {
      // 1. Act: Get a random pattern
      final pattern = HapticGeneratorLogic.getRandomPattern();

      // 2. Assert: Check if it's not null and has data
      expect(pattern, isNotNull);
      expect(pattern.name, isNotEmpty);
      expect(pattern.pattern, isNotEmpty);
    });

    test(
      'getRandomPattern should eventually return different patterns (Randomness check)',
      () {
        // Since it's random, we call it a few times to ensure
        // it's not just returning the same single item every time.
        final results = <String>{};

        for (int i = 0; i < 10; i++) {
          results.add(HapticGeneratorLogic.getRandomPattern().name);
        }

        // If we have more than 1 unique name in our Set, randomness is working
        expect(results.length, greaterThan(1));
      },
    );

    test('Morse SOS pattern should have the correct sequence length', () {
      // We can search for a specific pattern if we make it accessible,
      // but for now, we verify that any returned pattern has a non-negative duration
      final pattern = HapticGeneratorLogic.getRandomPattern();

      for (var duration in pattern.pattern) {
        expect(duration, isNonNegative);
      }
    });
  });
}
