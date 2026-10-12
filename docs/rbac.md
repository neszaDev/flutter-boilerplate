# Role-based access control

The app decides what to **show** from the signed-in account's role; the backend decides what is
**allowed**. Both use the same rules, and the app never relies on hiding alone.

## The model

```
Role (from /users/me)  ──rolePermissions──▶  Set<Permission>  ──▶  Access.can(permission)
   USER, ADMIN                (one table)          viewUsers, …         routes, menu, tabs, widgets
```

| File | Holds |
|---|---|
| `lib/core/rbac/role.dart` | `Role` enum with the backend's names (`USER`, `ADMIN`). Unknown values parse to `null`. |
| `lib/core/rbac/permission.dart` | `Permission`: everything a screen or action can be gated on, named after what the user does. |
| `lib/core/rbac/access_policy.dart` | `rolePermissions`: the **only** place that maps roles to permissions; `Access`. |
| `lib/core/rbac/access.dart` | `accessProvider`, `PermissionGate`, `RequirePermission`. |

The current table:

| Permission | USER | ADMIN | Backend rule |
|---|:-:|:-:|---|
| `viewDashboard`, `viewOwnAccount` | ✓ | ✓ | authenticated |
| `manageOwnTestResults`, `manageOwnFiles` | ✓ | ✓ | authenticated, owner-scoped in services |
| `useDeviceFeatures`, `viewShowcase` | ✓ | ✓ | (app only) |
| `viewUsers`, `editUsers`, `deleteUsers` | | ✓ | `/api/v1/users/**` → `hasRole("ADMIN")`, re-checked in `UserAdminService` |

A role the app doesn't know yet (added on the backend first) gets the member permissions only, so
an older app version keeps working and shows nothing it can't explain.

## Using it

**A whole screen** — register it with the permission; without it the user sees
`AccessDeniedView` (with their role and a way back), never a sign-out:

```dart
guardedRoute(
  path: Routes.users,
  permission: Permission.viewUsers,
  builder: (_) => const UsersScreen(),
),
```

**A menu entry or a tab** — give it the same permission (`NavLink(…, permission: …)` in
`nav_items.dart`; the tab list in `app_shell.dart`). Entries the account can't use disappear.

**A control on a screen:**

```dart
PermissionGate(
  permission: Permission.deleteUsers,
  child: DeleteUserButton(user: user),
)
// or, in logic:
if (ref.watch(accessProvider).can(Permission.editUsers)) { … }
```

**The backend's answer still wins.** A 403 arrives as `ApiFailure.forbidden`; screens render
`AccessDeniedView` for it (see `UsersScreen`). This covers a role changed while the app was open
and any rule the app doesn't mirror.

Ask for permissions, never for roles: `if (user.role == Role.admin)` in a widget is a bug waiting
for the next role.

## Adding a role

Example: the HR fork's `EMPLOYEE`, `MANAGER`, `HR_ADMIN`.

1. Backend: add the role and its rules (its repo).
2. `role.dart`: add the enum value with its API name.
3. `access_policy.dart`: give it its permission set in `rolePermissions`.
4. `l10n/<locale>/users.json`: add `AccountPage.role_<NAME>`, and the case in `roleLabel`
   (`lib/core/widgets/access_denied_view.dart`).
5. `test/core/rbac/access_policy_test.dart`: assert what the role can and can't do.
6. `make api-check` (it fails until the app knows the backend's new enum value).

## Adding a permission

1. Add it to `Permission` with a doc comment saying what it allows and which backend rule
   enforces it.
2. Grant it in `rolePermissions`.
3. Use it on the route, the menu entry and the controls.
4. Test it: policy test for the table, a widget test for the gated screen or control.
