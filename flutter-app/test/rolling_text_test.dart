import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_the_label/views/widgets/common/rolling_text.dart';

void main() {
  testWidgets('RollingText transition digits increase and decrease', (WidgetTester tester) async {
    // 1. Initial render with "99"
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RollingText(text: '99'),
          ),
        ),
      ),
    );

    // Verify digits are there
    expect(find.text('9'), findsNWidgets(2));

    // 2. Increase digits to "100"
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RollingText(text: '100'),
          ),
        ),
      ),
    );

    // Pump once to trigger the post-frame callback in RollingText didUpdateWidget
    await tester.pump();

    // Pump to start the animation
    await tester.pump(const Duration(milliseconds: 50));
    
    // During animation, '1' exists twice: once as layout spacer and once as animating text
    expect(find.text('1'), findsNWidgets(2));

    // Pump to finish the animation
    await tester.pumpAndSettle();

    // Verify we now have "100"
    expect(find.text('1'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));

    // 3. Decrease digits to "99"
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RollingText(text: '99'),
          ),
        ),
      ),
    );

    // Pump once to trigger the post-frame callback
    await tester.pump();

    // Pump to start the animation and step in by 50ms
    await tester.pump(const Duration(milliseconds: 50));

    // '1' exists twice during transition (layout spacer and fading-out text)
    expect(find.text('1'), findsNWidgets(2));
    
    await tester.pumpAndSettle();

    // After settle, it should show "99" and "1" should be completely gone.
    expect(find.text('9'), findsNWidgets(2));
    expect(find.text('1'), findsNothing);
  });
}
