import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/auth/session_tokens.dart';

/// A recorded request.
typedef Call = ({String method, String path, String? authorization, Object? body});

/// A response for [FakeBackend]: status and JSON body.
typedef Reply = ({int status, Object? body, Map<String, String> headers});

Reply reply(int status, [Object? body, Map<String, String> headers = const {}]) =>
    (status: status, body: body, headers: headers);

/// A dio adapter that answers from a function instead of the network, and records calls.
class FakeBackend implements HttpClientAdapter {
  FakeBackend(this.handler);

  /// Answers one request. May be async (e.g. to hold a refresh in flight).
  final Future<Reply> Function(Call call) handler;
  final calls = <Call>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final call = (
      method: options.method,
      path: options.path,
      authorization: options.headers['Authorization'] as String?,
      body: options.data,
    );
    calls.add(call);
    final answer = await handler(call);
    return ResponseBody.fromString(
      answer.body == null ? '' : jsonEncode(answer.body),
      answer.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        for (final MapEntry(:key, :value) in answer.headers.entries) key: [value],
      },
    );
  }

  @override
  void close({bool force = false}) {}

  Iterable<Call> callsTo(String path) => calls.where((call) => call.path == path);
}

/// A Dio on [backend] with a base URL, like the app's.
Dio fakeDio(FakeBackend backend) =>
    Dio(BaseOptions(baseUrl: 'http://backend.test'))..httpClientAdapter = backend;

/// The backend's token response.
Map<String, Object> tokenBody(String access, String refresh, {int expiresIn = 900}) => {
  'accessToken': access,
  'refreshToken': refresh,
  'expiresIn': expiresIn,
  'refreshExpiresIn': 2592000,
  'tokenType': 'Bearer',
};

/// Tokens valid for 15 minutes from [now].
SessionTokens validTokens(
  DateTime now, {
  String access = 'access-1',
  String refresh = 'refresh-1',
}) => SessionTokens(
  accessToken: access,
  accessExpiresAt: now.add(const Duration(minutes: 15)),
  refreshToken: refresh,
  refreshExpiresAt: now.add(const Duration(days: 30)),
);

/// The backend's `/users/me` body.
Map<String, Object> userBody({
  int id = 1,
  String email = 'ada@example.com',
  String role = 'USER',
}) => {
  'id': id,
  'email': email,
  'role': role,
  'createdAt': '2026-09-01T10:00:00Z',
};
