import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/tables/user_columns.dart';
import 'package:flutter_boilerplate/features/showcase/tables/users_data.dart';

/// `/dashboard/tables/tables`: the same users in every table style (simple, striped,
/// condensed, bordered, combined, on the folder). Rows are shuffled on each visit; wide tables
/// scroll sideways.
class BasicTablesScreen extends StatefulWidget {
  const BasicTablesScreen({super.key});

  @override
  State<BasicTablesScreen> createState() => _BasicTablesScreenState();
}

class _BasicTablesScreenState extends State<BasicTablesScreen> {
  // One shuffle per table and visit, kept across rebuilds.
  final _orders = List.generate(6, (_) => shuffledUsers());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.tablesPageTitle,
      description: Text(l10n.tablesPageDescription),
      children: [
        DemoCard(
          title: l10n.tablesPageSimpleTitle,
          description: l10n.tablesPageSimpleDescription,
          child: UserTable(users: _orders[0], caption: l10n.tablesPageSimpleTitle),
        ),
        DemoCard(
          title: l10n.tablesPageStripedTitle,
          description: l10n.tablesPageStripedDescription,
          child: UserTable(users: _orders[1], caption: l10n.tablesPageStripedTitle, striped: true),
        ),
        DemoCard(
          title: l10n.tablesPageCondensedTitle,
          description: l10n.tablesPageCondensedDescription,
          child: UserTable(users: _orders[2], caption: l10n.tablesPageCondensedTitle, small: true),
        ),
        DemoCard(
          title: l10n.tablesPageBorderedTitle,
          description: l10n.tablesPageBorderedDescription,
          child: UserTable(
            users: _orders[3],
            caption: l10n.tablesPageBorderedTitle,
            fixed: true,
            bordered: true,
          ),
        ),
        DemoCard(
          title: l10n.tablesPageCombinedTitle,
          description: l10n.tablesPageCombinedDescription,
          child: UserTable(
            users: _orders[4],
            caption: l10n.tablesPageCombinedTitle,
            hover: true,
            striped: true,
            bordered: true,
            small: true,
            fixed: true,
          ),
        ),
        DemoCard(
          title: l10n.tablesPageCombinedDarkTitle,
          description: l10n.tablesPageCombinedDarkDescription,
          child: UserTable(
            users: _orders[5],
            caption: l10n.tablesPageCombinedDarkTitle,
            hover: true,
            striped: true,
            bordered: true,
            small: true,
            fixed: true,
            dark: true,
          ),
        ),
      ],
    );
  }
}
