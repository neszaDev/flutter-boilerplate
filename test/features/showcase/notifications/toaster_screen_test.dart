import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/notifications/toaster_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_phone_notifier.dart';
import 'harness.dart';

Finder get _staticToasts => find.byKey(const Key('toaster.static'));

Future<void> _pumpToaster(WidgetTester tester, {FakePhoneNotifier? notifier}) async {
  usePhoneSize(tester, height: 2400);
  await tester.pumpWidget(
    harness(
      const ToasterScreen(),
      overrides: [phoneNotifierProvider.overrideWithValue(notifier ?? FakePhoneNotifier())],
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('autohideDelay', () {
    test('uses the typed milliseconds only when hiding is on and the number is positive', () {
      expect(
        autohideDelay(enabled: true, milliseconds: '5000'),
        const Duration(milliseconds: 5000),
      );
      expect(autohideDelay(enabled: false, milliseconds: '5000'), isNull);
      expect(autohideDelay(enabled: true, milliseconds: ''), isNull);
      expect(autohideDelay(enabled: true, milliseconds: '0'), isNull);
    });
  });

  group('ToasterScreen', () {
    testWidgets('starts with two static toasts and adds a numbered third', (tester) async {
      await _pumpToaster(tester);

      expect(
        find.descendant(of: _staticToasts, matching: find.text('Toast title')),
        findsNWidgets(2),
      );

      await tester.tap(find.byKey(const Key('toaster.position')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Static (in the page)').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add toast'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('This is toast number 3 in the “Static (in the page)” position.'),
        findsOneWidget,
      );
    });

    testWidgets('floats a toast with the chosen title and body', (tester) async {
      await _pumpToaster(tester);

      await tester.tap(find.text('Hide automatically'));
      await tester.enterText(find.byKey(const Key('toaster.title')), 'Marks saved');
      await tester.enterText(find.byKey(const Key('toaster.body')), 'Twelve results were updated.');
      await tester.tap(find.text('Add toast'));
      await tester.pump(const Duration(milliseconds: 300));

      // The text fields still hold the words, so each text shows twice.
      expect(find.text('Marks saved'), findsNWidgets(2));
      expect(find.text('Twelve results were updated.'), findsNWidgets(2));
      expect(
        find.descendant(of: _staticToasts, matching: find.text('Marks saved')),
        findsNothing,
      );
    });

    testWidgets('numbers each position on its own and hides toasts after their delay', (
      tester,
    ) async {
      await _pumpToaster(tester);

      await tester.enterText(find.byKey(const Key('toaster.autohideMs')), '1000');
      await tester.tap(find.text('Add toast'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('This is toast number 1 in the “Top right” position.'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('This is toast number 1 in the “Top right” position.'), findsNothing);
    });

    testWidgets('hides the delay field when autohide is off', (tester) async {
      await _pumpToaster(tester);

      await tester.tap(find.text('Hide automatically'));
      await tester.pump();

      expect(find.text('Time before hiding (ms)'), findsNothing);
      expect(find.byKey(const Key('toaster.autohideMs')), findsNothing);
    });

    testWidgets('closes a static toast from its close button', (tester) async {
      await _pumpToaster(tester);

      await tester.tap(
        find.descendant(of: _staticToasts, matching: find.byTooltip('Close')).first,
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: _staticToasts, matching: find.text('Toast title')),
        findsOneWidget,
      );
    });

    testWidgets('sends a phone notification and says so', (tester) async {
      final notifier = FakePhoneNotifier();
      await _pumpToaster(tester, notifier: notifier);

      await tester.tap(find.text('Phone notification'));
      await tester.pump();

      expect(notifier.shown.single.title, 'Toast title');
      expect(notifier.shown.single.body, 'Spring term marks are ready to review.');
      expect(find.textContaining('Notification sent.'), findsOneWidget);
    });

    testWidgets('says when notifications are off for the app', (tester) async {
      await _pumpToaster(tester, notifier: FakePhoneNotifier(granted: false));

      await tester.tap(find.text('Notify in 5 seconds'));
      await tester.pump();

      expect(find.textContaining('Notifications are off for this app.'), findsOneWidget);
    });

    testWidgets('renders every section in both themes and languages', (tester) async {
      await expectRendersEverywhere(tester, const ToasterScreen());
    });
  });
}
