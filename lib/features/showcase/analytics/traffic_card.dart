import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/feedback.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/analytics/analytics_data.dart';
import 'package:flutter_boilerplate/features/showcase/charts/chart_palette.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/chart_style.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/csv_export.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tile_grid.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tone_progress.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// The demo period ends on Sunday 27 September 2026; the month view is the four weeks before it.
final _monthStart = DateTime.utc(2026, 8, 31);
final _lastDay = DateTime.utc(2026, 9, 27);

/// The date of point [index] of [period]: an hour of the last day, a day of the four weeks, or
/// a month of the year.
DateTime _pointDate(Period period, int index) => switch (period) {
  Period.day => _lastDay.add(Duration(hours: index)),
  Period.month => _monthStart.add(Duration(days: index)),
  Period.year => DateTime.utc(2026, index + 1),
};

/// A point of the chart with its axis label and its full date.
typedef _Row = ({String tick, String title, TrafficPoint point});

/// The traffic card of the dashboard (`Dashboard.vue` + `MainChartExample.vue`): visits and
/// unique visitors against a target line, a day / month / year switch, the shown series as a
/// CSV file and the totals footer.
class TrafficCard extends ConsumerStatefulWidget {
  const TrafficCard({super.key});

  @override
  ConsumerState<TrafficCard> createState() => _TrafficCardState();
}

class _TrafficCardState extends ConsumerState<TrafficCard> {
  Period _period = Period.month;

  String _periodName(AppLocalizations l10n, Period period) => switch (period) {
    Period.day => l10n.trafficCardDay,
    Period.month => l10n.trafficCardMonth,
    Period.year => l10n.trafficCardYear,
  };

  Future<void> _share(BuildContext button, List<_Row> rows) async {
    final l10n = context.l10n;
    final csv = trafficCsv(
      [
        _periodName(l10n, _period),
        l10n.trafficCardVisits,
        l10n.trafficCardUnique,
        l10n.trafficCardTarget,
      ],
      [for (final row in rows) (row.title, row.point.visits, row.point.unique, trafficTarget)],
    );
    final box = button.findRenderObject() as RenderBox?;
    try {
      await ref
          .read(csvExportProvider)
          .share(
            filename: 'traffic-${_period.name}.csv',
            csv: csv,
            origin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
          );
    } on Exception {
      if (mounted) {
        showToast(context, l10n.trafficCardDownloadError, tone: ToastTone.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeName;
    final period = _period;
    final tick = switch (period) {
      Period.day => DateFormat.j(locale),
      Period.month => DateFormat.E(locale),
      Period.year => DateFormat.MMM(locale),
    };
    final title = switch (period) {
      Period.day => DateFormat.jm(locale),
      Period.month => DateFormat.MMMMEEEEd(locale),
      Period.year => DateFormat.yMMMM(locale),
    };
    final subtitle = switch (period) {
      Period.day => DateFormat.yMMMMd(locale).format(_lastDay),
      // Two dates in a translated template, like the web app.
      Period.month => l10n.trafficCardDateRange(
        DateFormat.yMMMd(locale).format(_monthStart),
        DateFormat.yMMMd(locale).format(_lastDay),
      ),
      Period.year => DateFormat.y(locale).format(_lastDay),
    };
    final rows = [
      for (final point in trafficSeries(period))
        (
          tick: tick.format(_pointDate(period, point.index)),
          title: title.format(_pointDate(period, point.index)),
          point: point,
        ),
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.card, Space.page, Space.md, Space.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(l10n.trafficCardTitle, style: context.text.titleLarge),
                          ),
                          Text(subtitle, style: context.text.bodySmall),
                        ],
                      ),
                    ),
                    Builder(
                      builder: (button) => IconButton.filled(
                        tooltip: l10n.trafficCardDownload,
                        onPressed: () => _share(button, rows),
                        icon: const Icon(LucideIcons.cloudDownload, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Space.md),
                Semantics(
                  label: l10n.trafficCardPeriod,
                  container: true,
                  child: SegmentedButton<Period>(
                    showSelectedIcon: false,
                    segments: [
                      for (final item in Period.values)
                        ButtonSegment(value: item, label: Text(_periodName(l10n, item))),
                    ],
                    selected: {period},
                    onSelectionChanged: (selection) => setState(() => _period = selection.first),
                  ),
                ),
              ],
            ),
          ),
          const DoubleRule(),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.sm, Space.lg, Space.page, Space.page),
            child: Column(
              children: [
                _TrafficChart(
                  rows: rows,
                  summary: _summary(context, subtitle, rows.map((row) => row.point).toList()),
                ),
                const SizedBox(height: Space.md),
                ChartLegend(
                  items: [
                    ChartLegendItem(
                      color: ChartPalette.of(context)[0],
                      label: l10n.trafficCardVisits,
                    ),
                    ChartLegendItem(
                      color: ChartPalette.of(context)[1],
                      label: l10n.trafficCardUnique,
                      line: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const _Totals(),
        ],
      ),
    );
  }

  String _summary(BuildContext context, String subtitle, List<TrafficPoint> points) {
    String number(int value) => context.formatNumber(value);
    final visits = points.map((point) => point.visits);
    final unique = points.map((point) => point.unique);
    return context.l10n.trafficCardChartSummary(
      subtitle,
      number(visits.reduce(math.min)),
      number(visits.reduce(math.max)),
      number(unique.reduce(math.min)),
      number(unique.reduce(math.max)),
      number(trafficTarget),
    );
  }
}

/// The chart: visits as a filled line, unique visitors as a line, the dashed target.
class _TrafficChart extends StatelessWidget {
  const _TrafficChart({required this.rows, required this.summary});

  final List<_Row> rows;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = ChartStyle.of(context);
    final palette = ChartPalette.of(context);
    final colors = context.colors;
    final series = [
      (name: l10n.trafficCardVisits, color: palette[0], area: true),
      (name: l10n.trafficCardUnique, color: palette[1], area: false),
    ];
    double valueOf(int bar, TrafficPoint point) =>
        (bar == 0 ? point.visits : point.unique).toDouble();

    return Semantics(
      container: true,
      label: summary,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 260,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Room per x label, so neighbours never touch (recharts' `minTickGap`).
              final widest = rows.map((row) => row.tick.length).reduce(math.max) * 7.0 + 12;
              final every = (rows.length * widest / (constraints.maxWidth - 40)).ceil().clamp(
                1,
                12,
              );
              return LineChart(
                LineChartData(
                  minX: 0,
                  maxX: rows.length - 1.0,
                  minY: 0,
                  maxY: trafficMax,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 50,
                    getDrawingHorizontalLine: style.gridLine,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 50,
                        getTitlesWidget: (value, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(context.formatNumber(value), style: style.axisLabel),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          if (index < 0 || index >= rows.length || index % every != 0) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(rows[index].tick, style: style.axisLabel),
                          );
                        },
                      ),
                    ),
                  ),
                  extraLinesData: ExtraLinesData(
                    extraLinesOnTop: false,
                    horizontalLines: [
                      HorizontalLine(
                        y: trafficTarget.toDouble(),
                        color: colors.pencil,
                        strokeWidth: 1.5,
                        dashArray: const [8, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          style: style.axisLabel,
                          labelResolver: (_) => l10n.trafficCardTarget,
                        ),
                      ),
                    ],
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: style.lineTooltip(
                      (spots) => [
                        for (final (index, spot) in spots.indexed)
                          style.lineItem(
                            index == 0 ? rows[spot.spotIndex].title : null,
                            '${series[spot.barIndex].name} ${context.formatNumber(spot.y)}',
                            swatch: series[spot.barIndex].color,
                          ),
                      ],
                    ),
                    getTouchedSpotIndicator: (bar, indexes) => [
                      for (final _ in indexes)
                        TouchedSpotIndicatorData(
                          FlLine(color: style.grid, strokeWidth: 1),
                          FlDotData(
                            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                              radius: 4,
                              color: bar.color ?? style.grid,
                              strokeColor: style.surface,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  lineBarsData: [
                    for (final (bar, item) in series.indexed)
                      LineChartBarData(
                        spots: [
                          for (final row in rows)
                            FlSpot(row.point.index.toDouble(), valueOf(bar, row.point)),
                        ],
                        color: item.color,
                        isCurved: true,
                        preventCurveOverShooting: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: item.area,
                          color: item.color.withValues(alpha: 0.1),
                        ),
                      ),
                  ],
                ),
                duration: Duration.zero,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The footer: each total with its share and a bar.
class _Totals extends StatelessWidget {
  const _Totals();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final percent = NumberFormat.percentPattern(context.localeName)..maximumFractionDigits = 2;
    String label(TrafficTotalId id) => switch (id) {
      TrafficTotalId.visits => l10n.trafficCardVisits,
      TrafficTotalId.unique => l10n.trafficCardUnique,
      TrafficTotalId.pageviews => l10n.trafficCardPageviews,
      TrafficTotalId.newUsers => l10n.trafficCardNewUsers,
      TrafficTotalId.bounceRate => l10n.trafficCardBounceRate,
    };
    String figure(({TrafficTotalId id, int count, double percent, Tone tone}) total) {
      final share = percent.format(total.percent / 100);
      final count = context.formatNumber(total.count);
      return switch (total.id) {
        TrafficTotalId.bounceRate => l10n.trafficCardFigureRate(share),
        TrafficTotalId.pageviews => l10n.trafficCardFigureViews(count, share),
        _ => l10n.trafficCardFigureUsers(count, share),
      };
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.paper,
        border: Border(top: BorderSide(color: colors.ink200)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.card, vertical: Space.page),
        child: TileGrid(
          minTileWidth: 180,
          spacing: Space.page,
          children: [
            for (final total in trafficTotals)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormLabel(label(total.id)),
                  const SizedBox(height: Space.xs),
                  Text(
                    figure(total),
                    style: context.type.table.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.ink950,
                    ),
                  ),
                  const SizedBox(height: Space.sm),
                  ToneProgress(value: total.percent, label: label(total.id), tone: total.tone),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
