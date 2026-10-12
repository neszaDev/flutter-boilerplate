/// A sort on one column, ascending unless [descending].
class SortRule {
  const SortRule(this.columnId, {this.descending = false});

  final String columnId;
  final bool descending;

  @override
  bool operator ==(Object other) =>
      other is SortRule && other.columnId == columnId && other.descending == descending;

  @override
  int get hashCode => Object.hash(columnId, descending);

  @override
  String toString() => 'SortRule($columnId${descending ? ', descending' : ''})';
}

/// Everything that decides which rows a table shows: what a backend would receive. Immutable.
class TableQuery {
  const TableQuery({
    required this.pageSize,
    this.sort,
    this.columnFilters = const {},
    this.globalFilter = '',
    this.pageIndex = 0,
  });

  /// The query of a table before anyone touches it: no sorting or filters, first page.
  const TableQuery.initial(int pageSize) : this(pageSize: pageSize);

  final SortRule? sort;

  /// Column id → filter text; empty filters are left out.
  final Map<String, String> columnFilters;

  /// The search over every filterable column.
  final String globalFilter;

  /// Zero-based.
  final int pageIndex;
  final int pageSize;

  /// Whether a filter narrows the rows.
  bool get filtered => globalFilter.isNotEmpty || columnFilters.isNotEmpty;

  TableQuery copyWith({
    SortRule? Function()? sort,
    Map<String, String>? columnFilters,
    String? globalFilter,
    int? pageIndex,
    int? pageSize,
  }) => TableQuery(
    sort: sort == null ? this.sort : sort(),
    columnFilters: columnFilters ?? this.columnFilters,
    globalFilter: globalFilter ?? this.globalFilter,
    pageIndex: pageIndex ?? this.pageIndex,
    pageSize: pageSize ?? this.pageSize,
  );

  /// This query with the filter of [columnId] set to [value] (removed when empty), back on
  /// the first page.
  TableQuery withColumnFilter(String columnId, String value) => copyWith(
    columnFilters: {
      for (final MapEntry(:key, value: filter) in columnFilters.entries)
        if (key != columnId) key: filter,
      if (value.isNotEmpty) columnId: value,
    },
    pageIndex: 0,
  );

  @override
  bool operator ==(Object other) =>
      other is TableQuery &&
      other.sort == sort &&
      other.globalFilter == globalFilter &&
      other.pageIndex == pageIndex &&
      other.pageSize == pageSize &&
      other.columnFilters.length == columnFilters.length &&
      columnFilters.entries.every((entry) => other.columnFilters[entry.key] == entry.value);

  @override
  int get hashCode => Object.hash(
    sort,
    globalFilter,
    pageIndex,
    pageSize,
    Object.hashAllUnordered(
      columnFilters.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );
}

/// The next sort after a tap on the head of [columnId]: ascending, then descending, then
/// (when [resettable]) unsorted.
SortRule? nextSort(SortRule? current, String columnId, {required bool resettable}) {
  if (current?.columnId != columnId) {
    return SortRule(columnId);
  }
  if (current?.descending == false) {
    return SortRule(columnId, descending: true);
  }
  return resettable ? null : SortRule(columnId);
}

/// What an empty table says.
enum EmptyReason { loading, noResults, noItems }

/// Loading, nothing matches the filters, or no rows at all.
EmptyReason emptyReason({required bool loading, required TableQuery query}) {
  if (loading) {
    return EmptyReason.loading;
  }
  return query.filtered ? EmptyReason.noResults : EmptyReason.noItems;
}

/// What the row logic reads from a column: its id and the value it sorts, filters and
/// exports (a `String` or a `num`).
class QueryColumn<T> {
  const QueryColumn({required this.id, required this.value, this.filterable = true});

  final String id;
  final Object Function(T row) value;

  /// Takes part in the table and column filters.
  final bool filterable;
}
