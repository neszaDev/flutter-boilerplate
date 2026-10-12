import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';

/// Where to send a navigation to [uri] in the current [session], or null to allow it.
/// The app's equivalent of the web proxy's auth rules:
///
/// - while the stored session is read, everything waits on the splash screen;
/// - signed out, `/dashboard/**` goes to sign-in (and comes back after it);
/// - signed in, the welcome and sign-in/up screens go to the dashboard.
///
/// Permissions are checked per route (`guardedRoute`), not here.
String? authRedirect(SessionState session, Uri uri) {
  final path = uri.path;
  final from = _safeFrom(uri.queryParameters['from']);

  switch (session) {
    case SessionRestoring() || RestoreFailed():
      return path == Routes.splash ? null : _with(Routes.splash, uri.toString());
    case SignedOut():
      if (Routes.isApp(path)) {
        return _with(Routes.signIn, uri.toString());
      }
      if (path == Routes.splash) {
        return from != null ? _with(Routes.signIn, from) : Routes.welcome;
      }
      return null;
    case SignedIn():
      if (path == Routes.splash ||
          path == Routes.welcome ||
          path == Routes.signIn ||
          path == Routes.signUp) {
        return from ?? Routes.dashboard;
      }
      return null;
  }
}

/// Only app paths are followed back after sign-in (never an external or odd location).
String? _safeFrom(String? from) {
  if (from == null) {
    return null;
  }
  final uri = Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority || !Routes.isApp(uri.path)) {
    return null;
  }
  return from;
}

String _with(String path, String from) {
  final safe = _safeFrom(from);
  return safe == null ? path : Uri(path: path, queryParameters: {'from': safe}).toString();
}
