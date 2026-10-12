import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_pager.dart';
import 'package:flutter_boilerplate/features/showcase/base/paginations_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_b_harness.dart';

Finder _bar(String label) =>
    find.byWidgetPredicate((widget) => widget is Pager && widget.label == label);

Future<void> _pumpDemos(WidgetTester tester) => pumpBaseB(
  tester,
  const Scaffold(body: SingleChildScrollView(child: PagerDemos())),
  width: 800,
);

void main() {
  group('PagerDemos', () {
    testWidgets('starts on page 3 in every bar', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpDemos(tester);

      for (final bar in ['Default', 'Small', 'Large', 'Centre alignment']) {
        expect(
          tester.getSemantics(semanticsLabelled('Page 3', of: _bar(bar))),
          isSemantics(isSelected: true, isButton: true),
        );
      }
      expect(find.text('Current page: 3'), findsNWidgets(2));
      semantics.dispose();
    });

    testWidgets('moves every bar to the page tapped in one of them', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpDemos(tester);

      await tester.tap(semanticsLabelled('Page 4', of: _bar('Small')));
      await tester.pump();

      expect(find.text('Current page: 4'), findsNWidgets(2));
      expect(
        tester.getSemantics(semanticsLabelled('Page 4', of: _bar('Centre alignment'))),
        isSemantics(isSelected: true),
      );
      expect(
        tester.getSemantics(semanticsLabelled('Page 3', of: _bar('Centre alignment'))),
        isSemantics(isSelected: false),
      );
      semantics.dispose();
    });

    testWidgets('shifts the window of pages and disables the end arrows on the last page', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpDemos(tester);

      await tester.tap(semanticsLabelled('Last page', of: _bar('Default')));
      await tester.pump();

      expect(find.text('Current page: 10'), findsNWidgets(2));
      expect(semanticsLabelled('Page 7', of: _bar('Default')), findsOneWidget);
      expect(semanticsLabelled('Page 3', of: _bar('Default')), findsNothing);
      expect(
        tester.getSemantics(semanticsLabelled('Next page', of: _bar('Default'))),
        isSemantics(isEnabled: false, hasEnabledState: true),
      );
      expect(
        tester.getSemantics(semanticsLabelled('Previous page', of: _bar('Default'))),
        isSemantics(isEnabled: true),
      );
      semantics.dispose();
    });

    testWidgets('disables the start arrows on the first page and ignores taps on them', (
      tester,
    ) async {
      await _pumpDemos(tester);

      await tester.tap(semanticsLabelled('Page 1', of: _bar('Default')));
      await tester.pump();
      await tester.tap(semanticsLabelled('Previous page', of: _bar('Default')));
      await tester.pump();

      expect(find.text('Current page: 1'), findsNWidgets(2));
    });
  });

  group('PaginationsScreen', () {
    testWidgets('drops the first/last arrows and the large bar on a narrow phone', (tester) async {
      await pumpBaseB(tester, const PaginationsScreen(), width: 360);

      expect(semanticsLabelled('Previous page', of: _bar('Default')), findsOneWidget);
      expect(semanticsLabelled('First page', of: _bar('Default')), findsNothing);
      expect(_bar('Large'), findsNothing);
      // One line: the arrows at both ends sit on the same row.
      expect(
        tester.getRect(semanticsLabelled('Next page', of: _bar('Small'))).top,
        tester.getRect(semanticsLabelled('Previous page', of: _bar('Small'))).top,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('gives every button a 44 pt tap target where it fits', (tester) async {
      await pumpBaseB(tester, const PaginationsScreen());

      expect(tester.getSize(semanticsLabelled('Page 3', of: _bar('Small'))), const Size(44, 44));
    });

    testWidgets('shows the large bar where it fits', (tester) async {
      await pumpBaseB(tester, const PaginationsScreen(), width: 430);

      expect(_bar('Large'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
