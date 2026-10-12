import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [home] in the app's localizations and theme on a phone-sized screen.
Future<void> pumpCampus(
  WidgetTester tester,
  Widget home, {
  ThemeData? theme,
  Locale locale = const Locale('en'),
}) async {
  tester.view
    ..physicalSize = const Size(390 * 3, 844 * 3)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        theme: theme ?? AppTheme.light(),
        home: home,
      ),
    ),
  );
}

/// Pumps a widget that isn't a screen, in a scrolling page.
Future<void> pumpCampusWidget(WidgetTester tester, Widget child) => pumpCampus(
  tester,
  Scaffold(
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child),
  ),
);

/// The text field that screen readers know as [label].
Finder fieldLabelled(String label) => find.descendant(
  of: find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.label == label),
  matching: find.byType(TextField),
);

/// The text of the field labelled [label].
String fieldText(WidgetTester tester, String label) =>
    tester.widget<TextField>(fieldLabelled(label)).controller?.text ?? '';
