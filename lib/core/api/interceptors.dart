import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/auth/token_manager.dart';
import 'package:flutter_boilerplate/core/logging/app_logger.dart';

final _log = appLogger('api');

/// `Options(extra: {publicRequest: true})` sends a request without the access token (auth
/// endpoints). Everything else is authenticated.
const publicRequest = 'public';

const _retriedKey = 'auth.retried';
const _tokenKey = 'auth.token';
const _startedKey = 'log.started';

/// Adds `Authorization: Bearer …`, refreshing first when the token is about to expire; on a 401
/// refreshes once (shared with every other request, see [TokenManager]) and retries.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this._tokens, required this._dio});

  final TokenManager _tokens;

  /// The client this interceptor belongs to, for the retry.
  final Dio _dio;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra[publicRequest] == true) {
      return handler.next(options);
    }
    try {
      final token = await _tokens.accessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        options.extra[_tokenKey] = token;
      }
      handler.next(options);
    } on ApiException catch (error) {
      handler.reject(DioException(requestOptions: options, error: error));
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        options.extra[publicRequest] == true ||
        options.extra[_retriedKey] == true) {
      return handler.next(err);
    }
    try {
      final token = await _tokens.refreshAfterRejection(options.extra[_tokenKey] as String?);
      if (token == null) {
        // The session is over; TokenManager.onExpired already told the app.
        return handler.next(err);
      }
      options.extra[_retriedKey] = true;
      final data = options.data;
      if (data is FormData) {
        // A multipart body is a one-shot stream.
        options.data = data.clone();
      }
      handler.resolve(await _dio.fetch<Object?>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    } on ApiException catch (refreshError) {
      handler.next(err.copyWith(error: refreshError));
    }
  }
}

/// Tags each request with `X-Request-Id` (the backend logs it and echoes it back) and the app
/// version, and logs method, path, status and timing. Never logs headers or bodies: they carry
/// tokens and passwords.
class RequestLogInterceptor extends Interceptor {
  RequestLogInterceptor({required this.clientName});

  /// `X-Client` header, e.g. `marksheet-app/1.0.0+1 (android)`.
  final String clientName;
  final _random = Random.secure();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Request-Id'] ??= _requestId();
    options.headers['X-Client'] = clientName;
    options.extra[_startedKey] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response<Object?> response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    _log.fine(
      '${options.method} ${options.path} → ${response.statusCode} in ${_elapsed(options)} ms',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final status = err.response?.statusCode;
    final message =
        '${options.method} ${options.path} → ${status ?? err.type.name} in ${_elapsed(options)} ms '
        '(request ${options.headers['X-Request-Id']})';
    if (status != null && status >= 500) {
      _log.severe(message, err.message);
    } else if (status == null && err.type != DioExceptionType.cancel) {
      _log.warning(message, err.message);
    } else {
      _log.fine(message);
    }
    handler.next(err);
  }

  String _requestId() =>
      List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

  int _elapsed(RequestOptions options) {
    final started = options.extra[_startedKey];
    return started is DateTime ? DateTime.now().difference(started).inMilliseconds : -1;
  }
}
