import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/tables/showcase_data_table.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widgets/showcase_test_app.dart';

typedef _Pupil = ({int id, String name, String house});

const _pupils = <_Pupil>[
  (id: 1, name: 'Cleo', house: 'Oak'),
  (id: 2, name: 'Ada', house: 'Elm'),
  (id: 3, name: 'Ben', house: 'Oak'),
];

final _many = <_Pupil>[
  for (var index = 1; index <= 12; index++)
    (id: index, name: 'Pupil ${'$index'.padLeft(2, '0')}', house: 'Ash'),
];

final _columns = <TableColumn<_Pupil>>[
  TableColumn(id: 'name', header: 'Name', value: (pupil) => pupil.name),
  TableColumn(id: 'house', header: 'House', value: (pupil) => pupil.house),
];

Future<void> _pumpTable(
  WidgetTester tester, {
  List<_Pupil> data = _pupils,
  int itemsPerPage = 10,
  bool sorter = false,
  bool tableFilter = false,
  bool columnFilter = false,
  bool pagination = false,
  bool selectable = false,
  bool loading = false,
  Widget Function(BuildContext context, _Pupil row)? details,
}) => pumpShowcase(
  tester,
  Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ShowcaseDataTable<_Pupil>(
        data: data,
        columns: _columns,
        rowId: (pupil) => '${pupil.id}',
        caption: 'Pupils',
        itemsPerPage: itemsPerPage,
        sorter: sorter,
        tableFilter: tableFilter,
        columnFilter: columnFilter,
        pagination: pagination,
        selectable: selectable,
        selectOnRowTap: selectable,
        loading: loading,
        detailsBuilder: details,
      ),
    ),
  ),
  width: 800,
);

/// Whether [above] is printed above [below].
bool _isAbove(WidgetTester tester, String above, String below) =>
    tester.getTopLeft(find.text(above)).dy < tester.getTopLeft(find.text(below)).dy;

void main() {
  group('ShowcaseDataTable', () {
    group('Sorting', () {
      testWidgets('sorts ascending, then descending, on taps on a head', (tester) async {
        await _pumpTable(tester, sorter: true);

        expect(
          tester.getSemantics(find.bySemanticsLabel('Name')),
          isSemantics(value: 'Not sorted', isButton: true),
        );

        await tester.tap(find.text('NAME'));
        await tester.pumpAndSettle();

        expect(_isAbove(tester, 'Ada', 'Ben') && _isAbove(tester, 'Ben', 'Cleo'), isTrue);
        expect(
          tester.getSemantics(find.bySemanticsLabel('Name')),
          isSemantics(value: 'Sorted ascending'),
        );

        await tester.tap(find.text('NAME'));
        await tester.pumpAndSettle();

        expect(_isAbove(tester, 'Cleo', 'Ben') && _isAbove(tester, 'Ben', 'Ada'), isTrue);
        expect(
          tester.getSemantics(find.bySemanticsLabel('Name')),
          isSemantics(value: 'Sorted descending'),
        );
      });
    });

    group('Filters', () {
      testWidgets('narrows the rows with the table filter and says when nothing matches', (
        tester,
      ) async {
        await _pumpTable(tester, tableFilter: true);
        final filter = find.widgetWithText(TextField, 'Filter');

        await tester.enterText(filter, 'oak');
        await tester.pumpAndSettle();

        expect(find.text('Cleo'), findsOneWidget);
        expect(find.text('Ada'), findsNothing);

        await tester.enterText(filter, 'pine');
        await tester.pumpAndSettle();

        expect(find.text('No rows match the filters'), findsOneWidget);
      });

      testWidgets('filters one column with its own field', (tester) async {
        await _pumpTable(tester, columnFilter: true);

        await tester.enterText(find.widgetWithText(TextField, 'Filter by House'), 'elm');
        await tester.pumpAndSettle();

        expect(find.text('Ada'), findsOneWidget);
        expect(find.text('Ben'), findsNothing);
      });
    });

    group('Pagination', () {
      testWidgets('shows one page of rows and moves to the next page', (tester) async {
        await _pumpTable(tester, data: _many, itemsPerPage: 5, pagination: true);

        expect(find.text('Pupil 05'), findsOneWidget);
        expect(find.text('Pupil 06'), findsNothing);

        await tester.tap(find.byTooltip('Next page'));
        await tester.pumpAndSettle();

        expect(find.text('Pupil 06'), findsOneWidget);
        expect(find.text('Pupil 05'), findsNothing);
        expect(
          tester.getSemantics(find.bySemanticsLabel('Page 2')),
          isSemantics(isSelected: true),
        );
      });

      testWidgets('says which page it is where the page numbers do not fit', (tester) async {
        await pumpShowcase(
          tester,
          Scaffold(
            body: ShowcaseDataTable<_Pupil>(
              data: _many,
              columns: _columns,
              rowId: (pupil) => '${pupil.id}',
              caption: 'Pupils',
              itemsPerPage: 2,
              pagination: true,
            ),
          ),
          width: 300,
        );

        expect(find.text('Page 1 of 6'), findsOneWidget);
        expect(find.bySemanticsLabel('Page 2'), findsNothing);
      });
    });

    group('Rows', () {
      testWidgets('opens and closes the details of a row', (tester) async {
        await _pumpTable(tester, details: (context, pupil) => Text('House of ${pupil.name}'));

        await tester.tap(find.bySemanticsLabel('Show details of Ada'));
        await tester.pumpAndSettle();

        expect(find.text('House of Ada'), findsOneWidget);

        await tester.tap(find.bySemanticsLabel('Hide details of Ada'));
        await tester.pumpAndSettle();

        expect(find.text('House of Ada'), findsNothing);
      });

      testWidgets('selects rows by tap and all filtered rows with the head box', (tester) async {
        await _pumpTable(tester, selectable: true);

        await tester.tap(find.text('Ben'));
        await tester.pumpAndSettle();

        expect(
          tester.getSemantics(find.bySemanticsLabel('Select Ben')),
          isSemantics(isChecked: true),
        );
        expect(find.text('1 row selected'), findsOneWidget);

        await tester.tap(find.bySemanticsLabel('Select all rows'));
        await tester.pumpAndSettle();

        expect(find.text('3 rows selected'), findsOneWidget);

        await tester.tap(find.text('Clear selection'));
        await tester.pumpAndSettle();

        expect(find.text('No rows selected'), findsOneWidget);
      });

      testWidgets('shows the loading overlay while rows load', (tester) async {
        await pumpShowcase(
          tester,
          Scaffold(
            body: ShowcaseDataTable<_Pupil>(
              data: const [],
              columns: _columns,
              rowId: (pupil) => '${pupil.id}',
              caption: 'Pupils',
              loading: true,
            ),
          ),
          settle: false,
        );

        expect(find.bySemanticsLabel('Loading'), findsWidgets);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });
  });
}
