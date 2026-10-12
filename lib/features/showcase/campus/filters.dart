import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_data.dart';

/// One choice of a filter select: the label in the current language and the unit id.
@immutable
class FilterOption {
  const FilterOption({required this.label, required this.value});

  final String label;
  final String value;

  @override
  bool operator ==(Object other) =>
      other is FilterOption && other.label == label && other.value == value;

  @override
  int get hashCode => Object.hash(label, value);

  @override
  String toString() => 'FilterOption($label, $value)';
}

/// Turns organisation units into select options labelled in the current language
/// (Vue `optionsMixin.buildOptions`): the title in [locale], else English, else "-".
List<FilterOption> buildOptions(List<OrgUnit> list, String locale) => [
  for (final unit in list)
    FilterOption(label: _title(unit, locale) ?? _title(unit, 'en') ?? '-', value: unit.id),
];

String? _title(OrgUnit unit, String key) {
  for (final entry in unit.title) {
    if (entry.key == key && entry.value.isNotEmpty) {
      return entry.value;
    }
  }
  return null;
}

/// The label of the option [value], or null.
String? labelOf(List<FilterOption> options, String? value) {
  for (final option in options) {
    if (option.value == value) {
      return option.label;
    }
  }
  return null;
}

/// Quick date ranges of the organisation filter, in button order.
enum QuickRange {
  today('today'),
  yesterday('yesterday'),
  thisWeek('this_week'),
  lastWeek('last_week');

  const QuickRange(this.id);

  /// The web app's value (`this_week`), as the filter emits it.
  final String id;
}

/// Two inclusive days as `yyyy-MM-dd`.
typedef DayRange = ({String start, String end});

/// A calendar day as `yyyy-MM-dd` (the web's `<input type="date">` value).
String formatDay(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Reads a `yyyy-MM-dd` day as local midnight, or null when it isn't one.
DateTime? parseDay(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) {
    return null;
  }
  return DateTime(int.parse(match[1]!), int.parse(match[2]!), int.parse(match[3]!));
}

/// The inclusive start and end days of a quick range. Weeks start on Monday.
DayRange quickRange(QuickRange range, DateTime now) {
  // Calendar arithmetic on (year, month, day) stays right across daylight-saving changes.
  DateTime day(int offset) => DateTime(now.year, now.month, now.day + offset);
  final monday = now.weekday - DateTime.monday;
  final (start, end) = switch (range) {
    QuickRange.today => (day(0), day(0)),
    QuickRange.yesterday => (day(-1), day(-1)),
    QuickRange.thisWeek => (day(-monday), day(0)),
    QuickRange.lastWeek => (day(-monday - 7), day(-monday - 1)),
  };
  return (start: formatDay(start), end: formatDay(end));
}

/// The Thai academic year (Buddhist Era) of a date: the Gregorian year + 543.
int buddhistYear(DateTime date) => date.year + 543;

/// The selects of the organisation filter.
enum OrgUnitKind {
  organization,
  agency,
  department;

  /// The units of this kind.
  List<OrgUnit> of(OrgUnits units) => switch (this) {
    organization => units.organizations,
    agency => units.agencies,
    department => units.departments,
  };
}

/// What the organisation filter emits. Dates are `yyyy-MM-dd`, both days included.
@immutable
class OrganizationFilterValue {
  const OrganizationFilterValue({
    required this.organization,
    required this.agency,
    required this.department,
    required this.range,
    required this.startDate,
    required this.endDate,
  });

  /// The first organisation chosen up front and the range on today, as in Vue.
  factory OrganizationFilterValue.initial(OrgUnits units, DateTime now) {
    final today = quickRange(QuickRange.today, now);
    return OrganizationFilterValue(
      organization: units.organizations.firstOrNull?.id,
      agency: null,
      department: null,
      range: QuickRange.today,
      startDate: today.start,
      endDate: today.end,
    );
  }

  final String? organization;
  final String? agency;
  final String? department;
  final QuickRange? range;
  final String startDate;
  final String endDate;

  String? unit(OrgUnitKind kind) => switch (kind) {
    OrgUnitKind.organization => organization,
    OrgUnitKind.agency => agency,
    OrgUnitKind.department => department,
  };

  OrganizationFilterValue _copy({
    String? Function()? organization,
    String? Function()? agency,
    String? Function()? department,
    QuickRange? Function()? range,
    String? startDate,
    String? endDate,
  }) => OrganizationFilterValue(
    organization: organization == null ? this.organization : organization(),
    agency: agency == null ? this.agency : agency(),
    department: department == null ? this.department : department(),
    range: range == null ? this.range : range(),
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
  );

  /// Chooses (or clears, with null) the unit of [kind].
  OrganizationFilterValue withUnit(OrgUnitKind kind, String? id) => switch (kind) {
    OrgUnitKind.organization => _copy(organization: () => id),
    OrgUnitKind.agency => _copy(agency: () => id),
    OrgUnitKind.department => _copy(department: () => id),
  };

  /// Picks a quick range and fills both dates from it.
  OrganizationFilterValue withRange(QuickRange range, DateTime now) {
    final days = quickRange(range, now);
    return _copy(range: () => range, startDate: days.start, endDate: days.end);
  }

  /// A typed start date clears the quick range.
  OrganizationFilterValue withStartDate(String day) => _copy(range: () => null, startDate: day);

  /// A typed end date clears the quick range.
  OrganizationFilterValue withEndDate(String day) => _copy(range: () => null, endDate: day);

  Map<String, Object?> toJson() => {
    'organization': organization,
    'agency': agency,
    'department': department,
    'range': range?.id,
    'startDate': startDate,
    'endDate': endDate,
  };
}

/// Semesters of the Thai academic year.
const semesters = [1, 2, 3];

/// What the course option filter emits (Vue `FilterOption`'s `option` event).
@immutable
class CourseOptionValue {
  const CourseOptionValue({
    required this.campusId,
    required this.academicYear,
    required this.semester,
  });

  /// The first university, this year in the Buddhist Era, the first semester.
  factory CourseOptionValue.initial(List<OrgUnit> universities, DateTime now) => CourseOptionValue(
    campusId: universities.firstOrNull?.id,
    academicYear: buddhistYear(now),
    semester: semesters.first,
  );

  final String? campusId;

  /// Null while the field is empty.
  final int? academicYear;
  final int semester;

  CourseOptionValue withCampus(String? id) =>
      CourseOptionValue(campusId: id, academicYear: academicYear, semester: semester);

  CourseOptionValue withAcademicYear(int? year) =>
      CourseOptionValue(campusId: campusId, academicYear: year, semester: semester);

  CourseOptionValue withSemester(int value) =>
      CourseOptionValue(campusId: campusId, academicYear: academicYear, semester: value);

  Map<String, Object?> toJson() => {
    'campusId': campusId,
    'academicYear': academicYear,
    'semester': semester,
  };
}

/// [value] as indented JSON, like the web's `JSON.stringify(value, null, 2)`.
String prettyJson(Object? value) => const JsonEncoder.withIndent('  ').convert(value);
