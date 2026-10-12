import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/interceptors.dart';
import 'package:flutter_boilerplate/core/auth/auth_repository.dart';
import 'package:flutter_boilerplate/core/auth/token_manager.dart';
import 'package:flutter_boilerplate/core/auth/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_backend.dart';

void main() {
  final now = DateTime.now();

  /// The app's wiring: a public client for refreshes, an authenticated one for the rest.
  ({Dio api, FakeBackend backend, TokenManager tokens}) setUpClients(
    Future<Reply> Function(Call call) handler, {
    String access = 'access-1',
  }) {
    final backend = FakeBackend(handler);
    final auth = AuthRepository(fakeDio(backend));
    final tokens = TokenManager(
      store: MemoryTokenStore(tokens: validTokens(now, access: access)),
      refresh: auth.refresh,
    );
    final api = fakeDio(backend);
    api.interceptors.add(AuthInterceptor(tokens: tokens, dio: api));
    return (api: api, backend: backend, tokens: tokens);
  }

  group('AuthInterceptor', () {
    test('sends the access token', () async {
      final setup = setUpClients((_) async => reply(200, userBody()));
      await setup.tokens.load();

      await setup.api.get<Object?>('/api/v1/users/me');

      expect(setup.backend.calls.single.authorization, 'Bearer access-1');
    });

    test('sends no token on public requests', () async {
      final setup = setUpClients((_) async => reply(200, tokenBody('a', 'r')));
      await setup.tokens.load();

      await setup.api.post<Object?>(
        '/api/v1/auth/login',
        options: Options(extra: {publicRequest: true}),
      );

      expect(setup.backend.calls.single.authorization, isNull);
    });

    test('refreshes once and retries when the backend answers 401', () async {
      final setup = setUpClients((call) async {
        if (call.path == '/api/v1/auth/refresh') {
          return reply(200, tokenBody('access-2', 'refresh-2'));
        }
        return call.authorization == 'Bearer access-2' ? reply(200, userBody()) : reply(401);
      });
      await setup.tokens.load();

      final response = await setup.api.get<Object?>('/api/v1/users/me');

      expect(response.statusCode, 200);
      expect(setup.backend.callsTo('/api/v1/auth/refresh'), hasLength(1));
      expect(setup.tokens.current?.refreshToken, 'refresh-2');
    });

    test('shares one refresh between parallel requests that get a 401', () async {
      final refreshGate = Completer<void>();
      final setup = setUpClients((call) async {
        if (call.path == '/api/v1/auth/refresh') {
          await refreshGate.future;
          return reply(200, tokenBody('access-2', 'refresh-2'));
        }
        return call.authorization == 'Bearer access-2' ? reply(200, {'ok': true}) : reply(401);
      });
      await setup.tokens.load();

      final requests = Future.wait([
        setup.api.get<Object?>('/api/v1/test-results'),
        setup.api.get<Object?>('/api/v1/test-results/summary'),
        setup.api.get<Object?>('/api/v1/files'),
      ]);
      await Future<void>.delayed(Duration.zero);
      refreshGate.complete();

      expect((await requests).map((response) => response.statusCode), [200, 200, 200]);
      expect(setup.backend.callsTo('/api/v1/auth/refresh'), hasLength(1));
    });

    test('gives up after one retry and ends the session when the refresh is refused', () async {
      final setup = setUpClients((call) async => reply(401, {'status': 401, 'message': 'no'}));
      await setup.tokens.load();
      final expired = setup.tokens.onExpired.first;

      final request = apiCall(() => setup.api.get<Object?>('/api/v1/users/me'));

      await expectLater(
        request,
        throwsA(isA<ApiException>().having((e) => e.failure, 'failure', ApiFailure.unauthorized)),
      );
      await expired;
      expect(setup.tokens.hasSession, isFalse);
      expect(setup.backend.callsTo('/api/v1/users/me'), hasLength(1));
    });
  });
}
