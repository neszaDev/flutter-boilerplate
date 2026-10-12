import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/interceptors.dart';
import 'package:flutter_boilerplate/core/api/json.dart';
import 'package:flutter_boilerplate/core/auth/session_tokens.dart';

final _public = Options(extra: {publicRequest: true});

/// The backend's `/auth` endpoints. Uses the client without the access token.
class AuthRepository {
  AuthRepository(this._dio, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final Dio _dio;
  final DateTime Function() _now;

  /// `POST /auth/login`. 401 means wrong email or password; 429 carries `Retry-After`.
  Future<SessionTokens> login({required String email, required String password}) =>
      _tokens('/api/v1/auth/login', {'email': email.trim(), 'password': password});

  /// `POST /auth/register`, which also signs in. 409 means the email is taken.
  Future<SessionTokens> register({required String email, required String password}) =>
      _tokens('/api/v1/auth/register', {'email': email.trim(), 'password': password});

  /// `POST /auth/refresh`. The backend rotates the refresh token: the old one stops working.
  Future<SessionTokens> refresh(String refreshToken) =>
      _tokens('/api/v1/auth/refresh', {'refreshToken': refreshToken});

  /// `POST /auth/logout`: revokes the refresh token. Best effort; never throws.
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<void>(
        '/api/v1/auth/logout',
        data: {'refreshToken': refreshToken},
        options: _public,
      );
    } on DioException {
      // The local session ends even when the backend is unreachable.
    }
  }

  Future<SessionTokens> _tokens(String path, Json body) => apiCall(() async {
    final response = await _dio.post<Object?>(path, data: body, options: _public);
    return SessionTokens.fromResponse(asJson(response.data), now: _now());
  });
}
