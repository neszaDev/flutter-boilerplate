import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/data/paged_list.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/offline_banner.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/test_results/test_result_form.dart';
import 'package:flutter_boilerplate/features/test_results/test_results_data.dart';
import 'package:flutter_boilerplate/features/test_results/widgets/report_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `/dashboard/test-results`: totals, then every result, most recent first. Add with the
/// button, tap a row to edit, swipe it to delete.
class TestResultsScreen extends ConsumerWidget {
  const TestResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final list = ref.watch(testResultsListProvider);
    final summary = ref.watch(testResultsSummaryProvider);
    final now = DateTime.now();

    Future<void> refresh() async {
      ref.invalidate(testResultsSummaryProvider);
      await ref.read(testResultsListProvider.notifier).reload();
    }

    return AppScaffold(
      title: l10n.testResultsPageTitle,
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('testResults.add'),
        onPressed: () => showTestResultSheet(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.testResultFormCreateButton),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, Space.lg),
                    sliver: SliverList.list(
                      children: [
                        PageHeader(
                          title: l10n.testResultsPageTitle,
                          description: Text(l10n.testResultsPageDescription),
                        ),
                        const SizedBox(height: Space.lg),
                        TotalsStrip(summary: summary.value ?? TestResultSummary.empty),
                        const SizedBox(height: Space.lg),
                        SectionTitle(l10n.testResultsPageListTitle),
                        const SizedBox(height: Space.sm),
                      ],
                    ),
                  ),
                  ...switch (list) {
                    AsyncValue(:final value?) => [
                      SliverToBoxAdapter(
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: Space.page),
                          clipBehavior: Clip.antiAlias,
                          child: value.items.isEmpty
                              ? ResultsList(
                                  rows: const [],
                                  empty: EmptyState(
                                    title: l10n.testResultsPageEmpty,
                                    text: l10n.testResultsPageEmptyText,
                                  ),
                                )
                              : _DismissibleRows(
                                  rows: value.items,
                                  drawDelays: freshDrawDelays(value.items, now),
                                ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PagedFooter(
                          state: value,
                          onLoadMore: ref.read(testResultsListProvider.notifier).loadMore,
                        ),
                      ),
                    ],
                    AsyncValue(:final error?) => [
                      SliverToBoxAdapter(
                        child: ErrorView(error: error, onRetry: refresh, compact: true),
                      ),
                    ],
                    _ => [
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Space.page),
                          child: SkeletonRows(),
                        ),
                      ),
                    ],
                  },
                  // Room for the floating button over the last row.
                  const SliverToBoxAdapter(child: SizedBox(height: 96)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissibleRows extends ConsumerWidget {
  const _DismissibleRows({required this.rows, required this.drawDelays});

  final List<TestResult> rows;
  final Map<int, Duration> drawDelays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Column(
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) Divider(color: colors.ink200, indent: Space.page),
          Dismissible(
            key: ValueKey(row.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: colors.pen,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: Space.lg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.testResultsPageDeleteButton,
                    style: TextStyle(color: colors.ply, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: Space.sm),
                  Icon(Icons.delete_outline, color: colors.ply),
                ],
              ),
            ),
            // The list reloads after a delete; never remove the row before the backend agrees.
            confirmDismiss: (_) async {
              await deleteTestResult(context, ref, row);
              return false;
            },
            child: Semantics(
              customSemanticsActions: {
                CustomSemanticsAction(label: l10n.testResultsPageDeleteLabel(row.testName)): () =>
                    deleteTestResult(context, ref, row),
              },
              child: ResultRow(
                result: row,
                drawDelay: drawDelays[row.id],
                onTap: () => showTestResultSheet(context, existing: row),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
