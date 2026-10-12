// Checks the backend's OpenAPI spec against what this app relies on: every endpoint it calls,
// every field it reads, every enum value it knows. Run against a backend (`make api-check`);
// CI runs it against the published backend image.
//
// The models in lib/core/api/models.dart are written by hand; this is what keeps them honest.
// When it fails: update the model and repository, then the lists below.
//
// Usage: dart run tool/api_check.dart [backend-url]   (default http://localhost:8080)
import 'dart:convert';
import 'dart:io';

/// method + path the repositories call.
const _endpoints = {
  ('post', '/api/v1/auth/login'),
  ('post', '/api/v1/auth/register'),
  ('post', '/api/v1/auth/refresh'),
  ('post', '/api/v1/auth/logout'),
  ('get', '/api/v1/users/me'),
  ('get', '/api/v1/users'),
  ('get', '/api/v1/users/{id}'),
  ('patch', '/api/v1/users/{id}'),
  ('delete', '/api/v1/users/{id}'),
  ('get', '/api/v1/test-results'),
  ('post', '/api/v1/test-results'),
  ('get', '/api/v1/test-results/summary'),
  ('patch', '/api/v1/test-results/{id}'),
  ('delete', '/api/v1/test-results/{id}'),
  ('get', '/api/v1/files'),
  ('post', '/api/v1/files'),
  ('get', '/api/v1/files/{id}/content'),
  ('delete', '/api/v1/files/{id}'),
};

/// Schema → fields the app reads or sends.
const _fields = {
  'AuthTokensResponse': ['accessToken', 'refreshToken', 'expiresIn', 'refreshExpiresIn'],
  'LoginRequest': ['email', 'password'],
  'RegisterRequest': ['email', 'password'],
  'RefreshTokenRequest': ['refreshToken'],
  'UserResponse': ['id', 'email', 'role', 'createdAt'],
  'UpdateUserRequest': ['email', 'role'],
  'TestResultResponse': [
    'id',
    'testName',
    'status',
    'score',
    'testedAt',
    'notes',
    'createdAt',
    'updatedAt',
  ],
  'CreateTestResultRequest': ['testName', 'status', 'score', 'testedAt', 'notes'],
  'UpdateTestResultRequest': ['testName', 'status', 'score', 'testedAt', 'notes'],
  'TestResultSummaryResponse': ['total', 'byStatus'],
  'StatusCount': ['status', 'count'],
  'FileResponse': ['id', 'name', 'size', 'contentType', 'createdAt'],
  'PageTestResultResponse': ['content', 'number', 'totalPages', 'totalElements'],
  'PageFileResponse': ['content', 'number', 'totalPages', 'totalElements'],
  'PageUserResponse': ['content', 'number', 'totalPages', 'totalElements'],
};

/// Schema.field → the enum values the app handles (Role, TestStatus).
const _enums = {
  'UserResponse.role': {'USER', 'ADMIN'},
  'TestResultResponse.status': {'PENDING', 'PASSED', 'FAILED'},
};

Future<void> main(List<String> args) async {
  final base = args.isEmpty ? 'http://localhost:8080' : args.first;
  final Map<String, Object?> spec;
  try {
    spec = await _fetch(Uri.parse('$base/v3/api-docs'));
  } on Object catch (error) {
    stderr.writeln('api-check: could not read $base/v3/api-docs ($error). Is the backend up?');
    exitCode = 2;
    return;
  }

  final problems = <String>[];
  final notes = <String>[];
  final paths = (spec['paths'] as Map<String, Object?>?) ?? {};
  for (final (method, path) in _endpoints) {
    final operations = paths[path];
    if (operations is! Map<String, Object?> || !operations.containsKey(method)) {
      problems.add('endpoint ${method.toUpperCase()} $path is gone');
    }
  }

  final schemas =
      ((spec['components'] as Map<String, Object?>?)?['schemas'] as Map<String, Object?>?) ?? {};
  for (final MapEntry(key: name, value: fields) in _fields.entries) {
    final schema = schemas[name];
    final properties = schema is Map<String, Object?>
        ? (schema['properties'] as Map<String, Object?>?) ?? {}
        : null;
    if (properties == null) {
      problems.add('schema $name is gone');
      continue;
    }
    for (final field in fields.where((field) => !properties.containsKey(field))) {
      problems.add('$name.$field is gone');
    }
    for (final field in properties.keys.where((field) => !fields.contains(field))) {
      if (!const {
        'empty',
        'first',
        'last',
        'pageable',
        'size',
        'sort',
        'numberOfElements',
        'tokenType',
      }.contains(field)) {
        notes.add('$name.$field is new (not used by the app yet)');
      }
    }
  }

  for (final MapEntry(key: target, value: known) in _enums.entries) {
    final [name, field] = target.split('.');
    final property =
        ((schemas[name] as Map<String, Object?>?)?['properties'] as Map<String, Object?>?)?[field];
    final values = property is Map<String, Object?> ? property['enum'] : null;
    if (values is! List<Object?>) {
      problems.add('$target is no longer an enum');
      continue;
    }
    final actual = values.whereType<String>().toSet();
    for (final value in actual.difference(known)) {
      problems.add('$target has a new value $value (add it to the app\'s enum)');
    }
    for (final value in known.difference(actual)) {
      notes.add('$target no longer sends $value');
    }
  }

  for (final note in notes) {
    stdout.writeln('api-check: note: $note');
  }
  if (problems.isEmpty) {
    stdout.writeln('api-check: the app matches the backend at $base.');
    return;
  }
  stderr.writeln('api-check: the backend changed:\n  ${problems.join('\n  ')}');
  exitCode = 1;
}

Future<Map<String, Object?>> _fetch(Uri uri) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('status ${response.statusCode}', uri: uri);
    }
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body) as Map<String, Object?>;
  } finally {
    client.close();
  }
}
