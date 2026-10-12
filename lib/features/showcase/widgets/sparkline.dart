import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/chart_style.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/months.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_data.dart';

/// An axis-less line or bar chart for widgets (the CoreUI `CChartLineSimple` and
/// `CChartBarSimple`), one value per month, with a touch tooltip. Screen readers get a one-line
/// summary instead of the drawing.
class Sparkline extends StatelessWidget {
  const Sparkline({
    required this.data,
    required this.name,
    required this.color,
    this.kind = SparklineKind.line,
    this.fill,
    this.fillOpacity,
    this.pointed = false,
    this.dotColor,
    this.linear = false,
    this.strokeWidth,
    this.height = 64,
    this.padding = EdgeInsets.zero,
    this.interactive = true,
    super.key,
  });

  /// One value per month, from January.
  final List<double> data;

  /// Series name, shown in the tooltip and the summary.
  final String name;

  /// Stroke (line) or fill (bar).
  final Color color;
  final SparklineKind kind;

  /// Area under the line; none when null.
  final Color? fill;

  /// Opacity of the area or the bars.
  final double? fillOpacity;

  /// Draws a dot on every value and pads the range (the "pointed" variant).
  final bool pointed;

  /// Fill of the dots when [pointed].
  final Color? dotColor;

  /// Straight segments instead of a smooth curve.
  final bool linear;
  final double? strokeWidth;

  /// Height of the drawing; null fills the parent.
  final double? height;
  final EdgeInsetsGeometry padding;

  /// False draws the chart without the touch tooltip (e.g. behind a logo).
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final locale = context.localeName;
    final months = monthNames(locale, data.length);
    final style = ChartStyle.of(context);
    String number(double value) => context.formatNumber(value);
    final low = data.reduce(math.min);
    final high = data.reduce(math.max);
    final summary = context.l10n.widgetsPageChartSummary(
      name,
      data.length,
      number(low),
      number(high),
      number(data.last),
    );

    final chart = switch (kind) {
      SparklineKind.bar => _bars(style, months, number),
      SparklineKind.line => _line(style, months, number, low, high),
    };
    return Semantics(
      container: true,
      label: summary,
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          child: Padding(padding: padding, child: chart),
        ),
      ),
    );
  }

  Widget _line(
    ChartStyle style,
    List<String> months,
    String Function(double) number,
    double low,
    double high,
  ) {
    final dot = dotColor ?? color;
    final lineWidth = strokeWidth ?? (pointed ? 1.0 : 2.0);
    return Padding(
      // Room for the dots and the stroke, like the web chart's margins.
      padding: EdgeInsets.symmetric(horizontal: pointed ? 10 : 6, vertical: 6),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: data.length - 1.0,
          minY: pointed ? low - 5 : low,
          maxY: pointed ? high + 5 : high,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: interactive,
            touchTooltipData: style.lineTooltip(
              (spots) => [
                for (final spot in spots)
                  style.lineItem(months[spot.spotIndex], '$name ${number(spot.y)}'),
              ],
            ),
            getTouchedSpotIndicator: (bar, indexes) => [
              for (final _ in indexes)
                TouchedSpotIndicatorData(
                  const FlLine(color: Colors.transparent, strokeWidth: 0),
                  FlDotData(
                    getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                      radius: 4,
                      color: dot,
                      strokeColor: color,
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (final (index, value) in data.indexed) FlSpot(index.toDouble(), value)],
              color: color,
              barWidth: lineWidth,
              isCurved: !linear,
              preventCurveOverShooting: true,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: pointed,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 4,
                  color: dot,
                  strokeColor: color,
                  strokeWidth: 1,
                ),
              ),
              belowBarData: BarAreaData(
                show: fill != null,
                color: (fill ?? color).withValues(alpha: fillOpacity ?? 1),
              ),
            ),
          ],
        ),
        duration: Duration.zero,
      ),
    );
  }

  Widget _bars(ChartStyle style, List<String> months, String Function(double) number) =>
      LayoutBuilder(
        builder: (context, constraints) {
          // A quarter of each slot stays empty between bars (`barCategoryGap="25%"`).
          final width = constraints.maxWidth / data.length * 0.75;
          final high = data.reduce(math.max);
          return BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              minY: 0,
              maxY: high,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: interactive,
                touchTooltipData: style.barTooltip(
                  (index, value) => style.barItem(months[index], '$name ${number(value)}'),
                ),
              ),
              barGroups: [
                for (final (index, value) in data.indexed)
                  BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        width: width,
                        color: color.withValues(alpha: fillOpacity ?? 1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                      ),
                    ],
                  ),
              ],
            ),
            duration: Duration.zero,
          );
        },
      );
}
