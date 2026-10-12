import 'dart:async';

import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/auth/session_tokens.dart';
import 'package:flutter_boilerplate/core/auth/token_store.dart';
import 'package:flutter_boilerplate/core/logging/app_logger.dart';

final _log = appLogger('auth.tokens');

/// Exchanges a refresh token for new tokens (`POST /auth/refresh`).
typedef RefreshCall = Future<SessionTokens> Function(String refreshToken);

/// Holds the session tokens and refreshes them, **one refresh at a time**.
///
/// The backend rotates the refresh token on every use, so two refreshes with the same token
/// can't both win. Every request that finds the access token expired (or gets a 401) awaits
/// the same in-flight refresh instead of starting its own.
///
/// Only an answer that the refresh token is invalid (401/400) ends the session. A network
/// failure keeps the tokens: the user is offline, not signed out.
class TokenManager {
  TokenManager({
    required this._store,
    required RefreshCall refresh,
    DateTime Function()? now,
  }) : _refreshCall = refresh,
       _now = now ?? DateTime.now;

  final TokenStore _store;
  final RefreshCall _refreshCall;
  final DateTime Function() _now;
  final _expired = StreamController<void>.broadcast();

  SessionTokens? _tokens;
  Future<SessionTokens?>? _refreshing;

  /// Fires when the backend refused the refresh token: the session is over.
  Stream<void> get onExpired => _expired.stream;

  SessionTokens? get current => _tokens;

  bool get hasSession => _tokens != null;

  /// Reads the stored tokens; drops them when even the refresh token has expired.
  Future<void> load() async {
    final stored = await _store.readTokens();
    if (stored != null && !stored.refreshValidAt(_now())) {
      _log.info('Stored session has expired');
      await _store.clear();
      _tokens = null;
      return;
    }
    _tokens = stored;
  }

  Future<void> save(SessionTokens tokens) async {
    _tokens = tokens;
    await _store.writeTokens(tokens);
  }

  /// Forgets the session (sign-out). An in-flight refresh result is discarded.
  Future<void> clear() async {
    _tokens = null;
    await _store.clear();
  }

  /// An access token that is valid now, refreshed first when it is about to expire.
  /// Null when signed out. Throws [ApiException] when a needed refresh couldn't reach the backend.
  Future<String?> accessToken() async {
    final tokens = _tokens;
    if (tokens == null) {
      return null;
    }
    if (tokens.accessValidAt(_now())) {
      return tokens.accessToken;
    }
    return (await _refresh())?.accessToken;
  }

  /// After the backend answered 401 to a request sent with [rejected]: refresh, unless another
  /// request already did (then the newer token is returned as is).
  Future<String?> refreshAfterRejection(String? rejected) async {
    final tokens = _tokens;
    if (tokens == null) {
      return null;
    }
    if (rejected != null && tokens.accessToken != rejected) {
      return tokens.accessToken;
    }
    return (await _refresh())?.accessToken;
  }

  Future<SessionTokens?> _refresh() =>
      _refreshing ??= _runRefresh().whenComplete(() => _refreshing = null);

  Future<SessionTokens?> _runRefresh() async {
    final tokens = _tokens;
    if (tokens == null) {
      return null;
    }
    if (!tokens.refreshValidAt(_now())) {
      await _expire('refresh token expired');
      return null;
    }
    try {
      final fresh = await _refreshCall(tokens.refreshToken);
      if (!identical(_tokens, tokens)) {
        // Signed out (or in again) while the refresh was in flight: don't resurrect the session.
        return _tokens;
      }
      await save(fresh);
      return fresh;
    } on ApiException catch (error) {
      if (error.failure == ApiFailure.unauthorized || error.status == 400) {
        await _expire('refresh rejected (${error.status})');
        return null;
      }
      _log.warning('Token refresh failed; keeping the session', error);
      rethrow;
    }
  }

  Future<void> _expire(String reason) async {
    _log.info('Session ended: $reason');
    await clear();
    _expired.add(null);
  }

  Future<void> dispose() => _expired.close();
}
