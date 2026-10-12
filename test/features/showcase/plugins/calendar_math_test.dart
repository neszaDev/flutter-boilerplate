import 'package:flutter_boilerplate/features/showcase/plugins/calendar_math.dart';
import 'package:flutter_test/flutter_test.dart';

CalendarEvent _event(String id, DateTime start, DateTime end) =>
    CalendarEvent(id: id, start: start, end: end, tone: EventTone.muted);

// Sunday 4 October 2026 to Saturday 10 October 2026.
final _weekStart = DateTime(2026, 10, 4);

void main() {
  group('weeksOfPeriod', () {
    test('returns the week rows that cover a month', () {
      final weeks = weeksOfPeriod(DateTime(2026, 10, 15), CalendarPeriod.month, DateTime.sunday);

      expect(weeks, hasLength(5));
      expect(weeks.first, DateTime(2026, 9, 27));
    });

    test('starts weeks on Monday when asked', () {
      expect(weeksOfPeriod(DateTime(2026, 10, 15), CalendarPeriod.week, DateTime.monday), [
        DateTime(2026, 10, 12),
      ]);
    });

    test('covers every week of the year', () {
      expect(
        weeksOfPeriod(DateTime(2026, 6), CalendarPeriod.year, DateTime.sunday),
        hasLength(53),
      );
    });
  });

  group('shiftPeriod', () {
    test('moves by the period shown', () {
      final date = DateTime(2026, 1, 31);

      expect(shiftPeriod(date, CalendarPeriod.month, 1), DateTime(2026, 2, 28));
      expect(shiftPeriod(date, CalendarPeriod.week, -1), DateTime(2026, 1, 24));
      expect(shiftPeriod(date, CalendarPeriod.year, 1), DateTime(2027, 1, 31));
    });

    test('keeps the 29th of February on the last day of a shorter February', () {
      expect(shiftPeriod(DateTime(2028, 2, 29), CalendarPeriod.year, 1), DateTime(2029, 2, 28));
    });
  });

  group('layoutWeek', () {
    test('stacks overlapping events in separate lanes and reuses free lanes', () {
      final week = layoutWeek(_weekStart, [
        _event('long', DateTime(2026, 10, 5), DateTime(2026, 10, 8)),
        _event('inside', DateTime(2026, 10, 6, 10), DateTime(2026, 10, 6, 11)),
        _event('later', DateTime(2026, 10, 9), DateTime(2026, 10, 9)),
      ]);
      WeekSegment segment(String id) =>
          week.segments.firstWhere((segment) => segment.event.id == id);

      expect(week.laneCount, 2);
      expect((segment('long').column, segment('long').span, segment('long').lane), (1, 4, 0));
      expect((segment('inside').column, segment('inside').span, segment('inside').lane), (2, 1, 1));
      expect((segment('later').column, segment('later').span, segment('later').lane), (5, 1, 0));
    });

    test('clips events that run past the week and marks where they continue', () {
      final segment = layoutWeek(_weekStart, [
        _event('across', DateTime(2026, 10, 2), DateTime(2026, 10, 12)),
      ]).segments.single;

      expect(segment.column, 0);
      expect(segment.span, 7);
      expect(segment.continuesBefore, isTrue);
      expect(segment.continuesAfter, isTrue);
    });

    test('leaves out events of other weeks', () {
      expect(
        layoutWeek(_weekStart, [
          _event('next', DateTime(2026, 10, 11), DateTime(2026, 10, 11)),
        ]).segments,
        isEmpty,
      );
    });

    test('puts the longer of two events that start together in the first lane', () {
      final week = layoutWeek(_weekStart, [
        _event('short', DateTime(2026, 10, 5), DateTime(2026, 10, 5)),
        _event('long', DateTime(2026, 10, 5), DateTime(2026, 10, 7)),
      ]);

      expect(week.segments.first.event.id, 'long');
      expect(week.segments.first.lane, 0);
    });
  });

  group('moveEventTo', () {
    test('moves the start to the new day and keeps times and length', () {
      final moved = moveEventTo(
        _event('late', DateTime(2026, 10, 17, 19, 30), DateTime(2026, 10, 18, 2)),
        DateTime(2026, 10, 3),
      );

      expect(moved.start, DateTime(2026, 10, 3, 19, 30));
      expect(moved.end, DateTime(2026, 10, 4, 2));
    });
  });

  group('buildSampleEvents', () {
    test('places the sample events in the month of today, the same way every time', () {
      final events = buildSampleEvents(DateTime(2026, 10, 2));

      expect(events.firstWhere((event) => event.id == 'conference').start, DateTime(2026, 10, 11));
      expect(events.firstWhere((event) => event.id == 'all-day').start, DateTime(2026, 9, 30));
      expect(buildSampleEvents(DateTime(2026, 10, 20)), events);
    });
  });
}
