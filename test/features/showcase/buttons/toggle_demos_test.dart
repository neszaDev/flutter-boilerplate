import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/toggle_demos.dart';
import 'package:flutter_test/flutter_test.dart';

import 'buttons_test_app.dart';

void main() {
  group('TogglePressedDemo', () {
    testWidgets('presses every toggle when one is pressed, and releases them together', (
      tester,
    ) async {
      await pumpButtons(tester, const Scaffold(body: Center(child: TogglePressedDemo())));

      expect(find.byType(DemoToggle), findsNWidgets(6));
      expect(find.textContaining(': Off'), findsNWidgets(6));

      await tester.tap(find.text('Outline, small: Off'));
      await tester.pumpAndSettle();

      expect(find.textContaining(': On'), findsNWidgets(6));
      expect(
        tester.getSemantics(find.text('Plain, large: On')),
        isSemantics(isButton: true, hasToggledState: true, isToggled: true),
      );

      await tester.tap(find.text('Plain, large: On'));
      await tester.pumpAndSettle();

      expect(find.textContaining(': Off'), findsNWidgets(6));
      expect(
        tester.getSemantics(find.text('Outline, small: Off')),
        isSemantics(hasToggledState: true, isToggled: false),
      );
    });
  });

  group('LoadingButtonDemo', () {
    testWidgets('shows a spinner and ignores taps while saving, then comes back', (tester) async {
      await pumpButtons(tester, const Scaffold(body: Center(child: LoadingButtonDemo())));

      await tester.tap(find.text('Save marks'));
      await tester.pump();

      expect(find.text('Saving…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

      await tester.pump(LoadingButtonDemo.saveDuration);

      expect(find.text('Save marks'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull);
    });
  });
}
