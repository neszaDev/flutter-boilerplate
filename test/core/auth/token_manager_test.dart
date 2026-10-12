import 'dart:async';

import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/auth/session_tokens.dart';
import 'package:flutter_boilerplate/core/auth/token_manager.dart';
import 'package:flutter_boilerplate/core/auth/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_backend.dart';

void main() {
  final now = DateTime.utc(2026, 10, 7, 12);

  SessionTokens expiredAccess() => SessionTokens(
    accessToken: 'old-access',
    accessExpiresAt: now.subtract(const Duration(minutes: 1)),
    refreshToken: 'refresh-1',
    refreshExpiresAt: now.add(const Duration(days: 30)),
  );

  group('TokenManager', () {
    test('returns the stored access token while it is valid', () async {
      var refreshes = 0;
      final manager = TokenManager(
        store: MemoryTokenStore(tokens: validTokens(now)),
        refresh: (_) async {
          refreshes++;
          return validTokens(now, access: 'access-2');
        },
        now: () => now,
      );
      await manager.load();

      expect(await manager.accessToken(), 'access-1');
      expect(refreshes, 0);
    });

    test('refreshes once for parallel requests with an expired token', () async {
      final store = MemoryTokenStore(tokens: expiredAccess());
      final gate = Completer<void>();
      final used = <String>[];
      final manager = TokenManager(
        store: store,
        refresh: (token) async {
          used.add(token);
          await gate.future;
          return validTokens(now, access: 'access-2', refresh: 'refresh-2');
        },
        now: () => now,
      );
      await manager.load();

      final tokens = Future.wait([
        manager.accessToken(),
        manager.accessToken(),
        manager.accessToken(),
      ]);
      gate.complete();

      expect(await tokens, ['access-2', 'access-2', 'access-2']);
      expect(used, ['refresh-1']);
      expect(store.tokens?.refreshToken, 'refresh-2');
    });

    test('ends the session when the backend rejects the refresh token', () async {
      final store = MemoryTokenStore(tokens: expiredAccess());
      final manager = TokenManager(
        store: store,
        refresh: (_) async => throw const ApiException(ApiFailure.unauthorized, status: 401),
        now: () => now,
      );
      await manager.load();
      final expired = manager.onExpired.first;

      expect(await manager.accessToken(), isNull);
      await expired;
      expect(manager.hasSession, isFalse);
      expect(store.tokens, isNull);
    });

    test('keeps the session when the refresh fails for lack of network', () async {
      final store = MemoryTokenStore(tokens: expiredAccess());
      final manager = TokenManager(
        store: store,
        refresh: (_) async => throw const ApiException(ApiFailure.network),
        now: () => now,
      );
      await manager.load();

      await expectLater(manager.accessToken(), throwsA(isA<ApiException>()));
      expect(manager.hasSession, isTrue);
      expect(store.tokens?.refreshToken, 'refresh-1');
    });

    test('does not refresh again after a 401 when another request already did', () async {
      var refreshes = 0;
      final manager = TokenManager(
        store: MemoryTokenStore(tokens: validTokens(now, access: 'access-2')),
        refresh: (_) async {
          refreshes++;
          return validTokens(now, access: 'access-3');
        },
        now: () => now,
      );
      await manager.load();

      expect(await manager.refreshAfterRejection('access-1'), 'access-2');
      expect(refreshes, 0);
      expect(await manager.refreshAfterRejection('access-2'), 'access-3');
      expect(refreshes, 1);
    });

    test('does not bring back a session signed out during a refresh', () async {
      final gate = Completer<void>();
      final store = MemoryTokenStore(tokens: expiredAccess());
      final manager = TokenManager(
        store: store,
        refresh: (_) async {
          await gate.future;
          return validTokens(now, access: 'access-2');
        },
        now: () => now,
      );
      await manager.load();

      final token = manager.accessToken();
      await manager.clear();
      gate.complete();

      expect(await token, isNull);
      expect(store.tokens, isNull);
    });

    test('drops a stored session whose refresh token has expired', () async {
      final store = MemoryTokenStore(
        tokens: SessionTokens(
          accessToken: 'a',
          accessExpiresAt: now.subtract(const Duration(days: 31)),
          refreshToken: 'r',
          refreshExpiresAt: now.subtract(const Duration(days: 1)),
        ),
      );
      final manager = TokenManager(
        store: store,
        refresh: (_) async => fail('must not refresh'),
        now: () => now,
      );

      await manager.load();

      expect(manager.hasSession, isFalse);
      expect(store.tokens, isNull);
    });
  });

  group('SessionTokens', () {
    test('turns relative lifetimes into absolute expiry times', () {
      final tokens = SessionTokens.fromResponse(tokenBody('a', 'r', expiresIn: 600), now: now);

      expect(tokens.accessExpiresAt, now.add(const Duration(seconds: 600)));
      expect(tokens.accessValidAt(now.add(const Duration(seconds: 569))), isTrue);
      // Refresh 30 seconds early, like the web app's cookie margin.
      expect(tokens.accessValidAt(now.add(const Duration(seconds: 571))), isFalse);
    });

    test('rejects an incomplete token response', () {
      expect(
        () => SessionTokens.fromResponse({'accessToken': 'a'}, now: now),
        throwsFormatException,
      );
    });

    test('survives a round trip through storage', () {
      final tokens = validTokens(now);
      final restored = SessionTokens.fromJson(tokens.toJson());

      expect(restored.accessToken, tokens.accessToken);
      expect(restored.refreshExpiresAt, tokens.refreshExpiresAt);
    });
  });
}
