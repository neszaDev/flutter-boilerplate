import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/features/showcase/analytics/analytics_data.dart';
import 'package:flutter_boilerplate/features/showcase/analytics/analytics_screen.dart';
import 'package:flutter_boilerplate/features/showcase/analytics/analytics_users_table.dart';
import 'package:flutter_boilerplate/features/showcase/analytics/traffic_card.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/csv_export.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widgets/showcase_test_app.dart';

/// Records what would go to the share sheet.
class _FakeExport extends CsvExport {
  final shared = <({String filename, String csv})>[];

  @override
  Future<void> share({required String filename, required String csv, Rect? origin}) async {
    shared.add((filename: filename, csv: csv));
  }
}

/// The page's own (vertical) scroll view; tables and charts may scroll sideways inside it.
final _page = find.byType(Scrollable).first;

void main() {
  group('trafficSeries', () {
    test('returns one point per hour, day of the four weeks or month', () {
      expect(trafficSeries(Period.day), hasLength(24));
      expect(trafficSeries(Period.month), hasLength(28));
      expect(trafficSeries(Period.year), hasLength(12));
    });

    test('returns the same series on every call', () {
      for (final period in Period.values) {
        expect(trafficSeries(period), trafficSeries(period));
      }
    });

    test('keeps visits and unique visitors within the demo ranges', () {
      for (final point in Period.values.expand(trafficSeries)) {
        expect(point.visits, inInclusiveRange(50, 200));
        expect(point.unique, inInclusiveRange(80, 100));
      }
    });

    test('draws a different series for each period', () {
      expect(trafficSeries(Period.day).sublist(0, 12), isNot(trafficSeries(Period.year)));
    });

    test('draws the web app’s series (same seeded generator)', () {
      // Park-Miller from seed 2017: 33 895 919 / (2^31 - 2) ≈ 0.0158 → 50 + floor(0.0158 × 151).
      expect(trafficSeries(Period.year).first.visits, 52);
    });
  });

  group('trafficCsv', () {
    test('writes a header row and one line per point', () {
      expect(
        trafficCsv(
          ['Month', 'Visits', 'Unique', 'Target'],
          [('January 2026', 120, 90, 65), ('February 2026', 80, 85, 65)],
        ),
        'Month,Visits,Unique,Target\r\nJanuary 2026,120,90,65\r\nFebruary 2026,80,85,65',
      );
    });

    test('quotes fields that hold commas or quotes', () {
      expect(
        trafficCsv(['Day', 'A', 'B', 'C'], [('Monday, 31 "Aug"', 1, 2, 3)]),
        'Day,A,B,C\r\n"Monday, 31 ""Aug""",1,2,3',
      );
    });
  });

  group('usageTone', () {
    test('picks a tone per quarter of usage', () {
      expect([0, 25, 26, 50, 75, 76, 100].map((value) => usageTone(value.toDouble())), [
        Tone.ink,
        Tone.ink,
        Tone.pass,
        Tone.pass,
        Tone.slate,
        Tone.pencil,
        Tone.pencil,
      ]);
    });
  });

  group('relativeTime', () {
    test('picks the unit next-intl picks and rounds the value', () {
      expect(relativeTime(10), (unit: RelativeUnit.second, value: 10));
      expect(relativeTime(5 * 60), (unit: RelativeUnit.minute, value: 5));
      expect(relativeTime(60 * 60), (unit: RelativeUnit.hour, value: 1));
      expect(relativeTime(3 * 24 * 3600), (unit: RelativeUnit.day, value: 3));
      expect(relativeTime(7 * 24 * 3600), (unit: RelativeUnit.week, value: 1));
      expect(relativeTime(31 * 24 * 3600), (unit: RelativeUnit.month, value: 1));
      expect(relativeTime(400 * 24 * 3600), (unit: RelativeUnit.year, value: 1));
    });

    test('words the sample users’ last logins', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final fr = await AppLocalizations.delegate.load(const Locale('fr'));

      expect(analyticsUsers.map((user) => relativeTimeText(en, user.lastSeenSecondsAgo)), [
        '10 seconds ago',
        '5 minutes ago',
        '1 hour ago',
        '1 month ago',
        '1 week ago',
        '1 week ago',
      ]);
      expect(relativeTimeText(fr, 5 * 60), 'il y a 5 minutes');
    });
  });

  group('TrafficCard', () {
    Future<void> pumpCard(WidgetTester tester, {_FakeExport? export}) => pumpShowcase(
      tester,
      const Scaffold(body: SingleChildScrollView(child: TrafficCard())),
      overrides: [if (export != null) csvExportProvider.overrideWithValue(export)],
    );

    Matcher selected({required bool checked}) => isSemantics(isSelected: checked);

    testWidgets('starts on the month and switches to the year', (tester) async {
      await pumpCard(tester);

      expect(tester.getSemantics(find.text('Month')), selected(checked: true));
      expect(find.text('Aug 31, 2026 – Sep 27, 2026'), findsOneWidget);

      await tester.tap(find.text('Year'));
      await tester.pumpAndSettle();

      expect(tester.getSemantics(find.text('Year')), selected(checked: true));
      expect(tester.getSemantics(find.text('Month')), selected(checked: false));
      expect(find.text('2026'), findsOneWidget);
    });

    testWidgets('keeps the current period when it is tapped again', (tester) async {
      await pumpCard(tester);

      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();

      expect(tester.getSemantics(find.text('Month')), selected(checked: true));
    });

    testWidgets('shares the shown series as a CSV file named after the period', (tester) async {
      final export = _FakeExport();
      await pumpCard(tester, export: export);

      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Share the shown series as CSV'));
      await tester.pumpAndSettle();

      expect(export.shared, hasLength(1));
      expect(export.shared.single.filename, 'traffic-day.csv');
      final lines = export.shared.single.csv.split('\r\n');
      expect(lines.first, 'Day,Visits,Unique,Target');
      expect(lines, hasLength(25));
      // The time may hold a narrow no-break space before AM.
      expect(lines[1], matches(RegExp(r'^12:00\sAM,\d+,\d+,65$')));
    });

    testWidgets('shows each footer figure with its share', (tester) async {
      await pumpCard(tester);

      expect(find.text('29,703 users (40%)'), findsOneWidget);
      expect(find.text('Average rate (40.15%)'), findsOneWidget);
      expect(find.bySemanticsLabel('New users'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is LinearProgressIndicator &&
              widget.semanticsLabel == 'New users' &&
              widget.semanticsValue == '80%',
        ),
        findsOneWidget,
      );
    });

    testWidgets('summarises the chart for screen readers', (tester) async {
      await pumpCard(tester);

      expect(
        find.bySemanticsLabel(RegExp(r'^Traffic, Aug 31, 2026 – Sep 27, 2026: visits between')),
        findsOneWidget,
      );
    });
  });

  group('AnalyticsScreen', () {
    for (final (dark, locale) in [(false, const Locale('en')), (true, const Locale('fr'))]) {
      testWidgets('lays the dashboard out on a narrow phone (${locale.languageCode})', (
        tester,
      ) async {
        await pumpShowcase(tester, const AnalyticsScreen(), width: 360, dark: dark, locale: locale);

        await tester.scrollUntilVisible(
          find.text(dark ? 'Pologne' : 'Poland'),
          600,
          scrollable: _page,
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
