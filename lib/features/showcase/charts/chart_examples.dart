import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/charts/chart_palette.dart';
import 'package:flutter_boilerplate/features/showcase/charts/charts_data.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/chart_style.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/months.dart';

/// The localized name of an [Activity].
String activityName(AppLocalizations l10n, Activity activity) => switch (activity) {
  Activity.eating => l10n.chartExamplesEating,
  Activity.drinking => l10n.chartExamplesDrinking,
  Activity.sleeping => l10n.chartExamplesSleeping,
  Activity.designing => l10n.chartExamplesDesigning,
  Activity.coding => l10n.chartExamplesCoding,
  Activity.cycling => l10n.chartExamplesCycling,
  Activity.running => l10n.chartExamplesRunning,
};

/// "Data one: January 30, February 39, …": a series read out for screen readers.
String seriesSummary(
  BuildContext context,
  String name,
  List<String> labels,
  List<double> values,
) => context.l10n.chartExamplesValueLabel(
  name,
  [
    for (final (index, value) in values.indexed) '${labels[index]} ${context.formatNumber(value)}',
  ].join(', '),
);

/// A chart drawing announced as [label] (its title and data) instead of its pixels.
class ChartSemantics extends StatelessWidget {
  const ChartSemantics({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: label,
    child: ExcludeSemantics(child: child),
  );
}

/// What the last touch on a chart picked: a title and one line per series. Before any touch it
/// says how to get values.
class ChartReadout extends StatelessWidget {
  const ChartReadout({this.title, this.entries = const [], super.key});

  final String? title;

  /// One swatch and text per series.
  final List<({Color color, String text})> entries;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final content = title == null
        ? Text(
            context.l10n.chartExamplesTouchHint,
            style: context.text.bodySmall,
            textAlign: TextAlign.center,
          )
        : Column(
            children: [
              Text(title ?? '', style: context.text.titleSmall, textAlign: TextAlign.center),
              const SizedBox(height: Space.xs),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Space.page,
                runSpacing: Space.xs,
                children: [
                  for (final entry in entries)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ExcludeSemantics(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: entry.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          entry.text,
                          style: context.type.table.copyWith(fontSize: 13, color: colors.ink700),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          );
    return Semantics(
      liveRegion: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Center(child: content),
      ),
    );
  }
}

/// Left axis labels: plain numbers in the locale.
AxisTitles _valueAxis(BuildContext context, ChartStyle style, double interval) => AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    reservedSize: 32,
    interval: interval,
    getTitlesWidget: (value, meta) => SideTitleWidget(
      meta: meta,
      child: Text(context.formatNumber(value), style: style.axisLabel),
    ),
  ),
);

/// Bottom axis labels from [labels]; [every] skips labels that would collide on a phone.
AxisTitles _labelAxis(ChartStyle style, List<String> labels, {int every = 1}) => AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    reservedSize: 28,
    interval: 1,
    getTitlesWidget: (value, meta) {
      final index = value.round();
      if (index < 0 || index >= labels.length || index % every != 0) {
        return const SizedBox.shrink();
      }
      return SideTitleWidget(
        meta: meta,
        child: Text(labels[index], style: style.axisLabel),
      );
    },
  ),
);

const _noTitles = AxisTitles();

/// Two filled lines over seven months (`CChartLineExample`).
class LineChartExample extends StatelessWidget {
  const LineChartExample({required this.title, super.key});

  /// The demo's title, read before the data.
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = ChartStyle.of(context);
    final palette = ChartPalette.of(context);
    final short = monthNames(context.localeName, lineSeriesOne.length, short: true);
    final long = monthNames(context.localeName, lineSeriesOne.length);
    final series = [
      (name: l10n.chartExamplesDataOne, values: lineSeriesOne, color: palette[0]),
      (name: l10n.chartExamplesDataTwo, values: lineSeriesTwo, color: palette[1]),
    ];

    return Column(
      children: [
        ChartSemantics(
          label: [
            title,
            for (final item in series) seriesSummary(context, item.name, long, item.values),
          ].join('. '),
          child: SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: lineSeriesOne.length - 1.0,
                minY: 0,
                maxY: 80,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: style.gridLine,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: _noTitles,
                  rightTitles: _noTitles,
                  leftTitles: _valueAxis(context, style, 20),
                  bottomTitles: _labelAxis(style, short),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: style.lineTooltip(
                    (spots) => [
                      for (final (index, spot) in spots.indexed)
                        style.lineItem(
                          index == 0 ? long[spot.spotIndex] : null,
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
                  for (final item in series)
                    LineChartBarData(
                      spots: [
                        for (final (index, value) in item.values.indexed)
                          FlSpot(index.toDouble(), value),
                      ],
                      color: item.color,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: item.color.withValues(alpha: 0.12),
                      ),
                    ),
                ],
              ),
              duration: Duration.zero,
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        ChartLegend(
          items: [
            for (final item in series)
              ChartLegendItem(color: item.color, label: item.name, line: true),
          ],
        ),
      ],
    );
  }
}

/// Commits per month as bars (`CChartBarExample`).
class BarChartExample extends StatelessWidget {
  const BarChartExample({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = ChartStyle.of(context);
    final color = ChartPalette.of(context)[0];
    final short = monthNames(context.localeName, commits.length, short: true);
    final long = monthNames(context.localeName, commits.length);

    return ChartSemantics(
      label: '$title. ${seriesSummary(context, l10n.chartExamplesCommits, long, commits)}',
      child: SizedBox(
        height: 240,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slot = (constraints.maxWidth - 32) / commits.length;
            return BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                minY: 0,
                maxY: 80,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: style.gridLine,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: _noTitles,
                  rightTitles: _noTitles,
                  leftTitles: _valueAxis(context, style, 20),
                  // Every other month when twelve labels would touch.
                  bottomTitles: _labelAxis(style, short, every: slot < 32 ? 2 : 1),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: style.barTooltip(
                    (index, value) => style.barItem(
                      long[index],
                      '${l10n.chartExamplesCommits} ${context.formatNumber(value)}',
                    ),
                  ),
                ),
                barGroups: [
                  for (final (index, value) in commits.indexed)
                    BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          width: math.max(slot * 0.7, 4),
                          color: color,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    ),
                ],
              ),
              duration: Duration.zero,
            );
          },
        ),
      ),
    );
  }
}

/// Framework shares as a pie, or as a doughnut with the centre cut out (`CChartPieExample`,
/// `CChartDoughnutExample`). Touch a sector to read it.
class PieChartExample extends StatefulWidget {
  const PieChartExample({required this.title, this.doughnut = false, super.key});

  final String title;
  final bool doughnut;

  @override
  State<PieChartExample> createState() => _PieChartExampleState();
}

class _PieChartExampleState extends State<PieChartExample> {
  int? _touched;

  void _onTouch(FlTouchEvent event, PieTouchResponse? response) {
    final index = response?.touchedSection?.touchedSectionIndex;
    if (!event.isInterestedForInteractions || index == null || index < 0 || index == _touched) {
      return;
    }
    setState(() => _touched = index);
  }

  @override
  Widget build(BuildContext context) {
    final palette = ChartPalette.of(context);
    final style = ChartStyle.of(context);
    final touched = _touched;
    final summary = [
      for (final framework in frameworks)
        '${framework.name} ${context.formatNumber(framework.value)}',
    ].join(', ');

    return Column(
      children: [
        ChartSemantics(
          label: '${widget.title}. $summary',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = math.min(constraints.maxWidth, 280.0);
              final outer = side / 2 - 8;
              final hole = widget.doughnut ? outer * 0.55 : 0.0;
              return SizedBox.square(
                dimension: side,
                child: PieChart(
                  PieChartData(
                    startDegreeOffset: pieStartDegrees,
                    sectionsSpace: 2,
                    centerSpaceRadius: hole,
                    centerSpaceColor: style.surface,
                    pieTouchData: PieTouchData(touchCallback: _onTouch),
                    sections: [
                      for (final (index, framework) in frameworks.indexed)
                        PieChartSectionData(
                          value: framework.value,
                          color: palette[index],
                          radius: outer - hole - (index == touched ? 0 : 6),
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Space.sm),
        ChartLegend(
          items: [
            for (final (index, framework) in frameworks.indexed)
              ChartLegendItem(color: palette[index], label: framework.name),
          ],
        ),
        const SizedBox(height: Space.sm),
        if (touched == null)
          const ChartReadout()
        else
          ChartReadout(
            title: frameworks[touched].name,
            entries: [
              (
                color: palette[touched],
                text: context.formatNumber(frameworks[touched].value),
              ),
            ],
          ),
      ],
    );
  }
}

/// The readout of one activity: both years' hours (the web's `polar_tooltip`).
ChartReadout _activityReadout(BuildContext context, int index, ChartPalette palette) {
  final l10n = context.l10n;
  final row = activities[index];
  return ChartReadout(
    title: activityName(l10n, row.id),
    entries: [
      for (final (year, hours) in [row.y2019, row.y2020].indexed)
        (
          color: palette[year],
          text: l10n.chartExamplesPolarTooltip(activityYears[year], context.formatNumber(hours)),
        ),
    ],
  );
}

/// The two years of activity hours as screen-reader text.
String _activitySummary(BuildContext context, String title) {
  final l10n = context.l10n;
  final names = [for (final row in activities) activityName(l10n, row.id)];
  return [
    title,
    seriesSummary(context, activityYears[0], names, [for (final row in activities) row.y2019]),
    seriesSummary(context, activityYears[1], names, [for (final row in activities) row.y2020]),
  ].join('. ');
}

/// Two years of activity hours on a radar (`CChartRadarExample`). Touch a point to read it.
class RadarChartExample extends StatefulWidget {
  const RadarChartExample({required this.title, super.key});

  final String title;

  @override
  State<RadarChartExample> createState() => _RadarChartExampleState();
}

class _RadarChartExampleState extends State<RadarChartExample> {
  int? _touched;

  void _onTouch(FlTouchEvent event, RadarTouchResponse? response) {
    final spot = response?.touchedSpot;
    // The third data set only pins zero to the centre; it is not data.
    if (!event.isInterestedForInteractions || spot == null || spot.touchedDataSetIndex > 1) {
      return;
    }
    if (spot.touchedRadarEntryIndex != _touched) {
      setState(() => _touched = spot.touchedRadarEntryIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = ChartPalette.of(context);
    final style = ChartStyle.of(context);
    final touched = _touched;
    final years = [
      [for (final row in activities) row.y2019],
      [for (final row in activities) row.y2020],
    ];
    final grid = BorderSide(color: style.grid);

    return Column(
      children: [
        ChartSemantics(
          label: _activitySummary(context, widget.title),
          child: LayoutBuilder(
            builder: (context, constraints) => SizedBox.square(
              dimension: math.min(constraints.maxWidth, 300.0),
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    for (final (index, values) in years.indexed)
                      RadarDataSet(
                        dataEntries: [for (final value in values) RadarEntry(value: value)],
                        fillColor: palette[index].withValues(alpha: 0.2),
                        borderColor: palette[index],
                        borderWidth: 2,
                        entryRadius: 3,
                      ),
                    // Invisible zeros, so the centre is 0 hours like the web chart's.
                    RadarDataSet(
                      dataEntries: [for (final _ in activities) const RadarEntry(value: 0)],
                      fillColor: Colors.transparent,
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      entryRadius: 0,
                    ),
                  ],
                  isMinValueAtCenter: true,
                  radarShape: RadarShape.polygon,
                  radarBorderData: grid,
                  gridBorderData: grid,
                  tickBorderData: grid,
                  tickCount: 4,
                  ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 1),
                  titleTextStyle: style.axisLabel,
                  titlePositionPercentageOffset: 0.08,
                  getTitle: (index, angle) =>
                      RadarChartTitle(text: activityName(l10n, activities[index].id)),
                  radarTouchData: RadarTouchData(touchCallback: _onTouch, touchSpotThreshold: 16),
                ),
                duration: Duration.zero,
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.sm),
        ChartLegend(
          items: [
            for (final (index, year) in activityYears.indexed)
              ChartLegendItem(color: palette[index], label: year, line: true),
          ],
        ),
        const SizedBox(height: Space.sm),
        if (touched == null) const ChartReadout() else _activityReadout(context, touched, palette),
      ],
    );
  }
}

/// Two years of activity hours as a polar area chart: equal angles, radius by value
/// (`CChartPolarAreaExample`). Touch a slice to read both years.
class PolarAreaChartExample extends StatefulWidget {
  const PolarAreaChartExample({required this.title, super.key});

  final String title;

  @override
  State<PolarAreaChartExample> createState() => _PolarAreaChartExampleState();
}

class _PolarAreaChartExampleState extends State<PolarAreaChartExample> {
  int? _touched;

  void _onTouch(Offset position, Size size) {
    final index = sectorAt(position, size, activities.length);
    if (index != null && index != _touched) {
      setState(() => _touched = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = ChartPalette.of(context);
    final touched = _touched;

    return Column(
      children: [
        ChartSemantics(
          label: _activitySummary(context, widget.title),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = math.min(constraints.maxWidth, 280.0);
              final size = Size.square(side);
              final outer = side / 2;
              PieChart year(int index) => PieChart(
                PieChartData(
                  startDegreeOffset: pieStartDegrees,
                  sectionsSpace: 0,
                  centerSpaceRadius: 0,
                  pieTouchData: PieTouchData(enabled: false),
                  sections: [
                    for (final (slice, row) in activities.indexed)
                      PieChartSectionData(
                        value: 1,
                        color: palette[index].withValues(alpha: slice == touched ? 0.55 : 0.35),
                        radius: (index == 0 ? row.y2019 : row.y2020) / maxHours * outer,
                        borderSide: BorderSide(color: palette[index], width: 1.5),
                        showTitle: false,
                      ),
                  ],
                ),
                duration: Duration.zero,
              );
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => _onTouch(details.localPosition, size),
                onPanUpdate: (details) => _onTouch(details.localPosition, size),
                child: SizedBox.fromSize(
                  size: size,
                  child: Stack(
                    children: [
                      Positioned.fill(child: year(0)),
                      Positioned.fill(child: year(1)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Space.sm),
        ChartLegend(
          items: [
            for (final (index, year) in activityYears.indexed)
              ChartLegendItem(color: palette[index], label: year),
          ],
        ),
        const SizedBox(height: Space.sm),
        if (touched == null) const ChartReadout() else _activityReadout(context, touched, palette),
      ],
    );
  }
}
