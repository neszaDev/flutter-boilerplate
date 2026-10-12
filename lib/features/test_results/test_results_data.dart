import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/api/api_client.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/json.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/core/data/paged_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The signed-in user's test results (`/test-results`). The backend scopes every call to the
/// owner; another user's id answers 404.
class TestResultsRepository {
  TestResultsRepository(this._dio);

  final Dio _dio;

  static const _path = '/api/v1/test-results';

  /// One page, most recent test first.
  Future<PageResult<TestResult>> list({required int page, required int size}) => apiCall(() async {
    final response = await _dio.get<Object?>(
      _path,
      queryParameters: {'page': page, 'size': size},
    );
    return PageResult.fromJson(asJson(response.data), TestResult.fromJson);
  });

  Future<TestResultSummary> summary() => apiCall(() async {
    final response = await _dio.get<Object?>('$_path/summary');
    return TestResultSummary.fromJson(asJson(response.data));
  });

  Future<TestResult> create(TestResultInput input) => apiCall(() async {
    final response = await _dio.post<Object?>(_path, data: input.toJson());
    return TestResult.fromJson(asJson(response.data));
  });

  Future<TestResult> update(int id, TestResultInput input) => apiCall(() async {
    final response = await _dio.patch<Object?>('$_path/$id', data: input.toJson());
    return TestResult.fromJson(asJson(response.data));
  });

  /// A result that is already gone (404) counts as deleted.
  Future<void> delete(int id) => apiCall(() async {
    await _dio.delete<void>(
      '$_path/$id',
      options: Options(validateStatus: (status) => status == 404 || (status ?? 500) < 300),
    );
  });
}

final testResultsRepositoryProvider = Provider<TestResultsRepository>(
  (ref) => TestResultsRepository(ref.watch(apiDioProvider)),
);

final testResultsSummaryProvider = FutureProvider.autoDispose<TestResultSummary>(
  (ref) => ref.watch(testResultsRepositoryProvider).summary(),
);

/// The five most recent results, for the overview.
final latestTestResultsProvider = FutureProvider.autoDispose<List<TestResult>>((ref) async {
  final page = await ref.watch(testResultsRepositoryProvider).list(page: 0, size: 5);
  return page.items;
});

class TestResultsList extends PagedNotifier<TestResult> {
  @override
  Future<PageResult<TestResult>> fetchPage(int page) =>
      ref.read(testResultsRepositoryProvider).list(page: page, size: AppConfig.testResultsPageSize);
}

final testResultsListProvider =
    AsyncNotifierProvider.autoDispose<TestResultsList, PagedState<TestResult>>(
      TestResultsList.new,
    );

/// After a create, edit or delete: everything that shows test results reloads.
void invalidateTestResults(WidgetRef ref) {
  ref
    ..invalidate(testResultsSummaryProvider)
    ..invalidate(latestTestResultsProvider)
    ..invalidate(testResultsListProvider);
}
