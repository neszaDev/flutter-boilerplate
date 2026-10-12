import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/api/interceptors.dart';
import 'package:flutter_boilerplate/core/auth/auth_repository.dart';
import 'package:flutter_boilerplate/core/auth/token_manager.dart';
import 'package:flutter_boilerplate/core/auth/token_store.dart';
import 'package:flutter_boilerplate/core/config/app_info.dart';
import 'package:flutter_boilerplate/core/config/env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

BaseOptions _baseOptions() => BaseOptions(
  baseUrl: Env.backendUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 30),
  // Uploads of up to 10 MB on a slow mobile connection.
  sendTimeout: const Duration(seconds: 90),
  headers: {'Accept': 'application/json'},
);

/// Session storage. Tests override it with a [MemoryTokenStore].
final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

/// The transport under both clients. Null uses dio's default (the network); tests override it
/// with a fake so the real interceptors (auth, refresh, request ids) still run.
final httpClientAdapterProvider = Provider<HttpClientAdapter?>((ref) => null);

Dio _client(Ref ref) {
  final dio = Dio(_baseOptions());
  final adapter = ref.watch(httpClientAdapterProvider);
  if (adapter != null) {
    dio.httpClientAdapter = adapter;
  }
  return dio;
}

/// Client without the access token, for the auth endpoints (and the token refresh itself).
final publicDioProvider = Provider<Dio>((ref) {
  final dio = _client(ref)
    ..interceptors.add(RequestLogInterceptor(clientName: ref.watch(appInfoProvider).clientName));
  ref.onDispose(dio.close);
  return dio;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(publicDioProvider)),
);

final tokenManagerProvider = Provider<TokenManager>((ref) {
  final manager = TokenManager(
    store: ref.watch(tokenStoreProvider),
    refresh: ref.watch(authRepositoryProvider).refresh,
  );
  ref.onDispose(manager.dispose);
  return manager;
});

/// The authenticated client every repository uses: sends the access token, refreshes it and
/// retries once on a 401. Talk to the backend only through repositories built on it.
final apiDioProvider = Provider<Dio>((ref) {
  final dio = _client(ref);
  dio.interceptors.addAll([
    RequestLogInterceptor(clientName: ref.watch(appInfoProvider).clientName),
    AuthInterceptor(tokens: ref.watch(tokenManagerProvider), dio: dio),
  ]);
  ref.onDispose(dio.close);
  return dio;
});
