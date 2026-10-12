import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/connectivity.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] in the app's theme and localizations, on a phone-sized screen
/// ([width] × [height] logical pixels), with [overrides], and waits for it to settle
/// (unless [settle] is false: a spinner never does).
Future<void> pumpShowcase(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  bool dark = false,
  double width = 400,
  double height = 900,
  List<Override> overrides = const [],
  bool settle = true,
}) async {
  tester.view
    ..devicePixelRatio = 2
    ..physicalSize = Size(width * 2, height * 2);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      // No connectivity plugin in tests: the offline banner stays hidden.
      overrides: [isOnlineProvider.overrideWithValue(true), ...overrides],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        home: child,
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}
