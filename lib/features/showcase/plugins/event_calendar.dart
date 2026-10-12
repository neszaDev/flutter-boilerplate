import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/calendar_math.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/edge_auto_scroll.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

String _dayKey(DateTime day) =>
    '${day.year}-${'${day.month}'.padLeft(2, '0')}-${'${day.day}'.padLeft(2, '0')}';

/// The title of a sample event, in the current language.
String sampleEventTitle(AppLocalizations l10n, String id) => switch (id) {
  'all-day' => l10n.eventCalendarSampleAllDay,
  'long' => l10n.eventCalendarSampleLong,
  'dst-starts' => l10n.eventCalendarSampleDstStarts,
  'dst-ends' => l10n.eventCalendarSampleDstEnds,
  'some' => l10n.eventCalendarSampleSome,
  'conference' => l10n.eventCalendarSampleConference,
  'meeting-1' || 'meeting-2' => l10n.eventCalendarSampleMeeting,
  'lunch' => l10n.eventCalendarSampleLunch,
  'happy-hour' => l10n.eventCalendarSampleHappyHour,
  'dinner' => l10n.eventCalendarSampleDinner,
  'birthday-1' => l10n.eventCalendarSampleBirthday,
  'birthday-2' => l10n.eventCalendarSampleBirthdayTwo,
  'late-night' => l10n.eventCalendarSampleLateNight,
  'multi-day' => l10n.eventCalendarSampleMultiDay,
  _ => id,
};

String? _sampleEventDescription(AppLocalizations l10n, String id) => switch (id) {
  'conference' => l10n.eventCalendarSampleConferenceText,
  'meeting-1' => l10n.eventCalendarSampleMeetingText,
  'lunch' => l10n.eventCalendarSampleLunchText,
  'happy-hour' => l10n.eventCalendarSampleHappyHourText,
  _ => null,
};

/// A calendar with events spanning days, built by hand like the web app's `EventCalendar`:
/// previous/next period and year, today, a year, month or week view, day selection, event
/// details, and moving events by long-press drag (or a screen reader's actions).
class EventCalendar extends StatefulWidget {
  const EventCalendar({required this.today, super.key});

  /// Today's date; the sample events are placed around it.
  final DateTime today;

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  late DateTime _shown = startOfDay(widget.today);
  var _period = CalendarPeriod.month;
  late var _events = buildSampleEvents(widget.today);
  DateTime? _selectedDay;
  String? _selectedEventId;
  var _dragging = false;
  var _message = '';
  final _autoScroll = EdgeAutoScroll();

  @override
  void dispose() {
    _autoScroll.stop();
    super.dispose();
  }

  String get _locale => context.localeName;

  /// The locale's first day of the week, as a [DateTime.weekday] (Sunday in English, Monday in
  /// French). intl counts from Monday = 0.
  int get _weekStartsOn => DateFormat.yMd(_locale).dateSymbols.FIRSTDAYOFWEEK % 7 + 1;

  String _formatDay(DateTime day) => DateFormat.yMMMMd(_locale).format(day);

  String _formatDayLong(DateTime day) => DateFormat.yMMMMEEEEd(_locale).format(day);

  String _title(String id) => sampleEventTitle(context.l10n, id);

  CalendarEvent? _event(String id) => _events.where((event) => event.id == id).firstOrNull;

  /// "October 12, 2026", "October 11, 2026 – October 13, 2026", "October 12, 2026 10:30 AM –
  /// 12:30 PM".
  String _describeRange(CalendarEvent event) {
    final l10n = context.l10n;
    final sameDay = isSameDay(event.start, event.end);
    final dateOnly =
        event.allDay ||
        (event.start == startOfDay(event.start) && event.end == startOfDay(event.end));
    if (dateOnly) {
      return sameDay
          ? _formatDay(event.start)
          : l10n.eventCalendarRange(_formatDay(event.start), _formatDay(event.end));
    }
    final withTime = DateFormat.yMMMMd(_locale).add_jm();
    return l10n.eventCalendarRange(
      withTime.format(event.start),
      sameDay ? DateFormat.jm(_locale).format(event.end) : withTime.format(event.end),
    );
  }

  void _selectDay(DateTime day) => setState(() {
    _selectedDay = day;
    _message = context.l10n.eventCalendarClickedDay(_formatDay(day));
  });

  void _selectEvent(String id) => setState(() {
    _selectedEventId = id;
    _message = context.l10n.eventCalendarClickedEvent(_title(id));
  });

  void _moveEvent(String id, DateTime day) {
    Haptics.light();
    setState(() {
      _events = [
        for (final event in _events)
          if (event.id == id) moveEventTo(event, day) else event,
      ];
      _message = context.l10n.eventCalendarMoved(_title(id), _formatDay(day));
    });
  }

  void _dragStarted(String id) {
    Haptics.medium();
    _autoScroll.start(context);
    setState(() {
      _dragging = true;
      _message = context.l10n.eventCalendarAnnounceStart(_title(id));
    });
  }

  void _dragCanceled(String id) =>
      setState(() => _message = context.l10n.eventCalendarAnnounceCancel(_title(id)));

  /// "October 2026", "2026", or the week's range ("Sep 27 – Oct 3, 2026").
  String _heading(DateTime firstWeek) {
    switch (_period) {
      case CalendarPeriod.year:
        return DateFormat.y(_locale).format(_shown);
      case CalendarPeriod.month:
        return DateFormat.yMMMM(_locale).format(_shown);
      case CalendarPeriod.week:
        final last = addDays(firstWeek, 6);
        final start = firstWeek.year == last.year
            ? DateFormat.MMMd(_locale)
            : DateFormat.yMMMd(_locale);
        return context.l10n.eventCalendarRange(
          start.format(firstWeek),
          DateFormat.yMMMd(_locale).format(last),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final weeks = weeksOfPeriod(_shown, _period, _weekStartsOn);
    final firstWeek = weeks.first;
    final selectedEvent = _selectedEventId == null ? null : _event(_selectedEventId!);
    final (previous, next) = switch (_period) {
      CalendarPeriod.year => (l10n.eventCalendarPreviousYear, l10n.eventCalendarNextYear),
      CalendarPeriod.month => (l10n.eventCalendarPreviousMonth, l10n.eventCalendarNextMonth),
      CalendarPeriod.week => (l10n.eventCalendarPreviousWeek, l10n.eventCalendarNextWeek),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          header: true,
          liveRegion: true,
          child: Text(_heading(firstWeek), style: context.text.headlineSmall),
        ),
        const SizedBox(height: Space.md),
        Row(
          children: [
            _NavButton(
              tooltip: l10n.eventCalendarPreviousYear,
              icon: LucideIcons.chevronsLeft,
              onPressed: () =>
                  setState(() => _shown = shiftPeriod(_shown, CalendarPeriod.year, -1)),
            ),
            const SizedBox(width: Space.xs),
            _NavButton(
              tooltip: previous,
              icon: LucideIcons.chevronLeft,
              onPressed: () => setState(() => _shown = shiftPeriod(_shown, _period, -1)),
            ),
            const SizedBox(width: Space.xs),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: Space.md),
                ),
                onPressed: () => setState(() => _shown = startOfDay(widget.today)),
                child: Text(l10n.eventCalendarToday, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: Space.xs),
            _NavButton(
              tooltip: next,
              icon: LucideIcons.chevronRight,
              onPressed: () => setState(() => _shown = shiftPeriod(_shown, _period, 1)),
            ),
            const SizedBox(width: Space.xs),
            _NavButton(
              tooltip: l10n.eventCalendarNextYear,
              icon: LucideIcons.chevronsRight,
              onPressed: () => setState(() => _shown = shiftPeriod(_shown, CalendarPeriod.year, 1)),
            ),
          ],
        ),
        const SizedBox(height: Space.page),
        DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: Border.all(color: colors.ink300),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WeekdayHeader(firstWeek: firstWeek, locale: _locale),
                const DoubleRule(),
                for (final weekStart in weeks)
                  _WeekRow(
                    key: ValueKey('week-${_dayKey(weekStart)}'),
                    weekStart: weekStart,
                    layout: layoutWeek(weekStart, _events),
                    period: _period,
                    shown: _shown,
                    today: widget.today,
                    selectedDay: _selectedDay,
                    selectedEventId: _selectedEventId,
                    dragging: _dragging,
                    dayLabel: (day, count) =>
                        l10n.eventCalendarDayLabel(_formatDayLong(day), count),
                    eventTitle: _title,
                    eventLabel: (event) =>
                        l10n.eventCalendarEventLabel(_title(event.id), _describeRange(event)),
                    onSelectDay: _selectDay,
                    onSelectEvent: _selectEvent,
                    onMove: _moveEvent,
                    onDragStarted: _dragStarted,
                    onDragMoved: _autoScroll.update,
                    onDragEnded: () {
                      _autoScroll.stop();
                      setState(() => _dragging = false);
                    },
                    onDragCanceled: _dragCanceled,
                  ),
              ],
            ),
          ),
        ),
        if (selectedEvent != null) ...[
          const SizedBox(height: Space.page),
          _EventDetails(
            title: _title(selectedEvent.id),
            when: _describeRange(selectedEvent),
            description: _sampleEventDescription(l10n, selectedEvent.id),
            onClose: () => setState(() => _selectedEventId = null),
          ),
        ],
        const SizedBox(height: Space.page),
        Divider(color: colors.ink200),
        const SizedBox(height: Space.page),
        Row(
          children: [
            FormLabel(l10n.eventCalendarView),
            const SizedBox(width: Space.md),
            Expanded(
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                label: l10n.eventCalendarView,
                child: SegmentedButton<CalendarPeriod>(
                  showSelectedIcon: false,
                  segments: [
                    for (final period in CalendarPeriod.values)
                      ButtonSegment(
                        value: period,
                        label: Text(switch (period) {
                          CalendarPeriod.year => l10n.eventCalendarPeriodYear,
                          CalendarPeriod.month => l10n.eventCalendarPeriodMonth,
                          CalendarPeriod.week => l10n.eventCalendarPeriodWeek,
                        }),
                      ),
                  ],
                  selected: {_period},
                  onSelectionChanged: (selection) {
                    Haptics.selection();
                    setState(() => _period = selection.first);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        Semantics(
          container: true,
          liveRegion: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 22),
            child: Text(
              _message,
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.ink950,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A square outlined icon button of the navigation row.
class _NavButton extends StatelessWidget {
  const _NavButton({required this.tooltip, required this.icon, required this.onPressed});

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton.outlined(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    style: IconButton.styleFrom(
      minimumSize: const Size.square(44),
      maximumSize: const Size.square(44),
      padding: EdgeInsets.zero,
      side: BorderSide(color: context.colors.ink300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
    ),
  );
}

/// The weekday names over the grid, starting on the locale's first day of the week.
class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.firstWeek, required this.locale});

  final DateTime firstWeek;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final format = DateFormat.E(locale);
    return ColoredBox(
      color: colors.paperCard,
      child: Row(
        children: [
          for (var index = 0; index < 7; index++)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: Space.sm),
                decoration: BoxDecoration(
                  border: Border(
                    right: index < 6 ? BorderSide(color: colors.ink200) : BorderSide.none,
                  ),
                ),
                child: Text(
                  format.format(addDays(firstWeek, index)).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                  style: context.type.formLabel.copyWith(letterSpacing: 0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One week of the grid: seven day cells that select a day and receive dropped events, with
/// the week's event bars laid over them in lanes.
class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.weekStart,
    required this.layout,
    required this.period,
    required this.shown,
    required this.today,
    required this.selectedDay,
    required this.selectedEventId,
    required this.dragging,
    required this.dayLabel,
    required this.eventTitle,
    required this.eventLabel,
    required this.onSelectDay,
    required this.onSelectEvent,
    required this.onMove,
    required this.onDragStarted,
    required this.onDragMoved,
    required this.onDragEnded,
    required this.onDragCanceled,
    super.key,
  });

  static const _header = 28.0;
  static const _lane = 24.0;
  static const _bar = 20.0;

  final DateTime weekStart;
  final ({List<WeekSegment> segments, int laneCount}) layout;
  final CalendarPeriod period;
  final DateTime shown;
  final DateTime today;
  final DateTime? selectedDay;
  final String? selectedEventId;

  /// An event is being dragged: the bars let the day cells under them receive it.
  final bool dragging;
  final String Function(DateTime day, int count) dayLabel;
  final String Function(String id) eventTitle;
  final String Function(CalendarEvent event) eventLabel;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<String> onSelectEvent;
  final void Function(String id, DateTime day) onMove;
  final ValueChanged<String> onDragStarted;

  /// The finger's position on the screen while it drags an event.
  final ValueChanged<Offset> onDragMoved;
  final VoidCallback onDragEnded;
  final ValueChanged<String> onDragCanceled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final minHeight = switch (period) {
      CalendarPeriod.week => 220.0,
      CalendarPeriod.month => 84.0,
      CalendarPeriod.year => 64.0,
    };
    final height = math.max(minHeight, _header + layout.laneCount * _lane + Space.sm);
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cell = constraints.maxWidth / 7;
          return Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var column = 0; column < 7; column++)
                    Expanded(child: _dayCell(context, addDays(weekStart, column), column)),
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: dragging,
                  child: Stack(
                    children: [
                      for (final segment in layout.segments)
                        Positioned(
                          left: segment.column * cell + 2,
                          top: _header + segment.lane * _lane,
                          width: segment.span * cell - 4,
                          height: _bar,
                          child: _EventBar(
                            key: ValueKey('event-${segment.event.id}@${_dayKey(weekStart)}'),
                            segment: segment,
                            title: eventTitle(segment.event.id),
                            label: eventLabel(segment.event),
                            selected: segment.event.id == selectedEventId,
                            width: segment.span * cell - 4,
                            moveEarlierLabel: l10n.eventCalendarMoveEarlier(
                              eventTitle(segment.event.id),
                            ),
                            moveLaterLabel: l10n.eventCalendarMoveLater(
                              eventTitle(segment.event.id),
                            ),
                            onSelect: () => onSelectEvent(segment.event.id),
                            onMoveBy: (days) => onMove(
                              segment.event.id,
                              addDays(startOfDay(segment.event.start), days),
                            ),
                            onDragStarted: () => onDragStarted(segment.event.id),
                            onDragMoved: onDragMoved,
                            onDragEnded: onDragEnded,
                            onDragCanceled: () => onDragCanceled(segment.event.id),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dayCell(BuildContext context, DateTime day, int column) {
    final colors = context.colors;
    final outside = period == CalendarPeriod.month && day.month != shown.month;
    final isToday = isSameDay(day, today);
    final selected = selectedDay != null && isSameDay(day, selectedDay!);
    final count = layout.segments
        .where((segment) => column >= segment.column && column < segment.column + segment.span)
        .length;
    final number = day.day == 1
        ? DateFormat.MMMd(context.localeName).format(day)
        : context.formatNumber(day.day);
    return DragTarget<String>(
      key: ValueKey('day-${_dayKey(day)}'),
      onAcceptWithDetails: (details) => onMove(details.data, day),
      builder: (context, candidates, _) => Semantics(
        container: true,
        button: true,
        selected: selected,
        label: dayLabel(day, count),
        onTap: () => onSelectDay(day),
        excludeSemantics: true,
        child: Material(
          color: candidates.isNotEmpty
              ? colors.ink100
              : outside
              ? colors.paper
              : colors.paperCard,
          child: InkWell(
            onTap: () => onSelectDay(day),
            child: Container(
              foregroundDecoration: selected
                  ? BoxDecoration(border: Border.all(color: colors.ink700, width: 2))
                  : null,
              decoration: BoxDecoration(
                border: Border(
                  right: column < 6 ? BorderSide(color: colors.ink200) : BorderSide.none,
                  bottom: BorderSide(color: colors.ink200),
                ),
              ),
              padding: const EdgeInsets.all(3),
              alignment: Alignment.topLeft,
              child: Container(
                height: 22,
                constraints: const BoxConstraints(minWidth: 22),
                padding: const EdgeInsets.symmetric(horizontal: Space.xs),
                alignment: Alignment.center,
                decoration: isToday
                    ? BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(11),
                      )
                    : null,
                child: Text(
                  number,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  style: context.text.labelMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: isToday
                        ? colors.onPrimary
                        : outside
                        ? colors.ink400
                        : colors.ink700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One event's bar in a week row: tap for its details, long-press to drag it to another day.
class _EventBar extends StatelessWidget {
  const _EventBar({
    required this.segment,
    required this.title,
    required this.label,
    required this.selected,
    required this.width,
    required this.moveEarlierLabel,
    required this.moveLaterLabel,
    required this.onSelect,
    required this.onMoveBy,
    required this.onDragStarted,
    required this.onDragMoved,
    required this.onDragEnded,
    required this.onDragCanceled,
    super.key,
  });

  final WeekSegment segment;
  final String title;
  final String label;
  final bool selected;
  final double width;
  final String moveEarlierLabel;
  final String moveLaterLabel;
  final VoidCallback onSelect;
  final ValueChanged<int> onMoveBy;
  final VoidCallback onDragStarted;
  final ValueChanged<Offset> onDragMoved;
  final VoidCallback onDragEnded;
  final VoidCallback onDragCanceled;

  @override
  Widget build(BuildContext context) {
    final face = _BarFace(segment: segment, title: title, selected: selected);
    return LongPressDraggable<String>(
      data: segment.event.id,
      // Haptics go through Haptics, which respects the user's setting.
      hapticFeedbackOnStart: false,
      onDragStarted: onDragStarted,
      onDragUpdate: (details) => onDragMoved(details.globalPosition),
      onDragEnd: (_) => onDragEnded(),
      onDraggableCanceled: (_, _) => onDragCanceled(),
      feedback: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          width: math.max(width, 120),
          height: _WeekRow._bar,
          child: _BarFace(
            segment: WeekSegment(
              event: segment.event,
              column: 0,
              span: 1,
              lane: 0,
              continuesBefore: false,
              continuesAfter: false,
            ),
            title: title,
            lifted: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: face),
      child: Semantics(
        container: true,
        button: true,
        selected: selected,
        label: label,
        onTap: onSelect,
        excludeSemantics: true,
        customSemanticsActions: {
          CustomSemanticsAction(label: moveEarlierLabel): () => onMoveBy(-1),
          CustomSemanticsAction(label: moveLaterLabel): () => onMoveBy(1),
        },
        child: GestureDetector(onTap: onSelect, child: face),
      ),
    );
  }
}

/// The printed bar: the event's tone, square ends where it runs on into another week.
class _BarFace extends StatelessWidget {
  const _BarFace({
    required this.segment,
    required this.title,
    this.selected = false,
    this.lifted = false,
  });

  final WeekSegment segment;
  final String title;
  final bool selected;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, border, ink) = switch (segment.event.tone) {
      EventTone.muted => (colors.ink100, colors.ink300, colors.ink900),
      EventTone.folder => (colors.folder, colors.folder, colors.folderInk),
      EventTone.outline => (colors.ply, colors.ink400, colors.ink900),
      EventTone.ink => (colors.ink700, colors.ink700, colors.paperCard),
    };
    const round = Radius.circular(Radii.sm);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: selected ? colors.ink950 : border, width: selected ? 2 : 1),
        borderRadius: BorderRadius.horizontal(
          left: segment.continuesBefore ? Radius.zero : round,
          right: segment.continuesAfter ? Radius.zero : round,
        ),
        boxShadow: lifted
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        title,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: context.text.labelMedium?.copyWith(fontSize: 11, height: 1.2, color: ink),
      ),
    );
  }
}

/// The selected event: title, when and description.
class _EventDetails extends StatelessWidget {
  const _EventDetails({
    required this.title,
    required this.when,
    required this.description,
    required this.onClose,
  });

  final String title;
  final String when;
  final String? description;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final body = context.text.bodyMedium?.copyWith(color: colors.ink900);
    return Container(
      padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.xs, Space.page),
      decoration: BoxDecoration(
        color: colors.ply,
        border: Border.all(color: colors.ink200),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: context.text.titleMedium),
                ),
              ),
              IconButton(
                tooltip: l10n.eventCalendarCloseDetails,
                onPressed: onClose,
                icon: const Icon(LucideIcons.x, size: 18),
              ),
            ],
          ),
          FormLabel(l10n.eventCalendarWhen),
          const SizedBox(height: Space.xs),
          Text(when, style: body),
          const SizedBox(height: Space.md),
          FormLabel(l10n.eventCalendarDescription),
          const SizedBox(height: Space.xs),
          Text(description ?? l10n.eventCalendarNoDescription, style: body),
        ],
      ),
    );
  }
}
