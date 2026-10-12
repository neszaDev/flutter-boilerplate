import 'package:flutter_boilerplate/features/showcase/forms/date_pickers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump.dart';

DateTime _day(int day) => DateTime(2026, 10, day);

void main() {
  group('addToRange', () {
    test('starts a one-day range, then moves its end', () {
      final first = addToRange(_day(7), null);

      expect(first, DayRange(from: _day(7), to: _day(7)));
      expect(addToRange(_day(11), first), DayRange(from: _day(7), to: _day(11)));
    });

    test('moves the start when the day comes before it', () {
      final range = DayRange(from: _day(7), to: _day(11));

      expect(addToRange(_day(3), range), DayRange(from: _day(3), to: _day(11)));
      expect(addToRange(_day(9), range), DayRange(from: _day(7), to: _day(9)));
    });

    test('collapses onto an end and clears a one-day range', () {
      final range = DayRange(from: _day(7), to: _day(11));

      expect(addToRange(_day(7), range), DayRange(from: _day(7), to: _day(7)));
      expect(addToRange(_day(11), range), DayRange(from: _day(11), to: _day(11)));
      expect(addToRange(_day(7), DayRange(from: _day(7), to: _day(7))), isNull);
    });

    test('orders an open range', () {
      expect(addToRange(_day(2), DayRange(from: _day(7))), DayRange(from: _day(2), to: _day(7)));
    });
  });

  group('RangeCalendarDemo', () {
    testWidgets('starts on the 7th to the 11th and prints a new end', (tester) async {
      await pumpDemo(tester, RangeCalendarDemo(today: _day(1)));

      expect(find.text('Oct 7, 2026'), findsOneWidget);
      expect(find.text('Oct 11, 2026'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Thursday, October 15, 2026'));
      await tester.pump();

      expect(find.text('Oct 15, 2026'), findsOneWidget);
      expect(find.text('Oct 11, 2026'), findsNothing);
    });

    testWidgets('pages through the months', (tester) async {
      await pumpDemo(tester, RangeCalendarDemo(today: _day(1)));

      expect(find.text('October 2026'), findsOneWidget);

      await tester.tap(find.byTooltip('Next month'));
      await tester.pump();

      expect(find.text('November 2026'), findsOneWidget);
    });
  });
}
