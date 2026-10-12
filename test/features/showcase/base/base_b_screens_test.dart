import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_b_progress_demos.dart';
import 'package:flutter_boilerplate/features/showcase/base/navbars_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/paginations_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/popovers_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/progress_bars_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/tabs_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/tooltips_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_b_harness.dart';

const _screens = <String, Widget>{
  'NavbarsScreen': NavbarsScreen(),
  'PaginationsScreen': PaginationsScreen(),
  'PopoversScreen': PopoversScreen(),
  'ProgressBarsScreen': ProgressBarsScreen(),
  'TabsScreen': TabsScreen(),
  'TooltipsScreen': TooltipsScreen(),
};

void main() {
  group('base screens (b)', () {
    for (final MapEntry(key: name, value: screen) in _screens.entries) {
      for (final (width, dark) in [(360.0, false), (390.0, true), (800.0, false)]) {
        testWidgets('$name lays out at $width pt in the ${dark ? 'dark' : 'light'} theme', (
          tester,
        ) async {
          final semantics = tester.ensureSemantics();
          await pumpBaseB(tester, screen, width: width, dark: dark);
          await tester.pump(const Duration(milliseconds: 600));

          expect(tester.takeException(), isNull);
          semantics.dispose();
        });
      }
    }

    testWidgets('lay out in French', (tester) async {
      for (final screen in _screens.values) {
        await pumpBaseB(tester, screen, locale: const Locale('fr'));
        await tester.pump(const Duration(milliseconds: 600));
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('TabsScreen', () {
    testWidgets('switches panels and refuses the disabled tab', (tester) async {
      await pumpBaseB(tester, const TabsScreen());

      expect(find.textContaining('1. The home tab'), findsNWidgets(2));

      await tester.tap(find.text('Disabled').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('1. The home tab'), findsNWidgets(2));
      expect(find.textContaining('3. This tab is disabled'), findsNothing);

      await tester.tap(find.text('Profile').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('2. The profile tab'), findsOneWidget);
      expect(find.textContaining('1. The home tab'), findsOneWidget);
    });

    testWidgets('starts the icon tabs on the cart and the vertical tabs on the calculator', (
      tester,
    ) async {
      await pumpBaseB(tester, const TabsScreen());

      expect(find.textContaining('2. The shopping cart'), findsNWidgets(2));
      expect(find.textContaining('1. Work out a term average'), findsOneWidget);

      await tester.tap(find.text('Charts').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('3. Charts show'), findsOneWidget);
      expect(find.textContaining('1. Work out a term average'), findsNothing);
    });
  });

  group('TooltipsScreen', () {
    testWidgets('shows the second tooltip on load and the first on a tap', (tester) async {
      await pumpBaseB(tester, const TooltipsScreen());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('I start open!'), findsOneWidget);
      expect(find.text('I am a tooltip!'), findsNothing);

      await tester.tap(find.text('Tap me').first);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('I am a tooltip!'), findsOneWidget);
    });

    testWidgets('shows a placement tooltip on a long press', (tester) async {
      // Wide enough for the test font's broad letters.
      await pumpBaseB(tester, const TooltipsScreen(), width: 800);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.longPress(find.text('Right end'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Placement: Right end'), findsOneWidget);
      final button = tester.getRect(find.widgetWithText(FilledButton, 'Right end'));
      final tooltip = tester.getRect(find.text('Placement: Right end'));
      expect(tooltip.left, greaterThan(button.right));
    });
  });

  group('PopoversScreen', () {
    testWidgets('starts with the second popover open and swaps on a tap', (tester) async {
      await pumpBaseB(tester, const PopoversScreen());
      await tester.pump();

      expect(find.text('Popover!'), findsOneWidget);
      expect(find.text('Popover header'), findsNothing);

      await tester.tap(find.text('Tap me').first);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Popover header'), findsOneWidget);
      expect(find.text('I am the popover content!'), findsOneWidget);
      expect(find.text('Popover!'), findsNothing);

      await tester.tap(find.text('Tap me').first);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Popover header'), findsNothing);
    });

    testWidgets('opens a placement popover beside its button', (tester) async {
      await pumpBaseB(tester, const PopoversScreen());
      await tester.pump();

      await tester.tap(find.text('Left'));
      await tester.pump(const Duration(milliseconds: 200));

      final button = tester.getRect(find.widgetWithText(FilledButton, 'Left'));
      final popover = tester.getRect(find.text('Placement: Left'));
      expect(popover.right, lessThan(button.left));
    });
  });

  group('NavbarsScreen', () {
    testWidgets('folds the links behind the menu button on a phone', (tester) async {
      await pumpBaseB(tester, const NavbarsScreen());

      expect(find.text('Disabled'), findsNothing);

      await tester.tap(find.byTooltip('Show navigation').first);
      await tester.pumpAndSettle();

      expect(find.text('Link'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('shows the links inline on a wide screen', (tester) async {
      await pumpBaseB(tester, const NavbarsScreen(), width: 800);

      expect(find.text('Disabled'), findsOneWidget);
      expect(find.text('Navbar text'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('answers a search with a toast', (tester) async {
      await pumpBaseB(tester, const NavbarsScreen());

      final form = find.widgetWithText(Card, 'Form');
      await tester.enterText(find.descendant(of: form, matching: find.byType(TextField)), ' x ');
      await tester.tap(find.descendant(of: form, matching: find.text('Search').last));
      await tester.pump();

      expect(find.text('No results for “x” in this demo.'), findsOneWidget);
    });

    testWidgets('keeps one language chosen', (tester) async {
      await pumpBaseB(tester, const NavbarsScreen(), width: 800);

      await tester.tap(find.text('Language').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('RU'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Language').first);
      await tester.pumpAndSettle();

      final ru = tester.widget<RadioMenuButton<String>>(
        find.widgetWithText(RadioMenuButton<String>, 'RU'),
      );
      expect(ru.groupValue, 'RU');
    });
  });

  group('ProgressBarsScreen', () {
    testWidgets('toggles the stripes and their animation', (tester) async {
      await pumpBaseB(tester, const ProgressBarsScreen());

      await tester.ensureVisible(find.text('Remove stripes'));
      await tester.tap(find.text('Remove stripes'));
      await tester.pump();
      expect(find.text('Add stripes'), findsOneWidget);

      await tester.ensureVisible(find.text('Stop the animation'));
      await tester.tap(find.text('Stop the animation'));
      await tester.pump();
      expect(find.text('Start the animation'), findsOneWidget);
    });

    testWidgets('moves both counter bars to a random value', (tester) async {
      await pumpBaseB(tester, Scaffold(body: CounterProgress(random: math.Random(7))));

      expect(find.text('73%'), findsOneWidget);
      expect(find.text('44'), findsOneWidget);

      final next = math.Random(7).nextDouble() * 100;
      await tester.tap(find.text('Tap to animate the progress bars'));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('${next.round()}%'), findsOneWidget);
      expect(find.text('${(next * 0.6).round()}'), findsOneWidget);
    });
  });
}
