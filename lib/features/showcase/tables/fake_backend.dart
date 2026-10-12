import 'package:flutter_boilerplate/features/showcase/tables/table_query.dart';

// Latin letters with marks, folded to their base letter for sorting (`sensitivity: 'base'`).
const _fold = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'ā': 'a',
  'ă': 'a',
  'ą': 'a',
  'ç': 'c',
  'ć': 'c',
  'ĉ': 'c',
  'č': 'c',
  'ď': 'd',
  'đ': 'd',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ē': 'e',
  'ė': 'e',
  'ę': 'e',
  'ě': 'e',
  'ĝ': 'g',
  'ğ': 'g',
  'ĥ': 'h',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ī': 'i',
  'į': 'i',
  'ĵ': 'j',
  'ł': 'l',
  'ľ': 'l',
  'ñ': 'n',
  'ń': 'n',
  'ň': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ō': 'o',
  'ő': 'o',
  'ř': 'r',
  'ś': 's',
  'ŝ': 's',
  'š': 's',
  'ş': 's',
  'ș': 's',
  'ť': 't',
  'ț': 't',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ū': 'u',
  'ů': 'u',
  'ű': 'u',
  'ŭ': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ź': 'z',
  'ż': 'z',
  'ž': 'z',
  'ß': 'ss',
  'æ': 'ae',
  'œ': 'oe',
};

/// [text] in lower case without accents: how a base-sensitivity collation sees it.
String foldForSort(String text) =>
    text.toLowerCase().split('').map((char) => _fold[char] ?? char).join();

final _chunks = RegExp(r'\d+|\D+');

/// Compares two strings like `localeCompare(…, { numeric: true, sensitivity: 'base' })`:
/// case and accents ignored, runs of digits compared as numbers ("Pupil 9" < "Pupil 10").
int naturalCompare(String a, String b) {
  final left = _chunks.allMatches(foldForSort(a)).map((match) => match[0] ?? '').toList();
  final right = _chunks.allMatches(foldForSort(b)).map((match) => match[0] ?? '').toList();
  for (var index = 0; index < left.length && index < right.length; index++) {
    final x = left[index];
    final y = right[index];
    final numbers = (int.tryParse(x), int.tryParse(y));
    final order = switch (numbers) {
      (final int p, final int q) => p.compareTo(q),
      _ => x.compareTo(y),
    };
    if (order != 0) {
      return order;
    }
  }
  return left.length.compareTo(right.length);
}

/// Numbers numerically, anything else as text in natural order.
int compareValues(Object a, Object b) =>
    a is num && b is num ? a.compareTo(b) : naturalCompare('$a', '$b');

bool _includes(Object value, String search) =>
    '$value'.toLowerCase().contains(search.toLowerCase());

/// The rows [query] lets through, sorted, before paging: case-insensitive "contains" filters
/// (the table filter over every filterable column, column filters combined), one sort
/// column, ties kept in their original order.
List<T> filterAndSort<T>({
  required List<T> rows,
  required List<QueryColumn<T>> columns,
  required TableQuery query,
}) {
  final searchable = columns.where((column) => column.filterable).toList();
  QueryColumn<T>? columnOf(String id) {
    for (final column in searchable) {
      if (column.id == id) {
        return column;
      }
    }
    return null;
  }

  final matching = [
    for (final row in rows)
      if ((query.globalFilter.isEmpty ||
              searchable.any((column) => _includes(column.value(row), query.globalFilter))) &&
          query.columnFilters.entries.every((filter) {
            final column = columnOf(filter.key);
            return column == null || _includes(column.value(row), filter.value);
          }))
        row,
  ];

  final sort = query.sort;
  final sortColumn = sort == null
      ? null
      : columns.where((column) => column.id == sort.columnId).firstOrNull;
  if (sort == null || sortColumn == null) {
    return matching;
  }
  final indexed = matching.indexed.toList()
    ..sort((a, b) {
      final order = compareValues(sortColumn.value(a.$2), sortColumn.value(b.$2));
      final directed = sort.descending ? -order : order;
      return directed != 0 ? directed : a.$1.compareTo(b.$1);
    });
  return [for (final (_, row) in indexed) row];
}

/// A stand-in for a backend list endpoint: filters, sorts and pages [rows] the way a server
/// would answer [query]. Returns the requested page and the number of matching rows.
({List<T> rows, int total}) queryRows<T>({
  required List<T> rows,
  required List<QueryColumn<T>> columns,
  required TableQuery query,
}) {
  final matching = filterAndSort(rows: rows, columns: columns, query: query);
  final start = query.pageIndex * query.pageSize;
  return (rows: matching.skip(start).take(query.pageSize).toList(), total: matching.length);
}
