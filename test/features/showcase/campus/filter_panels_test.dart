import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/campus/campus_data.dart';
import 'package:flutter_boilerplate/features/showcase/campus/filters.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/filter_panels.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/unit_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'campus_test_app.dart';

const _organizations = [
  OrgUnit(
    id: 'org-1',
    title: [
      LocalizedTitle('en', 'Mae Fah Luang University'),
      LocalizedTitle('th', 'มหาวิทยาลัยแม่ฟ้าหลวง'),
    ],
  ),
];
const _agencies = [
  OrgUnit(id: 'agency-1', title: [LocalizedTitle('en', 'Service centre')]),
];
const _units = OrgUnits(organizations: _organizations, agencies: _agencies, departments: []);

/// The picker labelled [label].
Finder _picker(String label) =>
    find.byWidgetPredicate((widget) => widget is UnitPicker && widget.label == label);

Future<void> _openPicker(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(of: _picker(label), matching: find.byType(InkWell)).first);
  await tester.pumpAndSettle();
}

void main() {
  group('OrganizationFilterPanel', () {
    testWidgets('preselects the first organisation and fills the dates of a quick range', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpCampusWidget(tester, const OrganizationFilterPanel(units: _units));

      expect(
        find.descendant(
          of: _picker('Organisation'),
          matching: find.text('Mae Fah Luang University'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Yesterday'));
      await tester.pumpAndSettle();
      final yesterday = quickRange(QuickRange.yesterday, DateTime.now());
      String shown(String day) => DateFormat.yMMMd('en').format(parseDay(day)!);

      expect(
        tester.getSemantics(find.bySemanticsLabel('Start date')),
        isSemantics(label: 'Start date', value: shown(yesterday.start)),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('End date')),
        isSemantics(label: 'End date', value: shown(yesterday.end)),
      );
      expect(find.textContaining('"range": "yesterday"'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('chooses an agency through the search list', (tester) async {
      await pumpCampusWidget(tester, const OrganizationFilterPanel(units: _units));

      await _openPicker(tester, 'Agency');
      await tester.tap(find.widgetWithText(ListTile, 'Service centre'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: _picker('Agency'), matching: find.text('Service centre')),
        findsOneWidget,
      );
      expect(find.textContaining('"agency": "agency-1"'), findsOneWidget);
    });

    testWidgets('says when the search matches nothing', (tester) async {
      await pumpCampusWidget(tester, const OrganizationFilterPanel(units: _units));

      await _openPicker(tester, 'Organisation');
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();

      expect(find.text('Nothing matches.'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Mae Fah Luang University'), findsNothing);
    });

    testWidgets('clears a choice', (tester) async {
      await pumpCampusWidget(tester, const OrganizationFilterPanel(units: _units));

      await tester.tap(find.byTooltip('Clear'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: _picker('Organisation'), matching: find.text('Choose…')),
        findsOneWidget,
      );
      expect(find.textContaining('"organization": null'), findsOneWidget);
    });
  });

  group('CourseOptionPanel', () {
    testWidgets('starts on the Buddhist year and emits the changed semester', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpCampusWidget(tester, const CourseOptionPanel(universities: _organizations));

      expect(fieldText(tester, 'Academic year'), '${DateTime.now().year + 543}');
      expect(find.bySemanticsLabel('Academic year'), findsOneWidget);

      await tester.tap(find.byType(DropdownMenu<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(MenuItemButton, 'Semester 2'));
      await tester.pumpAndSettle();

      expect(find.textContaining('"semester": 2'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('locks the fields', (tester) async {
      await pumpCampusWidget(tester, const CourseOptionPanel(universities: _organizations));

      await tester.tap(find.text('Lock the fields'));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(fieldLabelled('Academic year')).enabled, isFalse);
      expect(tester.widget<DropdownMenu<int>>(find.byType(DropdownMenu<int>)).enabled, isFalse);
    });

    testWidgets('emits null while the year is empty', (tester) async {
      await pumpCampusWidget(tester, const CourseOptionPanel(universities: _organizations));

      await tester.enterText(fieldLabelled('Academic year'), '');
      await tester.pump();

      expect(find.textContaining('"academicYear": null'), findsOneWidget);
    });
  });
}
