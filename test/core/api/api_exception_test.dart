import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_backend.dart';

void main() {
  Future<ApiException> failureFor(Reply answer) async {
    final dio = fakeDio(FakeBackend((_) async => answer));
    try {
      await apiCall(() => dio.get<Object?>('/anything'));
    } on ApiException catch (error) {
      return error;
    }
    fail('expected an ApiException');
  }

  group('ApiException.fromDio', () {
    test('maps statuses to failures', () async {
      expect((await failureFor(reply(401))).failure, ApiFailure.unauthorized);
      expect((await failureFor(reply(403))).failure, ApiFailure.forbidden);
      expect((await failureFor(reply(404))).failure, ApiFailure.notFound);
      expect((await failureFor(reply(409))).failure, ApiFailure.conflict);
      expect((await failureFor(reply(413))).failure, ApiFailure.invalid);
      expect((await failureFor(reply(503))).failure, ApiFailure.server);
    });

    test('reads the backend error body and its field errors', () async {
      final error = await failureFor(
        reply(400, {
          'timestamp': '2026-10-07T10:00:00Z',
          'status': 400,
          'error': 'Bad Request',
          'message': 'Validation failed',
          'path': '/api/v1/test-results',
          'fieldErrors': {'score': 'must be less than or equal to 100.00'},
        }),
      );

      expect(error.failure, ApiFailure.invalid);
      expect(error.message, 'Validation failed');
      expect(error.fieldErrors, {'score': 'must be less than or equal to 100.00'});
    });

    test('reads Retry-After on a 429', () async {
      final error = await failureFor(reply(429, null, {'retry-after': '120'}));

      expect(error.failure, ApiFailure.rateLimited);
      expect(error.retryAfter, const Duration(minutes: 2));
    });

    test('treats a connection error as a network failure', () {
      final error = ApiException.fromDio(
        DioException.connectionError(requestOptions: RequestOptions(), reason: 'refused'),
      );

      expect(error.failure, ApiFailure.network);
    });
  });

  group('ApiError.tryParse', () {
    test('ignores bodies that are not the backend error shape', () {
      expect(ApiError.tryParse('<html>Bad gateway</html>'), isNull);
      expect(ApiError.tryParse({'message': 'no status'}), isNull);
    });
  });
}
