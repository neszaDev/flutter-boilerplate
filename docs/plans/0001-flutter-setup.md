# 0001 — Flutter app setup

Status: accepted (2026-10-07)

## Context

The team has a Spring API ([spring-postgres-boilerplate]) and a web frontend
([nextjs-boilerplate]) with a sample product, "Marksheet", plus a large component showcase ported
from an older Vue app. We need the same starting point for phones: the same product, screens and
texts, role-based access, the phone's own capabilities (fingerprint and face unlock, shake,
sensors, camera, QR, location, haptics, notifications), and the same team workflow (make targets,
CI Gate, dev → main, Dependabot, docs, AGENTS.md).

[spring-postgres-boilerplate]: https://github.com/neszaDev/spring-postgres-boilerplate
[nextjs-boilerplate]: https://github.com/neszaDev/nextjs-boilerplate

## Decisions

| Topic | Decision | Why / alternatives |
|---|---|---|
| Platforms | Android + iOS | Phone features are the point; web/desktop add plugin gaps and weaker token storage. `flutter create --platforms=web .` can add web later. |
| Flutter | 3.47 stable, Dart 3.13 | Current stable; pinned in CI. |
| State | Riverpod 3, no codegen | Testable overrides (the whole test strategy relies on them), no build_runner. Bloc would add boilerplate; Provider lacks the override story. |
| Routing | go_router, web paths (`/dashboard/...`) | Redirects for auth, shell routes for tabs, deep links that match the web app. |
| HTTP | dio + interceptors | Interceptors for auth/refresh/request ids, multipart with progress, cancel tokens. |
| Tokens | flutter_secure_storage (Keychain, Keystore) | The mobile equivalent of httpOnly cookies. Never shared_preferences. iOS `first_unlock_this_device`: no iCloud sync, no restore to another device. Android backups off. |
| Refresh | single-flight in `TokenManager` | The backend rotates refresh tokens; parallel refreshes would sign users out (the web app solves the same race in its proxy). |
| RBAC | Role → Permission table in one file; routes, menu, tabs and widgets ask for permissions | Roles change per product (the HR fork has four); permissions keep widgets stable. The backend stays the authority (403 handled everywhere). |
| Models | hand-written + `tool/api_check.dart` against `/v3/api-docs` | Generators (openapi-generator, swagger_parser) need build_runner and produce code nobody reviews; ~15 small classes are easier to own. The check catches drift in CI. |
| Text | the web app's namespaced ICU JSON → ARB via `tool/l10n.dart` → gen-l10n | Same files and wording as the web app, one file per feature (parallel work, small diffs), parity checks like the web's i18n-check. |
| Design | Marksheet tokens as a `ThemeExtension` over Material 3; Libre Franklin + Kalam bundled | Same look as the web; fonts work offline and on first launch. A dark variant was added because phones follow the system setting; light stays the default, as the design is "daylight". |
| Config | `--dart-define-from-file=env/<name>.json` | Native-flavor setup (product flavors, Xcode schemes) is heavier and rarely needed for one backend URL. Add flavors when you need separate app ids per environment. |
| Errors | `ErrorReporter` interface, default to the device log | Crash reporting is a third-party service: a product decision, kept to one seam. |
| Showcase | ported screen by screen under `lib/features/showcase`, behind a permission | Parity with the web app; easy to delete as one folder. |
| Maps | flutter_map + OpenStreetMap tiles | No API key to start; Google Maps needs keys in native files. Use a tile provider in production. |
| Code editor | TextField + `highlight` | Code-editor packages are heavy and short-lived; the demo shows the technique. |
| Rich text | flutter_quill | The maintained rich-text editor for Flutter (tiptap's role on the web). |

## Not included (needs a decision)

- **Crash reporting / analytics** (Sentry, Crashlytics, …): implement `ErrorReporter`.
- **Push notifications** (FCM/APNs): needs a backend endpoint for device tokens.
- **Two-factor sign-in**: the backend has no 2FA endpoints yet; the campus showcase shows the UI
  with a "not available yet" outcome, like the web app.
- **Certificate pinning**: possible with dio's `HttpClientAdapter` (`badCertificateCallback`
  with a pinned key); pinned keys must be rotated with the server certificate, so it needs an
  operations plan first.
- **App/Universal Links**: the router handles the paths; the domain files are per product.
- **Android product flavors / iOS schemes**: see Config above.

## Consequences

- Every plugin brings native configuration; removing a feature means removing its permissions
  too ([phone features](../device-features.md)).
- The backend must be publicly reachable over HTTPS for phones (the web setup keeps it internal).
- Two message files per feature and locale stay in sync with the web app by copy, not by build.
