import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/tables/advanced_table_demos.dart';
import 'package:flutter_boilerplate/features/showcase/tables/advanced_tables_screen.dart';
import 'package:flutter_boilerplate/features/showcase/tables/basic_tables_screen.dart';
import 'package:flutter_boilerplate/features/showcase/tables/users_data.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/csv_export.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widgets/showcase_test_app.dart';

/// Records what would go to the share sheet.
class _FakeExport extends CsvExport {
  final shared = <({String filename, String csv})>[];

  @override
  Future<void> share({required String filename, required String csv, Rect? origin}) async {
    shared.add((filename: filename, csv: csv));
  }
}

Widget _inPage(Widget child) => Scaffold(
  body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child),
);

/// The page's own (vertical) scroll view; tables and charts may scroll sideways inside it.
final _page = find.byType(Scrollable).first;

void main() {
  group('shuffledUsers', () {
    test('keeps every sample user once', () {
      final users = shuffledUsers();

      expect(users, hasLength(25));
      expect(users.map((user) => user.id).toSet(), hasLength(25));
    });
  });

  group('BackendTable', () {
    testWidgets('sends the filter on submit, shows the loading overlay, then the answer', (
      tester,
    ) async {
      await pumpShowcase(tester, _inPage(const BackendTable()), width: 800);

      expect(find.bySemanticsLabel('Page 5'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Filter'), 'banned');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(find.bySemanticsLabel('Loading'), findsOneWidget);

      await tester.pump(BackendTable.latency);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Loading'), findsNothing);
      expect(find.text('Zbyněk Phoibos'), findsOneWidget);
      expect(find.text('Samppa Nori'), findsNothing);
      expect(find.bySemanticsLabel('Page 2'), findsNothing);
    });

    testWidgets('removes the sort on a third tap', (tester) async {
      await pumpShowcase(tester, _inPage(const BackendTable()), width: 800);

      for (var tap = 0; tap < 3; tap++) {
        await tester.tap(find.text('USERNAME'));
        await tester.pump(BackendTable.latency);
        await tester.pumpAndSettle();
      }

      expect(
        tester.getSemantics(find.bySemanticsLabel('Username')),
        isSemantics(value: 'Not sorted'),
      );
      expect(find.text('Samppa Nori'), findsOneWidget);
    });
  });

  group('SelectTable', () {
    testWidgets('filters by the localized status and counts the selected rows', (tester) async {
      await pumpShowcase(tester, _inPage(const SelectTable()), width: 800);

      await tester.enterText(find.widgetWithText(TextField, 'Filter by Status'), 'pending');
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Select all rows'));
      await tester.pumpAndSettle();

      expect(find.text('5 rows selected'), findsOneWidget);
    });
  });

  group('DownloadTable', () {
    testWidgets('shares every filtered row, sorted, as CSV', (tester) async {
      final export = _FakeExport();
      await pumpShowcase(
        tester,
        _inPage(const DownloadTable()),
        width: 800,
        overrides: [csvExportProvider.overrideWithValue(export)],
      );

      expect(find.text('Share 25 rows (.csv)'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Filter by Status'), 'banned');
      await tester.pumpAndSettle();
      await tester.tap(find.text('USERNAME'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share 5 rows (.csv)'));
      await tester.pumpAndSettle();

      expect(export.shared.single.filename, 'table-data.csv');
      expect(export.shared.single.csv.split('\r\n'), [
        'Username,Registered,Role,Status',
        'Avram Tarasios,2012-02-01,Staff,Banned',
        'Estavan Lykos,2012-02-01,Staff,Banned',
        'Nehemiah Tatius,2012-02-01,Staff,Banned',
        'Paĉjo Jadon,2012-02-01,Staff,Banned',
        'Zbyněk Phoibos,2012-02-01,Staff,Banned',
      ]);
    });
  });

  group('DemoTable', () {
    testWidgets('opens a user’s details and deletes the user', (tester) async {
      await pumpShowcase(tester, _inPage(const DemoTable()), width: 800);

      await tester.tap(find.bySemanticsLabel('Show details of Samppa Nori'));
      await tester.pumpAndSettle();

      expect(find.text('User since January 1, 2012'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Samppa Nori'), findsNothing);
      expect(find.text('Estavan Lykos'), findsOneWidget);
    });
  });

  group('Screens', () {
    for (final dark in [false, true]) {
      testWidgets('lays the basic tables out on a narrow phone (dark: $dark)', (tester) async {
        await pumpShowcase(tester, const BasicTablesScreen(), width: 360, dark: dark);

        expect(find.text('Page 1 of 5'), findsWidgets);

        await tester.scrollUntilVisible(
          find.text('Combined table on the folder'),
          600,
          scrollable: _page,
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('lays the advanced tables out on a narrow phone', (tester) async {
      await pumpShowcase(tester, const AdvancedTablesScreen(), width: 360);

      await tester.scrollUntilVisible(find.text('Selectable rows'), 600, scrollable: _page);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
