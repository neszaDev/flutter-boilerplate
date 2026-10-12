import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/api/json.dart';

/// Error body returned by every backend endpoint (`common/exception/ApiError` in the Spring
/// API). Written by hand: the backend's OpenAPI spec doesn't declare error responses.
class ApiError {
  const ApiError({
    required this.status,
    required this.message,
    this.error,
    this.path,
    this.fieldErrors = const {},
  });

  final int status;
  final String message;
  final String? error;
  final String? path;

  /// Validation messages by request field (`{"email": "must be a well-formed email address"}`).
  final Map<String, String> fieldErrors;

  /// Reads an error body; `null` when [body] isn't one (an HTML proxy page, an empty body).
  static ApiError? tryParse(Object? body) {
    if (body is! Map<String, Object?>) {
      return null;
    }
    final status = body['status'];
    final message = body['message'];
    if (status is! int || message is! String) {
      return null;
    }
    final fields = body['fieldErrors'];
    return ApiError(
      status: status,
      message: message,
      error: body.string('error'),
      path: body.string('path'),
      fieldErrors: fields is Map<String, Object?>
          ? {
              for (final MapEntry(:key, :value) in fields.entries)
                if (value is String) key: value,
            }
          : const {},
    );
  }
}

/// What went wrong, in the terms screens care about.
enum ApiFailure {
  /// No connection, DNS failure, connection refused.
  network,
  timeout,

  /// 401: the session is gone (or wrong credentials on sign-in).
  unauthorized,

  /// 403: signed in, but the role doesn't allow it. Render [AccessDeniedView], don't sign out.
  forbidden,
  notFound,
  conflict,

  /// 400 with field errors, or 413/415 for uploads.
  invalid,

  /// 429: carries [ApiException.retryAfter].
  rateLimited,

  /// 5xx.
  server,
  cancelled,

  /// A response the app couldn't read.
  unknown,
}

/// Every failed backend call surfaces as this; repositories never leak [DioException].
class ApiException implements Exception {
  const ApiException(
    this.failure, {
    this.status,
    this.body,
    this.retryAfter,
    this.requestId,
    this.cause,
  });

  /// Converts a dio failure, reading the backend's [ApiError] body and `Retry-After`.
  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final status = response?.statusCode;
    final requestId =
        response?.headers.value('x-request-id') ??
        error.requestOptions.headers['X-Request-Id']?.toString();

    final failure = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => ApiFailure.timeout,
      DioExceptionType.connectionError => ApiFailure.network,
      DioExceptionType.cancel => ApiFailure.cancelled,
      DioExceptionType.badCertificate => ApiFailure.network,
      DioExceptionType.badResponse => _fromStatus(status),
      DioExceptionType.unknown =>
        error.error is FormatException ? ApiFailure.unknown : ApiFailure.network,
    };

    final retryAfterSeconds = int.tryParse(response?.headers.value('retry-after') ?? '');
    return ApiException(
      failure,
      status: status,
      body: ApiError.tryParse(response?.data),
      retryAfter: retryAfterSeconds == null ? null : Duration(seconds: retryAfterSeconds),
      requestId: requestId,
      cause: error,
    );
  }

  final ApiFailure failure;
  final int? status;
  final ApiError? body;
  final Duration? retryAfter;

  /// The `X-Request-Id` the backend logged this request under. Show it in bug reports.
  final String? requestId;
  final Object? cause;

  /// The backend's message, when it sent one.
  String? get message => body?.message;

  Map<String, String> get fieldErrors => body?.fieldErrors ?? const {};

  static ApiFailure _fromStatus(int? status) => switch (status) {
    401 => ApiFailure.unauthorized,
    403 => ApiFailure.forbidden,
    404 => ApiFailure.notFound,
    409 => ApiFailure.conflict,
    400 || 413 || 415 || 422 => ApiFailure.invalid,
    429 => ApiFailure.rateLimited,
    final int code when code >= 500 => ApiFailure.server,
    _ => ApiFailure.unknown,
  };

  @override
  String toString() =>
      'ApiException(${failure.name}, status: $status, message: $message, requestId: $requestId)';
}

/// Runs a backend call and turns dio and parsing failures into [ApiException].
Future<T> apiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (error) {
    throw error.error is ApiException ? error.error! as ApiException : ApiException.fromDio(error);
  } on FormatException catch (error) {
    throw ApiException(ApiFailure.unknown, cause: error);
  }
}
