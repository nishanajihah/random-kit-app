// test/dice_roller_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:random_kit_app/main.dart';

// Helper function to check if a value is within the dice range
Matcher isInRange(int min, int max) => isA<int>()
    .having((s) => s >= min, 'is greated than or equal to $min', isTrue)
    .having((s) => s <= max, 'is less than or equal to $max', isTrue);

void main() {
  // Initialize dotenv before running tests
  setUpAll(() async {
    await dotenv.load(fileName: '.env.development');
  });

  testWidgets('Tapping the roll button updates the dice result', (
    WidgetTester tester,
  ) async {
    // Build the entire app to run the test
    await tester.pumpWidget(const RandomKitApp());

    // Wait for the UI to fully load and initialize (important for AdMob)
    await tester.pumpAndSettle();

    // Find the roll button and the result Text element using its Key
    final rollButton = find.text('ROLL DICE');
    final resultFinder = find.byKey(const Key('diceResultText'));

    // Simulate a tap on the button
    await tester.tap(rollButton);

    // Rebuild the screen to show the new number
    await tester.pump();

    // Verify the number element is still there
    expect(resultFinder, findsOneWidget);

    // Verify the new roll is within the valid range (1-6)
    final newTextWidget = tester.widget<Text>(resultFinder);
    int newRoll = int.parse(newTextWidget.data ?? '0');
    expect(newRoll, isInRange(1, 6));
  });
}
