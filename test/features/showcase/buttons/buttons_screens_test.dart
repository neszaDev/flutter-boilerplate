import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/brand_buttons_screen.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/button_groups_screen.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/demo_button.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/dropdowns_screen.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/menu_button.dart';
import 'package:flutter_boilerplate/features/showcase/buttons/standard_buttons_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'buttons_test_app.dart';

/// A phone screen tall enough to lay out every card at once.
const _tallPhone = Size(430, 7000);

void main() {
  group('button screens', () {
    final screens = <String, Widget>{
      'standard buttons': const StandardButtonsScreen(),
      'dropdowns': const DropdownsScreen(),
      'button groups': const ButtonGroupsScreen(),
      'brand buttons': const BrandButtonsScreen(),
    };
    for (final MapEntry(key: name, value: screen) in screens.entries) {
      for (final dark in [false, true]) {
        testWidgets('lays out the $name screen on a phone, ${dark ? 'dark' : 'light'}', (
          tester,
        ) async {
          await pumpButtons(tester, screen, size: _tallPhone, dark: dark);
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('StandardButtonsScreen', () {
    testWidgets('marks the active row as pressed and disables the disabled row', (tester) async {
      await pumpButtons(tester, const StandardButtonsScreen(), size: _tallPhone);
      await tester.pumpAndSettle();

      // The first card's three rows; the square and pill cards repeat them.
      final primaries = tester
          .widgetList<DemoButton>(find.widgetWithText(DemoButton, 'Primary'))
          .take(3);

      expect(primaries.map((button) => (button.active, button.enabled)), [
        (false, true),
        (true, true),
        (false, false),
      ]);
      expect(find.byTooltip('Settings'), findsNWidgets(DemoSize.values.length));
    });
  });

  group('ButtonGroupsScreen', () {
    testWidgets('drops a few buttons on a phone and shows them on a tablet', (tester) async {
      await pumpButtons(tester, const ButtonGroupsScreen(), size: _tallPhone);
      await tester.pumpAndSettle();

      expect(find.text('Four'), findsOneWidget);
      expect(find.text('Five'), findsNothing);
      expect(find.byTooltip('First page'), findsNothing);
      expect(find.text('Amount'), findsNothing);

      await pumpButtons(tester, const ButtonGroupsScreen(), size: const Size(800, 5000));
      await tester.pumpAndSettle();

      expect(find.text('Five'), findsOneWidget);
      expect(find.byTooltip('First page'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
    });
  });

  group('MenuButton', () {
    Future<Finder> open(WidgetTester tester, String label) async {
      await pumpButtons(tester, const DropdownsScreen(), size: const Size(400, 2400));
      await tester.pumpAndSettle();
      final button = find.widgetWithText(DemoButton, label);
      await tester.tap(button);
      await tester.pumpAndSettle();
      return button;
    }

    testWidgets('opens the menu under its button, aligned to its start', (tester) async {
      final button = await open(tester, 'Left align');
      final item = tester.getRect(find.widgetWithText(MenuItemButton, 'Another action'));

      expect(item.left, moreOrLessEquals(tester.getRect(button).left, epsilon: 1));
      expect(item.top, greaterThan(tester.getRect(button).bottom));
    });

    testWidgets('lines an end-aligned menu up with the end of its button', (tester) async {
      final button = await open(tester, 'Right align');
      final item = tester.getRect(find.widgetWithText(MenuItemButton, 'Another action'));

      expect(item.right, moreOrLessEquals(tester.getRect(button).right, epsilon: 1));
      expect(item.width, moreOrLessEquals(endAlignedMenuWidth, epsilon: 1));
    });

    testWidgets('opens a drop-up menu above its button', (tester) async {
      final button = await open(tester, 'Drop up');
      final item = tester.getRect(find.widgetWithText(MenuItemButton, 'Something else here'));

      expect(item.bottom, lessThan(tester.getRect(button).top));
    });

    testWidgets('closes the menu when an item is chosen', (tester) async {
      await open(tester, 'Dropdown button');

      expect(find.text('Disabled action'), findsOneWidget);

      await tester.tap(find.text('Second action'));
      await tester.pumpAndSettle();

      expect(find.text('Disabled action'), findsNothing);
    });
  });
}
