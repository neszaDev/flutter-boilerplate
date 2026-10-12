import 'package:flutter_boilerplate/features/showcase/campus/campus_data.dart';
import 'package:flutter_boilerplate/features/showcase/campus/filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildOptions', () {
    const units = [
      OrgUnit(
        id: 'org-1',
        title: [
          LocalizedTitle('en', 'Mae Fah Luang University'),
          LocalizedTitle('th', 'มหาวิทยาลัยแม่ฟ้าหลวง'),
        ],
      ),
      OrgUnit(id: 'org-2', title: [LocalizedTitle('th', 'ศูนย์บริการ')]),
      OrgUnit(id: 'org-3', title: [LocalizedTitle('th', '')]),
    ];

    test('labels each unit in the current locale', () {
      expect(
        buildOptions(units, 'th').first,
        const FilterOption(label: 'มหาวิทยาลัยแม่ฟ้าหลวง', value: 'org-1'),
      );
    });

    test('falls back to English, then to a dash', () {
      expect(buildOptions(units, 'fr').map((option) => option.label), [
        'Mae Fah Luang University',
        '-',
        '-',
      ]);
    });

    test('finds the label of a value', () {
      final options = buildOptions(units, 'en');
      expect(labelOf(options, 'org-1'), 'Mae Fah Luang University');
      expect(labelOf(options, null), isNull);
    });
  });

  group('quickRange', () {
    // Wednesday 2026-09-30.
    final now = DateTime(2026, 9, 30, 15);

    test('covers single days for today and yesterday', () {
      expect(quickRange(QuickRange.today, now), (start: '2026-09-30', end: '2026-09-30'));
      expect(quickRange(QuickRange.yesterday, now), (start: '2026-09-29', end: '2026-09-29'));
    });

    test('runs this week from Monday to today and last week from Monday to Sunday', () {
      expect(quickRange(QuickRange.thisWeek, now), (start: '2026-09-28', end: '2026-09-30'));
      expect(quickRange(QuickRange.lastWeek, now), (start: '2026-09-21', end: '2026-09-27'));
    });

    test('keeps a Sunday inside its own week', () {
      expect(
        quickRange(QuickRange.thisWeek, DateTime(2026, 10, 4)),
        (start: '2026-09-28', end: '2026-10-04'),
      );
    });

    test('crosses month and year ends', () {
      expect(
        quickRange(QuickRange.yesterday, DateTime(2027)),
        (start: '2026-12-31', end: '2026-12-31'),
      );
    });
  });

  group('buddhistYear', () {
    test('adds 543 to the Gregorian year', () {
      expect(buddhistYear(DateTime(2026)), 2569);
    });
  });

  group('days', () {
    test('format and parse yyyy-MM-dd', () {
      expect(formatDay(DateTime(2026, 3, 7)), '2026-03-07');
      expect(parseDay('2026-03-07'), DateTime(2026, 3, 7));
    });

    test('parse nothing from an empty or malformed value', () {
      expect(parseDay(''), isNull);
      expect(parseDay('07/03/2026'), isNull);
    });
  });

  group('OrganizationFilterValue', () {
    final now = DateTime(2026, 9, 30, 15);
    final initial = OrganizationFilterValue.initial(placeholderOrgUnits, now);

    test('starts on the first organisation and today', () {
      expect(initial.toJson(), {
        'organization': 'org-1',
        'agency': null,
        'department': null,
        'range': 'today',
        'startDate': '2026-09-30',
        'endDate': '2026-09-30',
      });
    });

    test('fills both dates from a quick range', () {
      final value = initial.withRange(QuickRange.lastWeek, now);
      expect(value.range, QuickRange.lastWeek);
      expect((value.startDate, value.endDate), ('2026-09-21', '2026-09-27'));
    });

    test('clears the quick range when a date is typed', () {
      expect(initial.withStartDate('2026-09-01').range, isNull);
      expect(initial.withEndDate('2026-10-01').range, isNull);
      expect(initial.withEndDate('2026-10-01').startDate, '2026-09-30');
    });

    test('chooses and clears units', () {
      final value = initial.withUnit(OrgUnitKind.agency, 'agency-1');
      expect(value.agency, 'agency-1');
      expect(value.organization, 'org-1');
      expect(value.withUnit(OrgUnitKind.organization, null).organization, isNull);
    });
  });

  group('CourseOptionValue', () {
    test('starts on the first university, the Buddhist year and semester 1', () {
      expect(
        CourseOptionValue.initial(placeholderOrgUnits.organizations, DateTime(2026, 5)).toJson(),
        {'campusId': 'org-1', 'academicYear': 2569, 'semester': 1},
      );
    });

    test('changes one field at a time', () {
      final value = CourseOptionValue.initial(const [], DateTime(2026));
      expect(value.campusId, isNull);
      expect(value.withSemester(2).semester, 2);
      expect(value.withAcademicYear(null).academicYear, isNull);
      expect(value.withCampus('org-1').academicYear, 2569);
    });
  });

  group('prettyJson', () {
    test('indents like JSON.stringify(value, null, 2)', () {
      expect(
        prettyJson({'agency': 'agency-1', 'range': null}),
        '{\n  "agency": "agency-1",\n  "range": null\n}',
      );
    });
  });
}
