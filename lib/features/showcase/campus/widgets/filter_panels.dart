import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/device/haptics.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_data.dart';
import 'package:flutter_boilerplate/features/showcase/campus/filters.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/unit_picker.dart';

/// The organisation filter (Vue `FilterOrganization`) with the selection it emits: searchable
/// organisation, agency and department selects, quick date ranges and start/end dates. The
/// first organisation is chosen up front and the range starts on today; picking a date clears
/// the quick range.
class OrganizationFilterPanel extends StatefulWidget {
  const OrganizationFilterPanel({required this.units, super.key});

  final OrgUnits units;

  @override
  State<OrganizationFilterPanel> createState() => _OrganizationFilterPanelState();
}

class _OrganizationFilterPanelState extends State<OrganizationFilterPanel> {
  late var _value = OrganizationFilterValue.initial(widget.units, DateTime.now());

  void _set(OrganizationFilterValue value) => setState(() => _value = value);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeName;
    final options = {
      for (final kind in OrgUnitKind.values) kind: buildOptions(kind.of(widget.units), locale),
    };
    String unitLabel(OrgUnitKind kind) => switch (kind) {
      OrgUnitKind.organization => l10n.campusFiltersOrganization,
      OrgUnitKind.agency => l10n.campusFiltersAgency,
      OrgUnitKind.department => l10n.campusFiltersDepartment,
    };
    String day(String value) {
      final date = parseDay(value);
      return date == null ? l10n.campusFiltersNone : context.formatDate(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final kind in OrgUnitKind.values) ...[
          UnitPicker(
            label: unitLabel(kind),
            options: options[kind] ?? const [],
            value: _value.unit(kind),
            onChanged: (id) => _set(_value.withUnit(kind, id)),
          ),
          const SizedBox(height: Space.page),
        ],
        FormLabel(l10n.campusFiltersDates),
        const SizedBox(height: Space.md),
        Semantics(
          container: true,
          label: l10n.campusFiltersQuickRanges,
          child: Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final range in QuickRange.values)
                ChoiceChip(
                  label: Text(_rangeLabel(l10n, range)),
                  selected: _value.range == range,
                  onSelected: (_) {
                    Haptics.selection();
                    _set(_value.withRange(range, DateTime.now()));
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DateField(
                label: l10n.campusFiltersStartDate,
                value: _value.startDate,
                last: parseDay(_value.endDate),
                onChanged: (value) => _set(_value.withStartDate(value)),
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: _DateField(
                label: l10n.campusFiltersEndDate,
                value: _value.endDate,
                first: parseDay(_value.startDate),
                onChanged: (value) => _set(_value.withEndDate(value)),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.lg),
        FilterSummary(
          json: _value.toJson(),
          rows: [
            for (final kind in OrgUnitKind.values)
              (
                unitLabel(kind),
                labelOf(options[kind] ?? const [], _value.unit(kind)) ?? l10n.campusFiltersNone,
              ),
            (
              l10n.campusFiltersDates,
              l10n.campusFiltersDateRange(day(_value.startDate), day(_value.endDate)),
            ),
          ],
        ),
      ],
    );
  }
}

String _rangeLabel(AppLocalizations l10n, QuickRange range) => switch (range) {
  QuickRange.today => l10n.campusFiltersRangeToday,
  QuickRange.yesterday => l10n.campusFiltersRangeYesterday,
  QuickRange.thisWeek => l10n.campusFiltersRangeThisWeek,
  QuickRange.lastWeek => l10n.campusFiltersRangeLastWeek,
};

/// A day field: shows the date, opens the date picker (within [first]–[last]) when tapped.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.first,
    this.last,
  });

  final String label;

  /// `yyyy-MM-dd`.
  final String value;
  final DateTime? first;
  final DateTime? last;
  final ValueChanged<String> onChanged;

  Future<void> _pick(BuildContext context) async {
    final firstDate = first ?? DateTime(2000);
    final lastDate = last ?? DateTime(2100);
    final current = parseDay(value) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(firstDate)
          ? firstDate
          : (current.isAfter(lastDate) ? lastDate : current),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: label,
    );
    if (picked != null) {
      onChanged(formatDay(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = parseDay(value);
    final text = date == null ? context.l10n.campusFiltersNone : context.formatDate(date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: ExcludeSemantics(child: Text(label, style: context.text.titleSmall)),
        ),
        Semantics(
          label: label,
          value: text,
          button: true,
          excludeSemantics: true,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              alignment: AlignmentDirectional.centerStart,
              padding: const EdgeInsets.symmetric(horizontal: Space.md),
            ),
            onPressed: () => _pick(context),
            child: Text(
              text,
              style: context.type.table,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

/// The course option filter (Vue `FilterOption`) with the option object it emits and a switch
/// that locks it: university, academic year (Buddhist Era) and semester.
class CourseOptionPanel extends StatefulWidget {
  const CourseOptionPanel({required this.universities, super.key});

  final List<OrgUnit> universities;

  @override
  State<CourseOptionPanel> createState() => _CourseOptionPanelState();
}

class _CourseOptionPanelState extends State<CourseOptionPanel> {
  late var _value = CourseOptionValue.initial(widget.universities, DateTime.now());
  late final _year = TextEditingController(text: '${_value.academicYear ?? ''}');
  var _locked = false;

  @override
  void dispose() {
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final universities = buildOptions(widget.universities, context.localeName);
    final enabled = !_locked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.campusFiltersLock),
          value: _locked,
          onChanged: (locked) => setState(() => _locked = locked),
        ),
        const SizedBox(height: Space.sm),
        _Labeled(
          label: l10n.campusFiltersUniversity,
          child: DropdownMenu<String>(
            expandedInsets: EdgeInsets.zero,
            enabled: enabled,
            initialSelection: _value.campusId,
            dropdownMenuEntries: [
              for (final option in universities)
                DropdownMenuEntry(value: option.value, label: option.label),
            ],
            onSelected: (id) => setState(() => _value = _value.withCampus(id)),
          ),
        ),
        const SizedBox(height: Space.card),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Labeled(
                label: l10n.campusFiltersAcademicYear,
                child: TextField(
                  controller: _year,
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style: context.type.table.copyWith(fontSize: 16),
                  onChanged: (text) =>
                      setState(() => _value = _value.withAcademicYear(int.tryParse(text))),
                ),
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: _Labeled(
                label: l10n.campusFiltersSemester,
                child: DropdownMenu<int>(
                  expandedInsets: EdgeInsets.zero,
                  enabled: enabled,
                  initialSelection: _value.semester,
                  dropdownMenuEntries: [
                    for (final semester in semesters)
                      DropdownMenuEntry(
                        value: semester,
                        label: l10n.campusFiltersSemesterOption('$semester'),
                      ),
                  ],
                  onSelected: (semester) {
                    if (semester != null) {
                      setState(() => _value = _value.withSemester(semester));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.lg),
        FilterSummary(
          json: _value.toJson(),
          rows: [
            (
              l10n.campusFiltersUniversity,
              labelOf(universities, _value.campusId) ?? l10n.campusFiltersNone,
            ),
            (l10n.campusFiltersAcademicYear, '${_value.academicYear ?? l10n.campusFiltersNone}'),
            (l10n.campusFiltersSemester, l10n.campusFiltersSemesterOption('${_value.semester}')),
          ],
        ),
      ],
    );
  }
}

/// A printed label over a control; the control carries the same label for screen readers.
class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ExcludeSemantics(child: Text(label, style: context.text.titleSmall)),
      ),
      Semantics(label: label, child: child),
    ],
  );
}

/// The emitted value: each term with its label, then the raw object as JSON.
class FilterSummary extends StatelessWidget {
  const FilterSummary({required this.rows, required this.json, super.key});

  final List<(String term, String value)> rows;
  final Object? json;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Semantics(
      container: true,
      label: l10n.campusFiltersSummaryTitle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.page, vertical: Space.md),
        decoration: BoxDecoration(
          color: colors.paper,
          border: Border.all(color: colors.ink200),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: FormLabel(l10n.campusFiltersSummaryTitle, color: colors.ink700),
            ),
            const SizedBox(height: Space.md),
            for (final (term, value) in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: MergeSemantics(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 112,
                        child: Text(
                          term,
                          style: context.text.bodySmall?.copyWith(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(child: Text(value, style: context.text.titleSmall)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: Space.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
              decoration: BoxDecoration(
                color: colors.ply,
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  prettyJson(json),
                  style: context.type.code.copyWith(fontSize: 12, color: colors.ink700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
