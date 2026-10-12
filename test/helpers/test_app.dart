import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/settings/settings_controller.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Empty in-memory preferences, for `preferencesProvider`.
Future<SharedPreferencesWithCache> testPreferences([Map<String, Object> data = const {}]) {
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.withData(data);
  return openPreferences();
}

/// Pumps [child] the way the app shows it: providers, theme, localizations (English).
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) async {
  final preferences = await testPreferences();
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [preferencesProvider.overrideWithValue(preferences), ...overrides],
      child: MaterialApp(
        locale: locale,
        theme: theme ?? AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}

/// English strings, for finders: `find.text(l10n.authFormSignInButton)`.
Future<AppLocalizations> englishStrings() => AppLocalizations.delegate.load(const Locale('en'));
