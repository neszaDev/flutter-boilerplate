import 'package:flutter/widgets.dart';
import 'package:flutter_boilerplate/core/auth/session_controller.dart';
import 'package:flutter_boilerplate/core/rbac/access_policy.dart';
import 'package:flutter_boilerplate/core/rbac/permission.dart';
import 'package:flutter_boilerplate/core/widgets/access_denied_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:flutter_boilerplate/core/rbac/access_policy.dart';
export 'package:flutter_boilerplate/core/rbac/permission.dart';
export 'package:flutter_boilerplate/core/rbac/role.dart';

/// What the signed-in account may do; [Access.none] when signed out.
final accessProvider = Provider<Access>((ref) {
  final user = ref.watch(currentUserProvider);
  return user == null ? Access.none : Access.forRole(user.role);
});

/// Shows [child] only with [permission]; otherwise [fallback] (nothing by default).
///
/// For a control or a section of a screen. A whole screen is guarded by its route
/// (`guardedRoute` in `app_router.dart`), which renders [AccessDeniedView] instead.
class PermissionGate extends ConsumerWidget {
  const PermissionGate({
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
    super.key,
  });

  final Permission permission;
  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(accessProvider).can(permission) ? child : fallback;
}

/// Renders [child] when the account has [permission], else the access-denied screen. Used by
/// the router for every screen that needs more than being signed in.
class RequirePermission extends ConsumerWidget {
  const RequirePermission({required this.permission, required this.child, super.key});

  final Permission permission;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(accessProvider).can(permission) ? child : const AccessDeniedScreen();
}
