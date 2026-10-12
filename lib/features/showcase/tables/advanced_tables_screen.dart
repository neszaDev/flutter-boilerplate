import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/tables/advanced_table_demos.dart';

/// `/dashboard/tables/advanced-tables`: one data table, four uses: filters and details, a
/// simulated backend, CSV export and row selection.
class AdvancedTablesScreen extends StatelessWidget {
  const AdvancedTablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.advancedTablesPageTitle,
      description: Text(l10n.advancedTablesPageDescription),
      children: [
        DemoCard(
          title: l10n.advancedTablesPageDemoTitle,
          description: l10n.advancedTablesPageDemoDescription,
          child: const DemoTable(),
        ),
        DemoCard(
          title: l10n.advancedTablesPageBackendTitle,
          description: l10n.advancedTablesPageBackendDescription,
          child: const BackendTable(),
        ),
        DemoCard(
          title: l10n.advancedTablesPageDownloadTitle,
          description: l10n.advancedTablesPageDownloadDescription,
          child: const DownloadTable(),
        ),
        DemoCard(
          title: l10n.advancedTablesPageSelectTitle,
          description: l10n.advancedTablesPageSelectDescription,
          child: const SelectTable(),
        ),
      ],
    );
  }
}
