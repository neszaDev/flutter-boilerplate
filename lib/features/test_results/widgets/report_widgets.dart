import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/mark.dart';

/// The localized name of a status (`TestResultForm.status_PASSED`, …).
String statusLabel(AppLocalizations l10n, TestStatus status) => switch (status) {
  TestStatus.pending => l10n.testResultFormStatusPENDING,
  TestStatus.passed => l10n.testResultFormStatusPASSED,
  TestStatus.failed => l10n.testResultFormStatusFAILED,
};

/// How long after creation a row still counts as new, so its mark draws on.
const freshFor = Duration(seconds: 20);

/// Draw delays for rows created moments ago, keyed by id (the web's `freshDrawDelays`).
Map<int, Duration> freshDrawDelays(List<TestResult> rows, DateTime now) {
  final fresh = rows.where(
    (row) => row.createdAt != null && now.difference(row.createdAt!) < freshFor,
  );
  return {
    for (final (index, row) in fresh.indexed) row.id: Duration(milliseconds: 150 + index * 150),
  };
}

/// A status as it appears on the card: the drawn mark plus its name.
class StatusMark extends StatelessWidget {
  const StatusMark({
    required this.status,
    this.animate = false,
    this.delay = Duration.zero,
    this.showLabel = true,
    this.size = 20,
    super.key,
  });

  final TestStatus status;
  final bool animate;
  final Duration delay;
  final bool showLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final label = statusLabel(context.l10n, status);
    final mark = Mark(status: status, animate: animate, delay: delay, size: size);
    if (!showLabel) {
      return Semantics(label: label, child: mark);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: Space.sm),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: status == TestStatus.failed ? context.colors.pen : context.colors.ink700,
          ),
        ),
      ],
    );
  }
}

/// The totals box at the top of a card: the overall count, then one count per mark.
class TotalsStrip extends StatelessWidget {
  const TotalsStrip({required this.summary, this.flat = false, super.key});

  final TestResultSummary summary;

  /// No border and background, when it sits inside another card.
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    Widget cell(Widget label, int count, {bool alarm = false}) => Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.card, vertical: Space.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label,
            const SizedBox(height: Space.xs),
            Text(
              context.formatNumber(count),
              style: context.type.figure.copyWith(color: alarm ? colors.pen : null),
            ),
          ],
        ),
      ),
    );
    Widget statusCell(TestStatus status) => cell(
      Row(
        children: [
          Mark(status: status, size: 14),
          const SizedBox(width: 6),
          Text(statusLabel(l10n, status).toUpperCase(), style: context.type.formLabel),
        ],
      ),
      summary.countOf(status),
      alarm: status == TestStatus.failed && summary.countOf(status) > 0,
    );
    final divider = BorderSide(color: colors.ink200);

    return Semantics(
      label: l10n.totalsLabel,
      child: Container(
        decoration: flat
            ? null
            : BoxDecoration(
                color: colors.paperCard,
                border: Border.all(color: colors.ink300),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(right: divider, bottom: divider),
                    ),
                    child: cell(
                      Text(l10n.totalsTotal.toUpperCase(), style: context.type.formLabel),
                      summary.total,
                    ),
                  ),
                ),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(border: Border(bottom: divider)),
                    child: statusCell(TestStatus.passed),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(border: Border(right: divider)),
                    child: statusCell(TestStatus.failed),
                  ),
                ),
                Expanded(child: statusCell(TestStatus.pending)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One ruled row of the card: mark, test name with its note, date, and the score.
class ResultRow extends StatelessWidget {
  const ResultRow({
    required this.result,
    this.drawDelay,
    this.compact = false,
    this.onTap,
    super.key,
  });

  final TestResult result;

  /// Draw the mark on after this delay (fresh rows).
  final Duration? drawDelay;

  /// The landing card: the day only, tighter rows.
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final date = compact
        ? context.formatDate(result.testedAt)
        : context.formatDateTime(result.testedAt);
    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Space.page,
            vertical: compact ? Space.sm + 2 : Space.md + 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: StatusMark(
                  status: result.status,
                  showLabel: false,
                  animate: drawDelay != null,
                  delay: drawDelay ?? Duration.zero,
                  size: compact ? 18 : 22,
                ),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.testName,
                      style: context.text.titleSmall?.copyWith(color: colors.ink950),
                    ),
                    if (result.notes != null && result.notes!.isNotEmpty)
                      Text(result.notes!, style: context.type.handNote),
                    const SizedBox(height: 2),
                    Text(
                      '${statusLabel(l10n, result.status)} · $date',
                      style: context.text.bodySmall?.copyWith(
                        color: result.status == TestStatus.failed ? colors.pen : colors.ink600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Space.md),
              Text(
                context.formatNumber(result.score),
                style: context.type.table.copyWith(
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.w600,
                  color: colors.ink950,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The ruled rows, or the empty card that keeps its ruling (honest absence, as on the web).
class ResultsList extends StatelessWidget {
  const ResultsList({
    required this.rows,
    this.drawDelays = const {},
    this.empty,
    this.compact = false,
    this.onTap,
    super.key,
  });

  final List<TestResult> rows;
  final Map<int, Duration> drawDelays;
  final Widget? empty;
  final bool compact;
  final void Function(TestResult result)? onTap;

  @override
  Widget build(BuildContext context) {
    final divider = Divider(color: context.colors.ink200, indent: Space.page);
    if (rows.isEmpty && empty != null) {
      return Column(
        children: [
          empty!,
          for (var blank = 0; blank < 3; blank++) ...[divider, const SizedBox(height: 44)],
        ],
      );
    }
    return Column(
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) divider,
          ResultRow(
            result: row,
            drawDelay: drawDelays[row.id],
            compact: compact,
            onTap: onTap == null ? null : () => onTap!(row),
          ),
        ],
      ],
    );
  }
}
