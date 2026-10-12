import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/forms/advanced_forms_screen.dart';
import 'package:flutter_boilerplate/features/showcase/forms/basic_forms_screen.dart';
import 'package:flutter_boilerplate/features/showcase/forms/validation_forms_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump.dart';

void main() {
  final screens = <String, Widget>{
    'BasicFormsScreen': const BasicFormsScreen(),
    'AdvancedFormsScreen': const AdvancedFormsScreen(),
    'ValidationFormsScreen': const ValidationFormsScreen(),
  };

  for (final MapEntry(key: name, value: screen) in screens.entries) {
    group(name, () {
      for (final (label, theme, width, locale) in [
        ('light', AppTheme.light(), 360.0, const Locale('fr')),
        ('dark', AppTheme.dark(), 430.0, const Locale('en')),
      ]) {
        testWidgets(
          'lays out on a ${width.round()} pt phone in the $label theme (${locale.languageCode})',
          (tester) async {
            useTallPhone(tester, width: width, height: name == 'BasicFormsScreen' ? 24000 : 6000);
            await pumpDemo(tester, screen, screen: true, theme: theme, locale: locale);

            expect(tester.takeException(), isNull);
            expect(find.byType(Card), findsWidgets);
          },
        );
      }
    });
  }

  group('BasicFormsScreen', () {
    testWidgets('resets a demo form to its defaults', (tester) async {
      useTallPhone(tester, height: 16000);
      await pumpDemo(tester, const BasicFormsScreen(), screen: true);
      final checked = find.byWidgetPredicate(
        (widget) => widget is Checkbox && (widget.value ?? false),
      );

      await tester.enterText(find.bySemanticsLabel(en.basicFormsPageFullNameLabel), 'Ada');
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();

      expect(find.text('Ada'), findsOneWidget);
      expect(checked, findsNWidgets(4));

      // The credit card and company forms have no buttons: the first reset is the elements'.
      await tester.tap(find.text(en.basicFormsPageReset).first);
      await tester.pumpAndSettle();

      expect(find.text('Ada'), findsNothing);
      expect(checked, findsNWidgets(3));
    });

    testWidgets('collapses, closes and brings back the form elements card', (tester) async {
      useTallPhone(tester, height: 16000);
      await pumpDemo(tester, const BasicFormsScreen(), screen: true);

      expect(find.text(en.basicFormsPageSaveChanges), findsOneWidget);

      await tester.tap(find.byTooltip(en.basicFormsPageCollapseCard));
      await tester.pumpAndSettle();
      expect(find.text(en.basicFormsPageSaveChanges), findsNothing);

      await tester.tap(find.byTooltip(en.basicFormsPageCloseCard));
      await tester.pumpAndSettle();
      expect(
        find.text(en.basicFormsPageCardClosed(en.basicFormsPageFormElementsTitle)),
        findsOneWidget,
      );

      await tester.tap(find.text(en.basicFormsPageShowCard));
      await tester.pumpAndSettle();
      expect(find.byTooltip(en.basicFormsPageExpandCard), findsOneWidget);
    });

    testWidgets('opens the action menu of an input group', (tester) async {
      useTallPhone(tester, height: 16000);
      await pumpDemo(tester, const BasicFormsScreen(), screen: true);

      await tester.tap(find.byTooltip(en.basicFormsPageMoreActions));
      await tester.pumpAndSettle();

      expect(find.text(en.basicFormsPageAnotherAction), findsOneWidget);
      final disabled = tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, en.basicFormsPageDisabledAction),
      );
      expect(disabled.onPressed, isNull);
    });
  });
}
