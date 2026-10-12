import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/connectivity.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [home] in the app's localizations and theme (English unless [locale] says otherwise),
/// on a [width] × [height] pt screen.
Future<void> pumpBaseB(
  WidgetTester tester,
  Widget home, {
  double width = 390,
  double height = 2400,
  bool dark = false,
  Locale locale = const Locale('en'),
}) async {
  tester.view
    ..physicalSize = Size(width, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [isOnlineProvider.overrideWithValue(true)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        home: home,
      ),
    ),
  );
}

/// The [Semantics] widget labelled [label], under [of] when given.
Finder semanticsLabelled(String label, {Finder? of}) {
  final matching = find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.label == label,
  );
  return of == null ? matching : find.descendant(of: of, matching: matching);
}
