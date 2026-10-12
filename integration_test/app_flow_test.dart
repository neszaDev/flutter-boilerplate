// End-to-end flows: the real app against the real backend (`make e2e`), on an emulator,
// simulator or phone. The backend comes from docker/compose.yml; its seeded admin is
// admin@e2e.test. Each run registers its own user, so runs never depend on each other.
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/main.dart' as app;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _adminEmail = String.fromEnvironment('E2E_ADMIN_EMAIL', defaultValue: 'admin@e2e.test');
const _adminPassword = String.fromEnvironment(
  'E2E_ADMIN_PASSWORD',
  defaultValue: 'e2e-admin-password',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps until [finder] shows up (network calls take real time here).
  Future<void> waitFor(WidgetTester tester, Finder finder, {int seconds = 30}) async {
    final end = DateTime.now().add(Duration(seconds: seconds));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    fail('Timed out waiting for $finder');
  }

  /// Pumps until [finder] is gone (a sheet or dialog closed).
  Future<void> waitUntilGone(WidgetTester tester, Finder finder, {int seconds = 30}) async {
    final end = DateTime.now().add(Duration(seconds: seconds));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isEmpty) {
        return;
      }
    }
    fail('Timed out waiting for $finder to go away');
  }

  Future<void> signIn(WidgetTester tester, String email, String password) async {
    await tester.enterText(find.byKey(const Key('auth.email')), email);
    await tester.enterText(find.byKey(const Key('auth.password')), password);
    await tester.tap(find.byKey(const Key('auth.submit')));
  }

  /// The menu tab; its first entry is always built (the list below it is lazy).
  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('tab.4')));
    await waitFor(tester, find.byKey(const Key('menu./dashboard')));
  }

  Future<void> signOut(WidgetTester tester, AppLocalizations l10n) async {
    await openMenu(tester);
    // Sign-out sits at the end of the long menu: scroll it into existence first.
    await tester.scrollUntilVisible(
      find.byKey(const Key('menu.signOut')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('menu.signOut')));
    await waitFor(tester, find.widgetWithText(FilledButton, l10n.settingsPageSignOut));
    await tester.tap(find.widgetWithText(FilledButton, l10n.settingsPageSignOut));
    await waitFor(tester, find.byKey(const Key('welcome.signUp')));
  }

  testWidgets('a new user signs up, adds a result and signs out; an admin finds them', (
    tester,
  ) async {
    // A clean device: no session, default settings.
    await const FlutterSecureStorage().deleteAll();
    await SharedPreferencesAsync().clear();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final email = 'e2e-${DateTime.now().millisecondsSinceEpoch}@example.com';

    // The test binding reports errors itself; keep its handlers.
    await app.bootstrap(installErrorHandlers: false);
    await waitFor(tester, find.byKey(const Key('welcome.signUp')));

    // Sign up: lands on the overview, greeted by email.
    await tester.tap(find.byKey(const Key('welcome.signUp')));
    await waitFor(tester, find.byKey(const Key('auth.email')));
    await signIn(tester, email, 'e2e-password');
    await waitFor(tester, find.text(l10n.dashboardPageHelloMessage(email)));
    // A USER has no user management.
    await openMenu(tester);
    expect(find.byKey(const Key('menu./dashboard/users')), findsNothing);

    // Add a test result: it shows on the card.
    await tester.tap(find.byKey(const Key('tab.1')));
    await waitFor(tester, find.byKey(const Key('testResults.add')));
    await tester.tap(find.byKey(const Key('testResults.add')));
    await waitFor(tester, find.byKey(const Key('testResult.name')));
    await tester.enterText(find.byKey(const Key('testResult.name')), 'Integration check');
    await tester.enterText(find.byKey(const Key('testResult.score')), '87.5');
    await tester.tap(find.byKey(const Key('testResult.submit')));
    // The sheet closes only once the backend saved it; then the row is on the card (the
    // name is no longer only in the form's text field).
    await waitUntilGone(tester, find.byKey(const Key('testResult.name')));
    await waitFor(tester, find.text('Integration check'));
    expect(find.text(l10n.testResultFormCreated), findsOneWidget);

    await signOut(tester, l10n);

    // The admin sees user management and finds the new account.
    await tester.tap(find.byKey(const Key('welcome.signIn')));
    await waitFor(tester, find.byKey(const Key('auth.email')));
    await signIn(tester, _adminEmail, _adminPassword);
    await waitFor(tester, find.byKey(const Key('tab.4')));
    await openMenu(tester);
    await waitFor(tester, find.byKey(const Key('menu./dashboard/users')));
    await tester.tap(find.byKey(const Key('menu./dashboard/users')));
    await waitFor(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField), email);
    await waitFor(tester, find.text(email));

    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 500));
    await signOut(tester, l10n);
  });
}
