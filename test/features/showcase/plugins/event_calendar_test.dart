import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/calendar_screen.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/event_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

Future<void> _pumpCalendar(WidgetTester tester, {Locale locale = const Locale('en')}) async {
  usePhoneSize(tester, height: 1600);
  await tester.pumpWidget(
    harness(
      Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: EventCalendar(today: DateTime(2026, 10, 2)),
        ),
      ),
      locale: locale,
    ),
  );
}

Finder _bar(String id, String weekStart) => find.byKey(ValueKey('event-$id@$weekStart'));

Finder _day(String day) => find.byKey(ValueKey('day-$day'));

void main() {
  group('EventCalendar', () {
    testWidgets('opens on the month of today with the sample events', (tester) async {
      await _pumpCalendar(tester);

      expect(find.text('October 2026'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^Conference, ')), findsOneWidget);
      expect(find.byKey(const ValueKey('week-2026-09-27')), findsOneWidget);
    });

    testWidgets('shows the details of a tapped event', (tester) async {
      await _pumpCalendar(tester);

      await tester.tap(_bar('conference', '2026-10-11'));
      await tester.pump();

      expect(find.text('Big conference for important people'), findsOneWidget);
      expect(find.text('October 11, 2026 – October 13, 2026'), findsOneWidget);
      expect(find.text('You tapped Conference.'), findsOneWidget);

      await tester.tap(find.byTooltip('Close the details'));
      await tester.pump();
      expect(find.text('Big conference for important people'), findsNothing);
    });

    testWidgets('says which day was tapped', (tester) async {
      await _pumpCalendar(tester);

      expect(find.bySemanticsLabel(RegExp('^Thursday, October 15, 2026, ')), findsOneWidget);
      await tester.tap(_day('2026-10-15'));
      await tester.pump();

      expect(find.text('You tapped October 15, 2026.'), findsOneWidget);
    });

    testWidgets('moves between months and switches to the week view', (tester) async {
      await _pumpCalendar(tester);

      await tester.tap(find.byTooltip('Next month'));
      await tester.pump();
      expect(find.text('November 2026'), findsOneWidget);

      await tester.tap(find.text('Today'));
      await tester.tap(find.text('Week'));
      await tester.pump();

      expect(find.text('Sep 27 – Oct 3, 2026'), findsOneWidget);
      expect(find.byKey(const ValueKey('week-2026-09-27')), findsOneWidget);
      expect(find.byKey(const ValueKey('week-2026-10-04')), findsNothing);
    });

    testWidgets('shows every week of the year in the year view', (tester) async {
      await _pumpCalendar(tester);

      await tester.tap(find.text('Year'));
      await tester.pump();

      expect(find.text('2026'), findsOneWidget);
      expect(find.byKey(const ValueKey('week-2025-12-28')), findsOneWidget);
      expect(find.byKey(const ValueKey('week-2026-12-27')), findsOneWidget);
    });

    testWidgets('moves an event to the next day with a long-press drag', (tester) async {
      await _pumpCalendar(tester);

      final gesture = await tester.startGesture(tester.getCenter(_bar('some', '2026-10-04')));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
      expect(find.text('Picked up Some event.'), findsOneWidget);

      await gesture.moveTo(tester.getCenter(_day('2026-10-10')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('Moved Some event to October 10, 2026.'), findsOneWidget);
      expect(find.bySemanticsLabel('Some event, October 10, 2026'), findsOneWidget);
    });

    testWidgets('moves an event with the screen reader actions', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpCalendar(tester);

      const later = CustomSemanticsAction(label: 'Move Some event a day later');
      final id = CustomSemanticsAction.getIdentifier(later);
      tester.semantics.customAction(
        find.semantics.byPredicate(
          (node) => node.getSemanticsData().customSemanticsActionIds?.contains(id) ?? false,
        ),
        later,
      );
      await tester.pump();

      expect(find.text('Moved Some event to October 10, 2026.'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('starts the week on Monday and names the month in French', (tester) async {
      await _pumpCalendar(tester, locale: const Locale('fr'));

      expect(find.text('octobre 2026'), findsOneWidget);
      expect(find.byKey(const ValueKey('week-2026-09-28')), findsOneWidget);
      // Sunday to Tuesday: in a week that starts on Monday, the conference spans two rows.
      expect(find.text('Conférence'), findsNWidgets(2));
    });
  });

  group('CalendarScreen', () {
    testWidgets('renders in both themes and languages', (tester) async {
      await expectRendersEverywhere(tester, const CalendarScreen());
    });
  });
}
