import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/features/showcase/tables/csv.dart';
import 'package:flutter_boilerplate/features/showcase/tables/fake_backend.dart';
import 'package:flutter_boilerplate/features/showcase/tables/showcase_data_table.dart';
import 'package:flutter_boilerplate/features/showcase/tables/table_query.dart';
import 'package:flutter_boilerplate/features/showcase/tables/user_columns.dart';
import 'package:flutter_boilerplate/features/showcase/tables/users_data.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/csv_export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

String _rowId(SampleUser user) => '${user.id}';

/// The Vue `DemoTable`: every `CDataTable` option at once (table and column filters, rows per
/// page, sorting, pagination) with a details panel per row.
class DemoTable extends StatefulWidget {
  const DemoTable({super.key});

  @override
  State<DemoTable> createState() => _DemoTableState();
}

class _DemoTableState extends State<DemoTable> {
  var _users = sampleUsers;

  @override
  Widget build(BuildContext context) => ShowcaseDataTable<SampleUser>(
    data: _users,
    columns: userColumns(context, vueWidths: true),
    rowId: _rowId,
    caption: context.l10n.advancedTablesPageDemoTitle,
    itemsPerPage: 5,
    tableFilter: true,
    columnFilter: true,
    itemsPerPageSelect: true,
    sorter: true,
    pagination: true,
    detailsBuilder: (context, user) => _UserDetails(
      user: user,
      onDelete: () => setState(
        () => _users = [
          for (final row in _users)
            if (row.id != user.id) row,
        ],
      ),
    ),
  );
}

/// A row's details: the user's initials, name, registration and actions.
class _UserDetails extends StatelessWidget {
  const _UserDetails({required this.user, required this.onDelete});

  final SampleUser user;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final initials = user.username.split(' ').take(2).map((part) => part.characters.first).join();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The Vue sample photos are not bundled: initials stand in for them.
        ExcludeSemantics(
          child: Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.ink100,
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Text(initials, style: context.text.titleLarge?.copyWith(color: colors.ink700)),
          ),
        ),
        const SizedBox(width: Space.page),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.username, style: context.text.titleMedium),
              const SizedBox(height: Space.xs),
              Text(
                l10n.advancedTablesPageUserSince(
                  DateFormat.yMMMMd(context.localeName).format(registeredOn(user)),
                ),
                style: context.text.bodyMedium?.copyWith(color: colors.ink600),
              ),
              const SizedBox(height: Space.sm),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => unawaited(context.push<void>(Routes.user(user.id))),
                    icon: const Icon(LucideIcons.settings, size: 16),
                    label: Text(l10n.advancedTablesPageUserSettings),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.pen,
                      foregroundColor: colors.ply,
                    ),
                    onPressed: onDelete,
                    icon: const Icon(LucideIcons.trash2, size: 16),
                    label: Text(l10n.advancedTablesPageDeleteUser),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The Vue `BackendTable`: filters, sorting and paging go to a "backend" that answers a second
/// later, while the table shows a loading overlay. Filters apply when the field is left or
/// submitted, and a third tap on a sorted head removes the sort.
class BackendTable extends StatefulWidget {
  const BackendTable({super.key});

  /// The Vue example's fake round trip.
  static const latency = Duration(seconds: 1);
  static const pageSize = 5;

  @override
  State<BackendTable> createState() => _BackendTableState();
}

class _BackendTableState extends State<BackendTable> {
  var _query = const TableQuery.initial(BackendTable.pageSize);
  ({List<SampleUser> rows, int total})? _page;
  var _loading = false;
  Timer? _request;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _page ??= queryRows(rows: sampleUsers, columns: userColumns(context), query: _query);
  }

  @override
  void dispose() {
    _request?.cancel();
    super.dispose();
  }

  void _load(TableQuery next) {
    setState(() {
      _query = next;
      _loading = true;
    });
    // Only the latest request may answer; older ones are superseded.
    _request?.cancel();
    _request = Timer(BackendTable.latency, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _page = queryRows(rows: sampleUsers, columns: userColumns(context), query: next);
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = _page;
    return ShowcaseDataTable<SampleUser>(
      data: page?.rows ?? const [],
      rowCount: page?.total ?? 0,
      columns: userColumns(context),
      rowId: _rowId,
      caption: context.l10n.advancedTablesPageBackendTitle,
      query: _query,
      onQueryChange: _load,
      loading: _loading,
      tableFilter: true,
      columnFilter: true,
      lazyFilters: true,
      sorter: true,
      sorterResettable: true,
      pagination: true,
    );
  }
}

/// The Vue `DownloadTable`: a filterable, sortable table whose current rows (every page, after
/// filters and sorting) go to the share sheet as a CSV file.
class DownloadTable extends ConsumerWidget {
  const DownloadTable({super.key});

  /// The name of the shared file.
  static const filename = 'table-data.csv';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final columns = userColumns(context);

    Future<void> share(BuildContext button, List<SampleUser> rows) async {
      final csv = toCsv([
        [for (final column in columns) column.header],
        for (final row in rows) [for (final column in columns) column.value(row)],
      ]);
      final box = button.findRenderObject() as RenderBox?;
      try {
        await ref
            .read(csvExportProvider)
            .share(
              filename: filename,
              csv: csv,
              origin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
            );
      } on Exception {
        if (button.mounted) {
          showToast(button, l10n.advancedTablesPageExportError, tone: ToastTone.error);
        }
      }
    }

    return ShowcaseDataTable<SampleUser>(
      data: sampleUsers,
      columns: columns,
      rowId: _rowId,
      caption: l10n.advancedTablesPageDownloadTitle,
      itemsPerPage: 5,
      columnFilter: true,
      sorter: true,
      pagination: true,
      toolbar: (context, rows) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Builder(
          builder: (button) => FilledButton.icon(
            onPressed: rows.isEmpty ? null : () => share(button, rows),
            icon: const Icon(LucideIcons.download, size: 18),
            label: Text(l10n.advancedTablesPageDownloadButton(rows.length)),
          ),
        ),
      ),
    );
  }
}

/// The Vue `SelectTable`: a checkbox per row (a tap anywhere on the row toggles it), plus a
/// select-all box for the filtered rows and the selected count.
class SelectTable extends StatelessWidget {
  const SelectTable({super.key});

  @override
  Widget build(BuildContext context) => ShowcaseDataTable<SampleUser>(
    data: sampleUsers,
    columns: userColumns(context, vueWidths: true),
    rowId: _rowId,
    caption: context.l10n.advancedTablesPageSelectTitle,
    itemsPerPage: 5,
    tableFilter: true,
    columnFilter: true,
    itemsPerPageSelect: true,
    sorter: true,
    pagination: true,
    selectable: true,
    selectOnRowTap: true,
  );
}
