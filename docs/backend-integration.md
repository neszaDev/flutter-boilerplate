# Backend integration

## Clients

`lib/core/api/api_client.dart` builds two dio clients on `Env.backendUrl`:

| Provider | Interceptors | Used for |
|---|---|---|
| `publicDioProvider` | `RequestLogInterceptor` | `/auth/*` (login, register, refresh, logout) |
| `apiDioProvider` | `RequestLogInterceptor`, `AuthInterceptor` | everything else |

`RequestLogInterceptor` adds `X-Request-Id` (the backend logs it and echoes it back, so an error
on a phone can be found in the server logs) and `X-Client: marksheet-app/<version>+<build>
(<platform>)`. `AuthInterceptor` adds the bearer token and handles refresh and the single retry
([architecture](architecture.md#session-design)).

Timeouts: 10 s to connect, 30 s to receive, 90 s to send (10 MB uploads on a slow network).

## Repositories

One per backend resource, next to the feature that uses it:

```dart
class TestResultsRepository {
  TestResultsRepository(this._dio);
  final Dio _dio;

  Future<PageResult<TestResult>> list({required int page, required int size}) =>
      apiCall(() async {
        final response = await _dio.get<Object?>(
          '/api/v1/test-results',
          queryParameters: {'page': page, 'size': size},
        );
        return PageResult.fromJson(asJson(response.data), TestResult.fromJson);
      });
}

final testResultsRepositoryProvider = Provider(
  (ref) => TestResultsRepository(ref.watch(apiDioProvider)),
);
```

`apiCall` turns dio and parsing failures into `ApiException`; screens never see `DioException`.

## Models

`lib/core/api/models.dart` mirrors the backend's OpenAPI schemas (`UserResponse`,
`TestResultResponse`, `FileResponse`, `Page<T>`, …). They are written by hand: Dart generators
for OpenAPI pull in build_runner and generated code that is harder to review than these ~200
lines. Parsing goes through `JsonRead` (`json.requireInt('id')`), which fails with the field's
name instead of a `TypeError` deep in a widget.

**`make api-check`** keeps them honest: `tool/api_check.dart` reads the running backend's
`/v3/api-docs` and fails when an endpoint the app calls, a field it reads or an enum value it knows
has changed. CI runs it against the published backend image (`BACKEND_TAG`, default `dev`), so a
backend change that breaks the app shows up in the next app CI run.

## Errors

The backend answers every error with `ApiError` (`status`, `message`, `fieldErrors`, …), parsed
into `ApiException.body`. Handle known cases with translated messages, then fall back to the
backend's text:

| Failure | Typical cause | What the app does |
|---|---|---|
| `unauthorized` | session gone; wrong password on sign-in | global: session ends, router goes to sign-in. Sign-in form: "Invalid email or password". |
| `forbidden` | role lacks the right | `AccessDeniedView` |
| `invalid` | validation (400), file too large (413) or wrong type (415) | field errors under inputs; specific messages for uploads |
| `conflict` | email taken (409) | under the email field |
| `rateLimited` | too many sign-in attempts (429) | "Try again in N minutes" from `Retry-After` |
| `network`, `timeout` | offline, server unreachable | "Can't reach the server…", data already shown stays |
| `server`, `unknown` | 5xx, unreadable answer | generic message + request id; logged as SEVERE |

## Files

Uploads are multipart `POST /files` with the file under `file`, checked first against the
backend's limits (10 MB; PNG, JPEG, GIF, WebP, PDF, text, CSV). Photos are re-encoded to JPEG at
quality 85 (HEIC isn't accepted, and it keeps them small). Downloads go to the app's temporary
directory and are handed to the share sheet; nothing is written to shared storage.

## Adding an endpoint end to end

1. Backend: implement and merge the endpoint (its own repo).
2. Here: add or update the model in `models.dart` and the method in the feature's repository.
3. Add the endpoint and fields to `tool/api_check.dart`, then `make backend-up api-check`.
4. Providers for the screen; `invalidate` them after writes.
5. Permission ([RBAC](rbac.md)), texts in every locale, a unit test for the parsing/logic, and an
   integration test step if it's a main flow.
