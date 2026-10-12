import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// How much time the calendar shows at once.
enum CalendarPeriod { year, month, week }

/// Fill of an event bar, one of the folder/ink tones.
enum EventTone { muted, folder, outline, ink }

/// One calendar entry. Dates are local wall-clock times; [end] is inclusive. The title and
/// description are looked up by [id] on screen, so they follow the language.
@immutable
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.start,
    required this.end,
    required this.tone,
    this.allDay = false,
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final EventTone tone;
  final bool allDay;

  CalendarEvent copyWith({DateTime? start, DateTime? end}) => CalendarEvent(
    id: id,
    start: start ?? this.start,
    end: end ?? this.end,
    tone: tone,
    allDay: allDay,
  );

  @override
  bool operator ==(Object other) =>
      other is CalendarEvent &&
      other.id == id &&
      other.start == start &&
      other.end == end &&
      other.tone == tone &&
      other.allDay == allDay;

  @override
  int get hashCode => Object.hash(id, start, end, tone, allDay);
}

/// Midnight at the start of [date]'s day.
DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

/// [date] moved by whole days, keeping its wall-clock time across daylight-saving changes.
DateTime addDays(DateTime date, int days) => DateTime(
  date.year,
  date.month,
  date.day + days,
  date.hour,
  date.minute,
  date.second,
  date.millisecond,
);

/// [date] moved by whole months; the day is clamped to the end of a shorter month.
DateTime addMonths(DateTime date, int months) {
  final first = DateTime(date.year, date.month + months);
  final lastDay = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(
    first.year,
    first.month,
    math.min(date.day, lastDay),
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
  );
}

/// Calendar days from [from] to [to] (negative when [to] is earlier), ignoring the time.
int calendarDaysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// Whether [a] and [b] are the same calendar day.
bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// The first day of [date]'s week. [weekStartsOn] is a [DateTime.weekday] (7 is Sunday).
DateTime startOfWeek(DateTime date, int weekStartsOn) =>
    startOfDay(addDays(date, -((date.weekday - weekStartsOn) % 7)));

/// The first day of each week row the calendar shows for a period.
List<DateTime> weeksOfPeriod(DateTime date, CalendarPeriod period, int weekStartsOn) {
  if (period == CalendarPeriod.week) {
    return [startOfWeek(date, weekStartsOn)];
  }
  final (start, end) = period == CalendarPeriod.month
      ? (DateTime(date.year, date.month), DateTime(date.year, date.month + 1, 0))
      : (DateTime(date.year), DateTime(date.year, 12, 31));
  return [
    for (var week = startOfWeek(start, weekStartsOn); !week.isAfter(end); week = addDays(week, 7))
      week,
  ];
}

/// Moves the shown date by whole periods; negative [amount] goes back.
DateTime shiftPeriod(DateTime date, CalendarPeriod period, int amount) => switch (period) {
  CalendarPeriod.week => addDays(date, 7 * amount),
  CalendarPeriod.month => addMonths(date, amount),
  CalendarPeriod.year => addMonths(date, 12 * amount),
};

/// One event's bar inside a week row. Columns count from 0.
@immutable
class WeekSegment {
  const WeekSegment({
    required this.event,
    required this.column,
    required this.span,
    required this.lane,
    required this.continuesBefore,
    required this.continuesAfter,
  });

  final CalendarEvent event;
  final int column;
  final int span;
  final int lane;
  final bool continuesBefore;
  final bool continuesAfter;
}

/// Places the events that touch a week as bars: each bar spans its days in the week and takes
/// the first lane that is free on all of them. Returns the bars and how many lanes they need.
({List<WeekSegment> segments, int laneCount}) layoutWeek(
  DateTime weekStart,
  List<CalendarEvent> events,
) {
  final first = startOfDay(weekStart);
  final last = addDays(first, 6);
  // Earliest first, longer first on the same start; the index keeps the sort stable.
  final touching =
      [
        for (final (index, event) in events.indexed)
          if (!startOfDay(event.start).isAfter(last) && !startOfDay(event.end).isBefore(first))
            (index, event),
      ]..sort((a, b) {
        final byStart = a.$2.start.compareTo(b.$2.start);
        if (byStart != 0) {
          return byStart;
        }
        final byLength =
            calendarDaysBetween(b.$2.start, b.$2.end) - calendarDaysBetween(a.$2.start, a.$2.end);
        return byLength != 0 ? byLength : a.$1 - b.$1;
      });

  // lanes[lane][column] is true when that day of that lane is taken.
  final lanes = <List<bool>>[];
  final segments = [
    for (final (_, event) in touching) _place(event, first, last, lanes),
  ];
  return (segments: segments, laneCount: lanes.length);
}

WeekSegment _place(CalendarEvent event, DateTime first, DateTime last, List<List<bool>> lanes) {
  final start = startOfDay(event.start);
  final end = startOfDay(event.end);
  final from = start.isBefore(first) ? first : start;
  final to = end.isAfter(last) ? last : end;
  final column = calendarDaysBetween(first, from);
  final span = calendarDaysBetween(from, to) + 1;
  final days = [for (var day = column; day < column + span; day++) day];
  var lane = lanes.indexWhere((taken) => days.every((day) => !taken[day]));
  if (lane == -1) {
    lanes.add(List.filled(7, false));
    lane = lanes.length - 1;
  }
  for (final day in days) {
    lanes[lane][day] = true;
  }
  return WeekSegment(
    event: event,
    column: column,
    span: span,
    lane: lane,
    continuesBefore: start.isBefore(first),
    continuesAfter: end.isAfter(last),
  );
}

/// Moves an event so it starts on another day, keeping its times and length.
CalendarEvent moveEventTo(CalendarEvent event, DateTime day) {
  final delta = calendarDaysBetween(event.start, day);
  return event.copyWith(start: addDays(event.start, delta), end: addDays(event.end, delta));
}

/// The Vue demo's sample events, placed relative to the month of [today].
List<CalendarEvent> buildSampleEvents(DateTime today) {
  final year = today.year;
  final month = today.month;
  DateTime at(int day, [int hours = 0, int minutes = 0]) =>
      DateTime(year, month, day, hours, minutes);

  return [
    CalendarEvent(id: 'all-day', allDay: true, start: at(0), end: at(1), tone: EventTone.muted),
    CalendarEvent(id: 'long', start: at(7), end: at(10), tone: EventTone.muted),
    CalendarEvent(
      id: 'dst-starts',
      start: DateTime(year + 1, 3, 13),
      end: DateTime(year + 1, 3, 20),
      tone: EventTone.muted,
    ),
    CalendarEvent(
      id: 'dst-ends',
      start: DateTime(year + 1, 11, 6),
      end: DateTime(year + 1, 11, 13),
      tone: EventTone.muted,
    ),
    CalendarEvent(id: 'some', start: at(9), end: at(9), tone: EventTone.muted),
    CalendarEvent(id: 'conference', start: at(11), end: at(13), tone: EventTone.outline),
    CalendarEvent(
      id: 'meeting-1',
      start: at(12, 10, 30),
      end: at(12, 12, 30),
      tone: EventTone.muted,
    ),
    CalendarEvent(id: 'lunch', start: at(12, 12), end: at(12, 13), tone: EventTone.muted),
    CalendarEvent(id: 'meeting-2', start: at(14, 14), end: at(14, 15), tone: EventTone.muted),
    CalendarEvent(id: 'happy-hour', start: at(12, 17), end: at(12, 17, 30), tone: EventTone.folder),
    CalendarEvent(id: 'dinner', start: at(26, 20), end: at(26, 21), tone: EventTone.ink),
    CalendarEvent(id: 'birthday-1', start: at(13, 7), end: at(13, 10, 30), tone: EventTone.muted),
    CalendarEvent(id: 'birthday-2', start: at(24, 17), end: at(24, 18, 30), tone: EventTone.folder),
    CalendarEvent(id: 'late-night', start: at(17, 19, 30), end: at(18, 2), tone: EventTone.ink),
    CalendarEvent(id: 'multi-day', start: at(20, 19, 30), end: at(22, 2), tone: EventTone.muted),
  ];
}
