import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/charts/chart_examples.dart';
import 'package:flutter_boilerplate/features/showcase/charts/chart_palette.dart';
import 'package:flutter_boilerplate/features/showcase/charts/charts_data.dart';
import 'package:flutter_boilerplate/features/showcase/charts/charts_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widgets/showcase_test_app.dart';

/// The point at [degrees] clockwise from twelve o'clock, [fraction] of the way to the edge of
/// the circle drawn by [finder].
Offset _onCircle(WidgetTester tester, Finder finder, double degrees, double fraction) {
  final rect = tester.getRect(finder);
  final radians = (degrees - 90) * math.pi / 180;
  final radius = rect.shortestSide / 2 * fraction;
  return rect.center + Offset(math.cos(radians), math.sin(radians)) * radius;
}

/// The page's own (vertical) scroll view; tables and charts may scroll sideways inside it.
final _page = find.byType(Scrollable).first;

void main() {
  group('sectorAt', () {
    const size = Size(200, 200);

    test('finds the sector under a point, clockwise from twelve o’clock', () {
      expect(sectorAt(const Offset(110, 20), size, 4), 0);
      expect(sectorAt(const Offset(180, 110), size, 4), 1);
      expect(sectorAt(const Offset(90, 180), size, 4), 2);
      expect(sectorAt(const Offset(20, 90), size, 4), 3);
    });

    test('splits the circle into equal slices', () {
      // Just past twelve o'clock and just before it.
      expect(sectorAt(const Offset(101, 10), size, 7), 0);
      expect(sectorAt(const Offset(99, 10), size, 7), 6);
    });

    test('finds nothing outside the circle', () {
      expect(sectorAt(const Offset(2, 2), size, 7), isNull);
      expect(sectorAt(const Offset(100, 100), size, 0), isNull);
    });
  });

  group('Chart data', () {
    test('keeps the web series', () {
      expect(lineSeriesOne, hasLength(7));
      expect(lineSeriesTwo, hasLength(7));
      expect(commits, hasLength(12));
      expect(frameworks.map((framework) => framework.value), [40, 20, 80, 10]);
    });

    test('puts the largest hour count of either year at the polar edge', () {
      expect(maxHours, 100);
    });
  });

  group('ChartPalette', () {
    test('has four series colours per theme, in a fixed order', () {
      expect(ChartPalette.light.series, hasLength(4));
      expect(ChartPalette.dark.series, hasLength(4));
      expect(ChartPalette.light[0], isNot(ChartPalette.dark[0]));
    });
  });

  group('ChartsScreen', () {
    for (final dark in [false, true]) {
      testWidgets('draws every chart on a narrow phone (dark: $dark)', (tester) async {
        await pumpShowcase(tester, const ChartsScreen(), width: 360, dark: dark);

        expect(find.byType(LineChart), findsOneWidget);

        await tester.scrollUntilVisible(find.text('Simple bar chart'), 500, scrollable: _page);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('summarises each chart for screen readers', (tester) async {
      await pumpShowcase(tester, const ChartsScreen());

      expect(
        find.bySemanticsLabel(RegExp(r'^Line chart\. Data one: January 30, February 39')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp(r'^Bar chart\. Commits: January 40')), findsOneWidget);
    });
  });

  group('PieChartExample', () {
    testWidgets('reads out the touched sector', (tester) async {
      await pumpShowcase(
        tester,
        const Scaffold(body: PieChartExample(title: 'Doughnut', doughnut: true)),
      );

      expect(find.text('Touch the chart for values.'), findsOneWidget);

      // React holds 80 of 150: from 144° to 336°.
      await tester.tapAt(_onCircle(tester, find.byType(PieChart), 240, 0.75));
      await tester.pumpAndSettle();

      expect(find.text('React'), findsNWidgets(2));
      expect(find.text('80'), findsOneWidget);
    });
  });

  group('PolarAreaChartExample', () {
    testWidgets('reads out both years of the touched activity', (tester) async {
      await pumpShowcase(tester, const Scaffold(body: PolarAreaChartExample(title: 'Polar')));

      // The fifth of seven slices: coding.
      await tester.tapAt(_onCircle(tester, find.byType(PieChart).first, 4.5 * 360 / 7, 0.4));
      await tester.pumpAndSettle();

      expect(find.text('Coding'), findsOneWidget);
      expect(find.text('2019: 56 h'), findsOneWidget);
      expect(find.text('2020: 96 h'), findsOneWidget);
    });
  });
}
