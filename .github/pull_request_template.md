## What and why

<!-- One or two sentences. Link the issue/ticket if there is one. Screenshots for UI changes
     (light and dark, phone width). -->

## Checklist

- [ ] `make verify` passes locally (and `make e2e` if auth, the router or a backend call changed)
- [ ] New behaviour is covered by a test in `test/` (or `integration_test/` for a flow)
- [ ] User-visible text is in every `l10n/<locale>/` file and `make l10n` was run
- [ ] New screens and actions declare their `Permission` (route, menu entry, controls)
- [ ] Native changes (permissions, Info.plist, Gradle) are explained, and built on both platforms
- [ ] If the backend API changed: models updated, `make api-check` passes
- [ ] Docs updated if commands, config or behaviour changed (`README.md`, `docs/`, `env/*.json`)
- [ ] No secrets, keystores, `key.properties`, `env/*.local.json` or build output committed
