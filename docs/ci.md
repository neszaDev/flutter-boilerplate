# CI/CD

Same model as the web and backend repos.

## Branches and environments

```
feature/* ──PR──▶ dev ──PR (release)──▶ main ──tag v1.2.3──▶ GitHub Release (AAB + APK)
                   │                      │
            CI/CD - dev             CI/CD - main
         staging builds          approval, then production builds
```

| Workflow | Trigger | Does |
|---|---|---|
| `ci.yml` (**CI**) | every pull request | the jobs below; **CI Gate** is required to merge |
| `cd-dev.yml` (**CI/CD - dev**) | push to `dev` | CI, then `build-release.yml` with `env/staging.json` |
| `cd-main.yml` (**CI/CD - main**) | push to `main`, tags `v*` | CI, **approval** on the `main` environment, then production builds; a tag also creates a GitHub Release |
| `build-release.yml` | called by the two above | the only place release builds are defined: signed AAB + APK, unsigned iOS build, obfuscation symbols as artifacts |
| `cleanup-pr-cache.yml` | PR closed | deletes that PR's Actions caches |

## CI jobs

| Job | Runs | Local equivalent |
|---|---|---|
| **Detect changes** | docs-only PRs (`*.md`, `docs/`) skip the jobs marked † | none |
| **Lint, l10n & tests** | Conventional Commits check (PR commits), format, analyze (infos fail), l10n up to date, unit + widget tests with coverage | `make verify` |
| **Android release build** † | `make build-apk ENV=staging` (R8, obfuscation, release manifest) | same |
| **iOS release build** † | `make build-ios ENV=staging` on macOS, no signing | same |
| **API drift & integration tests** † | backend image + Postgres, `make api-check`, then the integration test on an Android emulator | `make backend-up api-check e2e` |
| **CI Gate** | fails when any job above failed or was cancelled (skipped is fine) | none |

**Why one gate:** branch protection requires only **CI Gate**, so jobs can be added, split or
made conditional without editing repository settings.

**Backend version:** the e2e job uses the backend's `:dev` image (`BACKEND_TAG`). A backend
change that breaks the app shows up in the next app CI run, starting with `api-check`.

**Flutter version:** pinned in `.github/actions/setup-flutter/action.yml`. Upgrade it in one PR
with `pubspec.yaml`'s `flutter:` constraint, after `make verify` and `make e2e` locally.

## Releasing

1. Bump `version:` in `pubspec.yaml` (`1.2.0+12`: the build number must grow with every upload).
2. Open a PR `dev` → `main`, merge when CI is green.
3. Approve the **main** deployment in the Actions run: production builds become artifacts.
4. Tag it (`git tag v1.2.0 && git push origin v1.2.0`), approve again: a GitHub Release with the
   AAB and APK is created. Upload to the stores per [releasing](releasing.md).

## Dependabot

Weekly pub and Actions updates, monthly Gradle, against `dev`; minor/patch grouped, majors
separate. Plugin majors often need native changes: read the changelog, build both platforms, run
`make e2e`.

## Repository settings

| Setting | Value |
|---|---|
| Branch protection: `main`, `dev` | require **CI Gate**; no force-push/deletion |
| Environment `dev` | deployable from `dev` only |
| Environment `main` | required reviewer; deployable from `main` and `v*` tags; holds the signing secrets |
| Secrets (environment `main`, optionally `dev`) | `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` |
| Automatically delete head branches | on |
