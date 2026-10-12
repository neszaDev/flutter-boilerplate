# AGENTS.md

Instructions for AI coding agents, and a quick reference for humans, working in this repository.
Keep this file the single source of truth; `CLAUDE.md` only imports it.

## What this is

A Flutter app (Android + iOS) for the
[spring-postgres-boilerplate](https://github.com/neszaDev/spring-postgres-boilerplate) API, the
phone counterpart of [nextjs-boilerplate](https://github.com/neszaDev/nextjs-boilerplate): the same
sample product ("Marksheet"), the same screens and texts, plus phone features (biometric app
lock, shake, sensors, camera, QR, location, haptics, notifications).

The app talks to the backend directly. Tokens live in the Keychain / Keystore
(`flutter_secure_storage`), never in preferences, logs or files.
Architecture: [docs/architecture.md](docs/architecture.md). Guides: [RBAC](docs/rbac.md) ·
[configuration](docs/configuration.md) · [backend integration](docs/backend-integration.md) ·
[localization](docs/localization.md) · [phone features](docs/device-features.md) ·
[testing](docs/testing.md) · [CI/CD](docs/ci.md) · [releasing](docs/releasing.md).

## Layout

```
lib/main.dart, lib/app.dart     bootstrap (env check, logging, error handlers) and MaterialApp
lib/core/                       shared by every feature; features never import each other's internals
  api/                          dio clients, interceptors (auth, request id), ApiException, models
  auth/                         TokenStore (secure storage), TokenManager (single-flight refresh),
                                SessionController (sign-in/up/out, restore), repositories
  rbac/                         Role, Permission, rolePermissions, Access, PermissionGate
  router/                       Routes (paths), app_router (go_router), authRedirect, nav_items
  config/                       Env (--dart-define), AppConfig, AppInfo
  data/                         PagedNotifier (infinite lists)
  device/                       biometrics, shake detector, haptics, notifications, connectivity
  l10n/                         context.l10n, RichMessage, date/number formatting
  settings/                     user preferences (shared_preferences)
  theme/                        Marksheet tokens (MarksheetColors), AppTheme, Space, Radii
  validation/                   Rules + ValidationIssue (the web app's zod rules)
  widgets/                      AppPage, PageHeader, SheetCard, DemoCard, Mark, feedback, forms
lib/features/<feature>/         screens + their data (repository, providers, validation)
lib/features/showcase/<group>/  the web app's demo pages, one screen per page
lib/l10n/arb/                   GENERATED from l10n/ (committed); lib/l10n/gen/ generated, ignored
l10n/<locale>/*.json            all user-visible text, namespaced like the web app's locales
test/                           unit + widget tests (mirror lib/ paths)
integration_test/               flows against the real backend
env/                            build configurations (dev/staging/prod .json)
tool/                           l10n builder, API drift check
docs/                           guides and decision records (docs/plans/)
```

## Commands

| Task | Command |
|---|---|
| First setup | `make setup` |
| Run on a device / simulator | `make run` (starts one if none runs), `make run ENV=staging`, `make run DEVICE=<id>` |
| Format | `make fmt` |
| Analyze + format check + l10n check | `make lint` |
| Unit + widget tests | `make test` |
| Everything CI's verify job runs | `make verify` |
| Rebuild localizations after editing `l10n/` | `make l10n` |
| Backend for local development | `make backend-up` |
| Integration tests against the backend | `make e2e` (needs a running emulator/simulator) |
| Release builds | `make build-apk`, `make build-appbundle`, `make build-ios` |

Run `make` to list every target.

## Definition of done

1. `make verify` passes; `make e2e` too when auth, the router or a backend call changed.
2. New behaviour has a test: `test/**/*_test.dart` (logic and widgets), `integration_test/` (flows).
3. Text in every `l10n/<locale>/` file, `make l10n` run, ARB files committed.
4. `git status` shows only intended files. Never commit `env/*.local.json`, keystores,
   `key.properties`, `build/`, `coverage/`.
5. Conventional Commits: `type: summary` (`feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert`).

## Rules that keep the app correct

### Backend
- Screens never call dio. Reads and writes go through a repository in the feature
  (`*_data.dart`), built on `apiDioProvider`; wrap calls in `apiCall` so failures arrive as
  `ApiException`.
- Models are hand-written in `lib/core/api/models.dart` from the backend's OpenAPI spec. After a
  backend change, update them and run `make api-check`.
- Map failures by `ApiException.failure`, not by status code in widgets: `unauthorized` is handled
  globally (session ends, router goes to sign-in), `forbidden` renders `AccessDeniedView`, the
  rest goes through `errorMessage(context, error)`.

### Auth (extra care; change only with tests green)
`lib/core/auth/*`, `lib/core/api/interceptors.dart`, `lib/core/router/auth_redirect.dart`:
- Tokens only in `TokenStore`. Never log them, never put them in a URL or error message.
- One refresh at a time (`TokenManager`): the backend rotates refresh tokens, so parallel
  refreshes would sign the user out. Only a 400/401 from `/auth/refresh` ends a session;
  network errors keep it.
- Release builds must use an `https` `BACKEND_URL` (`Env.validate` refuses to start otherwise).

### RBAC
- Screens and actions ask for a `Permission`, never a `Role`. Which role has which permission
  lives only in `lib/core/rbac/access_policy.dart`.
- A screen that needs more than being signed in is registered with `guardedRoute` (or wrapped in
  `RequirePermission`); menu entries and tabs carry the same permission so they disappear.
- Hiding is UX, not security: the backend enforces every rule. Handle its 403 anyway.
- See [docs/rbac.md](docs/rbac.md) to add a role or a permission.

### Localization
- No hard-coded user-visible strings. Text lives in `l10n/<locale>/<file>.json` as
  `{ "Namespace": { "key_name": "ICU message" } }`; `Namespace.key_name` becomes
  `context.l10n.namespaceKeyName`. Every key in every locale (`make lint` fails otherwise).
- After editing, run `make l10n` (or `dart run tool/l10n.dart`). Never edit `lib/l10n/arb/*`.
- Format dates and numbers with `context.formatDate(...)` / `context.formatNumber(...)`.
- Markup like `<strong>…</strong>` in a message renders with `RichMessage`.

### UI
- Build screens from `lib/core/widgets`: `AppPage` (scrolling page with header and
  pull-to-refresh), `PageHeader`, `SheetCard`, `DemoCard`, `ErrorView`, `LoadingView`,
  `EmptyState`, `FormAlert`, `LabeledField`, `BusyButton`, `confirm(...)`, `showToast(...)`.
- Colours only from the theme: `context.colors` (Marksheet tokens), `Theme.of(context).colorScheme`.
  Text styles from `context.text` (Material) and `context.type` (form labels, figures, hand).
  Spacing from `Space`, radii from `Radii`. Both light and dark themes must read well.
- Accessibility: every icon-only button has a `tooltip`; decorative marks are excluded from
  semantics; tap targets at least 44 pt; announce async errors (`FormAlert`, `ErrorView` do).
- Haptics through `Haptics.*` (respects the user's setting), never `HapticFeedback` directly.

### State (Riverpod 3)
- Repositories and services: `Provider`. Reads: `FutureProvider.autoDispose(.family)`. Lists:
  `PagedNotifier`. App state: `Notifier`. No codegen, no legacy `StateProvider`.
- After a write, `ref.invalidate` what shows that data (see `invalidateTestResults`).
- `ProviderScope(retry: …)` disables automatic retries: errors show a retry button instead.

## Code conventions

- Clarity and consistency over cleverness. Minimal changes. Match existing patterns.
- `flutter analyze` with zero issues (infos included); `dart format` (100 columns).
- Absolute imports: `package:flutter_boilerplate/...`.
- Doc comments (`///`) on public classes and non-obvious members: short, present tense.
- No `dynamic`, no `!` on values that may really be null, no empty `catch`.
- Futures: `await` them, or mark fire-and-forget with `unawaited(...)` / `.ignore()`.
- Widgets: `const` constructors, small private widgets over helper methods for larger pieces.
- Tests: `group` = subject, `test` titles in the present tense ("refreshes once for parallel
  requests"); no network in unit tests (fake the repository or the dio adapter).

## Forbidden shortcuts

- Weakening checks: `// ignore:` for a real finding, deleting assertions, skipping tests,
  excluding files from analysis to get green.
- Storing tokens or personal data anywhere but `TokenStore`; logging them.
- Hard-coded user-visible strings, or adding a key to only one locale.
- Adding a third-party service SDK (analytics, crash reporting, push) without a decision recorded
  in `docs/plans/`. Crash reporting plugs into `ErrorReporter`.
- Committing signing keys, `key.properties` or `env/*.local.json`.
- Force-pushing or committing directly to `dev` or `main`: use a branch and a PR into `dev`.
