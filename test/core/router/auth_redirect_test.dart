import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/router/auth_redirect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const signedIn = SignedIn(UserProfile(id: 1, email: 'ada@example.com'));
  String? go(SessionState session, String location) => authRedirect(session, Uri.parse(location));

  group('authRedirect', () {
    group('while the session is restored', () {
      test('waits on the splash screen, remembering where it was going', () {
        expect(
          go(const SessionRestoring(), '/dashboard/files'),
          '/splash?from=%2Fdashboard%2Ffiles',
        );
        expect(go(const SessionRestoring(), '/splash'), isNull);
        expect(
          go(const RestoreFailed(ApiException(ApiFailure.network)), '/dashboard'),
          '/splash?from=%2Fdashboard',
        );
      });
    });

    group('signed out', () {
      test('sends the app area to sign-in and back afterwards', () {
        expect(
          go(const SignedOut(), '/dashboard/users/7'),
          '/sign-in?from=%2Fdashboard%2Fusers%2F7',
        );
      });

      test('allows the public screens', () {
        expect(go(const SignedOut(), '/'), isNull);
        expect(go(const SignedOut(), '/about'), isNull);
        expect(go(const SignedOut(), '/sign-up'), isNull);
      });

      test('leaves the splash screen for the welcome screen or the pending sign-in', () {
        expect(go(const SignedOut(), '/splash'), '/');
        expect(
          go(const SignedOut(), '/splash?from=%2Fdashboard%2Ffiles'),
          '/sign-in?from=%2Fdashboard%2Ffiles',
        );
      });
    });

    group('signed in', () {
      test('skips the welcome and sign-in screens', () {
        expect(go(signedIn, '/'), '/dashboard');
        expect(go(signedIn, '/sign-in'), '/dashboard');
        expect(go(signedIn, '/splash'), '/dashboard');
      });

      test('returns to the screen asked for before signing in', () {
        expect(go(signedIn, '/sign-in?from=%2Fdashboard%2Ffiles'), '/dashboard/files');
      });

      test('never follows a "from" outside the app', () {
        expect(go(signedIn, '/sign-in?from=https%3A%2F%2Fevil.example'), '/dashboard');
        expect(go(signedIn, '/sign-in?from=%2Fabout'), '/dashboard');
      });

      test('allows the app area', () {
        expect(go(signedIn, '/dashboard/test-results'), isNull);
      });
    });
  });
}
