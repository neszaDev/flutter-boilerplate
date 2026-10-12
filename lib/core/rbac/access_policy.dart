import 'package:flutter_boilerplate/core/rbac/permission.dart';
import 'package:flutter_boilerplate/core/rbac/role.dart';

/// Permissions every signed-in account has, whatever its role (also unknown roles).
const memberPermissions = <Permission>{
  Permission.viewDashboard,
  Permission.manageOwnTestResults,
  Permission.manageOwnFiles,
  Permission.viewOwnAccount,
  Permission.useDeviceFeatures,
  Permission.viewShowcase,
};

/// The role → permission table: the only place that knows what each role may do.
///
/// Keep it in step with the backend's `SecurityConfig` / service checks. When the backend says
/// no (403) anyway, screens show [AccessDeniedView]; the app never relies on hiding alone.
const rolePermissions = <Role, Set<Permission>>{
  Role.user: memberPermissions,
  Role.admin: {
    ...memberPermissions,
    Permission.viewUsers,
    Permission.editUsers,
    Permission.deleteUsers,
  },
};

/// What the signed-in account may do. Read it with `ref.watch(accessProvider)`.
class Access {
  const Access._(this.role, this.permissions);

  /// Nobody signed in: no permissions.
  static const none = Access._(null, <Permission>{});

  /// The permissions of [role]; an unknown role gets [memberPermissions].
  factory Access.forRole(Role? role) => Access._(role, rolePermissions[role] ?? memberPermissions);

  /// The account's role, or null when signed out or the backend sent an unknown role.
  final Role? role;
  final Set<Permission> permissions;

  bool can(Permission permission) => permissions.contains(permission);

  bool canAll(Iterable<Permission> required) => required.every(permissions.contains);

  bool canAny(Iterable<Permission> required) => required.any(permissions.contains);
}
