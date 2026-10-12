// Drives the real app against the local backend (`make screenshots`) and captures the screens
// shown in the README. It signs up a fresh user, so it never touches existing accounts.
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/router/app_router.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/settings/settings_controller.dart';
import 'package:flutter_boilerplate/features/test_results/test_results_data.dart';
import 'package:flutter_boilerplate/main.dart' as app;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester, [int milliseconds = 2500]) async {
    for (var i = 0; i < milliseconds ~/ 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> waitFor(WidgetTester tester, Finder finder, {bool gone = false}) async {
    for (var i = 0; i < 300; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isEmpty == gone) {
        return;
      }
    }
    fail('Timed out waiting for $finder${gone ? ' to go away' : ''}');
  }

  testWidgets('captures the README screenshots', (tester) async {
    await const FlutterSecureStorage().deleteAll();
    await SharedPreferencesAsync().clear();
    await app.bootstrap(installErrorHandlers: false);
    await binding.convertFlutterSurfaceToImage();

    await waitFor(tester, find.byKey(const Key('welcome.signUp')));
    await settle(tester);
    await binding.takeScreenshot('welcome');

    await tester.tap(find.byKey(const Key('welcome.signUp')));
    await waitFor(tester, find.byKey(const Key('auth.email')));
    await tester.enterText(
      find.byKey(const Key('auth.email')),
      'alex.${DateTime.now().millisecondsSinceEpoch}@example.com',
    );
    await tester.enterText(find.byKey(const Key('auth.password')), 'sample-password');
    await tester.tap(find.byKey(const Key('auth.submit')));
    await waitFor(tester, find.byKey(const Key('tab.1')));

    // A few results, one per mark, so the card has something on it. Made through the app's
    // repository: the form itself is covered by the integration test.
    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    final repository = container.read(testResultsRepositoryProvider);
    final now = DateTime.now();
    for (final (index, (name, score, status, notes)) in [
      ('Driving theory test', 94.0, TestStatus.passed, null),
      ('Spanish B1 mock exam', 58.0, TestStatus.failed, 'Retake the listening part'),
      ('First-aid refresher', 100.0, TestStatus.passed, null),
      ('Piano grade 3 mock', 81.0, TestStatus.pending, "Examiner's sheet due Friday"),
    ].indexed) {
      await repository.create(
        TestResultInput(
          testName: name,
          status: status,
          score: score,
          testedAt: now.subtract(Duration(days: index * 4, hours: index)),
          notes: notes,
        ),
      );
    }
    // What the app's own forms do after a write: everything showing test results reloads.
    container
      ..invalidate(testResultsSummaryProvider)
      ..invalidate(latestTestResultsProvider)
      ..invalidate(testResultsListProvider);
    final router = container.read(routerProvider);
    router.go(Routes.testResults);
    await settle(tester, 4000);
    await binding.takeScreenshot('test-results');

    for (final (name, path) in [
      ('overview', Routes.dashboard),
      ('phone-features', Routes.device),
      ('menu', Routes.menu),
      ('settings', Routes.settings),
      ('charts', Routes.charts),
      ('calendar', Routes.pluginsCalendar),
      ('inbox', Routes.appsInbox),
    ]) {
      router.go(path);
      await settle(tester);
      await binding.takeScreenshot(name);
    }

    await container.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);
    router.go(Routes.dashboard);
    await settle(tester);
    await binding.takeScreenshot('overview-dark');
    await container.read(settingsProvider.notifier).setThemeMode(ThemeMode.light);
  });
}
