import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/connectivity.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] in the app's theme and localizations, on a phone-sized screen. Widgets that are
/// not a whole screen are put in a scrolling page body.
Future<void> pumpBase(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  Locale locale = const Locale('en'),
  Size size = const Size(360, 780),
  bool screen = false,
}) async {
  tester.view
    ..physicalSize = size * 3
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      // No connectivity plugin in tests: count as online.
      overrides: [isOnlineProvider.overrideWithValue(true)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        theme: theme ?? AppTheme.light(),
        home: screen
            ? child
            : Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(Space.page),
                  child: child,
                ),
              ),
      ),
    ),
  );
}
