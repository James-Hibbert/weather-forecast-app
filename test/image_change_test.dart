import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Change background image on button press', (WidgetTester tester) async {
    // Arrange: Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: TestImageWidget(),
      ),
    );

    // Act: Checks the initial background image
    expect(find.byKey(Key('background_image_sunny')), findsOneWidget);

    // Tap the button to change the image
    await tester.tap(find.byKey(Key('change_image_button')));
    await tester.pump();

    // Assert: Verify the image has changed
    expect(find.byKey(Key('background_image_rainy')), findsOneWidget);
  });
}

// A simple widget for testing background image change
class TestImageWidget extends StatefulWidget {
  @override
  _TestImageWidgetState createState() => _TestImageWidgetState();
}

class _TestImageWidgetState extends State<TestImageWidget> {
  String currentImage = 'assets/images/sunny.jpg';

  void changeImage() {
    setState(() {
      currentImage = 'assets/images/rainy.jpg';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            currentImage,
            key: Key(currentImage == 'assets/images/sunny.jpg'
                ? 'background_image_sunny'
                : 'background_image_rainy'),
            fit: BoxFit.cover,
          ),
          Center(
            child: ElevatedButton(
              key: Key('change_image_button'),
              onPressed: changeImage,
              child: Text('Change Image'),
            ),
          ),
        ],
      ),
    );
  }
}
