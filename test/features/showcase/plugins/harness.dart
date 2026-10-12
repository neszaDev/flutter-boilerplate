import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/device/connectivity.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] like the app does: Riverpod (online, no retries), localizations and the
/// Marksheet theme. [reduceMotion] stands for the phone's "reduce motion" setting.
Widget harness(
  Widget child, {
  List<Override> overrides = const [],
  ThemeData? theme,
  Locale locale = const Locale('en'),
  bool reduceMotion = false,
}) => ProviderScope(
  overrides: [isOnlineProvider.overrideWithValue(true), ...overrides],
  retry: (_, _) => null,
  child: MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: theme ?? AppTheme.light(),
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: app ?? const SizedBox.shrink(),
    ),
    home: child,
  ),
);

/// A phone-sized test screen: 360 pt wide, [height] tall (tall enough to build a whole page).
void usePhoneSize(WidgetTester tester, {double width = 360, double height = 740}) {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = Size(width, height) * 3;
  addTearDown(tester.view.reset);
}

/// Pumps [screen] in both themes and both languages on a tall phone-width screen, so every
/// section is built: overflows and missing texts fail the test.
Future<void> expectRendersEverywhere(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
}) async {
  usePhoneSize(tester, height: 6000);
  for (final theme in [AppTheme.light(), AppTheme.dark()]) {
    for (final locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(
        harness(screen, theme: theme, locale: locale, overrides: overrides),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull, reason: '$locale, ${theme.brightness}');
      // Unmount so the next run starts from a fresh state.
      await tester.pumpWidget(const SizedBox.shrink());
    }
  }
}
