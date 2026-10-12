import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/form_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A range of calendar days; [to] is null while only the start is chosen.
@immutable
class DayRange {
  const DayRange({required this.from, this.to});

  final DateTime from;
  final DateTime? to;

  /// Whether [day] is inside the range, ends included.
  bool contains(DateTime day) {
    final end = to;
    if (end == null) {
      return isSameDay(day, from);
    }
    return !day.isBefore(dateOnly(from)) && !day.isAfter(dateOnly(end));
  }

  @override
  bool operator ==(Object other) =>
      other is DayRange &&
      isSameDay(other.from, from) &&
      (other.to == null ? to == null : to != null && isSameDay(other.to!, to!));

  @override
  int get hashCode => Object.hash(dateOnly(from), to == null ? null : dateOnly(to!));

  @override
  String toString() => 'DayRange($from – $to)';
}

/// [value] at midnight.
DateTime dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

/// Whether [a] and [b] fall on the same calendar day.
bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// Adds a tapped [day] to [range], like the web calendar (react-day-picker's `addToRange`):
/// the first tap picks a one-day range, a tap before the start moves the start, a tap after it
/// moves the end, and tapping a one-day range's day clears it. Null is no range.
DayRange? addToRange(DateTime day, DayRange? range) {
  if (range == null) {
    return DayRange(from: day, to: day);
  }
  final from = range.from;
  final to = range.to;
  if (to == null) {
    if (isSameDay(from, day)) {
      return DayRange(from: from, to: day);
    }
    return day.isBefore(from) ? DayRange(from: day, to: from) : DayRange(from: from, to: day);
  }
  if (isSameDay(from, day) && isSameDay(to, day)) {
    return null;
  }
  if (isSameDay(from, day)) {
    return DayRange(from: from, to: day);
  }
  if (isSameDay(to, day)) {
    return DayRange(from: day, to: day);
  }
  return day.isBefore(from) ? DayRange(from: day, to: to) : DayRange(from: from, to: day);
}

/// A month calendar where taps build a [DayRange] (the web's inline range calendar).
class RangeCalendar extends StatefulWidget {
  const RangeCalendar({
    required this.range,
    required this.onChanged,
    required this.initialMonth,
    super.key,
  });

  final DayRange? range;
  final ValueChanged<DayRange?> onChanged;

  /// The month shown first.
  final DateTime initialMonth;

  @override
  State<RangeCalendar> createState() => _RangeCalendarState();
}

class _RangeCalendarState extends State<RangeCalendar> {
  late DateTime _month = DateTime(widget.initialMonth.year, widget.initialMonth.month);

  void _shift(int months) => setState(() => _month = DateTime(_month.year, _month.month + months));

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final colors = context.colors;
    final firstWeekday = material.firstDayOfWeekIndex; // 0 is Sunday.
    final leading = (DateTime(_month.year, _month.month).weekday % 7 - firstWeekday + 7) % 7;
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    final today = DateTime.now();
    final range = widget.range;

    Widget cell(int day) {
      final date = DateTime(_month.year, _month.month, day);
      final inRange = range != null && range.contains(date);
      final end =
          range != null && (isSameDay(range.from, date) || isSameDay(range.to ?? range.from, date));
      final isToday = isSameDay(date, today);
      return Semantics(
        button: true,
        selected: inRange,
        label: material.formatFullDate(date),
        excludeSemantics: true,
        child: InkWell(
          onTap: () => widget.onChanged(addToRange(date, range)),
          borderRadius: BorderRadius.circular(Radii.md),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: end
                  ? colors.primary
                  : inRange
                  ? colors.primary.withValues(alpha: 0.14)
                  : null,
              borderRadius: BorderRadius.circular(Radii.md),
              border: isToday && !end ? Border.all(color: colors.ink300) : null,
            ),
            child: Text(
              '$day',
              style: context.type.table.copyWith(
                color: end ? colors.onPrimary : colors.ink900,
                fontWeight: end || isToday ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    final slots = [
      for (var index = 0; index < leading; index++) null,
      for (var day = 1; day <= days; day++) day,
    ];
    while (slots.length % 7 != 0) {
      slots.add(null);
    }

    return Container(
      padding: const EdgeInsets.all(Space.sm),
      decoration: BoxDecoration(
        color: colors.ply,
        border: Border.all(color: colors.ink300),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: material.previousMonthTooltip,
                icon: const Icon(LucideIcons.chevronLeft, size: 18),
                onPressed: () => _shift(-1),
              ),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    material.formatMonthYear(_month),
                    textAlign: TextAlign.center,
                    style: context.text.titleSmall,
                  ),
                ),
              ),
              IconButton(
                tooltip: material.nextMonthTooltip,
                icon: const Icon(LucideIcons.chevronRight, size: 18),
                onPressed: () => _shift(1),
              ),
            ],
          ),
          const SizedBox(height: Space.xs),
          ExcludeSemantics(
            child: Row(
              children: [
                for (var index = 0; index < 7; index++)
                  Expanded(
                    child: Text(
                      material.narrowWeekdays[(firstWeekday + index) % 7],
                      textAlign: TextAlign.center,
                      style: context.type.formLabel,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.xs),
          for (var week = 0; week < slots.length ~/ 7; week++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                children: [
                  for (final day in slots.sublist(week * 7, week * 7 + 7))
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: day == null ? const SizedBox(height: 40) : cell(day),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The inline range calendar with the chosen start and end printed under it. It starts on the
/// 7th to the 11th of the current month, as on the web.
class RangeCalendarDemo extends StatefulWidget {
  const RangeCalendarDemo({this.today, super.key});

  /// Overrides today (tests).
  final DateTime? today;

  @override
  State<RangeCalendarDemo> createState() => _RangeCalendarDemoState();
}

class _RangeCalendarDemoState extends State<RangeCalendarDemo> {
  late final DateTime _today = widget.today ?? DateTime.now();
  late DayRange? _range = DayRange(
    from: DateTime(_today.year, _today.month, 7),
    to: DateTime(_today.year, _today.month, 11),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String show(DateTime? date) => date == null ? '—' : context.formatDate(date);

    Widget row(String label, DateTime? date) => MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(width: 72, child: Text(label.toUpperCase(), style: context.type.formLabel)),
            Expanded(child: Text(show(date), style: context.type.table)),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RangeCalendar(
          range: _range,
          initialMonth: _range?.from ?? _today,
          onChanged: (range) => setState(() => _range = range),
        ),
        const SizedBox(height: Space.page),
        row(l10n.advancedFormsPageRangeStart, _range?.from),
        row(l10n.advancedFormsPageRangeEnd, _range?.to),
      ],
    );
  }
}

/// Two date fields that open the system pickers: a single date and a date range.
class PopoverDatePickers extends StatefulWidget {
  const PopoverDatePickers({super.key});

  @override
  State<PopoverDatePickers> createState() => _PopoverDatePickersState();
}

class _PopoverDatePickersState extends State<PopoverDatePickers> {
  DateTime? _date;
  DateTimeRange? _range;

  static final _first = DateTime(1900);
  static final _last = DateTime(2100, 12, 31);

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: _first,
      lastDate: _last,
    );
    if (date != null && mounted) {
      setState(() => _date = date);
    }
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: _first,
      lastDate: _last,
    );
    if (range != null && mounted) {
      setState(() => _range = range);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final range = _range;
    final date = _date;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledField(
          label: l10n.advancedFormsPageSingleDateLabel,
          child: DateFieldButton(
            key: const Key('date-single'),
            text: date == null ? l10n.advancedFormsPagePickDate : context.formatDate(date),
            empty: date == null,
            onPressed: _pickDate,
          ),
        ),
        const SizedBox(height: Space.card),
        LabeledField(
          label: l10n.advancedFormsPageRangeLabel,
          child: DateFieldButton(
            key: const Key('date-range'),
            text: range == null
                ? l10n.advancedFormsPagePickRange
                : l10n.advancedFormsPageDateRange(
                    context.formatDate(range.start),
                    context.formatDate(range.end),
                  ),
            empty: range == null,
            onPressed: _pickRange,
          ),
        ),
      ],
    );
  }
}

/// A field-shaped button with a calendar icon and the chosen date (or a prompt in [empty] grey).
class DateFieldButton extends StatelessWidget {
  const DateFieldButton({
    required this.text,
    required this.empty,
    required this.onPressed,
    super.key,
  });

  final String text;
  final bool empty;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: Space.md),
      ),
      onPressed: onPressed,
      icon: Icon(LucideIcons.calendar, size: 18, color: colors.ink600),
      label: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: context.type.table.copyWith(
          fontSize: 15,
          color: empty ? colors.ink400 : colors.ink900,
        ),
      ),
    );
  }
}
