import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/base/breadcrumbs_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/cards_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/carousels_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/collapses_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/jumbotrons_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/list_groups_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/navs_screen.dart';
import 'package:flutter_boilerplate/features/showcase/base/switches_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_a_harness.dart';

const _screens = <String, Widget>{
  'Breadcrumbs': BreadcrumbsScreen(),
  'Cards': CardsScreen(),
  'Carousels': CarouselsScreen(),
  'Collapses': CollapsesScreen(),
  'Jumbotrons': JumbotronsScreen(),
  'List groups': ListGroupsScreen(),
  'Navs': NavsScreen(),
  'Switches': SwitchesScreen(),
};

void main() {
  group('base screens', () {
    for (final MapEntry(key: name, value: screen) in _screens.entries) {
      for (final (theme, themeName) in [(AppTheme.light(), 'light'), (AppTheme.dark(), 'dark')]) {
        for (final locale in const [Locale('en'), Locale('fr')]) {
          testWidgets('$name lays out on a narrow phone ($themeName, ${locale.languageCode})', (
            tester,
          ) async {
            // Tall enough that every section of the page is built and laid out.
            await pumpBase(
              tester,
              screen,
              screen: true,
              theme: theme,
              locale: locale,
              size: const Size(360, 16000),
            );
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
            expect(find.byType(Scaffold), findsOneWidget);
          });
        }
      }
    }
  });

  group('CollapsesScreen', () {
    testWidgets('opens the nested panels one inside the other', (tester) async {
      await pumpBase(tester, const CollapsesScreen(), screen: true, size: const Size(360, 3000));

      expect(find.text('Toggle inner collapse'), findsNothing);

      await tester.tap(find.text('Toggle collapse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Toggle inner collapse'));
      await tester.pumpAndSettle();

      expect(find.text('Hello!'), findsOneWidget);
    });

    testWidgets('keeps one accordion section open at a time', (tester) async {
      await pumpBase(tester, const CollapsesScreen(), screen: true, size: const Size(360, 3000));

      const marks =
          'Each test is scored out of 100. The term mark is the average of every test '
          'taken in the term.';
      const remarks =
          'The subject teacher writes a remark for each test; the form tutor adds one '
          'for the term.';
      expect(find.text(marks), findsOneWidget);
      expect(find.text(remarks), findsNothing);

      await tester.tap(find.text('Who writes the remarks?'));
      await tester.pumpAndSettle();

      expect(find.text(remarks), findsOneWidget);
      expect(find.text(marks), findsNothing);

      await tester.tap(find.text('Who writes the remarks?'));
      await tester.pumpAndSettle();

      expect(find.text(remarks), findsNothing);
    });

    testWidgets('folds the collapsible card from its header', (tester) async {
      await pumpBase(tester, const CollapsesScreen(), screen: true, size: const Size(360, 3000));

      expect(find.textContaining('Tap the card header'), findsOneWidget);

      await tester.tap(find.text('Collapsible card'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tap the card header'), findsNothing);
    });
  });
}
