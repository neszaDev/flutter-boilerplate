import 'package:flutter/foundation.dart';

/// Build-time configuration, read from `--dart-define-from-file=env/<name>.json`
/// (`make run`, `make build-*`). Every variable is declared and checked here; never call
/// `String.fromEnvironment` anywhere else. See docs/configuration.md.
abstract final class Env {
  /// Which configuration file the app was built with: `dev`, `staging` or `prod`.
  static const name = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static const _backendUrl = String.fromEnvironment('BACKEND_URL');

  /// Port of the local backend when [backendUrl] is derived (BACKEND_URL empty). Set it when
  /// another service holds 8080 (`make backend-up BACKEND_PORT=8090`).
  static const _backendPort = String.fromEnvironment('BACKEND_PORT', defaultValue: '8080');

  /// Base URL of the Spring API, without a trailing slash.
  ///
  /// When unset (env/dev.json), debug builds reach a backend on the developer's machine: the
  /// Android emulator sees the host as `10.0.2.2`, the iOS simulator as `localhost`. A real
  /// phone needs the computer's LAN address (env/dev.local.json). Release builds must set it.
  static String get backendUrl {
    if (_backendUrl.isNotEmpty) {
      return _backendUrl;
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:$_backendPort'
        : 'http://localhost:$_backendPort';
  }

  /// Minimum level for `package:logging` output: `ALL`, `FINE`, `INFO`, `WARNING`, `SEVERE`.
  static const logLevel = String.fromEnvironment('LOG_LEVEL', defaultValue: 'INFO');

  /// Where "Report a problem" (shake menu) sends its email. Empty hides the action.
  static const supportEmail = String.fromEnvironment('SUPPORT_EMAIL');

  /// Map tiles for the map demo, `{z}/{x}/{y}` template. OpenStreetMap's public tiles are fine
  /// for development only; use your own tile server or provider in production.
  static const mapTileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static bool get isProd => name == 'prod';

  /// Fails fast on a configuration that must never ship.
  ///
  /// Release builds talk to the backend over https only: tokens and passwords cross this
  /// connection. Debug builds may use http against a local backend.
  static void validate() {
    if (kReleaseMode && _backendUrl.isEmpty) {
      throw StateError('Release builds need BACKEND_URL (--dart-define-from-file=env/<name>.json)');
    }
    final uri = Uri.tryParse(backendUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('BACKEND_URL is not a valid URL: "$backendUrl"');
    }
    if (backendUrl.endsWith('/')) {
      throw StateError('BACKEND_URL must not end with "/": "$backendUrl"');
    }
    if (kReleaseMode && uri.scheme != 'https') {
      throw StateError('Release builds need an https BACKEND_URL, got "$backendUrl"');
    }
    if (!const {'dev', 'staging', 'prod'}.contains(name)) {
      throw StateError('APP_ENV must be dev, staging or prod, got "$name"');
    }
  }
}
