import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/api/api_client.dart';
import 'package:flutter_boilerplate/core/auth/token_store.dart';
import 'package:flutter_boilerplate/features/auth/auth_screens.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_backend.dart';
import '../../helpers/test_app.dart';

void main() {
  Future<FakeBackend> pumpSignIn(WidgetTester tester, Future<Reply> Function(Call) handler) async {
    final backend = FakeBackend(handler);
    await pumpScreen(
      tester,
      const SignInScreen(),
      overrides: [
        tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
        httpClientAdapterProvider.overrideWithValue(backend),
      ],
    );
    await tester.pumpAndSettle();
    return backend;
  }

  group('SignInScreen', () {
    testWidgets('checks the fields before calling the backend', (tester) async {
      final l10n = await englishStrings();
      final backend = await pumpSignIn(tester, (_) async => fail('no request expected'));

      await tester.enterText(find.byKey(const Key('auth.email')), 'not-an-email');
      await tester.tap(find.byKey(const Key('auth.submit')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.validationInvalidEmail), findsOneWidget);
      expect(find.text(l10n.validationRequired), findsOneWidget);
      expect(backend.calls, isEmpty);
    });

    testWidgets('says the credentials are wrong on a 401', (tester) async {
      final l10n = await englishStrings();
      await pumpSignIn(tester, (_) async => reply(401, {'status': 401, 'message': 'Bad'}));

      await tester.enterText(find.byKey(const Key('auth.email')), 'ada@example.com');
      await tester.enterText(find.byKey(const Key('auth.password')), 'wrong-password');
      await tester.tap(find.byKey(const Key('auth.submit')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.authFormErrorInvalidCredentials), findsOneWidget);
    });

    testWidgets('says how long to wait when rate limited', (tester) async {
      final l10n = await englishStrings();
      await pumpSignIn(tester, (_) async => reply(429, null, {'retry-after': '90'}));

      await tester.enterText(find.byKey(const Key('auth.email')), 'ada@example.com');
      await tester.enterText(find.byKey(const Key('auth.password')), 'secret');
      await tester.tap(find.byKey(const Key('auth.submit')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.authFormErrorRateLimited(2)), findsOneWidget);
    });
  });
}
