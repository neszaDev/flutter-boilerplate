import 'package:flutter_boilerplate/features/showcase/tables/fake_backend.dart';
import 'package:flutter_boilerplate/features/showcase/tables/table_query.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Pupil = ({String name, String house, int age});

const _rows = <_Pupil>[
  (name: 'Ada', house: 'Oak', age: 12),
  (name: 'Ben', house: 'Elm', age: 9),
  (name: 'Cleo', house: 'Oak', age: 10),
  (name: 'Dev', house: 'Ash', age: 11),
];

final _columns = <QueryColumn<_Pupil>>[
  QueryColumn(id: 'name', value: (pupil) => pupil.name),
  QueryColumn(id: 'house', value: (pupil) => pupil.house),
  QueryColumn(id: 'age', value: (pupil) => pupil.age),
];

List<String> _names(({List<_Pupil> rows, int total}) result) => [
  for (final pupil in result.rows) pupil.name,
];

void main() {
  group('queryRows', () {
    test('returns the requested page with the total of matching rows', () {
      final result = queryRows(
        rows: _rows,
        columns: _columns,
        query: const TableQuery(pageSize: 3, pageIndex: 1),
      );

      expect(_names(result), ['Dev']);
      expect(result.total, 4);
    });

    test('filters every column with the table filter, ignoring case', () {
      final result = queryRows(
        rows: _rows,
        columns: _columns,
        query: const TableQuery(pageSize: 5, globalFilter: 'oAk'),
      );

      expect(_names(result), ['Ada', 'Cleo']);
    });

    test('combines column filters with each other', () {
      const query = TableQuery(pageSize: 5, columnFilters: {'house': 'oak', 'name': 'c'});

      expect(_names(queryRows(rows: _rows, columns: _columns, query: query)), ['Cleo']);
    });

    test('sorts numbers numerically in either direction', () {
      const query = TableQuery(pageSize: 5, sort: SortRule('age', descending: true));

      expect(_names(queryRows(rows: _rows, columns: _columns, query: query)), [
        'Ada',
        'Dev',
        'Cleo',
        'Ben',
      ]);
    });

    test('leaves columns that do not filter out of the table filter', () {
      final columns = [
        QueryColumn<_Pupil>(id: 'name', value: (pupil) => pupil.name),
        QueryColumn<_Pupil>(id: 'house', value: (pupil) => pupil.house, filterable: false),
      ];
      final result = queryRows(
        rows: _rows,
        columns: columns,
        query: const TableQuery(pageSize: 5, globalFilter: 'oak'),
      );

      expect(result.total, 0);
    });
  });

  group('filterAndSort', () {
    test('keeps ties in their original order', () {
      const query = TableQuery(pageSize: 5, sort: SortRule('house'));

      expect(
        [
          for (final pupil in filterAndSort(rows: _rows, columns: _columns, query: query))
            pupil.name,
        ],
        ['Dev', 'Ben', 'Ada', 'Cleo'],
      );
    });
  });

  group('naturalCompare', () {
    test('ignores case and accents', () {
      expect(naturalCompare('Félix', 'Friderik'), lessThan(0));
      expect(naturalCompare('šimun', 'Simun'), 0);
      expect(naturalCompare('ada', 'Ben'), lessThan(0));
    });

    test('compares runs of digits as numbers', () {
      expect(naturalCompare('Pupil 9', 'Pupil 10'), lessThan(0));
      expect(naturalCompare('2012-03-01', '2012-01-21'), greaterThan(0));
    });
  });
}
