import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/app.dart';
import 'package:flutter_boilerplate/core/api/api_client.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/auth/token_store.dart';
import 'package:flutter_boilerplate/core/settings/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';
import 'helpers/test_app.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    required TokenStore store,
    required FakeBackend backend,
  }) async {
    final preferences = await testPreferences();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          preferencesProvider.overrideWithValue(preferences),
          tokenStoreProvider.overrideWithValue(store),
          httpClientAdapterProvider.overrideWithValue(backend),
        ],
        child: const App(),
      ),
    );
    // Marks draw on over time; let the first frames settle without waiting for every animation.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('opens on the welcome screen when signed out', (tester) async {
    final l10n = await englishStrings();
    await pumpApp(
      tester,
      store: MemoryTokenStore(),
      backend: FakeBackend((_) async => fail('no request expected')),
    );

    expect(find.text(l10n.indexTitle), findsOneWidget);
    expect(find.byKey(const Key('welcome.signUp')), findsOneWidget);
  });

  testWidgets('opens on the overview with a stored session', (tester) async {
    final l10n = await englishStrings();
    final now = DateTime.now();
    await pumpApp(
      tester,
      store: MemoryTokenStore(
        tokens: validTokens(now),
        profile: const UserProfile(id: 1, email: 'ada@example.com'),
      ),
      backend: FakeBackend((call) async {
        return switch (call.path) {
          '/api/v1/users/me' => reply(200, userBody()),
          '/api/v1/test-results/summary' => reply(200, {'total': 0, 'byStatus': <Object>[]}),
          '/api/v1/test-results' => reply(200, {
            'content': <Object>[],
            'number': 0,
            'totalPages': 0,
            'totalElements': 0,
          }),
          _ => reply(404),
        };
      }),
    );

    expect(find.text(l10n.dashboardPageHelloMessage('ada@example.com')), findsOneWidget);
    expect(find.text(l10n.dashboardPageEmptyTitle), findsOneWidget);
    // Signed in as a USER: no user management in the menu, but the tabs are there.
    expect(find.byKey(const Key('tab.4')), findsOneWidget);
  });

  testWidgets('does not retry failed loads by itself (a backend without these endpoints)', (
    tester,
  ) async {
    final backend = FakeBackend(
      (call) async => call.path == '/api/v1/users/me'
          ? reply(200, userBody(role: 'HR_ADMIN'))
          : reply(404, {'status': 404, 'message': 'Not Found'}),
    );
    await pumpApp(
      tester,
      store: MemoryTokenStore(
        tokens: validTokens(DateTime.now()),
        profile: const UserProfile(id: 1, email: 'ada@example.com'),
      ),
      backend: backend,
    );
    final afterStart = backend.calls.length;

    // Ten more seconds with nobody touching the screen.
    for (var i = 0; i < 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(backend.calls.length, afterStart);
    // Profile refresh + the overview's two reads, nothing repeated.
    expect(afterStart, lessThanOrEqualTo(4));
  });
}
