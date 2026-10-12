import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_meter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_b_harness.dart';

const _value = 33.333333333;

void main() {
  group('Meter', () {
    group('labels', () {
      testWidgets('prints the value and the percentage of max, rounded to the precision', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await pumpBaseB(
          tester,
          const Scaffold(
            body: Column(
              children: [
                Meter(
                  label: 'value',
                  max: 50,
                  segments: [MeterSegment(value: _value, label: MeterLabel.value)],
                ),
                Meter(
                  label: 'percent',
                  max: 50,
                  segments: [MeterSegment(value: _value, label: MeterLabel.percentage)],
                ),
                Meter(
                  label: 'value2',
                  max: 50,
                  precision: 2,
                  segments: [MeterSegment(value: _value, label: MeterLabel.value)],
                ),
                Meter(
                  label: 'percent2',
                  max: 50,
                  precision: 2,
                  segments: [MeterSegment(value: _value, label: MeterLabel.percentage)],
                ),
              ],
            ),
          ),
        );

        expect(find.text('33'), findsOneWidget);
        expect(find.text('67%'), findsOneWidget);
        expect(find.text('33.33'), findsOneWidget);
        expect(find.text('66.67%'), findsOneWidget);
        expect(
          tester.getSemantics(semanticsLabelled('value')),
          isSemantics(label: 'value', value: '33', role: SemanticsRole.progressBar, maxValue: '50'),
        );
        expect(
          tester.getSemantics(semanticsLabelled('percent2')),
          isSemantics(label: 'percent2', value: '66.67%'),
        );
        semantics.dispose();
      });

      testWidgets('formats labels for the locale', (tester) async {
        await pumpBaseB(
          tester,
          const Scaffold(
            body: Meter(
              label: 'percent2',
              max: 50,
              precision: 2,
              segments: [MeterSegment(value: _value, label: MeterLabel.percentage)],
            ),
          ),
          locale: const Locale('fr'),
        );

        expect(find.textContaining('66,67'), findsOneWidget);
      });
    });

    group('stacked', () {
      testWidgets('groups one progress bar per segment, each sized to its share', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpBaseB(
          tester,
          const Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: Meter(
                  label: 'Stacked',
                  segments: [
                    MeterSegment(value: 15),
                    MeterSegment(value: 30, tone: MeterTone.pass),
                  ],
                ),
              ),
            ),
          ),
          width: 800,
        );
        await tester.pump(const Duration(milliseconds: 600));

        final group = semanticsLabelled('Stacked');
        final bars = find.descendant(of: group, matching: semanticsLabelled('Stacked'));
        expect(bars, findsNWidgets(2));
        expect(tester.getSemantics(bars.at(1)), isSemantics(label: 'Stacked', value: '30%'));
        expect(tester.getSize(find.byKey(const ValueKey(1))).width, moreOrLessEquals(120));
        semantics.dispose();
      });

      testWidgets('cuts a segment that would overflow the track', (tester) async {
        await pumpBaseB(
          tester,
          const Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: Meter(
                  label: 'Full',
                  segments: [MeterSegment(value: 80), MeterSegment(value: 40)],
                ),
              ),
            ),
          ),
          width: 800,
        );
        await tester.pump(const Duration(milliseconds: 600));

        expect(tester.getSize(find.byKey(const ValueKey(1))).width, moreOrLessEquals(80));
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('meterText', () {
    test('prints values and percentages to the precision', () {
      expect(meterText(value: _value, max: 50, label: MeterLabel.value, locale: 'en'), '33');
      expect(
        meterText(value: _value, max: 50, label: MeterLabel.percentage, locale: 'en', precision: 2),
        '66.67%',
      );
    });
  });

  group('meterSemantics', () {
    test('reads values against max and percentages against 100', () {
      final value = meterSemantics(value: 80, max: 50, label: MeterLabel.value);
      expect((value.value, value.min, value.max), ('50', '0', '50'));

      final percent = meterSemantics(value: _value, max: 50, precision: 2);
      expect((percent.value, percent.min, percent.max), ('66.67%', '0', '100'));
    });
  });
}
