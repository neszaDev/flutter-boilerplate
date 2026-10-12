import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/notifications/alerts_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

double? _progress(WidgetTester tester) =>
    tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value;

void main() {
  group('CountdownAlerts', () {
    testWidgets('counts down and dismisses both alerts at zero', (tester) async {
      await tester.pumpWidget(harness(const Scaffold(body: CountdownAlerts(seconds: 2))));

      expect(find.text('This alert closes in 2 seconds…'), findsNWidgets(2));
      expect(_progress(tester), 1);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('This alert closes in 1 second…'), findsNWidgets(2));
      expect(_progress(tester), 0.5);

      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.textContaining('This alert closes'), findsNothing);
    });

    testWidgets('stops when closed and starts again from the button', (tester) async {
      await tester.pumpWidget(harness(const Scaffold(body: CountdownAlerts(seconds: 5))));

      await tester.tap(find.byTooltip('Close').first);
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsNothing);

      // Closed means stopped: nothing comes back on its own.
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(LinearProgressIndicator), findsNothing);

      await tester.tap(find.text('Show alerts with timer'));
      await tester.pump();
      expect(find.text('This alert closes in 5 seconds…'), findsNWidgets(2));
    });

    testWidgets('says the time left in French', (tester) async {
      await tester.pumpWidget(
        harness(const Scaffold(body: CountdownAlerts(seconds: 1)), locale: const Locale('fr')),
      );

      expect(find.text('Cette alerte se ferme dans 1 seconde…'), findsNWidgets(2));
    });
  });

  group('DismissibleAlerts', () {
    testWidgets('dismisses each alert and brings both back', (tester) async {
      await tester.pumpWidget(harness(const Scaffold(body: DismissibleAlerts())));

      await tester.tap(find.byTooltip('Close'));
      await tester.pump();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Close'));
      await tester.pump();

      expect(find.text('Dismissible alert.'), findsNothing);
      expect(find.text('Dismissible alert with a custom button.'), findsNothing);

      await tester.tap(find.text('Show dismissible alerts'));
      await tester.pump();

      expect(find.text('Dismissible alert.'), findsOneWidget);
      expect(find.text('Dismissible alert with a custom button.'), findsOneWidget);
    });

    testWidgets('dismisses an alert with a swipe', (tester) async {
      await tester.pumpWidget(harness(const Scaffold(body: DismissibleAlerts())));

      await tester.fling(find.text('Dismissible alert.'), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Dismissible alert.'), findsNothing);
      expect(find.text('Dismissible alert with a custom button.'), findsOneWidget);
    });
  });

  group('AlertsScreen', () {
    testWidgets('renders every section in both themes and languages', (tester) async {
      await expectRendersEverywhere(tester, const AlertsScreen());
    });

    testWidgets('names every tone', (tester) async {
      usePhoneSize(tester, height: 6000);
      await tester.pumpWidget(harness(const AlertsScreen()));

      for (final tone in ['Note', 'Primary', 'Success', 'Pending', 'Error', 'Muted', 'Dark']) {
        expect(find.text('$tone alert'), findsOneWidget);
        expect(find.text('$tone alert with a link to the test results.'), findsOneWidget);
      }
    });
  });
}
