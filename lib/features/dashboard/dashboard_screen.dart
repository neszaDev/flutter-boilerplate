import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/access_denied_view.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/test_results/test_result_form.dart';
import 'package:flutter_boilerplate/features/test_results/test_results_data.dart';
import 'package:flutter_boilerplate/features/test_results/widgets/report_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// `/dashboard`: who is signed in, the totals and the most recent tests.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);
    final summary = ref.watch(testResultsSummaryProvider);
    final latest = ref.watch(latestTestResultsProvider);

    Future<void> refresh() async {
      ref
        ..invalidate(testResultsSummaryProvider)
        ..invalidate(latestTestResultsProvider);
      try {
        await Future.wait<Object?>([
          ref.read(sessionProvider.notifier).refreshProfile(),
          ref.read(testResultsSummaryProvider.future),
          ref.read(latestTestResultsProvider.future),
        ]);
      } on Object {
        // The cards show the failure with a retry button; the spinner only needs to stop.
      }
    }

    return AppPage(
      title: l10n.dashboardPageTitle,
      onRefresh: refresh,
      description: user == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dashboardPageHelloMessage(user.email),
                  style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.ink900),
                ),
                Text(
                  l10n.dashboardPageAccountDetails(
                    roleLabel(l10n, user.role),
                    user.createdAt == null ? '' : context.formatDate(user.createdAt!),
                  ),
                ),
              ],
            ),
      children: [
        SectionTitle(l10n.dashboardPageTotalsTitle),
        TotalsStrip(summary: summary.value ?? TestResultSummary.empty),
        SheetCard(
          title: l10n.dashboardPageLatestTitle,
          padding: EdgeInsets.zero,
          action: latest.value?.isNotEmpty ?? false
              ? TextButton(
                  onPressed: () => context.go(Routes.testResults),
                  child: Text(l10n.dashboardPageSeeAll),
                )
              : null,
          child: switch (latest) {
            AsyncValue(:final value?) => ResultsList(
              rows: value,
              drawDelays: freshDrawDelays(value, DateTime.now()),
              onTap: (row) => showTestResultSheet(context, existing: row),
              empty: EmptyState(
                title: l10n.dashboardPageEmptyTitle,
                text: l10n.dashboardPageEmptyText,
                action: FilledButton.icon(
                  onPressed: () => showTestResultSheet(context),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.dashboardPageEmptyCta),
                ),
              ),
            ),
            AsyncValue(:final error?) => ErrorView(error: error, onRetry: refresh, compact: true),
            _ => const Padding(
              padding: EdgeInsets.symmetric(horizontal: Space.page),
              child: SkeletonRows(),
            ),
          },
        ),
      ],
    );
  }
}
