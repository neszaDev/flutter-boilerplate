import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/connectivity.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/theme/marksheet_colors.dart';
import 'package:flutter_boilerplate/features/showcase/theme/colors_screen.dart';
import 'package:flutter_boilerplate/features/showcase/theme/palette.dart';
import 'package:flutter_boilerplate/features/showcase/theme/typography_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [home] in the app's theme on a phone screen tall enough to lay out every card.
Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  bool dark = false,
  Size size = const Size(400, 9000),
}) async {
  tester.view
    ..devicePixelRatio = 2
    ..physicalSize = size * 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      // No connectivity plugin in tests: the offline banner stays hidden.
      overrides: [isOnlineProvider.overrideWithValue(true)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ColorsScreen', () {
    for (final (dark, colors) in [
      (false, MarksheetColors.light),
      (true, MarksheetColors.dark),
    ]) {
      testWidgets('shows every token with its value in the ${dark ? 'dark' : 'light'} theme', (
        tester,
      ) async {
        await _pump(tester, const ColorsScreen(), dark: dark);

        for (final token in PaletteToken.values) {
          expect(find.text(token.name), findsOneWidget, reason: token.name);
          expect(find.text(hexOf(token.of(colors))), findsWidgets, reason: token.name);
        }
        expect(find.textContaining('with folderInk, AAA'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('TypographyScreen', () {
    for (final dark in [false, true]) {
      testWidgets('shows each style with its spec, ${dark ? 'dark' : 'light'}', (tester) async {
        await _pump(tester, const TypographyScreen(), dark: dark);

        expect(find.text('headlineMedium'), findsOneWidget);
        expect(find.text('700 · 28 · 1.25 · -0.56'), findsOneWidget);
        expect(find.text('context.text.titleLarge'), findsOneWidget);
        expect(find.text('TESTED AT'), findsOneWidget);
        expect(find.text('<mark>'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('sets terms beside their descriptions on a tablet', (tester) async {
      await _pump(tester, const TypographyScreen(), size: const Size(800, 7000));

      final term = tester.getRect(find.text('MARKING'));
      final description = tester.getRect(
        find.text(
          'Each test is marked out of 100; 50 or more is a pass.',
        ),
      );

      expect(description.left, greaterThan(term.right));
      expect(find.byTooltip('A truncated term is truncated'), findsOneWidget);
    });
  });
}
