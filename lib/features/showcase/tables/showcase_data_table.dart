import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/tables/fake_backend.dart';
import 'package:flutter_boilerplate/features/showcase/tables/table_pagination.dart';
import 'package:flutter_boilerplate/features/showcase/tables/table_query.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _pageSizes = [5, 10, 20, 50];
const _checkboxWidth = 52.0;
const _detailsWidth = 96.0;
const _minFixedWidth = 110.0;

/// A column of a [ShowcaseDataTable].
class TableColumn<T> extends QueryColumn<T> {
  const TableColumn({
    required super.id,
    required this.header,
    required super.value,
    super.filterable,
    this.cell,
    this.sortable = true,
    this.width = 140,
  });

  /// Column head; also names the column's filter field.
  final String header;

  /// Custom cell; defaults to the value as text.
  final Widget Function(BuildContext context, T row)? cell;

  /// Sorts on a tap on its head when the table has a sorter.
  final bool sortable;

  /// Preferred width; columns stretch to fill a wider table.
  final double width;
}

/// The ink a cell should print in when the table sits on the folder green (`dark`), or null on
/// card stock. Custom cells (marks, links) read it.
class TableInk extends InheritedWidget {
  const TableInk({required this.color, required super.child, super.key});

  final Color? color;

  static Color? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TableInk>()?.color;

  @override
  bool updateShouldNotify(TableInk oldWidget) => oldWidget.color != color;
}

/// The data table of the showcase (CoreUI's `CDataTable`): sorting, table and column filters,
/// rows per page, pagination, tappable rows, row details, selection, a loading overlay and the
/// empty view, in the Marksheet table styles. Wider than the screen, it scrolls sideways.
///
/// Without [query] it keeps its own query and does the filtering, sorting and paging itself.
/// With [rowCount] it trusts [data] as the current, processed page of a backend's answer.
class ShowcaseDataTable<T> extends StatefulWidget {
  const ShowcaseDataTable({
    required this.data,
    required this.columns,
    required this.rowId,
    required this.caption,
    this.itemsPerPage = 10,
    this.itemsPerPageSelect = false,
    this.pagination = false,
    this.sorter = false,
    this.sorterResettable = false,
    this.tableFilter = false,
    this.columnFilter = false,
    this.lazyFilters = false,
    this.loading = false,
    this.onRowTap,
    this.detailsBuilder,
    this.selectable = false,
    this.selectOnRowTap = false,
    this.rowTint,
    this.toolbar,
    this.query,
    this.onQueryChange,
    this.rowCount,
    this.striped = false,
    this.hover = true,
    this.bordered = false,
    this.small = false,
    this.fixed = false,
    this.dark = false,
    super.key,
  });

  final List<T> data;
  final List<TableColumn<T>> columns;
  final String Function(T row) rowId;

  /// Accessible name of the table.
  final String caption;

  /// Rows per page at first.
  final int itemsPerPage;

  /// Let the reader change the rows per page.
  final bool itemsPerPageSelect;
  final bool pagination;

  /// Sort by tapping column heads.
  final bool sorter;

  /// A third tap on a sorted head removes the sort.
  final bool sorterResettable;

  /// One search field over every filterable column.
  final bool tableFilter;

  /// A filter field under each filterable column head.
  final bool columnFilter;

  /// Apply filters when the field is left or submitted instead of on every keystroke.
  final bool lazyFilters;

  /// Dims the rows and shows a spinner, e.g. while a backend answers.
  final bool loading;
  final ValueChanged<T>? onRowTap;

  /// A details panel each row can open below itself.
  final Widget Function(BuildContext context, T row)? detailsBuilder;

  /// A checkbox on each row, a select-all box and the selected count.
  final bool selectable;

  /// Tapping a row toggles its checkbox.
  final bool selectOnRowTap;

  /// A background for some rows (the Vue `_classes`).
  final Color? Function(BuildContext context, T row)? rowTint;

  /// Shown above the table with every row the filters let through, in display order.
  final Widget Function(BuildContext context, List<T> rows)? toolbar;

  /// Controlled query; pair it with [onQueryChange].
  final TableQuery? query;
  final ValueChanged<TableQuery>? onQueryChange;

  /// Total rows on the server.
  final int? rowCount;

  /// Shade every other row.
  final bool striped;

  /// Highlight a row while it is pressed (the web's hover).
  final bool hover;

  /// Rule every cell.
  final bool bordered;

  /// Condensed rows.
  final bool small;

  /// Equal-width columns.
  final bool fixed;

  /// Print the table on the folder green.
  final bool dark;

  @override
  State<ShowcaseDataTable<T>> createState() => _ShowcaseDataTableState<T>();
}

class _ShowcaseDataTableState<T> extends State<ShowcaseDataTable<T>> {
  late TableQuery _ownQuery = TableQuery.initial(widget.itemsPerPage);
  final _selected = <String>{};
  final _expanded = <String>{};

  TableQuery get _query => widget.query ?? _ownQuery;

  void _commit(TableQuery next) {
    if (widget.query == null) {
      setState(() => _ownQuery = next);
    }
    widget.onQueryChange?.call(next);
  }

  void _toggleSelected(String id, bool selected) => setState(() {
    if (selected) {
      _selected.add(id);
    } else {
      _selected.remove(id);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = _query;
    final manual = widget.rowCount != null;
    final processed = manual
        ? widget.data
        : filterAndSort(rows: widget.data, columns: widget.columns, query: query);
    final total = widget.rowCount ?? processed.length;
    final pageCount = (total / query.pageSize).ceil();
    // Rows deleted under the last page: show the new last page.
    final pageIndex = manual
        ? query.pageIndex
        : math.min(query.pageIndex, math.max(pageCount - 1, 0));
    final pageRows = manual
        ? widget.data
        : processed.skip(pageIndex * query.pageSize).take(query.pageSize).toList();
    final filteredIds = [for (final row in processed) widget.rowId(row)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.tableFilter || widget.itemsPerPageSelect) ...[
          _Controls(
            query: query,
            tableFilter: widget.tableFilter,
            itemsPerPageSelect: widget.itemsPerPageSelect,
            lazy: widget.lazyFilters,
            onChange: _commit,
          ),
          const SizedBox(height: Space.page),
        ],
        if (widget.toolbar case final toolbar?) ...[
          toolbar(context, processed),
          const SizedBox(height: Space.page),
        ],
        Semantics(
          container: true,
          explicitChildNodes: true,
          label: widget.caption,
          child: Stack(
            children: [
              _TableBody<T>(
                table: widget,
                query: query,
                rows: pageRows,
                selected: _selected,
                expanded: _expanded,
                filteredIds: filteredIds,
                onSort: (columnId) => _commit(
                  query.copyWith(
                    sort: () => nextSort(query.sort, columnId, resettable: widget.sorterResettable),
                  ),
                ),
                onFilter: (columnId, value) => _commit(query.withColumnFilter(columnId, value)),
                onSelect: _toggleSelected,
                onSelectAll: (selected) => setState(() {
                  if (selected) {
                    _selected.addAll(filteredIds);
                  } else {
                    _selected.removeAll(filteredIds);
                  }
                }),
                onToggleDetails: (id) => setState(() {
                  if (!_expanded.remove(id)) {
                    _expanded.add(id);
                  }
                }),
              ),
              if (widget.loading)
                Positioned.fill(
                  child: ColoredBox(
                    color: context.colors.paperCard.withValues(alpha: 0.7),
                    child: Center(
                      child: Semantics(
                        container: true,
                        liveRegion: true,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          semanticsLabel: l10n.dataTableLoading,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.selectable) ...[
          const SizedBox(height: Space.sm),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Space.md,
            children: [
              Semantics(
                liveRegion: true,
                child: Text(
                  l10n.dataTableSelectedCount(_selected.length),
                  style: context.text.bodySmall,
                ),
              ),
              if (_selected.isNotEmpty)
                TextButton(
                  onPressed: () => setState(_selected.clear),
                  child: Text(l10n.dataTableClearSelection),
                ),
            ],
          ),
        ],
        if (widget.pagination && pageCount > 1) ...[
          const SizedBox(height: Space.sm),
          TablePagination(
            page: pageIndex + 1,
            pages: pageCount,
            onPageChange: (page) => _commit(query.copyWith(pageIndex: page - 1)),
          ),
        ],
      ],
    );
  }
}

/// The search field over every column and the rows-per-page menu.
class _Controls extends StatelessWidget {
  const _Controls({
    required this.query,
    required this.tableFilter,
    required this.itemsPerPageSelect,
    required this.lazy,
    required this.onChange,
  });

  final TableQuery query;
  final bool tableFilter;
  final bool itemsPerPageSelect;
  final bool lazy;
  final ValueChanged<TableQuery> onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (tableFilter)
          _FilterField(
            value: query.globalFilter,
            lazy: lazy,
            decoration: InputDecoration(
              labelText: l10n.dataTableFilterLabel,
              hintText: l10n.dataTableFilterPlaceholder,
              prefixIcon: const Icon(LucideIcons.search, size: 18),
            ),
            onApply: (value) => onChange(query.copyWith(globalFilter: value, pageIndex: 0)),
          ),
        if (itemsPerPageSelect)
          MergeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(l10n.dataTableItemsPerPage, style: context.text.bodySmall),
                const SizedBox(width: Space.md),
                DropdownButton<int>(
                  value: query.pageSize,
                  items: [
                    for (final size in _pageSizes)
                      DropdownMenuItem(
                        value: size,
                        child: Text('$size', style: context.type.table),
                      ),
                  ],
                  onChanged: (size) {
                    if (size != null) {
                      onChange(query.copyWith(pageSize: size, pageIndex: 0));
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A filter input: applied on every keystroke, or ([lazy]) when the field is left or
/// submitted.
class _FilterField extends StatefulWidget {
  const _FilterField({
    required this.value,
    required this.onApply,
    required this.decoration,
    this.lazy = false,
  });

  final String value;
  final ValueChanged<String> onApply;
  final InputDecoration decoration;
  final bool lazy;

  @override
  State<_FilterField> createState() => _FilterFieldState();
}

class _FilterFieldState extends State<_FilterField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus && widget.lazy && _controller.text != widget.value) {
        widget.onApply(_controller.text);
      }
    });
  }

  @override
  void didUpdateWidget(_FilterField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.lazy && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    focusNode: _focus,
    decoration: widget.decoration,
    textInputAction: TextInputAction.search,
    autocorrect: false,
    style: context.type.table,
    onChanged: widget.lazy ? null : widget.onApply,
    onSubmitted: widget.lazy ? widget.onApply : null,
    onTapOutside: (_) => _focus.unfocus(),
  );
}

/// The colours of a table style: card stock, or the folder green when [dark].
class _Look {
  const _Look({
    required this.ink,
    required this.head,
    required this.rule,
    required this.headRule,
    required this.stripe,
    required this.pressed,
    required this.selected,
    required this.background,
  });

  factory _Look.of(BuildContext context, {required bool dark}) {
    final colors = context.colors;
    Color onFolder(double alpha) => colors.folderInk.withValues(alpha: alpha);
    return dark
        ? _Look(
            ink: colors.folderInk,
            head: colors.folderInkSoft,
            rule: onFolder(0.15),
            headRule: onFolder(0.3),
            stripe: onFolder(0.06),
            pressed: onFolder(0.1),
            selected: onFolder(0.14),
            background: colors.folder,
          )
        : _Look(
            ink: colors.ink900,
            head: colors.ink600,
            rule: colors.ink200,
            headRule: colors.ink300,
            stripe: colors.ink100.withValues(alpha: 0.45),
            pressed: colors.ink100,
            selected: colors.primary.withValues(alpha: 0.08),
            background: Colors.transparent,
          );
  }

  final Color ink;
  final Color head;
  final Color rule;
  final Color headRule;
  final Color stripe;
  final Color pressed;
  final Color selected;
  final Color background;
}

class _TableBody<T> extends StatelessWidget {
  const _TableBody({
    required this.table,
    required this.query,
    required this.rows,
    required this.selected,
    required this.expanded,
    required this.filteredIds,
    required this.onSort,
    required this.onFilter,
    required this.onSelect,
    required this.onSelectAll,
    required this.onToggleDetails,
  });

  final ShowcaseDataTable<T> table;
  final TableQuery query;
  final List<T> rows;
  final Set<String> selected;
  final Set<String> expanded;
  final List<String> filteredIds;
  final ValueChanged<String> onSort;
  final void Function(String columnId, String value) onFilter;
  final void Function(String id, bool selected) onSelect;
  final ValueChanged<bool> onSelectAll;
  final ValueChanged<String> onToggleDetails;

  /// The width of each column: the preferred widths stretched to fill [available], or equal
  /// widths when the table is fixed.
  List<double> _widths(double available) {
    final extra =
        (table.selectable ? _checkboxWidth : 0) +
        (table.detailsBuilder != null ? _detailsWidth : 0);
    final room = available - extra;
    final count = table.columns.length;
    if (table.fixed) {
      return List.filled(count, math.max(room / count, _minFixedWidth));
    }
    final preferred = table.columns.fold<double>(0, (sum, column) => sum + column.width);
    final scale = math.max(1, room / preferred);
    return [for (final column in table.columns) column.width * scale];
  }

  @override
  Widget build(BuildContext context) {
    final look = _Look.of(context, dark: table.dark);
    return LayoutBuilder(
      builder: (context, constraints) {
        final widths = _widths(constraints.maxWidth);
        final width =
            widths.fold<double>(0, (sum, value) => sum + value) +
            (table.selectable ? _checkboxWidth : 0) +
            (table.detailsBuilder != null ? _detailsWidth : 0);
        final body = Container(
          width: width,
          decoration: BoxDecoration(
            color: look.background,
            borderRadius: table.dark ? BorderRadius.circular(Radii.sm) : null,
          ),
          // Drawn over the cells, so the rule takes no room from them.
          foregroundDecoration: table.bordered
              ? BoxDecoration(
                  border: Border.all(color: look.rule),
                  borderRadius: table.dark ? BorderRadius.circular(Radii.sm) : null,
                )
              : null,
          clipBehavior: table.dark ? Clip.antiAlias : Clip.none,
          child: TableInk(
            color: table.dark ? look.ink : null,
            child: DefaultTextStyle.merge(
              style: context.type.table.copyWith(color: look.ink),
              child: IconTheme.merge(
                data: IconThemeData(color: look.ink),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _headRow(context, look, widths),
                    if (table.columnFilter) _filterRow(context, look, widths),
                    if (rows.isEmpty) _empty(context, look),
                    for (final (index, row) in rows.indexed)
                      ..._dataRow(context, look, widths, index, row),
                  ],
                ),
              ),
            ),
          ),
        );
        return width > constraints.maxWidth
            ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: body)
            : body;
      },
    );
  }

  /// A cell of [width], ruled on its trailing side when the table is bordered and it is not the
  /// last.
  Widget _cell(_Look look, double width, Widget child, {bool last = false, bool center = false}) =>
      Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: Space.md, vertical: table.small ? 6 : Space.md),
        alignment: center ? Alignment.center : AlignmentDirectional.centerStart,
        decoration: table.bordered && !last
            ? BoxDecoration(
                border: BorderDirectional(end: BorderSide(color: look.rule)),
              )
            : null,
        child: child,
      );

  bool get _hasDetails => table.detailsBuilder != null;

  Widget _headRow(BuildContext context, _Look look, List<double> widths) {
    final l10n = context.l10n;
    final sort = query.sort;
    final allSelected = filteredIds.isNotEmpty && filteredIds.every(selected.contains);
    final someSelected = filteredIds.any(selected.contains);
    final style = context.type.formLabel.copyWith(color: look.head);
    final cells = <Widget>[
      if (table.selectable)
        _cell(
          look,
          _checkboxWidth,
          // Its own node: the head row merges the column names.
          Semantics(
            container: true,
            child: Checkbox(
              tristate: true,
              value: allSelected ? true : (someSelected ? null : false),
              semanticLabel: l10n.dataTableSelectAll,
              onChanged: (_) => onSelectAll(!allSelected),
            ),
          ),
          center: true,
        ),
      for (final (index, column) in table.columns.indexed)
        _cell(
          look,
          widths[index],
          table.sorter && column.sortable
              ? _SortHead(
                  header: column.header,
                  style: style,
                  direction: sort?.columnId != column.id
                      ? null
                      : (sort?.descending ?? false)
                      ? _Direction.descending
                      : _Direction.ascending,
                  onTap: () => onSort(column.id),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    column.header.toUpperCase(),
                    semanticsLabel: column.header,
                    style: style,
                  ),
                ),
          last: !_hasDetails && index == table.columns.length - 1,
        ),
      if (_hasDetails)
        _cell(
          look,
          _detailsWidth,
          Semantics(label: l10n.dataTableDetailsColumn, child: const SizedBox(height: 16)),
          last: true,
        ),
    ];
    return Semantics(
      container: true,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: look.headRule, width: 1.5)),
        ),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
        ),
      ),
    );
  }

  Widget _filterRow(BuildContext context, _Look look, List<double> widths) {
    final l10n = context.l10n;
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: look.rule)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (table.selectable) _cell(look, _checkboxWidth, const SizedBox()),
          for (final (index, column) in table.columns.indexed)
            Container(
              width: widths[index],
              padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.sm),
              decoration: table.bordered && (_hasDetails || index < table.columns.length - 1)
                  ? BoxDecoration(
                      border: BorderDirectional(end: BorderSide(color: look.rule)),
                    )
                  : null,
              child: column.filterable
                  ? _FilterField(
                      value: query.columnFilters[column.id] ?? '',
                      lazy: table.lazyFilters,
                      decoration: InputDecoration(
                        labelText: l10n.dataTableColumnFilterLabel(column.header),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: context.text.bodySmall,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Space.sm,
                          vertical: 10,
                        ),
                      ),
                      onApply: (value) => onFilter(column.id, value),
                    )
                  : null,
            ),
          if (_hasDetails) const SizedBox(width: _detailsWidth),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context, _Look look) {
    final l10n = context.l10n;
    final message = switch (emptyReason(loading: table.loading, query: query)) {
      EmptyReason.loading => l10n.dataTableLoading,
      EmptyReason.noResults => l10n.dataTableNoResults,
      EmptyReason.noItems => l10n.dataTableNoItems,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.xl),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: look.rule)),
      ),
      child: Column(
        children: [
          ExcludeSemantics(
            child: Icon(LucideIcons.searchX, size: 24, color: look.ink.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: Space.sm),
          Text(
            message,
            style: TextStyle(fontWeight: FontWeight.w600, color: look.ink),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _dataRow(BuildContext context, _Look look, List<double> widths, int index, T row) {
    final l10n = context.l10n;
    final id = table.rowId(row);
    final label = '${table.columns.first.value(row)}';
    final isSelected = selected.contains(id);
    final open = expanded.contains(id);
    final clickable = table.onRowTap != null || table.selectOnRowTap;
    final tint = table.rowTint?.call(context, row);
    final background =
        tint ??
        (isSelected ? look.selected : null) ??
        (table.striped && index.isEven ? look.stripe : Colors.transparent);

    final cells = <Widget>[
      if (table.selectable)
        _cell(
          look,
          _checkboxWidth,
          Semantics(
            container: true,
            child: Checkbox(
              value: isSelected,
              semanticLabel: l10n.dataTableSelectRow(label),
              onChanged: (value) => onSelect(id, value ?? false),
            ),
          ),
          center: true,
        ),
      for (final (column, entry) in table.columns.indexed)
        _cell(
          look,
          widths[column],
          entry.cell?.call(context, row) ?? Text('${entry.value(row)}'),
          last: !_hasDetails && column == table.columns.length - 1,
        ),
      if (table.detailsBuilder != null)
        _cell(
          look,
          _detailsWidth,
          Semantics(
            expanded: open,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(64, 44),
                padding: const EdgeInsets.symmetric(horizontal: Space.md),
              ),
              onPressed: () => onToggleDetails(id),
              child: Text(
                open ? l10n.dataTableHideDetails : l10n.dataTableShowDetails,
                semanticsLabel: open
                    ? l10n.dataTableHideDetailsOf(label)
                    : l10n.dataTableShowDetailsOf(label),
              ),
            ),
          ),
          last: true,
          center: true,
        ),
    ];

    return [
      // One node per row, so screen readers read the table row by row.
      Semantics(
        container: true,
        child: Material(
          type: MaterialType.transparency,
          child: Ink(
            decoration: BoxDecoration(
              color: background,
              border: Border(bottom: BorderSide(color: look.rule)),
            ),
            child: InkWell(
              // Pressed feedback: the phone's version of the web's hover highlight.
              onTap: clickable
                  ? () {
                      if (table.selectOnRowTap) {
                        onSelect(id, !isSelected);
                      }
                      table.onRowTap?.call(row);
                    }
                  : (table.hover ? () {} : null),
              excludeFromSemantics: !clickable,
              canRequestFocus: clickable,
              highlightColor: look.pressed,
              splashColor: look.pressed,
              child: IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
              ),
            ),
          ),
        ),
      ),
      if (open && table.detailsBuilder != null)
        Container(
          padding: const EdgeInsets.all(Space.md),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: look.rule)),
          ),
          child: table.detailsBuilder?.call(context, row),
        ),
    ];
  }
}

enum _Direction { ascending, descending }

/// A sortable column head: its name, the sort arrow, and the sort state for screen readers.
class _SortHead extends StatelessWidget {
  const _SortHead({
    required this.header,
    required this.style,
    required this.direction,
    required this.onTap,
  });

  final String header;
  final TextStyle style;
  final _Direction? direction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, state) = switch (direction) {
      _Direction.ascending => (LucideIcons.arrowUp, l10n.dataTableSortedAscending),
      _Direction.descending => (LucideIcons.arrowDown, l10n.dataTableSortedDescending),
      null => (LucideIcons.arrowUpDown, l10n.dataTableNotSorted),
    };
    return MergeSemantics(
      child: Semantics(
        button: true,
        value: state,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  // A long head shrinks to fit rather than breaking mid-word on a phone.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(header.toUpperCase(), semanticsLabel: header, style: style),
                  ),
                ),
                const SizedBox(width: 6),
                ExcludeSemantics(
                  child: Icon(
                    icon,
                    size: 14,
                    color: direction == null ? style.color?.withValues(alpha: 0.4) : style.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
