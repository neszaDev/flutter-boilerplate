import 'package:flutter_boilerplate/core/api/api_client.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/auth/token_store.dart';
import 'package:flutter_boilerplate/core/rbac/access.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_backend.dart';

void main() {
  late FakeBackend backend;
  late MemoryTokenStore store;

  ProviderContainer container(Future<Reply> Function(Call call) handler) {
    backend = FakeBackend(handler);
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        // Only the transport is fake: the app's interceptors (auth, refresh) run for real.
        httpClientAdapterProvider.overrideWithValue(backend),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Waits until the session leaves [SessionRestoring].
  Future<SessionState> settled(ProviderContainer container) async {
    container.listen(sessionProvider, (_, _) {});
    for (var i = 0; i < 100 && container.read(sessionProvider) is SessionRestoring; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    return container.read(sessionProvider);
  }

  setUp(() => store = MemoryTokenStore());

  group('SessionController', () {
    test('starts signed out without stored tokens', () async {
      final app = container((_) async => fail('no request expected'));

      expect(await settled(app), isA<SignedOut>());
    });

    test('opens with the cached profile and its role, then refreshes it', () async {
      store
        ..tokens = validTokens(DateTime.now())
        ..profile = const UserProfile(id: 1, email: 'ada@example.com', role: Role.user);
      final app = container(
        (call) async => reply(200, userBody(role: 'ADMIN')),
      );

      final state = await settled(app);
      expect(state, isA<SignedIn>());
      expect(app.read(accessProvider).can(Permission.viewUsers), isFalse);
      // The background refresh picks up a role changed by an admin.
      for (var i = 0; i < 100 && !app.read(accessProvider).can(Permission.viewUsers); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      expect(app.read(accessProvider).can(Permission.viewUsers), isTrue);
      expect(store.profile?.role, Role.admin);
    });

    test('keeps the session when the backend is unreachable at start', () async {
      store.tokens = validTokens(DateTime.now());
      final app = container((_) async => throw Exception('offline'));

      final state = await settled(app);

      expect(state, isA<RestoreFailed>());
      expect(store.tokens, isNotNull);
    });

    test('signs in, stores the tokens and loads the profile', () async {
      final app = container((call) async {
        return switch (call.path) {
          '/api/v1/auth/login' => reply(200, tokenBody('access-1', 'refresh-1')),
          '/api/v1/users/me' => reply(200, userBody()),
          _ => reply(404),
        };
      });
      await settled(app);

      await app.read(sessionProvider.notifier).signIn(email: 'ada@example.com', password: 'secret');

      expect(app.read(currentUserProvider)?.email, 'ada@example.com');
      expect(store.tokens?.refreshToken, 'refresh-1');
      expect(backend.callsTo('/api/v1/users/me').single.authorization, 'Bearer access-1');
    });

    test('reports wrong credentials and stays signed out', () async {
      final app = container((_) async => reply(401, {'status': 401, 'message': 'Bad credentials'}));
      await settled(app);

      await expectLater(
        app.read(sessionProvider.notifier).signIn(email: 'ada@example.com', password: 'nope'),
        throwsA(isA<ApiException>().having((e) => e.failure, 'failure', ApiFailure.unauthorized)),
      );
      expect(app.read(sessionProvider), isA<SignedOut>());
      expect(store.tokens, isNull);
    });

    test('signs out locally and revokes the refresh token', () async {
      store
        ..tokens = validTokens(DateTime.now())
        ..profile = const UserProfile(id: 1, email: 'ada@example.com');
      final app = container((_) async => reply(204));
      await settled(app);

      await app.read(sessionProvider.notifier).signOut();

      expect(app.read(sessionProvider), isA<SignedOut>());
      expect(store.tokens, isNull);
      expect(backend.callsTo('/api/v1/auth/logout').single.body, {'refreshToken': 'refresh-1'});
    });
  });
}
