import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferences keys. Only non-sensitive settings go here; tokens live in `TokenStore`.
abstract final class _Keys {
  static const locale = 'settings.locale';
  static const themeMode = 'settings.themeMode';
  static const appLock = 'settings.appLock';
  static const shakeMenu = 'settings.shakeMenu';
  static const haptics = 'settings.haptics';

  static const all = {locale, themeMode, appLock, shakeMenu, haptics};
}

/// Opens the preferences store; called once in `main.dart`.
Future<SharedPreferencesWithCache> openPreferences() => SharedPreferencesWithCache.create(
  cacheOptions: const SharedPreferencesWithCacheOptions(allowList: _Keys.all),
);

/// Overridden in `main.dart` (and in tests) with an opened store.
final preferencesProvider = Provider<SharedPreferencesWithCache>(
  (ref) => throw UnimplementedError('preferencesProvider must be overridden'),
);

@immutable
class AppSettings {
  const AppSettings({
    this.locale,
    this.themeMode = ThemeMode.light,
    this.appLock = false,
    this.shakeMenu = true,
    this.haptics = true,
  });

  /// Null follows the phone's language (falling back to English).
  final Locale? locale;

  /// Light by default: the Marksheet design is a daylight one. Users can pick dark or system.
  final ThemeMode themeMode;

  /// Ask for biometrics / the device passcode when the app opens or returns.
  final bool appLock;

  /// Shake the phone to open the quick menu.
  final bool shakeMenu;
  final bool haptics;

  AppSettings copyWith({
    Locale? Function()? locale,
    ThemeMode? themeMode,
    bool? appLock,
    bool? shakeMenu,
    bool? haptics,
  }) => AppSettings(
    locale: locale == null ? this.locale : locale(),
    themeMode: themeMode ?? this.themeMode,
    appLock: appLock ?? this.appLock,
    shakeMenu: shakeMenu ?? this.shakeMenu,
    haptics: haptics ?? this.haptics,
  );
}

/// User preferences, persisted on the device.
class SettingsController extends Notifier<AppSettings> {
  SharedPreferencesWithCache get _prefs => ref.read(preferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(preferencesProvider);
    final code = prefs.getString(_Keys.locale);
    final supported = AppConfig.locales.map((locale) => locale.languageCode);
    return AppSettings(
      locale: code != null && supported.contains(code) ? Locale(code) : null,
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == prefs.getString(_Keys.themeMode),
        orElse: () => ThemeMode.light,
      ),
      appLock: prefs.getBool(_Keys.appLock) ?? false,
      shakeMenu: prefs.getBool(_Keys.shakeMenu) ?? true,
      haptics: prefs.getBool(_Keys.haptics) ?? true,
    );
  }

  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: () => locale);
    if (locale == null) {
      await _prefs.remove(_Keys.locale);
    } else {
      await _prefs.setString(_Keys.locale, locale.languageCode);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_Keys.themeMode, mode.name);
  }

  /// Turn on only after a successful authentication (see `AppLockController.enable`).
  Future<void> setAppLock({required bool enabled}) async {
    state = state.copyWith(appLock: enabled);
    await _prefs.setBool(_Keys.appLock, enabled);
  }

  Future<void> setShakeMenu({required bool enabled}) async {
    state = state.copyWith(shakeMenu: enabled);
    await _prefs.setBool(_Keys.shakeMenu, enabled);
  }

  Future<void> setHaptics({required bool enabled}) async {
    state = state.copyWith(haptics: enabled);
    await _prefs.setBool(_Keys.haptics, enabled);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
