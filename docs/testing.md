# Testing

| Kind | Files | Runner | Needs | Run |
|---|---|---|---|---|
| Unit | `test/**/*_test.dart` (logic) | `flutter test` | nothing | `make test` |
| Widget | `test/**/*_test.dart` (`testWidgets`) | `flutter test` | nothing | `make test` |
| Integration | `integration_test/*_test.dart` | `flutter test integration_test` | the real backend + a device | `make e2e` |
| API contract | `tool/api_check.dart` | dart | the real backend | `make api-check` |
| Static | the whole tree | `flutter analyze --fatal-infos`, `dart format`, l10n check | nothing | `make lint` |

`test/` mirrors `lib/`. Coverage: `make coverage` → `coverage/lcov.info`.

## Unit and widget tests

- **No network.** Backend calls are faked at the transport: override `httpClientAdapterProvider`
  with a `FakeBackend` (`test/helpers/fake_backend.dart`), so the real interceptors — bearer
  token, refresh, single retry, request id — run in every test that touches the backend.
- **No secure storage.** Override `tokenStoreProvider` with a `MemoryTokenStore`.
- **Preferences.** `testPreferences()` gives an in-memory `SharedPreferencesWithCache`.
- **Screens.** `pumpScreen(tester, widget, overrides: […])` (`test/helpers/test_app.dart`) wraps
  the widget the way the app does: providers, theme, English localizations. Find text through
  the generated strings (`(await englishStrings()).authFormSignInButton`), not literals.
- **Plugins** are absent in tests: keep logic pure, and put plugin calls behind a service with a
  provider you can override.

What's covered in core: token refresh races and expiry (`token_manager_test`), the interceptor's
refresh-and-retry including parallel 401s (`interceptors_test`), error mapping
(`api_exception_test`), the session lifecycle (`session_controller_test`), redirects
(`auth_redirect_test`), the RBAC table, menu filtering and gates (`access_policy_test`),
validation mirroring the backend, shake and compass maths, l10n plurals, the sign-in form's
backend errors, and app start-up signed in and out (`app_test`). Showcase logic ported from the
web app keeps its tests under `test/features/showcase/`.

## Integration tests

`integration_test/app_flow_test.dart` runs the real app against the real backend on an emulator,
simulator or phone:

1. `make e2e`: starts the backend (Postgres + the published backend image; seeds
   `admin@e2e.test`) and, when no device runs, an iOS simulator (on a Mac) or the first Android
   emulator. `make e2e DEVICE=<id>` picks a device, `EMULATOR=<id>` which one to start
   (`make devices` lists both).

The flow: sign up a fresh user, check a USER has no user management, add a test result and see
it on the card, sign out; sign in as the admin, open Users and find the new account. Every run
registers its own user, so runs are independent. CI runs it on an Android emulator against the
backend image (the emulator reaches the host's backend at `10.0.2.2:8080`).

Never change or delete the seeded admin in a test.

## Manual checks before a release

Things automated tests can't see: the app lock on a real phone (Face ID and fingerprint), camera
and scanner, location permission flows (allow once / deny / deny forever), notifications with the
app closed, dark mode, a large text size (Settings → Accessibility), VoiceOver/TalkBack on the
main flows, and a slow or flaky network (Developer settings → network throttling).
