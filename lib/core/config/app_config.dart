import 'package:flutter/widgets.dart';

/// Centralized application configuration.
abstract final class AppConfig {
  // The sample product's name. Replace it (and the copy in l10n/) with your own.
  static const name = 'Marksheet';

  /// Supported locales; the first one is the fallback. Every locale needs a folder in l10n/.
  static const locales = [Locale('en'), Locale('fr')];

  /// How long the app may sit in the background before the app lock asks again.
  static const appLockGrace = Duration(seconds: 30);

  /// Page sizes, the same as the web app.
  static const testResultsPageSize = 10;
  static const filesPageSize = 20;
  static const usersPageSize = 20;
}
