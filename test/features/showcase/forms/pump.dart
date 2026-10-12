import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// English texts, to find widgets by what they say.
final en = lookupAppLocalizations(const Locale('en'));

/// Pumps [child] in the app's localizations and theme. A widget that is not a screen goes in a
/// scrolling page; a screen ([screen]) is pumped as is.
Future<void> pumpDemo(
  WidgetTester tester,
  Widget child, {
  bool screen = false,
  ThemeData? theme,
  Locale? locale,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: theme ?? AppTheme.light(),
        home: screen
            ? child
            : Scaffold(
                body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child),
              ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// A phone-wide surface tall enough to build a whole showcase screen at once, so a layout
/// overflow anywhere fails the test.
void useTallPhone(WidgetTester tester, {double width = 390, double height = 12000}) {
  tester.view
    ..devicePixelRatio = 3
    ..physicalSize = Size(width * 3, height * 3);
  addTearDown(tester.view.reset);
}
