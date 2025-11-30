// test/color_mixer_logic_test.dart

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:random_kit_app/color_mixer_logic.dart';

void main() {
  group('ColorMixerLogic', () {
    test('generateRandomColor always returns an opaque color (Alpha=1.0)', () {
      for (int i = 0; i < 100; i++) {
        final result = ColorMixerLogic.generateRandomColor();

        // Assert that alpha is 1.0 (fully opaque)
        expect(result.a, equals(1.0));
      }
    });

    test('generateRandomColor returns valid RGB values (0.0-1.0)', () {
      for (int i = 0; i < 100; i++) {
        final result = ColorMixerLogic.generateRandomColor();

        // Assert RGB values are within valid range (0.0 to 1.0)
        expect(result.r, greaterThanOrEqualTo(0.0));
        expect(result.r, lessThanOrEqualTo(1.0));

        expect(result.g, greaterThanOrEqualTo(0.0));
        expect(result.g, lessThanOrEqualTo(1.0));

        expect(result.b, greaterThanOrEqualTo(0.0));
        expect(result.b, lessThanOrEqualTo(1.0));
      }
    });

    test('colorToHex returns proper hex format', () {
      // Create a test color: red=1.0, green=0.34, blue=0.2
      final testColor = Color.from(
        alpha: 1.0,
        red: 1.0,
        green: 0.34117647058823,
        blue: 0.2,
      );
      final hexString = ColorMixerLogic.colorToHex(testColor);

      // Should return "#FF5733" (255, 87, 51 in RGB)
      expect(hexString, equals('#FF5733'));
    });

    test('colorToRGB returns proper RGB format', () {
      // Create a test color: red=1.0, green=0.34, blue=0.2
      final testColor = Color.from(
        alpha: 1.0,
        red: 1.0,
        green: 0.34117647058823,
        blue: 0.2,
      );
      final rgbString = ColorMixerLogic.colorToRGB(testColor);

      // Should return "RGB(255, 87, 51)"
      expect(rgbString, equals('RGB(255, 87, 51)'));
    });

    test('colorToHex and colorToRGB produce consistent results', () {
      for (int i = 0; i < 50; i++) {
        final color = ColorMixerLogic.generateRandomColor();

        final hexString = ColorMixerLogic.colorToHex(color);
        final rgbString = ColorMixerLogic.colorToRGB(color);

        // Verify hex format
        expect(hexString, matches(r'^#[0-9A-F]{6}$'));

        // Verify RGB format
        expect(rgbString, matches(r'^RGB\(\d{1,3}, \d{1,3}, \d{1,3}\)$'));
      }
    });
  });
}
