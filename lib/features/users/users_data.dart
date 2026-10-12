import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/api/api_client.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/json.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/core/data/paged_list.dart';
import 'package:flutter_boilerplate/core/rbac/role.dart';
import 'package:flutter_boilerplate/core/validation/validation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User management (`/users`, admins only; the backend answers 403 to anyone else and
/// re-checks the role in its database).
class UsersRepository {
  UsersRepository(this._dio);

  final Dio _dio;

  static const _path = '/api/v1/users';

  /// Newest first; [query] matches part of the email.
  Future<PageResult<UserProfile>> list({
    required String query,
    required int page,
    required int size,
  }) => apiCall(() async {
    final response = await _dio.get<Object?>(
      _path,
      queryParameters: {'q': query.isEmpty ? null : query, 'page': page, 'size': size},
    );
    return PageResult.fromJson(asJson(response.data), UserProfile.fromJson);
  });

  Future<UserProfile> get(int id) => apiCall(() async {
    final response = await _dio.get<Object?>('$_path/$id');
    return UserProfile.fromJson(asJson(response.data));
  });

  /// Changes email and role. The backend refuses your own account and taken emails (409), and
  /// signs the user out everywhere.
  Future<UserProfile> update(int id, {required String email, required Role role}) =>
      apiCall(() async {
        final response = await _dio.patch<Object?>(
          '$_path/$id',
          data: {'email': email.trim(), 'role': role.apiName},
        );
        return UserProfile.fromJson(asJson(response.data));
      });

  /// Deletes the account with its test results and files. 404 counts as deleted.
  Future<void> delete(int id) => apiCall(() async {
    await _dio.delete<void>(
      '$_path/$id',
      options: Options(validateStatus: (status) => status == 404 || (status ?? 500) < 300),
    );
  });
}

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepository(ref.watch(apiDioProvider)),
);

/// The user list for a search query (empty lists everyone).
class UsersList extends PagedNotifier<UserProfile> {
  UsersList(this.query);

  final String query;

  @override
  Future<PageResult<UserProfile>> fetchPage(int page) => ref
      .read(usersRepositoryProvider)
      .list(query: query, page: page, size: AppConfig.usersPageSize);
}

final usersListProvider = AsyncNotifierProvider.autoDispose
    .family<UsersList, PagedState<UserProfile>, String>(UsersList.new);

final userProvider = FutureProvider.autoDispose.family<UserProfile, int>(
  (ref, id) => ref.watch(usersRepositoryProvider).get(id),
);

/// Mirrors the backend's UpdateUserRequest.
final userEmailRule = Rules.all([Rules.required, Rules.email, Rules.maxLength(254)]);

/// Whether [error] means "you can't do this" rather than "it failed".
bool isForbidden(Object? error) => error is ApiException && error.failure == ApiFailure.forbidden;
