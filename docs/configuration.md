# Configuration

Build-time settings come from `env/<name>.json`, passed with `--dart-define-from-file`
(`make run`, `make build-*` and the VS Code launch configurations do it). They are compiled into
the app: **never put secrets in them** (anything in an app binary can be extracted). The app
reads them only in `lib/core/config/env.dart`, which checks them at startup (`Env.validate`).

| File | Use | Committed |
|---|---|---|
| `env/dev.json` | local development against `make backend-up` | yes |
| `env/staging.json` | test builds (CI on `dev`) | yes, with your staging URL |
| `env/prod.json` | store releases (CI on `main` / tags) | yes, with your production URL |
| `env/<name>.local.json` | personal overrides, e.g. your computer's LAN address for a real phone | no (git-ignored) |

`make run ENV=staging` picks `env/staging.json`; when `env/staging.local.json` exists it wins.
Copy `env/dev.local.json.example` to start one.

## Variables

| Variable | Default | Meaning |
|---|---|---|
| `APP_ENV` | `dev` | `dev`, `staging` or `prod`. `prod` hides the debug section of the shake menu. |
| `BACKEND_URL` | see below | Base URL of the Spring API, no trailing slash. **Release builds require an `https` URL** and refuse to start otherwise. |
| `BACKEND_PORT` | `8080` | Port of the local backend when `BACKEND_URL` is empty. Use another when 8080 is taken (e.g. by another project's backend). |
| `LOG_LEVEL` | `INFO` | `ALL`, `FINE`, `INFO`, `WARNING`, `SEVERE`. `FINE` logs every request (method, path, status, time — never headers or bodies). |
| `SUPPORT_EMAIL` | empty | Where the shake menu's "Report a problem" writes to. Empty hides it. |
| `MAP_TILE_URL` | OpenStreetMap | Tile template for the map demo. The public OSM servers are for development only ([tile usage policy](https://operations.osmfoundation.org/policies/tiles/)); use your own or a provider's in production. |

`BACKEND_URL` empty (the `dev` default) means a backend on your computer: `http://10.0.2.2:8080`
from the Android emulator, `http://localhost:8080` from the iOS simulator. A real phone needs
`http://<your computer's LAN IP>:8080` in `env/dev.local.json`, on the same Wi-Fi.

**Port 8080 taken** (another backend already runs there — the app would sign in to *that* API
and get 404s): run this backend on another port and tell the app, keeping the emulator/simulator
detection:

```sh
make backend-up BACKEND_PORT=8090
make run BACKEND_PORT=8090          # every make target passes BACKEND_PORT to the app
```

From VS Code, add `"BACKEND_PORT": "8090"` to `env/dev.local.json` and use the "dev (local
overrides)" launch configuration. `make api-check BACKEND_PORT=8090` tells you which backend
answers: against the wrong one it lists the missing endpoints.

Plain `http` works only in debug builds: Android allows cleartext in `src/debug/AndroidManifest.xml`
only, iOS allows local-network addresses only (`NSAllowsLocalNetworking`).

## The backend side

- **Reachability.** A phone calls the backend directly, so its ingress must be public HTTPS.
  The web app's Azure setup keeps the backend internal (only the Next.js server reaches it);
  serving this app from that environment needs the backend container app's ingress switched to
  external (a change in the backend repo's `infra/`).
- **CORS** doesn't apply to native apps; nothing to configure.
- **Rate limits** are per client IP. Phones reach the backend through its ingress, which sets
  `X-Forwarded-For`; the backend trusts it from private addresses only (backend docs).
- **The local backend** (`docker/compose.yml`, the published `:dev` image) seeds the admin
  `admin@e2e.test` / `e2e-admin-password` and raises the per-IP limits for the integration
  tests. Change them with `BACKEND_ADMIN_EMAIL`, `BACKEND_ADMIN_PASSWORD`,
  `BACKEND_RATE_LIMIT_PER_IP`, `BACKEND_TAG` and `BACKEND_PORT` in your shell.

## App identity

| What | Where |
|---|---|
| Display name | `android/app/src/main/AndroidManifest.xml` (`android:label`), `ios/Runner/Info.plist` (`CFBundleDisplayName`), `AppConfig.name` |
| Application id / bundle id | `android/app/build.gradle.kts` (`applicationId`, `namespace`), Xcode → Runner → Signing (`PRODUCT_BUNDLE_IDENTIFIER`). Change before the first release; it can never change afterwards. |
| Version | `pubspec.yaml` `version: 1.0.0+1` (name + build number; bump the build number for every store upload) |
| Icons and splash | `android/app/src/main/res/mipmap-*`, `ios/Runner/Assets.xcassets` (or add `flutter_launcher_icons`) |
| Permission texts (iOS) | `ios/Runner/Info.plist` `NS*UsageDescription`; translate them with `InfoPlist.strings` per language (see [phone features](device-features.md)) |
