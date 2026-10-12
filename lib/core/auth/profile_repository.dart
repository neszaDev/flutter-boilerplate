import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/api/api_client.dart';
import 'package:flutter_boilerplate/core/api/api_exception.dart';
import 'package:flutter_boilerplate/core/api/json.dart';
import 'package:flutter_boilerplate/core/api/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The signed-in account (`GET /users/me`): its role drives every permission check.
class ProfileRepository {
  ProfileRepository(this._dio);

  final Dio _dio;

  Future<UserProfile> me() => apiCall(() async {
    final response = await _dio.get<Object?>('/api/v1/users/me');
    return UserProfile.fromJson(asJson(response.data));
  });
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(apiDioProvider)),
);
