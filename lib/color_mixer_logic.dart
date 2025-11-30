// lib/color_mixer_logic.dart

import 'dart:math';
import 'dart:ui';

class ColorMixerLogic {
  // Generates a completely random opaque Color object
  static Color generateRandomColor() {
    final random = Random();

    // Generate random RGB values (0-255)
    final red = random.nextDouble();
    final green = random.nextDouble();
    final blue = random.nextDouble();

    // Return Color using the newest API (no deprecation warnings)
    return Color.from(
      alpha: 1.0, // Fully opaque (0.0 to 1.0)
      red: red,
      green: green,
      blue: blue,
    );
  }

  // Helper method to convert Color to Hex string (e.g., "#FF5733")
  static String colorToHex(Color color) {
    // Convert 0.0-1.0 values to 0-255 integers
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();

    return '#${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  // Helper method to get RGB values as string (e.g., "RGB(255, 87, 51)")
  static String colorToRGB(Color color) {
    // Convert 0.0-1.0 values to 0-255 integers
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();

    return 'RGB($r, $g, $b)';
  }
}
