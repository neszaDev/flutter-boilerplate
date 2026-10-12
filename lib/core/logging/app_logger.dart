import 'dart:developer' as developer;

import 'package:flutter_boilerplate/core/config/env.dart';
import 'package:flutter_boilerplate/core/logging/error_reporter.dart';
import 'package:logging/logging.dart';

/// Named loggers. Use one per area: `final _log = appLogger('api');`.
Logger appLogger(String name) => Logger('app.$name');

/// Sends `package:logging` records to the platform log (Xcode / logcat / `flutter logs`), and
/// SEVERE records to the [ErrorReporter].
///
/// Never log tokens, passwords or personal data: logs leave the device in crash reports.
void configureLogging(ErrorReporter reporter) {
  Logger.root.level = Level.LEVELS.firstWhere(
    (level) => level.name == Env.logLevel,
    orElse: () => Level.INFO,
  );
  Logger.root.onRecord.listen((record) {
    developer.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      error: record.error,
      stackTrace: record.stackTrace,
    );
    if (record.level >= Level.SEVERE) {
      reporter.report(
        record.error ?? record.message,
        record.stackTrace,
        context: record.loggerName,
      );
    }
  });
}
