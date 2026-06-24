import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherprojectnew/weather_screen.dart';

void main() {
  testWidgets('Test toggle between Celsius and Fahrenheit', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: WeatherScreen()));


    final switchTileFinder = find.byType(SwitchListTile);

    // Ensure the switch starts in Celsius mode (value = true)
    expect(switchTileFinder, findsOneWidget);
    SwitchListTile switchTile = tester.widget(switchTileFinder) as SwitchListTile;
    expect(switchTile.value, isTrue);  // Initially, it should be Celsius

    // Tap the switch to change it to Fahrenheit
    await tester.tap(switchTileFinder);
    await tester.pump();

    // Verify it is now set to Fahrenheit
    switchTile = tester.widget(switchTileFinder) as SwitchListTile;
    expect(switchTile.value, isFalse);  // It should now be Fahrenheit

  });
}
