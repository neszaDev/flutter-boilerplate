import 'package:flutter_boilerplate/core/api/json.dart';

/// Tokens from `/auth/register`, `/auth/login` and `/auth/refresh`, with absolute expiry times
/// so they survive an app restart.
class SessionTokens {
  const SessionTokens({
    required this.accessToken,
    required this.accessExpiresAt,
    required this.refreshToken,
    required this.refreshExpiresAt,
  });

  /// Reads `AuthTokensResponse`. All its fields are optional in the spec, so a body without
  /// them is rejected here rather than half-stored.
  factory SessionTokens.fromResponse(Json body, {required DateTime now}) {
    final access = body.string('accessToken');
    final refresh = body.string('refreshToken');
    final expiresIn = body.integer('expiresIn');
    final refreshExpiresIn = body.integer('refreshExpiresIn');
    if (access == null ||
        refresh == null ||
        expiresIn == null ||
        refreshExpiresIn == null ||
        access.isEmpty ||
        refresh.isEmpty) {
      throw const FormatException('the token response is incomplete');
    }
    return SessionTokens(
      accessToken: access,
      accessExpiresAt: now.add(Duration(seconds: expiresIn)),
      refreshToken: refresh,
      refreshExpiresAt: now.add(Duration(seconds: refreshExpiresIn)),
    );
  }

  factory SessionTokens.fromJson(Json json) => SessionTokens(
    accessToken: json.requireString('accessToken'),
    accessExpiresAt: json.dateTime('accessExpiresAt')!,
    refreshToken: json.requireString('refreshToken'),
    refreshExpiresAt: json.dateTime('refreshExpiresAt')!,
  );

  /// Refresh this long before the access token expires, so a request never races expiry
  /// (the web app drops its cookie 30 s early for the same reason).
  static const expiryMargin = Duration(seconds: 30);

  final String accessToken;
  final DateTime accessExpiresAt;
  final String refreshToken;
  final DateTime refreshExpiresAt;

  bool accessValidAt(DateTime now) => now.isBefore(accessExpiresAt.subtract(expiryMargin));

  bool refreshValidAt(DateTime now) => now.isBefore(refreshExpiresAt);

  Json toJson() => {
    'accessToken': accessToken,
    'accessExpiresAt': accessExpiresAt.toUtc().toIso8601String(),
    'refreshToken': refreshToken,
    'refreshExpiresAt': refreshExpiresAt.toUtc().toIso8601String(),
  };
}
