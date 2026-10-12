// Backend payloads, written to match the Spring API's OpenAPI spec (`/v3/api-docs`, schema
// names in the comments). When the backend changes, update these and the repository that uses
// them; `make api-check` compares the field names with a running backend.
import 'package:flutter_boilerplate/core/api/json.dart';
import 'package:flutter_boilerplate/core/rbac/role.dart';

/// `UserResponse`: an account as `/users/me` and the admin endpoints return it.
class UserProfile {
  const UserProfile({required this.id, required this.email, this.role, this.createdAt});

  factory UserProfile.fromJson(Json json) => UserProfile(
    id: json.requireInt('id'),
    email: json.requireString('email'),
    role: Role.fromApi(json.string('role')),
    createdAt: json.dateTime('createdAt'),
  );

  final int id;
  final String email;

  /// Null when the backend sent a role this app version doesn't know.
  final Role? role;
  final DateTime? createdAt;

  Json toJson() => {
    'id': id,
    'email': email,
    'role': role?.apiName,
    'createdAt': createdAt?.toUtc().toIso8601String(),
  };
}

/// `TestResultResponse.status`, `testresult/TestStatus` in the backend.
enum TestStatus {
  pending('PENDING'),
  passed('PASSED'),
  failed('FAILED');

  const TestStatus(this.apiName);

  final String apiName;

  static TestStatus fromApi(String? value) =>
      values.firstWhere((status) => status.apiName == value, orElse: () => pending);
}

/// `TestResultResponse`.
class TestResult {
  const TestResult({
    required this.id,
    required this.testName,
    required this.status,
    required this.score,
    required this.testedAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory TestResult.fromJson(Json json) => TestResult(
    id: json.requireInt('id'),
    testName: json.string('testName') ?? '',
    status: TestStatus.fromApi(json.string('status')),
    score: json.decimal('score') ?? 0,
    testedAt: json.dateTime('testedAt') ?? DateTime.fromMillisecondsSinceEpoch(0),
    notes: json.string('notes'),
    createdAt: json.dateTime('createdAt'),
    updatedAt: json.dateTime('updatedAt'),
  );

  final int id;
  final String testName;
  final TestStatus status;
  final double score;
  final DateTime testedAt;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

/// `CreateTestResultRequest` / `UpdateTestResultRequest` (same fields).
class TestResultInput {
  const TestResultInput({
    required this.testName,
    required this.status,
    required this.score,
    required this.testedAt,
    this.notes,
  });

  final String testName;
  final TestStatus status;
  final double score;
  final DateTime testedAt;
  final String? notes;

  Json toJson() => {
    'testName': testName.trim(),
    'status': status.apiName,
    'score': score,
    'testedAt': testedAt.toUtc().toIso8601String(),
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}

/// `TestResultSummaryResponse`: the total and the count per status.
class TestResultSummary {
  const TestResultSummary({required this.total, required this.byStatus});

  factory TestResultSummary.fromJson(Json json) => TestResultSummary(
    total: json.integer('total') ?? 0,
    byStatus: {
      for (final entry in json.objects('byStatus'))
        TestStatus.fromApi(entry.string('status')): entry.integer('count') ?? 0,
    },
  );

  static const empty = TestResultSummary(total: 0, byStatus: {});

  final int total;
  final Map<TestStatus, int> byStatus;

  int countOf(TestStatus status) => byStatus[status] ?? 0;
}

/// `FileResponse`: metadata of an uploaded file.
class StoredFile {
  const StoredFile({
    required this.id,
    required this.name,
    required this.size,
    this.contentType,
    this.createdAt,
  });

  factory StoredFile.fromJson(Json json) => StoredFile(
    id: json.requireInt('id'),
    name: json.string('name') ?? '',
    size: json.integer('size') ?? 0,
    contentType: json.string('contentType'),
    createdAt: json.dateTime('createdAt'),
  );

  final int id;
  final String name;
  final int size;
  final String? contentType;
  final DateTime? createdAt;

  bool get isImage => contentType?.startsWith('image/') ?? false;
}

/// One page of a Spring `Page<T>` (`PageTestResultResponse`, `PageFileResponse`, …).
class PageResult<T> {
  const PageResult({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalElements,
  });

  factory PageResult.fromJson(Json json, T Function(Json item) parse) => PageResult(
    items: json.objects('content').map(parse).toList(),
    page: json.integer('number') ?? 0,
    totalPages: json.integer('totalPages') ?? 0,
    totalElements: json.integer('totalElements') ?? 0,
  );

  final List<T> items;

  /// Zero-based.
  final int page;
  final int totalPages;
  final int totalElements;

  bool get isLast => page >= totalPages - 1;
}
