import 'package:flutter_boilerplate/features/showcase/tables/table_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nextSort', () {
    test('sorts ascending, then descending, on taps on a head', () {
      final first = nextSort(null, 'name', resettable: false);
      final second = nextSort(first, 'name', resettable: false);

      expect(first, const SortRule('name'));
      expect(second, const SortRule('name', descending: true));
      expect(nextSort(second, 'name', resettable: false), const SortRule('name'));
    });

    test('removes the sort on a third tap when resettable', () {
      expect(nextSort(const SortRule('name', descending: true), 'name', resettable: true), isNull);
    });

    test('starts ascending on another column', () {
      expect(
        nextSort(const SortRule('name', descending: true), 'house', resettable: true),
        const SortRule('house'),
      );
    });
  });

  group('TableQuery', () {
    test('sets and clears a column filter and goes back to the first page', () {
      const query = TableQuery(pageSize: 5, pageIndex: 3);

      final filtered = query.withColumnFilter('house', 'oak');
      expect(filtered.columnFilters, {'house': 'oak'});
      expect(filtered.pageIndex, 0);
      expect(filtered.filtered, isTrue);

      expect(filtered.withColumnFilter('house', '').columnFilters, isEmpty);
    });

    test('compares by value', () {
      expect(
        const TableQuery(pageSize: 5, columnFilters: {'a': 'x'}),
        const TableQuery(pageSize: 5).withColumnFilter('a', 'x'),
      );
    });
  });

  group('emptyReason', () {
    test('says loading, no results or no items', () {
      const plain = TableQuery(pageSize: 5);

      expect(emptyReason(loading: true, query: plain), EmptyReason.loading);
      expect(emptyReason(loading: false, query: plain), EmptyReason.noItems);
      expect(
        emptyReason(loading: false, query: plain.copyWith(globalFilter: 'pine')),
        EmptyReason.noResults,
      );
    });
  });
}
