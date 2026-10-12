import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/charts/chart_examples.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/sparkline.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tones.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_data.dart';

/// `/dashboard/charts`: line, bar, doughnut, radar, pie and polar area charts (fl_chart), then
/// the axis-less charts of the widgets. Touch a chart to read its values.
class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.chartsPageTitle,
      description: Text(l10n.chartsPageDescription),
      children: [
        DemoCard(
          title: l10n.chartsPageLineTitle,
          description: l10n.chartsPageLineDescription,
          child: LineChartExample(title: l10n.chartsPageLineTitle),
        ),
        DemoCard(
          title: l10n.chartsPageBarTitle,
          description: l10n.chartsPageBarDescription,
          child: BarChartExample(title: l10n.chartsPageBarTitle),
        ),
        DemoCard(
          title: l10n.chartsPageDoughnutTitle,
          description: l10n.chartsPageDoughnutDescription,
          child: PieChartExample(title: l10n.chartsPageDoughnutTitle, doughnut: true),
        ),
        DemoCard(
          title: l10n.chartsPageRadarTitle,
          description: l10n.chartsPageRadarDescription,
          child: RadarChartExample(title: l10n.chartsPageRadarTitle),
        ),
        DemoCard(
          title: l10n.chartsPagePieTitle,
          description: l10n.chartsPagePieDescription,
          child: PieChartExample(title: l10n.chartsPagePieTitle),
        ),
        DemoCard(
          title: l10n.chartsPagePolarTitle,
          description: l10n.chartsPagePolarDescription,
          child: PolarAreaChartExample(title: l10n.chartsPagePolarTitle),
        ),
        DemoCard(
          title: l10n.chartsPageSimpleLineTitle,
          description: l10n.chartsPageSimpleLineDescription,
          child: Sparkline(
            data: salesPoints,
            name: l10n.chartsPageSales,
            color: ToneColors.of(context, Tone.pass).fill,
            height: 160,
          ),
        ),
        DemoCard(
          title: l10n.chartsPageSimplePointedTitle,
          description: l10n.chartsPageSimplePointedDescription,
          child: Sparkline(
            data: salesPoints,
            name: l10n.chartsPageSales,
            color: ToneColors.of(context, Tone.slate).fill,
            dotColor: context.colors.ply,
            pointed: true,
            height: 160,
          ),
        ),
        DemoCard(
          title: l10n.chartsPageSimpleBarTitle,
          description: l10n.chartsPageSimpleBarDescription,
          child: Sparkline(
            kind: SparklineKind.bar,
            data: salesPoints,
            name: l10n.chartsPageSales,
            color: ToneColors.of(context, Tone.pencil).fill,
            height: 160,
          ),
        ),
      ],
    );
  }
}
