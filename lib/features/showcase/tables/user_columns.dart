import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/tables/showcase_data_table.dart';
import 'package:flutter_boilerplate/features/showcase/tables/user_status_mark.dart';
import 'package:flutter_boilerplate/features/showcase/tables/users_data.dart';
import 'package:intl/intl.dart';

/// The columns the Vue tables show for a user: name, registered, role and status. Sorting and
/// filters use the localized role and status names, as the reader sees them; [vueWidths]
/// gives the name 40% and role and status 20% each, like the Vue advanced tables.
List<TableColumn<SampleUser>> userColumns(BuildContext context, {bool vueWidths = false}) {
  final l10n = context.l10n;
  final medium = DateFormat.yMMMd(context.localeName);
  return [
    TableColumn(
      id: 'username',
      header: l10n.usersTableColumnUsername,
      value: (user) => user.username,
      width: vueWidths ? 220 : 170,
    ),
    TableColumn(
      id: 'registered',
      header: l10n.usersTableColumnRegistered,
      // ISO days sort in calendar order; the cell shows the localized date.
      value: (user) => user.registered,
      cell: (context, user) => Text(medium.format(registeredOn(user))),
      width: vueWidths ? 120 : 130,
    ),
    TableColumn(
      id: 'role',
      header: l10n.usersTableColumnRole,
      value: (user) => userRoleName(l10n, user.role),
      width: 110,
    ),
    TableColumn(
      id: 'status',
      header: l10n.usersTableColumnStatus,
      value: (user) => userStatusName(l10n, user.status),
      cell: (context, user) => UserStatusMark(status: user.status, color: TableInk.of(context)),
      width: 130,
    ),
  ];
}

/// The Vue `_classes` row tints, in Marksheet tokens; null for a plain row.
Color? userRowTint(BuildContext context, SampleUser user) => switch (user.highlight) {
  UserHighlight.success => context.colors.pass.withValues(alpha: 0.1),
  UserHighlight.danger => context.colors.pen.withValues(alpha: 0.06),
  null => null,
};

/// The Vue `Table.vue` wrapper: the users with name, registered, role and status, paginated
/// (10 rows when [small], 5 otherwise), in the requested table style.
class UserTable extends StatelessWidget {
  const UserTable({
    required this.users,
    required this.caption,
    this.striped = false,
    this.hover = false,
    this.bordered = false,
    this.small = false,
    this.fixed = false,
    this.dark = false,
    super.key,
  });

  /// Rows, already in display order.
  final List<SampleUser> users;
  final String caption;
  final bool striped;
  final bool hover;
  final bool bordered;
  final bool small;
  final bool fixed;
  final bool dark;

  @override
  Widget build(BuildContext context) => ShowcaseDataTable<SampleUser>(
    data: users,
    columns: userColumns(context),
    rowId: (user) => '${user.id}',
    caption: caption,
    striped: striped,
    hover: hover,
    bordered: bordered,
    small: small,
    fixed: fixed,
    dark: dark,
    itemsPerPage: small ? 10 : 5,
    rowTint: userRowTint,
    pagination: true,
  );
}
