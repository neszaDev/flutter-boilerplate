import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/app.dart';
import 'package:flutter_boilerplate/core/config/app_info.dart';
import 'package:flutter_boilerplate/core/config/env.dart';
import 'package:flutter_boilerplate/core/device/notifications.dart';
import 'package:flutter_boilerplate/core/logging/app_logger.dart';
import 'package:flutter_boilerplate/core/logging/error_reporter.dart';
import 'package:flutter_boilerplate/core/settings/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> main() => bootstrap();

/// Starts the app. Pass a different [reporter] to send crashes to a service of your choice.
/// Integration tests pass `installErrorHandlers: false`: their binding reports errors itself.
Future<void> bootstrap({
  ErrorReporter reporter = const LogErrorReporter(),
  bool installErrorHandlers = true,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.validate();
  configureLogging(reporter);

  if (installErrorHandlers) {
    // Everything that escapes a widget or a Future ends up in the reporter.
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      reporter.report(details.exception, details.stack, context: 'flutter');
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      reporter.report(error, stack, context: 'platform');
      return true;
    };
  }

  final (preferences, package) = await (openPreferences(), PackageInfo.fromPlatform()).wait;
  await LocalNotifications.instance.initialize();

  appLogger('app').info('Starting ${package.version}+${package.buildNumber} (${Env.name})');
  runApp(
    ProviderScope(
      // Errors are shown with a retry button; providers don't retry behind the user's back
      // (Riverpod 3 would, by default).
      retry: (retryCount, error) => null,
      overrides: [
        preferencesProvider.overrideWithValue(preferences),
        appInfoProvider.overrideWithValue(
          AppInfo(
            version: package.version,
            buildNumber: package.buildNumber,
            platform: defaultTargetPlatform.name,
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
