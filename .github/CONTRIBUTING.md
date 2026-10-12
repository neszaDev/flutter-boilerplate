# Contributing

## Setup

```sh
make setup       # dependencies, localizations, flutter doctor
make verify      # should pass before you change anything
make backend-up  # the backend in Docker, for `make run` and `make e2e`
make run         # on the running emulator / simulator / phone
```

## Workflow

1. Branch from `dev`: `feat/…`, `fix/…`, `chore/…`, `docs/…`, `ci/…`, and open the PR against
   `dev`. Never push directly to `dev` or `main`; releases are a `dev` → `main` PR
   ([CI/CD](../docs/ci.md#releasing)).
2. Small, focused commits; mechanical changes (formatting, renames) in their own commits.
3. Before pushing: `make verify`, plus `make e2e` if you touched auth, the router or a backend call.
4. Open a PR and fill in the checklist. CI must pass (the **CI Gate** check).

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/), checked in CI:
`type: summary`, types `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`,
`chore`, `style`, `revert`; `BREAKING CHANGE:` footer when needed.

## Definition of done

- `make verify` passes (and `make e2e` for behaviour changes).
- New behaviour is tested ([Testing](../docs/testing.md)).
- User-visible text is in every `l10n/<locale>/` file.
- New screens and actions are guarded by a `Permission` ([RBAC](../docs/rbac.md)).
- New config documented in [Configuration](../docs/configuration.md) and `env/*.json`.

Full conventions and the "don't do this" list: [AGENTS.md](../AGENTS.md). They apply to humans too.
