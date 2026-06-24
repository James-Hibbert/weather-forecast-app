import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Button presses trigger actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TestWidget(),
        ),
      ),
    );

    expect(find.text('No action yet'), findsOneWidget);

    // Act: Tap "Use Current Location" button
    await tester.tap(find.text('Use Current Location'));
    await tester.pump();
    expect(find.text('Location is being used'), findsOneWidget);

    // Reset the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TestWidget(),
        ),
      ),
    );

    // Act: Tap "Fetch Weather" button
    await tester.tap(find.text('Fetch Weather'));
    await tester.pump();
    expect(find.text('Weather fetched'), findsOneWidget);


    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TestWidget(),
        ),
      ),
    );

    // Act: Tap "3-Day Forecast" button
    await tester.tap(find.text('3-Day Forecast'));
    await tester.pump();
    expect(find.text('3-Day forecast fetched'), findsOneWidget);
  });
}

class TestWidget extends StatefulWidget {
  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  String actionText = 'No action yet';

  void useLocation() {
    setState(() {
      actionText = 'Location is being used';
    });
  }

  void fetchWeather() {
    setState(() {
      actionText = 'Weather fetched';
    });
  }

  void fetchThreeDayForecast() {
    setState(() {
      actionText = '3-Day forecast fetched';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: useLocation,
          child: Text('Use Current Location'),
        ),
        ElevatedButton(
          onPressed: fetchWeather,
          child: Text('Fetch Weather'),
        ),
        ElevatedButton(
          onPressed: fetchThreeDayForecast,
          child: Text('3-Day Forecast'),
        ),
        Text(actionText),
      ],
    );
  }
}
