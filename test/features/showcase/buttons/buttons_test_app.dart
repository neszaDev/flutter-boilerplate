import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/connectivity.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [home] in the app's theme and localizations on a [size] logical-pixel screen.
Future<void> pumpButtons(
  WidgetTester tester,
  Widget home, {
  Size size = const Size(400, 900),
  bool dark = false,
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
}
