@AGENTS.md

## Claude Code specifics

- `.claude/settings.json` pre-approves the build and test commands above. Personal overrides
  go in `.claude/settings.local.json` (git-ignored).
- For auth (`lib/core/auth/`, `lib/core/api/interceptors.dart`, `lib/core/router/auth_redirect.dart`),
  native configuration (`android/`, `ios/`) or CI, plan first and state the verification you will
  run before editing.
