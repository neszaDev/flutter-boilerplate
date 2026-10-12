import 'dart:developer' as developer;

/// Where unexpected errors go: uncaught exceptions (see `main.dart`) and SEVERE log records.
///
/// The boilerplate ships no crash-reporting SDK (a third-party service needs a recorded decision,
/// see AGENTS.md). To add one (Sentry, Crashlytics, …), implement this interface and pass it to
/// `bootstrap()` in `main.dart`; nothing else changes.
abstract interface class ErrorReporter {
  void report(Object error, StackTrace? stackTrace, {String? context});
}

/// Writes errors to the platform log. The default until a real reporter is chosen.
class LogErrorReporter implements ErrorReporter {
  const LogErrorReporter();

  @override
  void report(Object error, StackTrace? stackTrace, {String? context}) {
    developer.log(
      'Unhandled error${context == null ? '' : ' ($context)'}',
      name: 'app.error',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
