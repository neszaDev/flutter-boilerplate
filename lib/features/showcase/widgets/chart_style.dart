import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';

/// The chrome every showcase chart shares: recessive grid and axes in the ink ramp, and a
/// card-like touch tooltip (the web's `ChartTooltipContent`). Series colours come from the
/// caller.
@immutable
class ChartStyle {
  const ChartStyle({
    required this.surface,
    required this.grid,
    required this.axisLabel,
    required this.tooltipBackground,
    required this.tooltipBorder,
    required this.tooltipTitle,
    required this.tooltipBody,
  });

  factory ChartStyle.of(BuildContext context) {
    final colors = context.colors;
    final table = context.type.table;
    return ChartStyle(
      surface: colors.paperCard,
      grid: colors.ink200,
      axisLabel: table.copyWith(fontSize: 12, height: 1.2, color: colors.ink600),
      tooltipBackground: colors.ply,
      tooltipBorder: BorderSide(color: colors.ink200),
      tooltipTitle: table.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink950),
      tooltipBody: table.copyWith(fontSize: 12, color: colors.ink700),
    );
  }

  /// The card the chart sits on; sector gaps and dot rings use it.
  final Color surface;
  final Color grid;
  final TextStyle axisLabel;
  final Color tooltipBackground;
  final BorderSide tooltipBorder;
  final TextStyle tooltipTitle;
  final TextStyle tooltipBody;

  /// A horizontal grid line.
  FlLine gridLine(double _) => FlLine(color: grid, strokeWidth: 1);

  /// The tooltip of a line chart: [items] gives one entry per touched spot, in order (the
  /// first usually carries the title).
  LineTouchTooltipData lineTooltip(GetLineTooltipItems items) => LineTouchTooltipData(
    getTooltipColor: (_) => tooltipBackground,
    tooltipBorder: tooltipBorder,
    tooltipBorderRadius: BorderRadius.circular(Radii.md),
    tooltipPadding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 6),
    maxContentWidth: 200,
    fitInsideHorizontally: true,
    fitInsideVertically: true,
    getTooltipItems: items,
  );

  /// The tooltip of a bar chart.
  BarTouchTooltipData barTooltip(BarTooltipItem? Function(int groupIndex, double value) content) =>
      BarTouchTooltipData(
        getTooltipColor: (_) => tooltipBackground,
        tooltipBorder: tooltipBorder,
        tooltipBorderRadius: BorderRadius.circular(Radii.md),
        tooltipPadding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 6),
        maxContentWidth: 180,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItem: (group, groupIndex, rod, rodIndex) => content(groupIndex, rod.toY),
      );

  /// A tooltip entry: a bold [title] (if any) over [body], with a [swatch] dot in the series
  /// colour before the body.
  LineTooltipItem lineItem(String? title, String body, {Color? swatch}) => LineTooltipItem(
    title == null ? '' : '$title\n',
    tooltipTitle,
    textAlign: TextAlign.start,
    children: [
      if (swatch != null)
        TextSpan(
          text: '\u25CF ',
          style: tooltipBody.copyWith(color: swatch),
        ),
      TextSpan(text: body, style: tooltipBody),
    ],
  );

  /// The bar chart counterpart of [lineItem].
  BarTooltipItem barItem(String title, String body) => BarTooltipItem(
    '$title\n',
    tooltipTitle,
    textAlign: TextAlign.start,
    children: [TextSpan(text: body, style: tooltipBody)],
  );
}

/// A legend entry: a small swatch and the series name (text stays in ink, the swatch carries
/// the identity).
class ChartLegendItem extends StatelessWidget {
  const ChartLegendItem({required this.color, required this.label, this.line = false, super.key});

  final Color color;
  final String label;

  /// Draws a short line instead of a square (for line series).
  final bool line;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ExcludeSemantics(
        child: Container(
          width: line ? 14 : 10,
          height: line ? 3 : 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: context.text.bodySmall?.copyWith(color: context.colors.ink700)),
    ],
  );
}

/// A centred row of [ChartLegendItem]s under a chart.
class ChartLegend extends StatelessWidget {
  const ChartLegend({required this.items, super.key});

  final List<ChartLegendItem> items;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: Space.page,
    runSpacing: Space.xs,
    children: items,
  );
}
